import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../find_team/find_team_screen.dart';
import '../explore/explore_screen.dart';
import '../chat/booking_screen.dart';

class MainScreen extends StatefulWidget {
  final int? initialTabIndex;

  const MainScreen({super.key, this.initialTabIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const FindTeamScreen(),
    const BookingScreen(), // Changed from ExploreScreen to BookingScreen
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Set initial tab index if provided
    if (widget.initialTabIndex != null) {
      _currentIndex = widget.initialTabIndex!;
    }
  }

  DateTime? _currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex == 0) {
          return _onWillPop();
        } else {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: _buildCustomBottomNavigationBar(),
        floatingActionButton: _buildBookingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildCustomBottomNavigationBar() {
    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width - 40, 75),
            painter: BottomNavBarPainter(),
          ),
          SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Trang chủ',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.group_outlined,
                  label: 'Tìm đội',
                  index: 1,
                ),
                const SizedBox(width: 80),
                _buildNavItem(
                  icon: Icons.chat_bubble_rounded, // Changed from explore icon to soccer icon
                  label: 'Chat', // Changed label to "Đặt sân"
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.account_box,
                  label: 'Hồ sơ',
                  index: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? const Color(0xFF7FD957).withOpacity(0.15)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                    ? const Color(0xFF7FD957)
                    : Colors.black.withOpacity(0.5),
                  size: 32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                    ? const Color(0xFF7FD957)
                    : Colors.black.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingButton() {
    return Container(
      width: 85,
      height: 85,
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF7FD957), Color(0xFF5FB833)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7FD957).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExploreScreen()), // Changed to ExploreScreen
            );
          },
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.sports_soccer_rounded, // Changed icon to explore
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhấn lần nữa để thoát'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }
}

class BottomNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    
    // Bắt đầu từ góc trái
    path.moveTo(0, 20);
    
    // Cạnh trái bo tròn
    path.quadraticBezierTo(0, 0, 20, 0);
    
    // Đường thẳng đến điểm bắt đầu notch
    path.lineTo(size.width * 0.35, 0);
    
    // Tạo notch (phần khoét) cho nút booking - sâu hơn nhiều
    path.quadraticBezierTo(
      size.width * 0.37, 0,
      size.width * 0.39, 15,
    );
    
    path.quadraticBezierTo(
      size.width * 0.43, 38,
      size.width * 0.50, 38,
    );
    
    path.quadraticBezierTo(
      size.width * 0.57, 38,
      size.width * 0.61, 15,
    );
    
    path.quadraticBezierTo(
      size.width * 0.63, 0,
      size.width * 0.65, 0,
    );
    
    // Đường thẳng đến góc phải
    path.lineTo(size.width - 20, 0);
    
    // Cạnh phải bo tròn
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    
    // Cạnh dưới
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(
      size.width, size.height,
      size.width - 20, size.height,
    );
    
    path.lineTo(20, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 20);
    
    path.close();

    // Vẽ bóng
    canvas.drawPath(path, shadowPaint);
    
    // Vẽ bottom bar
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}