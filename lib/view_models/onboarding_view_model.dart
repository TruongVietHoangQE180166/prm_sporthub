import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingViewModel extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;
  
  bool _isLoading = false;
  bool _isOnboardingCompleted = false;
  int _currentPage = 0;
  PageController _pageController = PageController();
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  int get currentPage => _currentPage;
  PageController get pageController => _pageController;
  
  // Onboarding data
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Chào mừng đến với\nSportHub',
      description: 'Nền tảng đặt sân thể thao thông minh, kết nối cộng đồng yêu thể thao',
      imagePath: 'assets/images/onboarding/welcome.png',
      icon: Icons.sports_soccer_rounded,
      backgroundColor: Color(0xFF7FD957),
    ),
    OnboardingPageData(
      title: 'Đặt sân chỉ trong\nvài cú chạm',
      description: 'Khám phá hàng trăm sân thể thao chất lượng, đặt lịch nhanh chóng, thanh toán tiện lợi',
      imagePath: 'assets/images/onboarding/booking.png',
      icon: Icons.calendar_today_rounded,
      backgroundColor: Color(0xFF42A5F5),
    ),
    OnboardingPageData(
      title: 'Tìm đồng đội,\ntạo trận đấu',
      description: 'Kết nối với người chơi cùng đam mê, tham gia giải đấu, nâng cao kỹ năng',
      imagePath: 'assets/images/onboarding/team.png',
      icon: Icons.group_rounded,
      backgroundColor: Color(0xFF7E57C2),
    ),
    OnboardingPageData(
      title: 'Ưu đãi độc quyền\nđang chờ bạn',
      description: 'Nhận voucher giảm giá, tích điểm thưởng, trải nghiệm sân VIP với giá ưu đãi',
      imagePath: 'assets/images/onboarding/rewards.png',
      icon: Icons.card_giftcard_rounded,
      backgroundColor: Color(0xFFFF7043),
    ),
  ];
  
  List<OnboardingPageData> get pages => _pages;
  int get totalPages => _pages.length;
  bool get isLastPage => _currentPage == _pages.length - 1;
  
  OnboardingViewModel() {
    _initializeOnboarding();
  }
  
  Future<void> _initializeOnboarding() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = _prefs?.getBool('onboarding_completed') ?? false;
      
      // Check if user is logged in
      final userId = await _secureStorage.read(key: 'userId');
      if (userId != null) {
        _isOnboardingCompleted = true;
      }
    } catch (e) {
      print('Error initializing onboarding: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }
  
  void nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void skipToLastPage() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  
  Future<void> completeOnboarding() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _prefs?.setBool('onboarding_completed', true);
      _isOnboardingCompleted = true;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error completing onboarding: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> resetOnboarding() async {
    try {
      await _prefs?.setBool('onboarding_completed', false);
      _isOnboardingCompleted = false;
      _currentPage = 0;
      _pageController.animateToPage(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    } catch (e) {
      print('Error resetting onboarding: $e');
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color backgroundColor;
  
  OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.backgroundColor,
  });
}