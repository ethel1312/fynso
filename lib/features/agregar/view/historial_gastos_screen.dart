import 'dart:convert';
import 'dart:io' show HttpDate;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:fynso/common/widgets/custom_text_title.dart';
import 'package:fynso/features/agregar/view/widgets/boton_mic.dart';
import 'package:fynso/features/agregar/view/widgets/gasto_card.dart';
import '../../../common/themes/app_color.dart';
import '../../../data/models/transaction_detail_request.dart';
import '../../../data/models/transaction_response.dart';
import '../../../common/navigation/route_observer.dart';

import '../view_model/historial_gastos_view_model.dart';
import '../../../data/models/transactions_filter.dart';
import '../../../data/models/category_item.dart';
import '../../../data/models/subcategory_item.dart';

class HistorialGastosScreen extends StatefulWidget {
  const HistorialGastosScreen({super.key});

  @override
  State<HistorialGastosScreen> createState() => _HistorialGastosScreenState();
}

class _YearMonth {
  final int year;
  final int month;
  const _YearMonth(this.year, this.month);
}

class _HistorialGastosScreenState extends State<HistorialGastosScreen>
    with RouteAware {
  late HistorialGastosViewModel viewModel;
  String jwt = '';

  // ===== Rango disponible desde backend =====
  static const String _baseUrl = 'https://fynso.pythonanywhere.com';
  int? _minYear;    // primer año con transacciones
  int? _minMonth;   // primer mes con transacciones
  int? _maxYearTx;  // último año con transacciones
  int? _maxMonthTx; // último mes con transacciones

  // para limitar el date range del filtro
  DateTime? _minDateAvailable; // 1er día del primer mes con tx
  DateTime? _maxDateAvailable; // último día del último mes con tx

  // tope superior del selector: mes siguiente al último con tx
  int _capNextYear = 0;
  int _capNextMonth = 0;

  // Spinner inicial sin parpadeos
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    viewModel = HistorialGastosViewModel();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // spinner pleno desde el arranque
    setState(() => _booting = true);

    await _loadJwt();
    await _fetchAvailableRange(); // fija límites de meses y de date-range

    // Clamp del mes visible a [min .. capNext]
    final now = DateTime.now();
    final clamped = _clampMonth(_YearMonth(now.year, now.month));
    if (clamped.year != viewModel.anio || clamped.month != viewModel.mes) {
      viewModel.changeMonth(clamped.year, clamped.month);
    }

    await viewModel.loadTransactions(jwt: jwt, anio: viewModel.anio, mes: viewModel.mes);
    await viewModel.initCatalogs();

    if (mounted) setState(() => _booting = false);
  }

  Future<void> _loadJwt() async {
    final prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt_token') ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Se llama cuando volvemos a esta ruta (p.ej., saliste de Detalle/Editar)
  @override
  void didPopNext() {
    _reloadSameMonth(); // recarga al volver
  }

  Future<void> _reloadSameMonth() async {
    await viewModel.loadTransactions(
      jwt: jwt,
      anio: viewModel.anio,
      mes: viewModel.mes,
    );
  }

  // ====== Backend: rango disponible ======
  Future<void> _fetchAvailableRange() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/transactions/available_range');
      final resp = await http.get(
        uri,
        headers: {'Authorization': 'JWT $jwt', 'Accept': 'application/json'},
      );

      if (resp.statusCode != 200) return;
      final root = jsonDecode(resp.body) as Map<String, dynamic>;
      if ((root['code'] ?? 0) != 1) return;

      final data = (root['data'] as Map<String, dynamic>?) ?? {};
      _minYear   = data['min_year'] as int?;
      _minMonth  = data['min_month'] as int?;
      _maxYearTx = data['max_year'] as int?;
      _maxMonthTx= data['max_month'] as int?;

      if (_minYear != null && _minMonth != null) {
        _minDateAvailable = DateTime(_minYear!, _minMonth!, 1);
      }
      if (_maxYearTx != null && _maxMonthTx != null) {
        _maxDateAvailable = DateTime(
          _maxYearTx!,
          _maxMonthTx!,
          _lastDayOfMonth(_maxYearTx!, _maxMonthTx!),
        );
      }

      // Si no hay transacciones: usa mes actual como rango trivial
      final today = DateTime.now();
      _minDateAvailable ??= DateTime(today.year, today.month, 1);
      _maxDateAvailable ??= DateTime(today.year, today.month, _lastDayOfMonth(today.year, today.month));

      // rellena mínimos/máximos si no vinieron
      _minYear   ??= _minDateAvailable!.year;
      _minMonth  ??= _minDateAvailable!.month;
      _maxYearTx ??= _maxDateAvailable!.year;
      _maxMonthTx??= _maxDateAvailable!.month;

      // Tope superior = mes siguiente al último mes con tx
      final capNext = DateTime(_maxYearTx!, _maxMonthTx! + 1, 1);
      _capNextYear  = capNext.year;
      _capNextMonth = capNext.month;
    } catch (_) { /* silencio */ }
    if (mounted) setState(() {});
  }

  // ========= Agrupación en secciones =========

  DateTime? _parseFlexible(String raw) {
    // ISO-8601
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    // HTTP-date "Tue, 28 Oct 2025 00:00:00 GMT"
    try {
      return HttpDate.parse(raw);
    } catch (_) {}

    // yyyy-MM-dd
    final re = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final m = re.firstMatch(raw);
    if (m != null) {
      final y = int.parse(m.group(1)!);
      final mm = int.parse(m.group(2)!);
      final d = int.parse(m.group(3)!);
      return DateTime(y, mm, d);
    }

    // dd/MM/yyyy
    final re2 = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final m2 = re2.firstMatch(raw);
    if (m2 != null) {
      final d = int.parse(m2.group(1)!);
      final mm = int.parse(m2.group(2)!);
      final y = int.parse(m2.group(3)!);
      return DateTime(y, mm, d);
    }
    return null;
  }

  Map<String, List<TransactionResponse>> _groupTransactions(
      List<TransactionResponse> list) {
    final today = DateTime.now();
    DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);
    final t0 = onlyDate(today);
    final y1 = t0.subtract(const Duration(days: 1));
    final weekAgo = t0.subtract(const Duration(days: 7));

    final map = <String, List<TransactionResponse>>{
      'Hoy': [],
      'Ayer': [],
      'Semana pasada': [],
      'Anteriores': [],
    };

    for (final t in list) {
      final d = _parseFlexible(t.fecha);
      if (d == null) {
        map['Anteriores']!.add(t);
        continue;
      }
      final dd = DateTime(d.year, d.month, d.day); // sin toLocal()

      if (dd == t0) {
        map['Hoy']!.add(t);
      } else if (dd == y1) {
        map['Ayer']!.add(t);
      } else if (dd.isAfter(weekAgo) && dd.isBefore(y1)) {
        map['Semana pasada']!.add(t);
      } else {
        map['Anteriores']!.add(t);
      }
    }
    return map;
  }

  // ========= Month utils =========
  int _lastDayOfMonth(int y, int m) => DateTime(y, m + 1, 0).day;

  int _ymCompare(int y1, int m1, int y2, int m2) {
    if (y1 != y2) return y1.compareTo(y2);
    return m1.compareTo(m2);
  }

  bool _isMonthInRange({
    required int year,
    required int month,
    required int minY,
    required int minM,
    required int maxY,
    required int maxM,
  }) {
    final lo = _ymCompare(year, month, minY, minM) >= 0;
    final hi = _ymCompare(year, month, maxY, maxM) <= 0;
    return lo && hi;
  }

  _YearMonth _clampMonth(_YearMonth ym) {
    final minY = _minYear ?? ym.year;
    final minM = _minMonth ?? ym.month;
    final maxY = _capNextYear == 0 ? ym.year : _capNextYear;
    final maxM = _capNextMonth == 0 ? ym.month : _capNextMonth;

    if (_ymCompare(ym.year, ym.month, minY, minM) < 0) {
      return _YearMonth(minY, minM);
    }
    if (_ymCompare(ym.year, ym.month, maxY, maxM) > 0) {
      return _YearMonth(maxY, maxM);
    }
    return ym;
  }

  // ========= Month Picker (bottom sheet, sin ícono de calendario) =========
  Future<void> _openMonthSheet() async {
    if (!mounted) return;

    final minY = _minYear ?? viewModel.anio;
    final minM = _minMonth ?? viewModel.mes;
    final maxY = _capNextYear == 0 ? viewModel.anio : _capNextYear;
    final maxM = _capNextMonth == 0 ? viewModel.mes  : _capNextMonth;

    int tempYear = viewModel.anio;

    final picked = await showModalBottomSheet<_YearMonth>(
      context: context,
      // 👇 importante: permite que el sheet use más alto y sea scrollable
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            // esto evita overflows cuando el contenido es más alto que la pantalla
            child: Padding(
              // deja espacio por si hay insets (gesture/nav bar)
              padding: EdgeInsets.fromLTRB(
                16, 12, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: StatefulBuilder(
                builder: (ctx, setStateSheet) {
                  final months = List<int>.generate(12, (i) => i + 1);

                  bool isEnabled(int y, int m) => _isMonthInRange(
                    year: y, month: m,
                    minY: minY, minM: minM,
                    maxY: maxY, maxM: maxM,
                  );

                  String monthName(int m) =>
                      DateFormat('MMM', 'es').format(DateTime(2000, m, 1)).toUpperCase();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // barra de año compacta
                      Row(
                        children: [
                          IconButton(
                            splashRadius: 20,
                            onPressed: _ymCompare(tempYear - 1, 12, minY, minM) >= 0
                                ? () => setStateSheet(() => tempYear -= 1)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            color: AppColor.azulFynso,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$tempYear',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            splashRadius: 20,
                            onPressed: _ymCompare(tempYear + 1, 1, maxY, maxM) <= 0
                                ? () => setStateSheet(() => tempYear += 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: AppColor.azulFynso,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // rejilla compacta (no scroll propia; la scroll la hace el sheet)
                      GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        // 👇 estas dos líneas son clave para evitar overflow dentro de la grid
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        // 👇 hace los botones un poco más “bajos” (reduce altura total)
                        childAspectRatio: 2.4,
                        children: [
                          for (final m in months)
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: isEnabled(tempYear, m)
                                    ? AppColor.azulFynso
                                    : Colors.grey,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: isEnabled(tempYear, m)
                                  ? () => Navigator.pop(ctx, _YearMonth(tempYear, m))
                                  : null,
                              child: Text(monthName(m)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      final clamped = _clampMonth(picked);
      viewModel.changeMonth(clamped.year, clamped.month);
      await viewModel.loadTransactions(
        jwt: jwt,
        anio: clamped.year,
        mes: clamped.month,
      );
      if (mounted) setState(() {});
    }
  }

  // ========= UI del BottomSheet de filtros (limitado a rango real) =========

  Future<void> _openFilters() async {
    final vm = viewModel;
    final categories = vm.categories;
    final filter = vm.filter;

    final catController = ValueNotifier<int?>(filter.categoryId);
    final subcatController = ValueNotifier<int?>(filter.subcategoryId);
    final dateFromController = ValueNotifier<DateTime?>(filter.dateFrom);
    final dateToController   = ValueNotifier<DateTime?>(filter.dateTo);
    final amountMinCtrl = TextEditingController(
        text: filter.amountMin != null ? filter.amountMin!.toString() : '');
    final amountMaxCtrl = TextEditingController(
        text: filter.amountMax != null ? filter.amountMax!.toString() : '');

    // si ya hay categoría, carga sus subcategorías
    if (filter.categoryId != null) {
      await vm.loadSubcategories(filter.categoryId!);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (ctx, setStateSheet) {
              List<SubcategoryItem> subs = vm.subcategories;

              Future<void> pickDateRange() async {
                // límites exactos a lo disponible en BD
                final first = _minDateAvailable ?? DateTime(2000, 1, 1);
                final last  = _maxDateAvailable ?? DateTime.now();

                final initialDateRange =
                (dateFromController.value != null && dateToController.value != null)
                    ? DateTimeRange(
                  start: dateFromController.value!,
                  end: dateToController.value!,
                )
                    : DateTimeRange(start: first, end: last);

                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: first,  // 1 del primer mes con tx
                  lastDate: last,    // último día del último mes con tx
                  initialDateRange: initialDateRange,
                  helpText: 'Rango de fechas',
                  cancelText: 'Cancelar',
                  confirmText: 'Confirmar',
                  locale: const Locale('es', ''),
                );
                if (picked != null) {
                  dateFromController.value = DateTime(
                      picked.start.year, picked.start.month, picked.start.day);
                  dateToController.value = DateTime(
                      picked.end.year, picked.end.month, picked.end.day);
                  setStateSheet(() {});
                }
              }

              String _fmt(DateTime? d) {
                if (d == null) return '—';
                return DateFormat('dd/MM/yyyy').format(d);
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtros',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Categoría
                    DropdownButtonFormField<int?>(
                      value: catController.value,
                      items: <DropdownMenuItem<int?>>[
                        const DropdownMenuItem(value: null, child: Text('Todas las categorías')),
                        ...categories.map((c) => DropdownMenuItem<int?>(
                          value: c.idCategory,
                          child: Text(c.nombre),
                        )),
                      ],
                      onChanged: (v) async {
                        catController.value = v;
                        subcatController.value = null;
                        if (v != null) {
                          await vm.loadSubcategories(v);
                        } else {
                          vm.subcategories = [];
                        }
                        setStateSheet(() {});
                      },
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                    const SizedBox(height: 8),

                    // Subcategoría
                    DropdownButtonFormField<int?>(
                      value: subcatController.value,
                      items: <DropdownMenuItem<int?>>[
                        const DropdownMenuItem(value: null, child: Text('Todas las subcategorías')),
                        ...subs.map((s) => DropdownMenuItem<int?>(
                          value: s.idSubcategory,
                          child: Text(s.nombre),
                        )),
                      ],
                      onChanged: (v) {
                        subcatController.value = v;
                        setStateSheet(() {});
                      },
                      decoration: const InputDecoration(labelText: 'Subcategoría'),
                    ),
                    const SizedBox(height: 8),

                    // Fechas
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: BorderSide(color: AppColor.azulFynso),
                            ),
                            onPressed: pickDateRange,
                            child: Text(
                              'Rango de fechas: ${_fmt(dateFromController.value)} - ${_fmt(dateToController.value)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            dateFromController.value = null;
                            dateToController.value = null;
                            setStateSheet(() {});
                          },
                          icon: const Icon(Icons.clear),
                          tooltip: 'Limpiar fechas',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Monto min/max
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: amountMinCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Monto mínimo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: amountMaxCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Monto máximo'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await viewModel.clearFilters(); // limpia en VM y recarga
                              if (mounted) Navigator.pop(context);
                            },
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.azulFynso,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final f = TransactionsFilter(
                                categoryId: catController.value,
                                subcategoryId: subcatController.value,
                                dateFrom: dateFromController.value,
                                dateTo: dateToController.value,
                                amountMin: amountMinCtrl.text.trim().isEmpty
                                    ? null
                                    : double.tryParse(amountMinCtrl.text.trim()),
                                amountMax: amountMaxCtrl.text.trim().isEmpty
                                    ? null
                                    : double.tryParse(amountMaxCtrl.text.trim()),
                              );
                              await viewModel.applyFilter(f); // aplica y recarga
                              if (mounted) Navigator.pop(context);
                            },
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ========= Build =========

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<HistorialGastosViewModel>(
        builder: (context, vm, _) {
          final grouped = _groupTransactions(vm.transactions);

          // Etiqueta del mes
          final monthLabel = () {
            final s = DateFormat('MMMM yyyy', 'es')
                .format(DateTime(vm.anio, vm.mes, 1));
            return s[0].toUpperCase() + s.substring(1);
          }();

          // Header siempre visible: selector de mes (sin ícono) + filtros
          Widget _headerRow() {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: AppColor.azulFynso),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    onPressed: _openMonthSheet,
                    child: Text(
                      monthLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: AppColor.azulFynso),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtros'),
                  onPressed: _openFilters,
                ),
              ],
            );
          }

          // Spinner inicial y durante cargas
          if (_booting || vm.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const CustomTextTitle('Historial de gastos'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
              ),
              body: const Center(child: CircularProgressIndicator()),
              floatingActionButton: MicButton(
                onPressed: () => Navigator.pushNamed(context, '/grabarGasto'),
                backgroundColor: AppColor.azulFynso,
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const CustomTextTitle('Historial de gastos'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _headerRow(),
                const SizedBox(height: 12),

                if (vm.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
                  ),
                ] else if (vm.transactions.isEmpty) ...[
                  const SizedBox(height: 48),
                  const Center(child: Text('No hay transacciones')),
                ] else ...[
                  for (final section in ['Hoy','Ayer','Semana pasada','Anteriores'])
                    if ((grouped[section] ?? []).isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          section,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...grouped[section]!.map((t) => GastoCard(
                        categoria: t.category,
                        subcategoria: t.subcategory,
                        monto: t.monto,
                        fecha: t.fecha,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detalleGasto',
                            arguments: TransactionDetailRequest(
                              idTransaction: t.idTransaction,
                              jwt: jwt,
                            ),
                          );
                        },
                      )),
                      const SizedBox(height: 8),
                    ],
                ],
              ],
            ),
            floatingActionButton: MicButton(
              onPressed: () {
                Navigator.pushNamed(context, '/grabarGasto');
              },
              backgroundColor: AppColor.azulFynso,
            ),
          );
        },
      ),
    );
  }
}
