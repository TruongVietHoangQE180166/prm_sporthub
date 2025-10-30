import 'package:flutter/material.dart';
import 'otp_input_field.dart';

class ResetPasswordFormFields extends StatefulWidget {
  final TextEditingController newPasswordController;
  final TextEditingController confirmNewPasswordController;
  final String? Function(String?)? validateNewPassword;
  final String? Function(String?)? validateConfirmNewPassword;
  final Function(String)? onOtpCompleted;

  const ResetPasswordFormFields({
    super.key,
    required this.newPasswordController,
    required this.confirmNewPasswordController,
    this.validateNewPassword,
    this.validateConfirmNewPassword,
    this.onOtpCompleted,
  });

  @override
  State<ResetPasswordFormFields> createState() => _ResetPasswordFormFieldsState();
}

class _ResetPasswordFormFieldsState extends State<ResetPasswordFormFields> {
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _otpValue = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // OTP input field
        Text(
          'Nhập mã OTP đã được gửi đến email của bạn',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        OtpInputField(
          onCompleted: (otp) {
            setState(() {
              _otpValue = otp;
            });
            widget.onOtpCompleted?.call(otp);
          },
          onChanged: (otp) {
            setState(() {
              _otpValue = otp;
            });
          },
        ),
        const SizedBox(height: 24),
        // New password field with visibility toggle
        _buildInputField(
          controller: widget.newPasswordController,
          hint: 'Mật khẩu mới',
          prefixIcon: Icons.lock_outline,
          obscureText: !_isNewPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        // Confirm new password field with visibility toggle
        _buildInputField(
          controller: widget.confirmNewPasswordController,
          hint: 'Xác nhận mật khẩu mới',
          prefixIcon: Icons.lock_outline,
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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