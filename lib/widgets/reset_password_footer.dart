import 'package:flutter/material.dart';

class ResetPasswordFooter extends StatelessWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const ResetPasswordFooter({
    super.key,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Back to login link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đã nhớ mật khẩu? ',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),
            GestureDetector(
              onTap: onLoginTap,
              child: Text(
                'Đăng nhập',
                style: TextStyle(
                  color: const Color(0xFF7FD957),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chưa có tài khoản? ',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),
            GestureDetector(
              onTap: onRegisterTap,
              child: Text(
                'Đăng ký ngay',
                style: TextStyle(
                  color: const Color(0xFF7FD957),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}