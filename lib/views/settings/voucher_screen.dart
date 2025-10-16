import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/voucher_model.dart';
import '../../models/user_voucher_model.dart';
import '../../view_models/voucher_view_model.dart';
import '../../view_models/profile_view_model.dart';
import '../../widgets/voucher/points_card_header.dart';
import '../../widgets/voucher/voucher_tabs.dart';
import '../../widgets/voucher/all_vouchers_view.dart';
import '../../widgets/voucher/my_vouchers_view.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  bool showMyVouchers = false;
  int _userPoints = 0;
  bool _isLoading = true;

  static final List<VoucherTemplate> voucherTemplates = [
    VoucherTemplate(
      discountValue: 50000,
      minOrderValue: 200000,
      image: "",
      exchangePoint: 100,
      active: true,
      percentage: false,
    ),
    VoucherTemplate(
      discountValue: 10,
      minOrderValue: 100000,
      image: "",
      exchangePoint: 50,
      active: true,
      percentage: true,
    ),
    VoucherTemplate(
      discountValue: 100000,
      minOrderValue: 500000,
      image: "",
      exchangePoint: 200,
      active: true,
      percentage: false,
    ),
    VoucherTemplate(
      discountValue: 15,
      minOrderValue: 250000,
      image: "",
      exchangePoint: 120,
      active: true,
      percentage: true,
    ),
    VoucherTemplate(
      discountValue: 70000,
      minOrderValue: 350000,
      image: "",
      exchangePoint: 100,
      active: true,
      percentage: false,
    ),
    VoucherTemplate(
      discountValue: 30,
      minOrderValue: 500000,
      image: "",
      exchangePoint: 180,
      active: true,
      percentage: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  void _loadUserPoints() {
    // Load user points from the profile view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = context.read<ProfileViewModel>();
      profileViewModel.getUserPoint().then((result) {
        if (result != null && result['success'] == true) {
          setState(() {
            _userPoints = result['data'] as int? ?? 0;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
  }

  void _handleExchange(VoucherTemplate voucher, BuildContext context) async {
    final viewModel = context.read<VoucherViewModel>();
    
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
                ),
              ),
            ),
          );
        },
      );
    }

    final result = await viewModel.exchangeVoucher(voucher);
    
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // Show result
    if (context.mounted) {
      if (result['success'] == true) {
        // Refresh points
        _loadUserPoints();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ?? 'Đổi voucher thành công'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ?? 'Đổi voucher thất bại'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoucherViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        // Remove default AppBar and use custom header
        appBar: null, // Hide default app bar
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
                ),
              )
            : SafeArea( // Add SafeArea to handle notches and cutouts properly
                child: Column(
                  children: [
                    // Custom header with enhanced design (matching order_screen header)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF7FD957),
                            const Color(0xFF7FD957).withOpacity(0.85),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7FD957).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white, size: 20),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kho Voucher',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Quản lý voucher của bạn',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Points Card Header - now using actual user points
                    PointsCardHeader(currentPoints: _userPoints),
                    
                    // Toggle Tabs
                    VoucherTabs(
                      showMyVouchers: showMyVouchers,
                      onTabChanged: (value) => setState(() => showMyVouchers = value),
                    ),

                    // Content
                    Expanded(
                      child: showMyVouchers
                          ? const MyVouchersView()
                          : AllVouchersView(
                              voucherTemplates: voucherTemplates,
                              currentPoints: _userPoints,
                              onExchange: (voucher) => _handleExchange(voucher, context),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class VoucherCard extends StatelessWidget {
  final VoucherTemplate voucher;
  final int currentPoints;
  final VoidCallback onExchange;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.currentPoints,
    required this.onExchange,
  });

  @override
  Widget build(BuildContext context) {
    final canExchange = currentPoints >= voucher.exchangePoint;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: canExchange
              ? const Color(0xFF7FD957).withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative background pattern
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF7FD957).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 40,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF7FD957).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Discount badge
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: canExchange 
                                ? [const Color(0xFF7FD957), const Color(0xFF5FB939)]
                                : [Colors.grey[400]!, Colors.grey[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: canExchange 
                                  ? const Color(0xFF7FD957).withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          voucher.percentage ? Icons.percent : Icons.local_offer,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7FD957), Color(0xFF5FB939)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7FD957).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Text(
                            voucher.discountText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Description with icon
                  Row(
                    children: [
                      Icon(
                        Icons.discount_outlined,
                        size: 16,
                        color: canExchange ? const Color(0xFF7FD957) : Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Giảm giá đơn hàng',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: canExchange ? Colors.grey[800] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 14,
                        color: canExchange ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tối thiểu ${voucher.minOrderText}đ',
                        style: TextStyle(
                          fontSize: 11,
                          color: canExchange ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.grey[300]!,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Points required
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: canExchange 
                          ? const Color(0xFF7FD957).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.amber, Color(0xFFFFB300)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.stars_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${voucher.exchangePoint}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: canExchange
                                ? const Color(0xFF2D3436)
                                : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'điểm',
                          style: TextStyle(
                            fontSize: 12,
                            color: canExchange ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Exchange button
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: canExchange ? onExchange : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7FD957),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: canExchange ? 4 : 0,
                        shadowColor: const Color(0xFF7FD957).withOpacity(0.4),
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            canExchange ? Icons.check_circle : Icons.lock_outline,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            canExchange ? 'Đổi ngay' : 'Chưa đủ điểm',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserVoucherCard extends StatelessWidget {
  final UserVoucher userVoucher;

  const UserVoucherCard({super.key, required this.userVoucher});

  @override
  Widget build(BuildContext context) {
    final voucher = userVoucher.voucher;
    final isUsed = userVoucher.used;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isUsed ? Colors.grey[300]! : const Color(0xFF7FD957),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUsed ? Colors.grey[300] : const Color(0xFF7FD957),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isUsed ? 'Đã sử dụng' : 'Có thể sử dụng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '#${voucher.code}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Discount information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUsed 
                            ? [Colors.grey[300]!, Colors.grey[400]!]
                            : [const Color(0xFF7FD957), const Color(0xFF5FB939)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isUsed 
                              ? Colors.grey.withOpacity(0.3)
                              : const Color(0xFF7FD957).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          voucher.discountText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Giảm giá',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Voucher details
                  _buildDetailRow(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Đơn tối thiểu',
                    value: '${voucher.minOrderText}đ',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày tạo',
                    value: '${voucher.createdDate.day}/${voucher.createdDate.month}/${voucher.createdDate.year}',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    icon: Icons.stars_outlined,
                    label: 'Điểm quy đổi',
                    value: '${voucher.exchangePoint} điểm',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7FD957)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }
}