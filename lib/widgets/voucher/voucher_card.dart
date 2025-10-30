import 'package:flutter/material.dart';
import '../../models/voucher_model.dart';

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
          color: canExchange
              ? const Color(0xFF7FD957).withOpacity(0.3)
              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[200]!),
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
                          color: canExchange
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[800])
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500]),
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
                        color: canExchange
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[600])
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey[400]),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tối thiểu ${voucher.minOrderText}đ',
                        style: TextStyle(
                          fontSize: 11,
                          color: canExchange
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[600])
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey[400]),
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
                          Theme.of(context).brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey[300]!,
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
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100]),
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
                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2D3436))
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500]),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'điểm',
                          style: TextStyle(
                            fontSize: 12,
                            color: canExchange
                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[600])
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey[400]),
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
                        disabledBackgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300],
                        disabledForegroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500],
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