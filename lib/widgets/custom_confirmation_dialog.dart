import 'package:flutter/material.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmButtonColor;
  final Widget? additionalContent;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmButtonText = 'Xác nhận',
    this.cancelButtonText = 'Hủy',
    required this.onConfirm,
    required this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmButtonColor,
    this.additionalContent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF7FD957)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFF7FD957),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70,
              ),
            ),
          ),
          if (additionalContent != null) ...[
            const SizedBox(height: 16),
            additionalContent!,
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            cancelButtonText,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor ?? const Color(0xFF7FD957),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            confirmButtonText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}