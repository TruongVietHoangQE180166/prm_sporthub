import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/verify_otp_header.dart';
import '../../widgets/otp_input_field.dart';
import '../../widgets/resend_otp_section.dart';
import '../../widgets/verify_otp_footer.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final bool isRegistration; // Add this parameter
  final String? email; // Add email parameter

  const VerifyOtpScreen({super.key, this.isRegistration = false, this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _otpValue = '';
  bool _isVerifying = false;

  String? _validateOtp(String otp) {
    if (otp.length != 6) {
      return 'Mã OTP phải có 6 chữ số';
    }
    // Check if all characters are digits
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'Mã OTP chỉ được chứa chữ số';
    }
    return null;
  }

  Future<void> _handleVerifyOtp() async {
    final error = _validateOtp(_otpValue);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
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
    final success = await authViewModel.verifyOTP(widget.email ?? '', _otpValue);

    if (mounted) {
      if (success) {
        // Show success message based on context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isRegistration 
              ? 'Xác minh tài khoản thành công! Chào mừng bạn đến với SportHub' 
              : 'Xác minh OTP thành công!'),
            backgroundColor: const Color(0xFF7FD957),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate to login screen after successful verification
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Xác minh OTP thất bại'),
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

  Future<void> _handleResendOtp() async {
    // TODO: Implement resend OTP logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isRegistration
          ? 'Mã OTP mới đã được gửi đến email ${widget.email ?? 'của bạn'} để xác minh tài khoản'
          : 'Mã OTP mới đã được gửi đến email ${widget.email ?? 'của bạn'}'),
        backgroundColor: const Color(0xFF7FD957),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
                VerifyOtpHeader(isRegistration: widget.isRegistration),
                const SizedBox(height: 50),
                // OTP input field
                OtpInputField(
                  onCompleted: (otp) {
                    setState(() {
                      _otpValue = otp;
                    });
                    // Removed automatic verification when 6 digits are entered
                    // User must click the verify button instead
                  },
                  onChanged: (otp) {
                    setState(() {
                      _otpValue = otp;
                    });
                  },
                ),
                const SizedBox(height: 32),
                // Verify button
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return CustomButton(
                      text: 'Xác minh',
                      onPressed: _handleVerifyOtp,
                      isLoading: authViewModel.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Resend OTP section with countdown timer
                ResendOtpSection(
                  email: widget.email,
                ),
                const SizedBox(height: 24),
                // Footer with login and register links
                VerifyOtpFooter(
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