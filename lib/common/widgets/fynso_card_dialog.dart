import 'package:flutter/material.dart';
import 'package:fynso/common/themes/app_color.dart';

class FynsoCardDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final List<Widget> actions;

  const FynsoCardDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.azulFynso.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColor.azulFynso.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColor.azulFynso.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColor.azulFynso),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: actions
                  .map(
                    (widget) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: widget,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Future<T?> showFynsoCardDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required List<Widget> actions,
  IconData icon = Icons.info_outline,
  bool dismissible = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (_) => WillPopScope(
      onWillPop: () async => dismissible,
      child: FynsoCardDialog(
        title: title,
        message: message,
        actions: actions,
        icon: icon,
      ),
    ),
  );
}
