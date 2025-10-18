import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/onboarding_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/onboarding/onboarding_page_content.dart';
import '../../widgets/onboarding/onboarding_page_indicator.dart';
import '../../widgets/onboarding/onboarding_navigation_button.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _setupBackgroundAnimation();
  }

  void _setupBackgroundAnimation() {
    _backgroundController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7FD957),
                  strokeWidth: 3.5,
                ),
              ),
            );
          }

          if (viewModel.isOnboardingCompleted) {
            return LoginScreen();
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                // Animated background
                _buildAnimatedBackground(),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 16, right: 24),
                          child: SkipButton(
                            onPressed: () => _handleSkip(viewModel),
                          ),
                        ),
                      ),
                      
                      // Page content
                      Expanded(
                        child: PageView.builder(
                          controller: viewModel.pageController,
                          onPageChanged: viewModel.onPageChanged,
                          itemCount: viewModel.totalPages,
                          itemBuilder: (context, index) {
                            return OnboardingPageContent(
                              pageData: viewModel.pages[index],
                              isVisible: index == viewModel.currentPage,
                            );
                          },
                        ),
                      ),
                      
                      // Bottom section with indicators and buttons
                      _buildBottomSection(viewModel),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: OnboardingBackgroundPainter(
              animationValue: _backgroundAnimation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(OnboardingViewModel viewModel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicators
          OnboardingPageIndicator(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
          ),
          
          SizedBox(height: 32),
          
          // Navigation buttons
          if (viewModel.isLastPage)
            _buildAuthButtons(viewModel)
          else
            _buildNavigationButtons(viewModel),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(OnboardingViewModel viewModel) {
    return Row(
      children: [
        // Previous button (hidden on first page)
        if (viewModel.currentPage > 0)
          Expanded(
            child: OnboardingNavigationButton(
              text: 'Trước',
              onPressed: viewModel.previousPage,
              isPrimary: false,
              height: 56,
            ),
          ),
        
        if (viewModel.currentPage > 0)
          SizedBox(width: 16),
        
        // Next button
        Expanded(
          child: OnboardingNavigationButton(
            text: viewModel.currentPage == viewModel.totalPages - 2 
                ? 'Khám phá thêm' 
                : 'Tiếp tục',
            onPressed: viewModel.nextPage,
            height: 56,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons(OnboardingViewModel viewModel) {
    return Column(
      children: [
        // Primary CTA button
        OnboardingNavigationButton(
          text: 'Đăng ký ngay',
          onPressed: () => _handleRegister(viewModel),
          height: 56,
          width: double.infinity,
        ),
        
        SizedBox(height: 16),
        
        // Secondary button
        OnboardingNavigationButton(
          text: 'Đăng nhập',
          onPressed: () => _handleLogin(viewModel),
          isPrimary: false,
          height: 56,
          width: double.infinity,
        ),
      ],
    );
  }

  void _handleSkip(OnboardingViewModel viewModel) {
    viewModel.skipToLastPage();
  }

  void _handleRegister(OnboardingViewModel viewModel) async {
    await viewModel.completeOnboarding();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RegisterScreen()),
      );
    }
  }

  void _handleLogin(OnboardingViewModel viewModel) async {
    await viewModel.completeOnboarding();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }
}

class OnboardingBackgroundPainter extends CustomPainter {
  final double animationValue;

  OnboardingBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF7FD957).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Create floating circles
    final circles = [
      {'x': 0.1, 'y': 0.2, 'radius': 80.0, 'speed': 0.5},
      {'x': 0.8, 'y': 0.1, 'radius': 60.0, 'speed': 0.7},
      {'x': 0.3, 'y': 0.7, 'radius': 100.0, 'speed': 0.3},
      {'x': 0.9, 'y': 0.8, 'radius': 70.0, 'speed': 0.6},
      {'x': 0.5, 'y': 0.4, 'radius': 90.0, 'speed': 0.4},
    ];

    for (final circle in circles) {
      final x = (circle['x'] as double) * size.width;
      final y = (circle['y'] as double) * size.height;
      final radius = circle['radius'] as double;
      final speed = circle['speed'] as double;
      
      // Calculate position based on animation
      final offset = (animationValue * speed * 2 * 3.14159) % (2 * 3.14159);
      final offsetY = math.sin(offset) * 20;
      final offsetX = math.cos(offset) * 15;
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }

    // Create gradient overlay
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Color(0xFF7FD957).withOpacity(0.02),
          Colors.transparent,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
