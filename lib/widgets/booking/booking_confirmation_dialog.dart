import 'package:flutter/material.dart';
import '../../models/user_voucher_model.dart';
import '../custom_confirmation_dialog.dart'; // Added import

class BookingConfirmationDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final UserVoucher? selectedVoucher;
  final bool isVoucherApplied;

  const BookingConfirmationDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    required this.selectedVoucher,
    required this.isVoucherApplied,
  });

  @override
  Widget build(BuildContext context) {
    // Create additional content for voucher information if applicable
    Widget? voucherContent;
    if (selectedVoucher != null && isVoucherApplied) {
      voucherContent = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF7FD957).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_offer,
              color: Color(0xFF7FD957),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Voucher áp dụng: ${selectedVoucher!.voucher.code}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7FD957),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CustomConfirmationDialog(
      title: 'Xác nhận đặt sân',
      message: 'Bạn có chắc chắn muốn đặt sân với các thông tin đã chọn không?',
      onConfirm: onConfirm,
      onCancel: onCancel,
      icon: Icons.sports_soccer,
      iconColor: const Color(0xFF7FD957),
      additionalContent: voucherContent,
    );
  }
}