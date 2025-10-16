import 'package:flutter/material.dart';
import '../../models/voucher_model.dart';
import 'voucher_card.dart';

class AllVouchersView extends StatelessWidget {
  final List<VoucherTemplate> voucherTemplates;
  final int currentPoints;
  final Function(VoucherTemplate) onExchange;

  const AllVouchersView({
    super.key,
    required this.voucherTemplates,
    required this.currentPoints,
    required this.onExchange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: voucherTemplates.length,
        itemBuilder: (context, index) {
          final voucher = voucherTemplates[index];
          return VoucherCard(
            voucher: voucher,
            currentPoints: currentPoints,
            onExchange: () => onExchange(voucher),
          );
        },
      ),
    );
  }
}