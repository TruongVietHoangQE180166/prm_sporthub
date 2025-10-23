import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../views/auth/login_screen.dart';
import '../custom_confirmation_dialog.dart'; // Thêm import

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          // Hiển thị modal xác nhận đăng xuất
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) { // Sử dụng dialogContext riêng biệt
              return CustomConfirmationDialog(
                title: 'Xác nhận đăng xuất',
                message: 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
                confirmButtonText: 'Đăng xuất',
                cancelButtonText: 'Hủy',
                icon: Icons.logout,
                iconColor: Colors.red,
                onConfirm: () async {
                  // Thực hiện đăng xuất
                  context.read<AuthViewModel>().logout();

                  // Show success message before navigating
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đăng xuất thành công!'),
                      backgroundColor: const Color(0xFF7FD957),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );

                  // Đóng dialog
                  Navigator.of(dialogContext).pop();
                  
                  // Navigate to login screen after a delay
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  });
                },
                onCancel: () {
                  Navigator.of(dialogContext).pop(); // Đóng dialog bằng dialogContext
                },
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Black color
          foregroundColor: Colors.white, // White text
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}