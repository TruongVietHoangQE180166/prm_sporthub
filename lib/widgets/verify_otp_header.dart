import 'package:flutter/material.dart';

class VerifyOtpHeader extends StatelessWidget {
  final bool isRegistration; // Add this parameter

  const VerifyOtpHeader({super.key, this.isRegistration = false});

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
              color: Colors.green.shade400,
            );
          },
        ),
        const SizedBox(height: 24),
        // Title
        const Text(
          'Xác minh mã OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle - different text based on context
        Text(
          isRegistration 
            ? 'Nhập 6 chữ số đã được gửi đến email của bạn để xác minh tài khoản'
            : 'Nhập 6 chữ số đã được gửi đến email của bạn',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}