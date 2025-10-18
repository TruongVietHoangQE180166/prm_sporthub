import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/payment_model.dart';
import '../../view_models/order_status_view_model.dart';
import '../custom_confirmation_dialog.dart';
import '../../views/main/main_screen.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentModel payment;
  final VoidCallback onPaymentCompleted;
  final VoidCallback onBack;

  const PaymentScreen({
    super.key,
    required this.payment,
    required this.onPaymentCompleted,
    required this.onBack,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  late OrderStatusViewModel _orderStatusViewModel;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _timer;
  bool _paymentCompleted = false;
  bool _paymentCancelled = false;
  String _currentStatus = 'PENDING';

  @override
  void initState() {
    super.initState();
    _orderStatusViewModel = OrderStatusViewModel();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_paymentCompleted && !_paymentCancelled) {
        final success = await _orderStatusViewModel.checkOrderStatus(widget.payment.ordersId);
        if (success && _orderStatusViewModel.orderStatus != null) {
          final status = _orderStatusViewModel.orderStatus!.status;
          setState(() {
            _currentStatus = status;
          });
          
          if (status == 'COMPLETED') {
            setState(() {
              _paymentCompleted = true;
            });
            _animationController.forward();
            timer.cancel();
            widget.onPaymentCompleted();
          }
        }
      }
    });
  }

  void _cancelPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          title: 'Xác nhận hủy',
          message: 'Bạn có chắc chắn muốn hủy thanh toán? Thao tác này không thể hoàn tác.',
          confirmButtonText: 'Hủy thanh toán',
          cancelButtonText: 'Quay lại',
          onConfirm: () {
            Navigator.of(context).pop();
            setState(() {
              _paymentCancelled = true;
              _timer?.cancel();
            });
            _animationController.forward();
          },
          onCancel: () => Navigator.of(context).pop(),
          icon: Icons.warning_rounded,
          iconColor: Colors.red,
          confirmButtonColor: Colors.red,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _paymentCompleted || _paymentCancelled,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header - Only show when payment is pending
                      if (!_paymentCompleted && !_paymentCancelled)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 48,
                                color: Color(0xFF7FD957),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Quét mã QR để thanh toán',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mã đơn hàng: ${widget.payment.ordersId}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Only show QR code and instructions when payment is pending
                            if (!_paymentCompleted && !_paymentCancelled) ...[
                              // QR Code Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // QR Code with border and shadow
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: widget.payment.qrCode.isNotEmpty
                                          ? Image.network(
                                              widget.payment.qrCode,
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.contain,
                                            )
                                          : Icon(
                                              Icons.qr_code_rounded,
                                              size: 200,
                                              color: Colors.grey[300],
                                            ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Amount Display
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7FD957).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.payments_rounded,
                                            color: Color(0xFF7FD957),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_formatCurrency(widget.payment.amount.toInt())}đ',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF7FD957),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Instructions Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7FD957).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.info_rounded,
                                            color: Color(0xFF7FD957),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Hướng dẫn thanh toán',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInstructionStep(
                                      '1',
                                      'Mở ứng dụng ngân hàng của bạn',
                                    ),
                                    _buildInstructionStep(
                                      '2',
                                      'Chọn chức năng quét mã QR',
                                    ),
                                    _buildInstructionStep(
                                      '3',
                                      'Quét mã QR bên trên',
                                    ),
                                    _buildInstructionStep(
                                      '4',
                                      'Xác nhận thanh toán',
                                      isLast: true,
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                            ],
                            
                            // Status Display
                            if (_paymentCompleted)
                              _buildSuccessStatus()
                            else if (_paymentCancelled)
                              _buildCancelledStatus()
                            else if (_currentStatus == 'PENDING')
                              _buildPendingStatus(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action Button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF7FD957),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF3CD),
            const Color(0xFFFFF3CD).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFEAA7),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF856404)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang chờ thanh toán',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Vui lòng quét mã QR để hoàn tất',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF856404),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStatus() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD4EDDA),
              const Color(0xFFD4EDDA).withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFC3E6CB),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF155724).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF155724),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thanh toán thành công!',
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF155724),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Đơn hàng của bạn đã được xác nhận',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF155724),
              ),
            ),
            const SizedBox(height: 20),
            // Additional details for success status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mã đơn hàng:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF155724),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.payment.ordersId,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF155724),
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Số tiền:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF155724),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_formatCurrency(widget.payment.amount.toInt())}đ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF155724),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thời gian:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF155724),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateTime.now().toString().substring(0, 19),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF155724),
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildCancelledStatus() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF8D7DA),
              const Color(0xFFF8D7DA).withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFF5C6CB),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF721C24).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.cancel_rounded,
                color: Color(0xFF721C24),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thanh toán đã bị hủy!',
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF721C24),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Giao dịch đã được hủy bỏ',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF721C24),
              ),
            ),
            const SizedBox(height: 20),
            // Additional details for cancelled status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mã đơn hàng:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF721C24),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.payment.ordersId,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF721C24),
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Số tiền:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF721C24),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_formatCurrency(widget.payment.amount.toInt())}đ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF721C24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trạng thái:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF721C24),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Đã hủy',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF721C24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn có thể thực hiện đặt sân lại nếu cần',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF721C24),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_paymentCompleted || _paymentCancelled) 
                ? () {
                    // Navigate to Home Screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  }
                : _cancelPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: (_paymentCompleted || _paymentCancelled)
                  ? (_paymentCompleted ? const Color(0xFF7FD957) : Colors.red)
                  : Colors.red,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  (_paymentCompleted || _paymentCancelled)
                      ? Icons.home_rounded
                      : Icons.cancel_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  (_paymentCompleted || _paymentCancelled)
                      ? 'Về trang chủ'
                      : 'Hủy thanh toán',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}