import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/theme_view_model.dart';
import '../../widgets/custom_button.dart';
import '../main/main_screen.dart';
import '../onboarding/onboarding_screen.dart';
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

          // Navigate to main screen after short delay
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

  Widget _buildBackButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7FD957), Color(0xFF5FB833)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7FD957).withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingScreen(forceShow: true)),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Consumer<ThemeViewModel>(
          builder: (context, themeViewModel, child) {
            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: themeViewModel.toggleTheme,
                icon: Icon(
                  themeViewModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: theme.iconTheme.color,
                ),
                tooltip: themeViewModel.isDarkMode
                    ? 'Chuyển sang chế độ sáng'
                    : 'Chuyển sang chế độ tối',
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      body: SafeArea(
        child: Stack(
          children: [
            // Main login form
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const LoginHeader(),
                      const SizedBox(height: 50),
                      LoginFormFields(
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        validateUsername: _validateUsername,
                        validatePassword: _validatePassword,
                      ),
                      const SizedBox(height: 32),
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

            // Back button aligned with logo
            Positioned(
              top: 40,
              left: 25,
              child: _buildBackButton(),
            ),
          ],
        ),
      ),
    );
  }
}
