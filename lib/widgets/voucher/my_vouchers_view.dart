import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/voucher_view_model.dart';
import 'user_voucher_card.dart';

class MyVouchersView extends StatefulWidget {
  const MyVouchersView({super.key});

  @override
  State<MyVouchersView> createState() => _MyVouchersViewState();
}

class _MyVouchersViewState extends State<MyVouchersView> {
  bool _isInitialized = false;
  String? _lastErrorMessage;

  @override
  Widget build(BuildContext context) {
    return Consumer<VoucherViewModel>(
      builder: (context, viewModel, child) {
        // Initialize the view model when this tab is first accessed
        if (!_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.initialize().then((_) {
              // Show any error message that occurred during initialization
              if (viewModel.errorMessage != null && 
                  viewModel.errorMessage != _lastErrorMessage) {
                _lastErrorMessage = viewModel.errorMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage!),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            });
            setState(() {
              _isInitialized = true;
            });
          });
        }

        // Show error messages using SnackBar
        if (viewModel.errorMessage != null && 
            viewModel.errorMessage != _lastErrorMessage) {
          _lastErrorMessage = viewModel.errorMessage;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          });
        }

        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
            ),
          );
        }

        if (viewModel.userVouchers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có voucher nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đổi voucher để nhận ưu đãi ngay!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Display user vouchers in grid
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7, // Tỷ lệ card cao hơn để chứa nội dung
            ),
            itemCount: viewModel.userVouchers.length,
            itemBuilder: (context, index) {
              final userVoucher = viewModel.userVouchers[index];
              return UserVoucherCard(userVoucher: userVoucher);
            },
          ),
        );
      },
    );
  }
}