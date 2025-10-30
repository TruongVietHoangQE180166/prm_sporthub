import 'package:flutter/material.dart';

class ResetPasswordHeader extends StatelessWidget {
  const ResetPasswordHeader({super.key});

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
          'Đặt lại mật khẩu',
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
          'Nhập mã OTP và mật khẩu mới',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}