// lib/features/pago/view/pago_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fynso/features/pago/view/pendiente_screen.dart';
import 'package:fynso/features/pago/view/rechazado_screen.dart';
import 'package:fynso/features/settings/view_model/premium_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aprobado_screen.dart';

class PagoScreen extends StatefulWidget {
  final String? url;

  const PagoScreen({super.key, this.url});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  String jwt = '';
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _loadJwt();
  }

  /// 🔹 Carga el token JWT almacenado localmente
  Future<void> _loadJwt() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      jwt = prefs.getString('jwt_token') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PremiumViewModel>(context, listen: false);

    // 🧩 Verifica que haya una URL válida
    if (widget.url == null || widget.url!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "❌ No se pudo cargar la URL del pago.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Procesando pago"),
        backgroundColor: Colors.amber[700],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(widget.url!)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) async {
                final currentUrl = url?.toString() ?? '';
                print("🔗 Navegando a: $currentUrl");

                if (currentUrl.isEmpty) return;

                // 🔹 Ajusta estas condiciones según tus URLs reales de Mercado Pago
                if (currentUrl.contains("pago_exitoso")) {
                  // ✅ Confirmar pago en tu backend
                  final error = await viewModel.confirmarPago(jwt: jwt);
                  if (error == null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AprobadoScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error ?? "Error al confirmar pago"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                } else if (currentUrl.contains("failure")) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RechazadoScreen()),
                  );
                } else if (currentUrl.contains("pending")) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PendienteScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
