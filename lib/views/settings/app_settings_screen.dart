import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/theme_view_model.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // Remove default AppBar and use custom header
      appBar: null, // Hide default app bar
      body: SafeArea( // Add SafeArea to handle notches and cutouts properly
        child: Column(
          children: [
            // Custom header with enhanced design (matching order_screen header)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7FD957),
                    const Color(0xFF7FD957).withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7FD957).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cài đặt',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Quản lý cài đặt ứng dụng',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Content area
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Dark Mode Section
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7FD957).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                context.watch<ThemeViewModel>().isDarkMode
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: const Color(0xFF7FD957),
                                size: 24,
                              ),
                            ),
                            title: const Text(
                              'Chế độ tối',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              context.watch<ThemeViewModel>().isDarkMode
                                  ? 'Đang bật chế độ tối'
                                  : 'Đang tắt chế độ tối',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: Switch(
                              value: context.watch<ThemeViewModel>().isDarkMode,
                              onChanged: (value) {
                                context.read<ThemeViewModel>().toggleTheme();
                              },
                              activeColor: const Color(0xFF7FD957),
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          const ListTile(
                            leading: SizedBox(width: 56), // Same width as the switch area
                            title: Text(
                              'Chế độ tối giúp bảo vệ mắt và tiết kiệm pin khi sử dụng ứng dụng vào ban đêm.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Other settings sections can be added here
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF7FD957),
                              size: 24,
                            ),
                            title: Text(
                              'Thông báo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Quản lý thông báo ứng dụng',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey),
                          ListTile(
                            leading: Icon(
                              Icons.language_outlined,
                              color: Color(0xFF7FD957),
                              size: 24,
                            ),
                            title: Text(
                              'Ngôn ngữ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Tiếng Việt',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey),
                          ListTile(
                            leading: Icon(
                              Icons.help_outline,
                              color: Color(0xFF7FD957),
                              size: 24,
                            ),
                            title: Text(
                              'Trợ giúp & Hỗ trợ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Câu hỏi thường gặp, liên hệ hỗ trợ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App info section
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Phiên bản ứng dụng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '1.0.0',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}