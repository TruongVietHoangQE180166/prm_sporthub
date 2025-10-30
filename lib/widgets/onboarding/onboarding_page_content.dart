import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../view_models/onboarding_view_model.dart';

class OnboardingPageContent extends StatelessWidget {
  final OnboardingPageData pageData;

  const OnboardingPageContent({
    super.key,
    required this.pageData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo section - độc lập phía trên
          _buildLogo(),

          SizedBox(height: 16),

          // Illustration section - độc lập bên dưới
          _buildIllustration(),

          SizedBox(height: 40),

          // Title section
          _buildTitle(context),

          SizedBox(height: 16),

          // Description section
          _buildDescription(context),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/SportHub-Logo.png',
        width: 250,  // Phóng to từ 80 lên 120 (+50%)
        height: 85,  // Phóng to từ 32 lên 48 (+50%)
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'SportHub',
            style: TextStyle(
              fontSize: 50,  // Tăng kích thước font tương ứng
              fontWeight: FontWeight.w800,
              color: pageData.backgroundColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 220,  // Giảm từ 240 xuống 220 để khắc phục overflow
      height: 220, // Giảm từ 240 xuống 220 để khắc phục overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22), // Điều chỉnh bo tròn tương ứng
        boxShadow: [
          BoxShadow(
            color: pageData.backgroundColor.withOpacity(0.2),
            blurRadius: 20, // Giảm blur tương ứng
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          pageData.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              pageData.icon,
              size: 100, // Giảm kích thước icon fallback tương ứng
              color: pageData.backgroundColor,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      pageData.title,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey.shade900,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      pageData.description,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.grey.shade600,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

}