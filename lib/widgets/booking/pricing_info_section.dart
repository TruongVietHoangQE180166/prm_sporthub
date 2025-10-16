import 'package:flutter/material.dart';
import '../../models/user_voucher_model.dart';

class PricingInfoSection extends StatelessWidget {
  final int pricePerHour;
  final List<DateTime> selectedTimeSlots;
  final UserVoucher? selectedVoucher;
  final bool isVoucherApplied;
  final String Function(int) formatCurrency;
  final String Function(List<DateTime>) calculateTotalPrice;
  final String Function(UserVoucher) calculateVoucherDiscount;
  final String Function() calculateTotalPriceWithVoucher;

  const PricingInfoSection({
    super.key,
    required this.pricePerHour,
    required this.selectedTimeSlots,
    required this.selectedVoucher,
    required this.isVoucherApplied,
    required this.formatCurrency,
    required this.calculateTotalPrice,
    required this.calculateVoucherDiscount,
    required this.calculateTotalPriceWithVoucher,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Price per hour
          _buildPricingRow(
            label: 'Đơn giá',
            value: '${formatCurrency(pricePerHour)}đ/giờ',
            isEmphasized: false,
          ),
          const SizedBox(height: 12),
          // Total duration
          _buildPricingRow(
            label: 'Tổng thời lượng',
            value: '${_calculateTotalHours(selectedTimeSlots)} giờ',
            isEmphasized: false,
          ),
          const SizedBox(height: 12),
          // Voucher discount (only shown if a voucher is applied)
          if (selectedVoucher != null && isVoucherApplied)
            _buildPricingRow(
              label: 'Giảm giá',
              value: '-${calculateVoucherDiscount(selectedVoucher!)}đ',
              isEmphasized: false,
            ),
          // Voucher info (only shown if a voucher is applied)
          if (selectedVoucher != null && isVoucherApplied)
            _buildVoucherInfoRow(),
          const Divider(height: 24, thickness: 1, color: Colors.grey),
          // Total price (emphasized)
          _buildPricingRow(
            label: 'Tổng tiền',
            value: '${calculateTotalPriceWithVoucher()}đ',
            isEmphasized: true,
          ),
        ],
      ),
    );
  }

  int _calculateTotalHours(List<DateTime> timeSlots) {
    return timeSlots.length;
  }

  // Build a pricing row with optional emphasis
  Widget _buildPricingRow({
    required String label,
    required String value,
    required bool isEmphasized,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isEmphasized ? 16 : 14,
              fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w500,
              color: isEmphasized ? Colors.black87 : Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isEmphasized ? 20 : 16,
            fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w600,
            color: isEmphasized ? const Color(0xFF7FD957) : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Build voucher info row
  Widget _buildVoucherInfoRow() {
    if (selectedVoucher == null || !isVoucherApplied) return const SizedBox.shrink();

    final originalPrice = calculateTotalPrice(selectedTimeSlots);
    final originalPriceInt = int.parse(originalPrice.replaceAll(',', ''));
    final minOrderValue = selectedVoucher!.voucher.minOrderValue.toInt();

    // Check if the order meets the minimum requirement
    final isEligible = originalPriceInt >= minOrderValue;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isEligible ? Icons.check_circle : Icons.error,
            size: 16,
            color: isEligible ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEligible
                  ? 'Đơn hàng đủ điều kiện áp dụng voucher'
                  : 'Đơn hàng cần tối thiểu ${formatCurrency(minOrderValue)}đ để áp dụng voucher',
              style: TextStyle(
                fontSize: 12,
                color: isEligible ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}