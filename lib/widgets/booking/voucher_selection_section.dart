import 'package:flutter/material.dart';
import '../../models/user_voucher_model.dart';

class VoucherSelectionSection extends StatefulWidget {
  final bool isExpanded;
  final bool isVoucherApplied;
  final UserVoucher? selectedVoucher;
  final List<UserVoucher> userVouchers;
  final bool isLoadingVouchers;
  final String? voucherErrorMessage;
  final VoidCallback onToggleExpand;
  final VoidCallback onFetchVouchers;
  final Function(UserVoucher)? onVoucherSelected;
  final VoidCallback onApplyVoucher;
  final VoidCallback onRemoveVoucher;
  final String Function() getVoucherEligibilityMessage;
  final String Function(UserVoucher) calculateVoucherDiscount;
  final String Function(List<DateTime>) calculateTotalPrice;
  final List<DateTime> selectedTimeSlots;

  const VoucherSelectionSection({
    super.key,
    required this.isExpanded,
    required this.isVoucherApplied,
    required this.selectedVoucher,
    required this.userVouchers,
    required this.isLoadingVouchers,
    required this.voucherErrorMessage,
    required this.onToggleExpand,
    required this.onFetchVouchers,
    required this.onVoucherSelected,
    required this.onApplyVoucher,
    required this.onRemoveVoucher,
    required this.getVoucherEligibilityMessage,
    required this.calculateVoucherDiscount,
    required this.calculateTotalPrice,
    required this.selectedTimeSlots,
  });

  @override
  State<VoucherSelectionSection> createState() => _VoucherSelectionSectionState();
}

class _VoucherSelectionSectionState extends State<VoucherSelectionSection> {
  String _formatCurrency(int amount) {
    String amountStr = amount.toString();
    if (amountStr.length <= 3) return amountStr;

    String result = '';
    int count = 0;

    for (int i = amountStr.length - 1; i >= 0; i--) {
      result = amountStr[i] + result;
      count++;

      if (count % 3 == 0 && i != 0) {
        result = ',$result';
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7FD957),
                    const Color(0xFF6BC942),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Voucher giảm giá',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Selected voucher display or select button
                  GestureDetector(
                    onTap: widget.onToggleExpand,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.selectedVoucher != null
                            ? (widget.isVoucherApplied
                                ? const Color(0xFF7FD957)
                                    .withOpacity(0.1)
                                : Colors.orange
                                    .withOpacity(0.1))
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.selectedVoucher != null
                              ? (widget.isVoucherApplied
                                  ? const Color(0xFF7FD957)
                                  : Colors.orange)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.selectedVoucher != null
                                  ? (widget.isVoucherApplied
                                      ? const Color(0xFF7FD957)
                                      : Colors.orange)
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              widget.selectedVoucher != null
                                  ? Icons.confirmation_number_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectedVoucher != null
                                      ? widget.selectedVoucher!.voucher.code
                                      : 'Chọn hoặc nhập mã voucher',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: widget.selectedVoucher != null
                                        ? (widget.isVoucherApplied
                                            ? const Color(0xFF6BC942)
                                            : Colors.orange[700])
                                        : Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.selectedVoucher != null
                                      ? (widget.isVoucherApplied
                                          ? 'Voucher đã được áp dụng'
                                          : 'Chưa áp dụng - Nhấn để xem chi tiết')
                                      : widget.getVoucherEligibilityMessage(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow icon
                          Icon(
                            widget.isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey[600],
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Animated voucher list
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: widget.isExpanded
                        ? Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildVoucherSelectionSection(),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Remove voucher button (only shown when a voucher is applied)
                  if (widget.selectedVoucher != null && widget.isVoucherApplied)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onRemoveVoucher,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.red[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.red[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bỏ chọn voucher',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildVoucherSelectionSection() {
    if (widget.isLoadingVouchers) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Column(
          children: [
            Text(
              'Đang tải voucher...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.voucherErrorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              widget.voucherErrorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onFetchVouchers,
                child: const Text('Thử lại'),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.userVouchers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Bạn không có voucher nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy kiểm tra lại sau hoặc đổi voucher mới',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Filter vouchers based on minimum order value
    final originalPrice = widget.calculateTotalPrice(widget.selectedTimeSlots);
    final originalPriceInt = int.parse(originalPrice.replaceAll(',', ''));

    final eligibleVouchers = widget.userVouchers.where((voucher) {
      return originalPriceInt >= voucher.voucher.minOrderValue;
    }).toList();

    if (eligibleVouchers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            const Text(
              'Không có voucher nào đủ điều kiện',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tổng tiền đơn hàng của bạn là ${_formatCurrency(originalPriceInt)}đ, chưa đạt mức tối thiểu để áp dụng voucher',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const Text(
            'Chọn một voucher để áp dụng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: eligibleVouchers.length,
              itemBuilder: (context, index) {
                final voucher = eligibleVouchers[index];
                final isSelected =
                    widget.selectedVoucher?.voucher.id == voucher.voucher.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7FD957).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7FD957)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      '${voucher.voucher.discountText} giảm giá',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF7FD957)
                            : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Đơn tối thiểu ${voucher.voucher.minOrderText}đ',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF7FD957)
                            : Colors.grey[600],
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF7FD957),
                          )
                        : null,
                    onTap: () {
                      if (widget.onVoucherSelected != null) {
                        widget.onVoucherSelected!(voucher);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Apply voucher button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.selectedVoucher != null
                  ? widget.onApplyVoucher
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FD957),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}