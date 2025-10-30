import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback? onGoogleSignIn;

  const LoginFooter({
    super.key,
    required this.onRegisterTap,
    this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'hoặc',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Google Sign In Button
        _buildGoogleSignInButton(context),
        const SizedBox(height: 24),
        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chưa có tài khoản? ',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
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

  Widget _buildGoogleSignInButton(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onGoogleSignIn,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icons8-google-100.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if image not found
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Đăng nhập với Google',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}