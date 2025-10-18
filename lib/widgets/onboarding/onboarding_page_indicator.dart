import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double spacing;
  final Duration animationDuration;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor = AppColors.primaryGreen,
    this.inactiveColor = AppColors.grey300,
    this.dotSize = 8.0,
    this.spacing = 8.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == currentPage;
    
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      width: isActive ? dotSize * 3.5 : dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [activeColor, activeColor.withOpacity(0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isActive ? null : inactiveColor,
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
    );
  }
}