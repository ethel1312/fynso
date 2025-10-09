import 'package:flutter/material.dart';
import 'package:fynso/common/widgets/custom_text_title.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTextTitle("Términos y Condiciones"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "1. Introducción",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Bienvenido a Fynso. Al utilizar esta aplicación, aceptas los términos y condiciones que se describen a continuación. Esta app tiene como objetivo ayudarte a gestionar y distribuir tu dinero de manera responsable.",
            ),
            SizedBox(height: 16),
            Text(
              "2. Uso de la aplicación",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "- La app está destinada únicamente para estudiantes que deseen llevar control de sus ingresos, gastos y presupuestos.\n"
              "- Los usuarios son responsables de la información que ingresan; la app no realiza transacciones reales ni retiene dinero.\n"
              "- No se permite el uso de la app para fines ilegales o fraudulentos.",
            ),
            SizedBox(height: 16),
            Text(
              "3. Privacidad y datos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "- Los datos proporcionados por los usuarios se utilizan únicamente para mejorar la experiencia dentro de la app.\n"
              "- No se compartirán los datos con terceros sin consentimiento.\n"
              "- Se recomienda no ingresar información sensible, como contraseñas de bancos o números de tarjeta.",
            ),
            SizedBox(height: 16),
            Text(
              "4. Responsabilidad",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "- La app es solo una herramienta de gestión y planificación; no garantiza ganancias ni pérdidas.\n"
              "- Los desarrolladores no se hacen responsables por errores en el registro de datos o decisiones financieras tomadas basadas en la app.",
            ),
            SizedBox(height: 16),
            Text(
              "5. Actualizaciones y cambios",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "- Los términos pueden actualizarse en cualquier momento.\n"
              "- Se recomienda revisar los términos periódicamente.",
            ),
            SizedBox(height: 16),
            Text(
              "6. Contacto",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "- Para dudas o sugerencias, los usuarios pueden contactar a soporte en soporte@fynso.com",
            ),
          ],
        ),
      ),
    );
  }
}
