import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/custom_button.dart';
import '../main/main_screen.dart';
import 'register_screen.dart';
import '../../widgets/login_header.dart';
import '../../widgets/login_form_fields.dart';
import '../../widgets/login_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = context.read<AuthViewModel>();
      final success = await authViewModel.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // Show success message before navigating
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đăng nhập thành công!'),
              backgroundColor: const Color(0xFF7FD957),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          
          // Navigate to main screen after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authViewModel.errorMessage ?? 'Đăng nhập thất bại'),
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
  }

  Future<void> _handleGoogleSignIn() async {
    // TODO: Implement Google Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chức năng đăng nhập Google đang được phát triển'),
        backgroundColor: Colors.blue.shade400,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Header with logo and title
                  const LoginHeader(),
                  const SizedBox(height: 50),
                  // Form fields
                  LoginFormFields(
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    validateUsername: _validateUsername,
                    validatePassword: _validatePassword,
                  ),
                  const SizedBox(height: 32),
                  // Login button
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return CustomButton(
                        text: 'Đăng nhập',
                        onPressed: _handleLogin,
                        isLoading: authViewModel.isLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Footer with register link
                  LoginFooter(
                    onRegisterTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    onGoogleSignIn: _handleGoogleSignIn,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}