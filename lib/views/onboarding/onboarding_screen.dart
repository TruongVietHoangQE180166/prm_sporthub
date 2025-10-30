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
  final bool forceShow;

  const OnboardingScreen({super.key, this.forceShow = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 3.5,
                ),
              ),
            );
          }

          if (viewModel.isOnboardingCompleted && !widget.forceShow) {
            return LoginScreen();
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor, // Responsive với theme
        child: CustomPaint(
          painter: OnboardingBackgroundPainter(),
        ),
      ),
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
  @override
  void paint(Canvas canvas, Size size) {
    // Nền trắng tinh - không có bất kỳ màu sắc nào khác
    // Không vẽ gì cả để giữ nền trắng hoàn toàn
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

