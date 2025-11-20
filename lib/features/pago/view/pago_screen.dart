import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aprobado_screen.dart';
import 'pendiente_screen.dart';
import 'rechazado_screen.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJwt();
  }

  /// 🔹 Cargar token JWT almacenado localmente
  Future<void> _loadJwt() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      jwt = prefs.getString('jwt_token') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🧩 Validar que exista URL válida
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
        backgroundColor: const Color(0xFF007BFF), // Azul Fynso
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(widget.url!)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useOnDownloadStart: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() => isLoading = true);
              },
              onLoadStop: (controller, url) async {
                setState(() => isLoading = false);
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) async {
                final currentUrl = url?.toString() ?? '';
                print("🔗 Navegando a: $currentUrl");

                if (currentUrl.isEmpty || !context.mounted) return;

                // 🔹 Redirecciones esperadas
                if (currentUrl.contains("pago_exitoso")) {
                  controller.stopLoading();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AprobadoScreen()),
                    );
                  }
                } else if (currentUrl.contains("pago_fallido") ||
                    currentUrl.contains("failure")) {
                  controller.stopLoading();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RechazadoScreen()),
                  );
                } else if (currentUrl.contains("pago_pendiente") ||
                    currentUrl.contains("pending")) {
                  controller.stopLoading();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PendienteScreen()),
                  );
                }
              },
            ),

            // 🔹 Loader visual mientras carga el pago
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF007BFF), // Azul Fynso
                ),
              ),
          ],
        ),
      ),
    );
  }
}
