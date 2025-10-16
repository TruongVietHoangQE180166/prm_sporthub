import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/reset_password_header.dart';
import '../../widgets/reset_password_form_fields.dart';
import '../../widgets/reset_password_footer.dart';
import '../../widgets/resend_otp_section.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email; // Add email parameter

  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  String _otpValue = '';
  bool _isResetting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  String? _validateOtp(String otp) {
    if (otp.isEmpty) {
      return 'Vui lòng nhập mã OTP';
    }
    if (otp.length != 6) {
      return 'Mã OTP phải có 6 chữ số';
    }
    // Check if all characters are digits
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'Mã OTP chỉ được chứa chữ số';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? _validateConfirmNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu mới';
    }
    if (value != _newPasswordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    // Validate inputs
    final otpError = _validateOtp(_otpValue);
    final newPasswordError = _validateNewPassword(_newPasswordController.text);
    final confirmPasswordError = _validateConfirmNewPassword(_confirmNewPasswordController.text);
    
    if (otpError != null || newPasswordError != null || confirmPasswordError != null) {
      String errorMessage = 'Vui lòng điền đầy đủ thông tin';
      if (otpError != null) errorMessage = otpError;
      else if (newPasswordError != null) errorMessage = newPasswordError;
      else if (confirmPasswordError != null) errorMessage = confirmPasswordError;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.resetPassword(
      _otpValue,
      widget.email ?? '',
      _newPasswordController.text,
    );

    if (mounted) {
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đặt lại mật khẩu thành công!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate to login screen after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      } else {
        setState(() {
          _isResetting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Đặt lại mật khẩu thất bại'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Header with logo and title
                const ResetPasswordHeader(),
                const SizedBox(height: 30),
                // Form fields
                ResetPasswordFormFields(
                  newPasswordController: _newPasswordController,
                  confirmNewPasswordController: _confirmNewPasswordController,
                  validateNewPassword: _validateNewPassword,
                  validateConfirmNewPassword: _validateConfirmNewPassword,
                  onOtpCompleted: (otp) {
                    setState(() {
                      _otpValue = otp;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Resend OTP section with countdown timer
                ResendOtpSection(
                  email: widget.email, // Pass email to ResendOtpSection
                ),
                const SizedBox(height: 24),
                // Reset password button
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return CustomButton(
                      text: 'Đặt lại mật khẩu',
                      onPressed: _handleResetPassword,
                      isLoading: authViewModel.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Footer with login and register links
                ResetPasswordFooter(
                  onLoginTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  onRegisterTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}