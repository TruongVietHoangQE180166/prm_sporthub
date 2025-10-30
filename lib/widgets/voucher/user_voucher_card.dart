import 'package:flutter/material.dart';
import '../../models/user_voucher_model.dart';

class UserVoucherCard extends StatelessWidget {
  final UserVoucher userVoucher;
  final VoidCallback? onUseVoucher; // Added callback for using the voucher

  const UserVoucherCard({super.key, required this.userVoucher, this.onUseVoucher});

  @override
  Widget build(BuildContext context) {
    final voucher = userVoucher.voucher;
    final isUsed = userVoucher.used;
    final isActive = voucher.active;
    final canUseVoucher = !isUsed && isActive;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: canUseVoucher
              ? const Color(0xFF7FD957)
              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[300]!),
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
                  color: canUseVoucher ? const Color(0xFF7FD957).withOpacity(0.05) : Colors.grey.withOpacity(0.05),
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
                  color: canUseVoucher ? const Color(0xFF7FD957).withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content (removed SingleChildScrollView to match VoucherCard behavior)
            Padding(
              padding: const EdgeInsets.all(14.0), // Reverted to original padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Discount badge
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isUsed || !isActive
                                ? [Colors.grey[400]!, Colors.grey[500]!]
                                : [const Color(0xFF7FD957), const Color(0xFF5FB939)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: isUsed || !isActive
                                  ? Colors.black.withOpacity(0.1)
                                  : const Color(0xFF7FD957).withOpacity(0.3),
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
                            gradient: LinearGradient(
                              colors: isUsed || !isActive
                                  ? [Colors.grey[300]!, Colors.grey[400]!]
                                  : [const Color(0xFF7FD957), const Color(0xFF5FB939)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: isUsed || !isActive
                                    ? Colors.black.withOpacity(0.1)
                                    : const Color(0xFF7FD957).withOpacity(0.3),
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
                  const SizedBox(height: 12), // Reduced from 14 to 12

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: canUseVoucher
                          ? const Color(0xFF7FD957).withOpacity(0.15)
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isUsed 
                          ? 'Đã dùng' 
                          : (isActive 
                              ? 'Có thể dùng'
                              : 'Không hoạt động'),
                      style: TextStyle(
                        color: canUseVoucher ? const Color(0xFF5FB939) : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // Reduced from 10 to 8

                  // Voucher code with icon
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 16,
                        color: isUsed || !isActive ? Colors.grey[500] : const Color(0xFF7FD957),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        voucher.code,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isUsed || !isActive
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700])
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[800]),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Reduced from 6 to 4

                  // Min order
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 14,
                        color: isUsed || !isActive ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tối thiểu ${voucher.minOrderText}đ',
                        style: TextStyle(
                          fontSize: 11,
                          color: isUsed || !isActive
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey[400])
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Reduced from 6 to 4

                  // Exchange points
                  Row(
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 14,
                        color: isUsed || !isActive ? Colors.grey[400] : const Color(0xFF7FD957),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Điểm đổi: ${voucher.exchangePoint}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isUsed || !isActive
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey[400])
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Reduced from 6 to 4

                  // Created date
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isUsed || !isActive ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ngày tạo: ${voucher.createdDate.day}/${voucher.createdDate.month}/${voucher.createdDate.year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isUsed || !isActive
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey[400])
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 8), // Reduced from 10 to 8
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[300]!,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Use voucher button (similar to exchange button in voucher_card)
                  SizedBox(
                    width: double.infinity,
                    height: 36, // Reduced from 38 to 36
                    child: ElevatedButton(
                      onPressed: canUseVoucher ? (onUseVoucher ?? () {}) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canUseVoucher
                            ? const Color(0xFF7FD957)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300]),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300],
                        disabledForegroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: canUseVoucher ? 4 : 0,
                        shadowColor: const Color(0xFF7FD957).withOpacity(0.4),
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isUsed 
                                ? Icons.check_circle 
                                : (canUseVoucher ? Icons.check_circle : Icons.lock_outline),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isUsed 
                                ? 'Đã sử dụng' 
                                : (canUseVoucher ? 'Sử dụng ngay' : 'Không hoạt động'),
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
  }}