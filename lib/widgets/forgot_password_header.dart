import 'package:flutter/material.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo full without container
        Image.asset(
          'assets/images/SportHub-Logo.png',
          width: 400,
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback nếu không tìm thấy logo
            return Icon(
              Icons.sports_soccer,
              size: 80,
              color: const Color(0xFF7FD957),
            );
          },
        ),
        const SizedBox(height: 24),
        // Title
        Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          'Nhập email để nhận liên kết đặt lại mật khẩu',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}