import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class OnboardingNavigationButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const OnboardingNavigationButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56.0,
    this.padding,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = isPrimary 
        ? (backgroundColor ?? AppColors.primaryGreen)
        : Colors.transparent;
    
    final defaultTextColor = isPrimary
        ? (textColor ?? Colors.white)
        : (textColor ?? AppColors.primaryGreen);
    
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final defaultPadding = padding ?? EdgeInsets.symmetric(horizontal: 32, vertical: 16);

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    defaultBackgroundColor,
                    defaultBackgroundColor.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : defaultBackgroundColor,
          borderRadius: defaultBorderRadius,
          border: border ?? (isPrimary 
              ? null 
              : Border.all(
                  color: defaultTextColor,
                  width: 1.5,
                )),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: defaultBackgroundColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: defaultBorderRadius,
            child: Container(
              padding: defaultPadding,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: defaultTextColor,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          color: defaultTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? textColor;

  const SkipButton({
    super.key,
    required this.onPressed,
    this.text = 'Bỏ qua',
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.grey500,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: textColor ?? AppColors.grey500,
        ),
      ),
    );
  }
}