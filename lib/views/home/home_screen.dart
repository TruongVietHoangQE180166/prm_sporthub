import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:provider/provider.dart';
import '../../view_models/field_view_model.dart';
import '../../view_models/profile_view_model.dart';
import '../../models/field_model.dart';
import '../explore/explore_screen.dart';
import '../field/field_detail_screen.dart';
import '../find_team/find_team_screen.dart';
import '../settings/order_screen.dart';
import '../settings/voucher_screen.dart';
import '../main/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _promoController = PageController();
  int _currentPromoPage = 0;
  Timer? _timer;

  Color _getContrastColor(Color backgroundColor) {
    if (backgroundColor == Colors.black) {
      return const Color(0xFF7FD957);
    } else if (backgroundColor == const Color(0xFF7FD957)) {
      return Colors.black;
    } else if (backgroundColor == Colors.white) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Start auto-scrolling timer
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_mockPromos.isNotEmpty && _promoController.hasClients) {
        int nextPage = (_currentPromoPage + 1) % _mockPromos.length;
        _promoController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
    
    // Load profile data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final profileViewModel = context.read<ProfileViewModel>();
        if (profileViewModel.profile == null) {
          await profileViewModel.fetchProfile();
        }
      } catch (e) {
        print('HomeScreen - Error loading profile: $e');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FieldViewModel()..fetchAllFields()),
      ],
      child: Consumer<FieldViewModel>(
        builder: (context, fieldViewModel, child) {
          final List<FieldModel> displayFields = fieldViewModel.fields.length > 4 
              ? fieldViewModel.fields.sublist(0, 4) 
              : fieldViewModel.fields;
          
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: fieldViewModel.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              color: const Color(0xFF7FD957),
                              strokeWidth: 3.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Đang tải dữ liệu...',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade600,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : fieldViewModel.errorMessage != null
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(32),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.red.shade900.withOpacity(0.1) : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.red.shade700 : Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  fieldViewModel.errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    fieldViewModel.fetchAllFields();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Thử lại'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7FD957),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(child: _buildAppBar()),
                            SliverToBoxAdapter(child: _buildSearchSection()),
                            SliverToBoxAdapter(child: _buildCategorySection()),
                            SliverToBoxAdapter(child: _buildPromoCarousel()),
                            SliverToBoxAdapter(child: _buildQuickActions()),
                            SliverToBoxAdapter(child: _buildSectionHeader('Sân gần bạn')),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildFieldCardFromModel(displayFields[index]),
                                  childCount: displayFields.length,
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
            bottomNavigationBar: null,
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'app_logo',
            child: Image.asset(
              'assets/images/SportHub-Logo.png',
              height: 38,
            ),
          ),
          const Spacer(),
          
          Builder(
            builder: (context) {
              final profileViewModel = context.watch<ProfileViewModel>();
              final profile = profileViewModel.profile;
              
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: profile?.avatar != null && profile!.avatar!.isNotEmpty
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF7FD957), Color(0xFF5FB839)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7FD957).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: profile?.avatar != null && profile!.avatar!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          profile.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF7FD957), Color(0xFF5FB839)],
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 22,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 22,
                        color: Colors.white,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sân thể thao...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade400,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.6) ?? Colors.grey.shade400,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7FD957), Color(0xFF5FB839)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7FD957).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade900),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockCategories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(_mockCategories[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int index) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to explore screen with selected category
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExploreScreen(),
                  settings: RouteSettings(arguments: category['name'] as String),
                ),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: Theme.of(context).brightness == Brightness.dark
                          ? [
                              Colors.grey.shade700,
                              Colors.grey.shade600,
                            ]
                          : [
                              Colors.grey.shade100,
                              Colors.grey.shade200,
                            ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.shade300.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.grey.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCarousel() {
    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _promoController,
            onPageChanged: (index) {
              setState(() => _currentPromoPage = index);
              _timer?.cancel();
              _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
                if (_mockPromos.isNotEmpty && _promoController.hasClients) {
                  int nextPage = (_currentPromoPage + 1) % _mockPromos.length;
                  _promoController.animateToPage(
                    nextPage,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOutCubic,
                  );
                }
              });
            },
            itemCount: _mockPromos.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _promoController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_promoController.position.haveDimensions) {
                    value = _promoController.page! - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _buildPromoCard(_mockPromos[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _mockPromos.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _currentPromoPage == index ? 28 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: _currentPromoPage == index
                    ? const LinearGradient(
                        colors: [Color(0xFF7FD957), Color(0xFF5FB839)],
                      )
                    : null,
                color: _currentPromoPage == index
                  ? null
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade600
                      : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Image.network(
              promo['image'] as String? ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7FD957), Color(0xFF5FB839)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      promo['badge'] as String,
                      style: const TextStyle(
                        color: Color(0xFF7FD957),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    promo['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    promo['subtitle'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildActionPill('Đặt sân ngay', Icons.calendar_today_rounded, 0)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionPill('Tạo đội', Icons.group_add_rounded, 1)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionPill('Lịch sử đặt', Icons.receipt_long_rounded, 2)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionPill('Ưu đãi', Icons.card_giftcard_rounded, 3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill(String label, IconData icon, int index) {
    final colors = [
      {'bg': const Color(0xFF7FD957), 'text': Colors.white},
      {'bg': Colors.grey.shade700, 'text': Colors.white},
      {'bg': Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade700
          : Colors.grey.shade800, 'text': Colors.white},
      {'bg': Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade600
          : Colors.grey.shade400,
       'text': Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.grey.shade900},
    ];
    
    final color = colors[index];
    final isWhiteBg = color['bg'] == Colors.white ||
                     (Theme.of(context).brightness == Brightness.dark && index == 3);
    
    // Define navigation destinations for each action
    void Function()? onTap;
    switch (index) {
      case 0: // Đặt sân ngay - Navigate to ExploreScreen
        onTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExploreScreen(),
            ),
          );
        };
        break;
      case 1: // Tạo đội - Navigate to MainScreen with FindTeam tab
        onTap = () {
          // Navigate to MainScreen and set the correct tab index
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(initialTabIndex: 1),
            ),
          );
        };
        break;
      case 2: // Lịch sử đặt - Navigate to OrderScreen
        onTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OrderScreen(),
            ),
          );
        };
        break;
      case 3: // Ưu đãi - Navigate to VoucherScreen
        onTap = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VoucherScreen(),
            ),
          );
        };
        break;
      default:
        onTap = null;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: color['bg'] as Color,
        borderRadius: BorderRadius.circular(16),
        border: isWhiteBg
            ? Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade200, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: (color['bg'] as Color).withOpacity(isWhiteBg ? 0.05 : 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color['text'] as Color,
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color['text'] as Color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade900),
              letterSpacing: -0.5,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to explore screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExploreScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: const Color(0xFF7FD957),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: const Color(0xFF7FD957),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCardFromModel(FieldModel field) {
    String? imageUrl;
    if (field.images.isNotEmpty) {
      imageUrl = field.images.first;
    } else {
      imageUrl = field.avatar;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to field detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FieldDetailScreen(field: field),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'field_${field.fieldName}',
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7FD957), Color(0xFF5FB839)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7FD957).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.sports_soccer_rounded,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.sports_soccer_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.fieldName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade900),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFC107),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  field.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF57C00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade500),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              field.location,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade600),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade500),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${field.openTime} - ${field.closeTime}',
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade600),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${(field.normalPricePerHour ~/ 1000)}K',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF7FD957),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: '/giờ',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7FD957),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7FD957), Color(0xFF5FB839)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7FD957).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Đặt sân',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for field pattern background
class _FieldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final spacing = 30.0;
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.3),
      40,
      paint,
    );
    
    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, 0), radius: 50),
      0,
      math.pi / 2,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Mock Data
final List<Map<String, dynamic>> _mockCategories = [
  {'name': 'Tất cả', 'icon': Icons.apps_rounded},
  {'name': 'Bóng Đá', 'icon': Icons.sports_soccer_rounded},
  {'name': 'Cầu Lông', 'icon': Icons.sports_tennis_rounded},
  {'name': 'Pickleball', 'icon': Icons.sports_cricket_rounded},
  {'name': 'Bóng Rổ', 'icon': Icons.sports_basketball_rounded},
  {'name': 'Bóng Chuyền', 'icon': Icons.sports_volleyball_rounded},
  {'name': 'Bơi Lội', 'icon': Icons.pool_rounded},
  {'name': 'Tennis', 'icon': Icons.sports_tennis_rounded},
  {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
];

final List<Map<String, dynamic>> _mockPromos = [
  {
    'badge': 'ƯU ĐÃI MỚI',
    'title': 'Giảm 50% cho lần đặt sân đầu tiên',
    'subtitle': 'Áp dụng cho tất cả các sân thể thao',
    'image': 'https://images.pexels.com/photos/46798/the-ball-stadion-football-the-pitch-46798.jpeg?_gl=1*197jvac*_ga*MTM4MjA3NDU0OS4xNzUxMjg5Mzg3*_ga_8JE65Q40S6*czE3NTEyODkzODYkbzEkZzEkdDE3NTEyODkzOTkkajQ3JGwwJGgw',
  },
  {
    'badge': 'ƯU ĐÃI CUỐI TUẦN',
    'title': 'Đặt 3 giờ, tặng 1 giờ',
    'subtitle': 'Chỉ áp dụng thứ Bảy & Chủ nhật',
    'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop&crop=center',
  },
  {
    'badge': 'GIẢM GIÁ THEO NHÓM',
    'title': 'Đặt sân theo nhóm giảm 30%',
    'subtitle': 'Cho nhóm từ 8 người trở lên',
    'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=600&fit=crop&crop=center',
  },
  {
    'badge': 'ƯU ĐÃI ĐẶC BIỆT',
    'title': 'Miễn phí đặt sân VIP',
    'subtitle': 'Áp dụng cho tất cả sân',
    'image': 'https://images.pexels.com/photos/209977/pexels-photo-209977.jpeg?_gl=1*t142ag*_ga*MTM4MjA3NDU0OS4xNzUxMjg5Mzg3*_ga_8JE65Q40S6*czE3NTEyODkzODYkbzEkZzEkdDE3NTEyODk0OTMkajU1JGwwJGgw',
  },
];