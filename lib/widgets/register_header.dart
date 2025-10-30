import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

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
          'Tạo tài khoản mới',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          'Đăng ký để bắt đầu',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}