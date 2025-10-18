import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/colors.dart';
import '../../view_models/onboarding_view_model.dart';
import 'onboarding_animation.dart';

class OnboardingPageContent extends StatefulWidget {
  final OnboardingPageData pageData;
  final bool isVisible;

  const OnboardingPageContent({
    super.key,
    required this.pageData,
    this.isVisible = false,
  });

  @override
  State<OnboardingPageContent> createState() => _OnboardingPageContentState();
}

class _OnboardingPageContentState extends State<OnboardingPageContent>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _descriptionController;
  late AnimationController _imageController;
  late AnimationController _iconController;

  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _imageAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _titleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _descriptionController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _imageController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutBack,
    ));

    _descriptionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _descriptionController,
      curve: Curves.easeOutCubic,
    ));

    _imageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeOutCubic,
    ));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(OnboardingPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startAnimations();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _resetAnimations();
    }
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (mounted && _titleController.isAnimating == false) {
      _titleController.forward();
    }
    
    await Future.delayed(Duration(milliseconds: 200));
    if (mounted && _descriptionController.isAnimating == false) {
      _descriptionController.forward();
    }
    
    await Future.delayed(Duration(milliseconds: 300));
    if (mounted && _imageController.isAnimating == false) {
      _imageController.forward();
    }
    
    await Future.delayed(Duration(milliseconds: 200));
    if (mounted && _iconController.isAnimating == false) {
      _iconController.forward();
    }
  }

  void _resetAnimations() {
    if (mounted && _titleController.isAnimating == false) {
      _titleController.reset();
    }
    if (mounted && _descriptionController.isAnimating == false) {
      _descriptionController.reset();
    }
    if (mounted && _imageController.isAnimating == false) {
      _imageController.reset();
    }
    if (mounted && _iconController.isAnimating == false) {
      _iconController.reset();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main illustration or icon
            _buildIllustration(),
            SizedBox(height: 40),
            
            // Title
            _buildTitle(),
            SizedBox(height: 16),
            
            // Description
            _buildDescription(),
            SizedBox(height: 40),
            
            // Additional content based on page
            _buildAdditionalContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    switch (widget.pageData.title.split('\n')[0]) {
      case 'Chào mừng đến với':
        return _buildWelcomeIllustration();
      case 'Đặt sân chỉ trong':
        return _buildBookingIllustration();
      case 'Tìm đồng đội,':
        return _buildTeamIllustration();
      case 'Ưu đãi độc quyền':
        return _buildRewardsIllustration();
      default:
        return _buildDefaultIllustration();
    }
  }

  Widget _buildWelcomeIllustration() {
    return OnboardingAnimation(
      duration: Duration(milliseconds: 800),
      delay: Duration(milliseconds: 200),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.pageData.backgroundColor.withOpacity(0.1),
              widget.pageData.backgroundColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: widget.pageData.backgroundColor.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Logo
            Center(
              child: PulseAnimation(
                duration: Duration(seconds: 3),
                child: Image.asset(
                  'assets/images/SportHub-Logo.png',
                  width: 120,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.sports_soccer_rounded,
                      size: 80,
                      color: widget.pageData.backgroundColor,
                    );
                  },
                ),
              ),
            ),
            // Floating sports player images
            ...List.generate(6, (index) {
              final angle = (index * 60) * (math.pi / 180);
              final radius = 70.0;
              return AnimatedBuilder(
                animation: _iconAnimation,
                builder: (context, child) {
                  final offset = _iconAnimation.value * radius;
                  return Positioned(
                    left: 100 + math.cos(angle) * offset - 15,
                    top: 100 + math.sin(angle) * offset - 15,
                    child: FloatingAnimation(
                      duration: Duration(seconds: 4 + index),
                      amplitude: 5.0,
                      child: Transform.scale(
                        scale: _iconAnimation.value,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: widget.pageData.backgroundColor.withOpacity(0.7),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              _getSportPlayerImage(index),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  _getSportIcon(index),
                                  size: 20,
                                  color: widget.pageData.backgroundColor.withOpacity(0.7),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingIllustration() {
    return OnboardingAnimation(
      duration: Duration(milliseconds: 800),
      delay: Duration(milliseconds: 200),
      child: Container(
        height: 180,
        child: Stack(
          children: [
            // Search step
            _buildProcessStep(
              image: 'assets/images/onboarding/booking/step_search.webp',
              label: 'Tìm kiếm',
              position: 0,
              totalSteps: 3,
            ),
            // Select step
            _buildProcessStep(
              image: 'assets/images/onboarding/booking/step_field.webp',
              label: 'Chọn sân',
              position: 1,
              totalSteps: 3,
            ),
            // Confirm step
            _buildProcessStep(
              image: 'assets/images/onboarding/booking/step_confirm.webp',
              label: 'Xác nhận',
              position: 2,
              totalSteps: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep({
    IconData? icon,
    String? image,
    required String label,
    required int position,
    required int totalSteps,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final stepWidth = (screenWidth - 80) / totalSteps;
    final leftPosition = 40 + (position * stepWidth);

    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        final clampedValue = _iconAnimation.value.clamp(0.0, 1.0);
        final delay = position * 0.2;
        final rawValue = clampedValue - delay;
        // Đảm bảo giá trị luôn nằm trong khoảng [0.0, 1.0]
        var animationValue = rawValue.clamp(0.0, 1.0);

        // DEBUG: Log opacity values
        print('DEBUG: Process step - position: $position, rawValue: $rawValue, clampedValue: $animationValue');

        // Thêm kiểm tra double đảm bảo giá trị hợp lệ
        if (animationValue.isNaN || animationValue.isInfinite) {
          animationValue = 0.0;
          print('ERROR: Invalid opacity value (NaN/Infinite), reset to 0.0');
        }

        // Đảm bảo giá trị không vượt quá 1.0 do elasticOut curve
        if (animationValue > 1.0) animationValue = 1.0;
        if (animationValue < 0.0) animationValue = 0.0;
        
        return Positioned(
          left: leftPosition - 30,
          top: 60,
          child: Transform.scale(
            scale: animationValue,
            child: Opacity(
              opacity: animationValue,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.pageData.backgroundColor,
                          widget.pageData.backgroundColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: widget.pageData.backgroundColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              image,
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  icon ?? Icons.help_outline,
                                  color: Colors.white,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : Icon(
                            icon ?? Icons.help_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamIllustration() {
    return OnboardingAnimation(
      duration: Duration(milliseconds: 800),
      delay: Duration(milliseconds: 200),
      child: Container(
        height: 180,
        child: Stack(
          children: [
            // Central user
            _buildNetworkNode(
              image: 'assets/images/onboarding/team/player_center.webp',
              isCenter: true,
              color: widget.pageData.backgroundColor,
            ),
            // Surrounding players
            ...List.generate(6, (index) {
              final angle = (index * 60) * (math.pi / 180);
              return _buildNetworkNode(
                image: 'assets/images/onboarding/team/player_${index + 1}.webp',
                angle: angle,
                radius: 60,
                color: widget.pageData.backgroundColor.withOpacity(0.7),
                delay: index * 0.1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkNode({
    IconData? icon,
    String? image,
    bool isCenter = false,
    double angle = 0,
    double radius = 0,
    required Color color,
    double delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        final clampedValue = _iconAnimation.value.clamp(0.0, 1.0);
        final rawValue = clampedValue - delay;
        // Đảm bảo giá trị luôn nằm trong khoảng [0.0, 1.0]
        var animationValue = rawValue.clamp(0.0, 1.0);
        final offset = animationValue * radius;

        // DEBUG: Log opacity values
        print('DEBUG: Network node - delay: $delay, rawValue: $rawValue, clampedValue: $animationValue');

        // Thêm kiểm tra double đảm bảo giá trị hợp lệ
        if (animationValue.isNaN || animationValue.isInfinite) {
          animationValue = 0.0;
          print('ERROR: Invalid opacity value in network node (NaN/Infinite), reset to 0.0');
        }

        // Đảm bảo giá trị không vượt quá 1.0 do elasticOut curve
        if (animationValue > 1.0) animationValue = 1.0;
        if (animationValue < 0.0) animationValue = 0.0;
        
        return Positioned(
          left: 100 + math.cos(angle) * offset - 20,
          top: 70 + math.sin(angle) * offset - 20,
          child: Transform.scale(
            scale: animationValue,
            child: Opacity(
              opacity: animationValue,
              child: Container(
                width: isCenter ? 50 : 40,
                height: isCenter ? 50 : 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isCenter ? 25 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(isCenter ? 12.5 : 10),
                        child: Image.asset(
                          image,
                          width: isCenter ? 25 : 20,
                          height: isCenter ? 25 : 20,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              icon ?? Icons.person,
                              color: Colors.white,
                              size: isCenter ? 25 : 20,
                            );
                          },
                        ),
                      )
                    : Icon(
                        icon ?? Icons.person,
                        color: Colors.white,
                        size: isCenter ? 25 : 20,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardsIllustration() {
    return OnboardingAnimation(
      duration: Duration(milliseconds: 800),
      delay: Duration(milliseconds: 200),
      child: Container(
        height: 180,
        child: Stack(
          children: [
            // VIP Badge
            _buildFloatingReward(
              image: 'assets/images/onboarding/rewards/star.webp',
              label: 'VIP',
              color: Colors.amber,
              position: 0,
            ),
            // Voucher
            _buildFloatingReward(
              image: 'assets/images/onboarding/rewards/voucher.webp',
              label: '-50%',
              color: Colors.red,
              position: 1,
            ),
            // Coins
            _buildFloatingReward(
              image: 'assets/images/onboarding/rewards/coin.webp',
              label: '1000',
              color: Colors.orange,
              position: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingReward({
    IconData? icon,
    String? image,
    required String label,
    required Color color,
    required int position,
  }) {
    final positions = [
      Offset(50, 30),
      Offset(150, 50),
      Offset(100, 100),
    ];

    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        final clampedValue = _iconAnimation.value.clamp(0.0, 1.0);
        final delay = position * 0.2;
        final rawValue = clampedValue - delay;
        // Đảm bảo giá trị luôn nằm trong khoảng [0.0, 1.0]
        var animationValue = rawValue.clamp(0.0, 1.0);
        final offset = positions[position];

        // DEBUG: Log opacity values
        print('DEBUG: Floating reward - position: $position, rawValue: $rawValue, clampedValue: $animationValue');

        // Thêm kiểm tra double đảm bảo giá trị hợp lệ
        if (animationValue.isNaN || animationValue.isInfinite) {
          animationValue = 0.0;
          print('ERROR: Invalid opacity value in floating reward (NaN/Infinite), reset to 0.0');
        }

        // Đảm bảo giá trị không vượt quá 1.0 do elasticOut curve
        if (animationValue > 1.0) animationValue = 1.0;
        if (animationValue < 0.0) animationValue = 0.0;
        
        return Positioned(
          left: offset.dx,
          top: offset.dy + (math.sin(_iconAnimation.value * 2 * math.pi + position) * 10),
          child: Transform.scale(
            scale: animationValue,
            child: Opacity(
              opacity: animationValue,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              image,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  icon ?? Icons.star,
                                  color: Colors.white,
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Icon(
                            icon ?? Icons.star,
                            color: Colors.white,
                            size: 24,
                          ),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultIllustration() {
    return AnimatedBuilder(
      animation: _imageAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _imageAnimation.value,
          child: Opacity(
            opacity: _imageAnimation.value,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.pageData.backgroundColor.withOpacity(0.2),
                    widget.pageData.backgroundColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(75),
              ),
              child: Icon(
                widget.pageData.icon,
                size: 80,
                color: widget.pageData.backgroundColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return SlideInAnimation(
      direction: SlideDirection.down,
      duration: Duration(milliseconds: 600),
      delay: Duration(milliseconds: 100),
      child: Text(
        widget.pageData.title,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.grey900,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescription() {
    return SlideInAnimation(
      direction: SlideDirection.down,
      duration: Duration(milliseconds: 600),
      delay: Duration(milliseconds: 300),
      child: Text(
        widget.pageData.description,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.grey600,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAdditionalContent() {
    switch (widget.pageData.title.split('\n')[0]) {
      case 'Chào mừng đến với':
        return _buildSportsGrid();
      case 'Đặt sân chỉ trong':
        return _buildFeatureCards();
      case 'Tìm đồng đội,':
        return _buildTeamFeatures();
      case 'Ưu đãi độc quyền':
        return _buildRewardFeatures();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildSportsGrid() {
    final sports = [
      {'icon': Icons.sports_soccer_rounded, 'name': 'Bóng đá'},
      {'icon': Icons.sports_tennis_rounded, 'name': 'Tennis'},
      {'icon': Icons.sports_basketball_rounded, 'name': 'Bóng rổ'},
      {'icon': Icons.sports_volleyball_rounded, 'name': 'Bóng chuyền'},
      {'icon': Icons.pool_rounded, 'name': 'Bơi lội'},
      {'icon': Icons.fitness_center_rounded, 'name': 'Gym'},
    ];

    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconAnimation.value,
          child: Opacity(
            opacity: _iconAnimation.value,
            child: Container(
              height: 120,
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: sports.length,
                itemBuilder: (context, index) {
                  final sport = sports[index];
                  final delay = index * 0.1;
                  final animationValue = (_iconAnimation.value - delay).clamp(0.0, 1.0);
                  
                  return Transform.scale(
                    scale: animationValue,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.pageData.backgroundColor.withOpacity(0.1),
                            widget.pageData.backgroundColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.pageData.backgroundColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            sport['icon'] as IconData,
                            color: widget.pageData.backgroundColor,
                            size: 24,
                          ),
                          SizedBox(height: 4),
                          Text(
                            sport['name'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: widget.pageData.backgroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      {'icon': Icons.search_rounded, 'title': 'Tìm kiếm thông minh', 'desc': 'Lọc theo vị trí, giá'},
      {'icon': Icons.calendar_today_rounded, 'title': 'Đặt lịch linh hoạt', 'desc': 'Chọn giờ phù hợp'},
    ];

    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconAnimation.value,
          child: Opacity(
            opacity: _iconAnimation.value,
            child: Row(
              children: features.map((feature) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.grey200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.pageData.backgroundColor.withOpacity(0.3),
                                widget.pageData.backgroundColor.withOpacity(0.15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: widget.pageData.backgroundColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          feature['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          feature['desc'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamFeatures() {
    final features = [
      {'icon': Icons.group_add_rounded, 'title': 'Tìm đội nhanh chóng'},
      {'icon': Icons.chat_rounded, 'title': 'Chat nội bộ'},
      {'icon': Icons.emoji_events_rounded, 'title': 'Giải đấu'},
      {'icon': Icons.leaderboard_rounded, 'title': 'Xếp hạng'},
    ];

    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconAnimation.value,
          child: Opacity(
            opacity: _iconAnimation.value,
            child: Container(
              height: 100,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  final delay = index * 0.1;
                  final animationValue = (_iconAnimation.value - delay).clamp(0.0, 1.0);
                  
                  return Transform.scale(
                    scale: animationValue,
                    child: Container(
                      width: 80,
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.pageData.backgroundColor.withOpacity(0.1),
                            widget.pageData.backgroundColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.pageData.backgroundColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            feature['icon'] as IconData,
                            color: widget.pageData.backgroundColor,
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            feature['title'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: widget.pageData.backgroundColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardFeatures() {
    final rewards = [
      {'icon': Icons.local_offer, 'title': 'Voucher giảm giá', 'value': 'Đến 50%'},
      {'icon': Icons.star, 'title': 'Điểm thưởng', 'value': 'Tích lũy'},
      {'icon': Icons.card_membership, 'title': 'VIP', 'value': 'Ưu đãi đặc biệt'},
    ];

    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconAnimation.value,
          child: Opacity(
            opacity: _iconAnimation.value,
            child: Column(
              children: rewards.map((reward) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.pageData.backgroundColor.withOpacity(0.1),
                        widget.pageData.backgroundColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.pageData.backgroundColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.pageData.backgroundColor,
                              widget.pageData.backgroundColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          reward['icon'] as IconData,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey900,
                              ),
                            ),
                            Text(
                              reward['value'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.pageData.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  IconData _getSportIcon(int index) {
    final icons = [
      Icons.sports_soccer_rounded,
      Icons.sports_tennis_rounded,
      Icons.sports_basketball_rounded,
      Icons.sports_volleyball_rounded,
      Icons.pool_rounded,
      Icons.fitness_center_rounded,
    ];
    return icons[index % icons.length];
  }

  String _getSportPlayerImage(int index) {
    final images = [
      'assets/images/SportHub-Logo.png', // Temporary fallback
      'assets/images/SportHub-Logo.png', // Temporary fallback
      'assets/images/SportHub-Logo.png', // Temporary fallback
      'assets/images/SportHub-Logo.png', // Temporary fallback
      'assets/images/SportHub-Logo.png', // Temporary fallback
      'assets/images/SportHub-Logo.png', // Temporary fallback
    ];
    return images[index % images.length];
  }
}