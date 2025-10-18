import 'package:flutter/material.dart';
import '../views/auth/forgot_password_screen.dart';

class LoginFormFields extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? Function(String?)? validateUsername;
  final String? Function(String?)? validatePassword;

  const LoginFormFields({
    super.key,
    required this.usernameController,
    required this.passwordController,
    this.validateUsername,
    this.validatePassword,
  });

  @override
  State<LoginFormFields> createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<LoginFormFields> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Username field
        _buildInputField(
          controller: widget.usernameController,
          hint: 'Tên đăng nhập',
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        // Password field with visibility toggle
        _buildInputField(
          controller: widget.passwordController,
          hint: 'Mật khẩu',
          prefixIcon: Icons.lock_outline,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade400,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Navigate to forgot password screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7FD957),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Quên mật khẩu?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7FD957),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFF7FD957),
                size: 22,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}