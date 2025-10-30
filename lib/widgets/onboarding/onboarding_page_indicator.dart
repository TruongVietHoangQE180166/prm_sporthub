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
    final effectiveActiveColor = activeColor;
    final effectiveInactiveColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : inactiveColor;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => _buildDot(index, effectiveActiveColor, effectiveInactiveColor),
      ),
    );
  }

  Widget _buildDot(int index, Color effectiveActiveColor, Color effectiveInactiveColor) {
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
                colors: [effectiveActiveColor, effectiveActiveColor.withOpacity(0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isActive ? null : effectiveInactiveColor,
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
    );
  }
}