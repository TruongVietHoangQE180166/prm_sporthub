import 'package:flutter/material.dart';
import '../../models/field_model.dart';
import '../../models/user_voucher_model.dart';
import '../../view_models/voucher_view_model.dart';
import '../../view_models/booking_view_model.dart';
import '../../view_models/payment_view_model.dart';
import '../../widgets/booking/booking_header.dart';
import '../../widgets/booking/field_info_card.dart';
import '../../widgets/booking/voucher_selection_section.dart';
import '../../widgets/booking/booking_details_section.dart';
import '../../widgets/booking/pricing_info_section.dart';
import '../../widgets/booking/booking_confirmation_button.dart';
import '../../widgets/booking/booking_confirmation_dialog.dart';
import '../../widgets/booking/payment_screen.dart';

class VerifyBookingScreen extends StatefulWidget {
  final FieldModel field;
  final String selectedSmallFieldId;
  final List<DateTime> selectedTimeSlots;

  const VerifyBookingScreen({
    super.key,
    required this.field,
    required this.selectedSmallFieldId,
    required this.selectedTimeSlots,
  });

  @override
  State<VerifyBookingScreen> createState() => _VerifyBookingScreenState();
}

class _VerifyBookingScreenState extends State<VerifyBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late SmallFieldResponse _selectedSmallField;
  UserVoucher? _selectedVoucher;
  bool _voucherSectionExpanded = false;
  bool _isVoucherApplied = false;
  List<UserVoucher> _userVouchers = [];
  bool _isLoadingVouchers = false;
  String? _voucherErrorMessage;

  @override
  void initState() {
    super.initState();
    // Find the selected small field
    _selectedSmallField = widget.field.smallFieldResponses.firstWhere(
      (field) => field.id == widget.selectedSmallFieldId,
      orElse: () => SmallFieldResponse(
        id: '',
        createdDate: '',
        smallFiledName: 'Unknown Field',
        description: '',
        capacity: '',
        booked: false,
        available: true,
      ),
    );
  }

  // Group time slots by date
  Map<DateTime, List<DateTime>> _groupTimeSlotsByDate() {
    final Map<DateTime, List<DateTime>> groupedSlots = {};

    for (final slot in widget.selectedTimeSlots) {
      final dateKey = DateTime(slot.year, slot.month, slot.day);

      if (groupedSlots.containsKey(dateKey)) {
        groupedSlots[dateKey]!.add(slot);
      } else {
        groupedSlots[dateKey] = [slot];
      }
    }

    // Sort time slots within each date
    groupedSlots.forEach((date, slots) {
      slots.sort((a, b) => a.compareTo(b));
    });

    return groupedSlots;
  }

  String _formatDateTime(DateTime dateTime) {
    final dayNames = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];
    final monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];

    return '${dayNames[dateTime.weekday - 1]}, ngày ${dateTime.day} ${monthNames[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatTimeRange(List<DateTime> timeSlots) {
    if (timeSlots.isEmpty) return '';

    // Sort time slots
    timeSlots.sort((a, b) => a.compareTo(b));

    // Group consecutive hours
    final List<String> timeRanges = [];
    List<DateTime> currentGroup = [];

    for (int i = 0; i < timeSlots.length; i++) {
      final currentSlot = timeSlots[i];

      if (currentGroup.isEmpty) {
        // Start a new group
        currentGroup.add(currentSlot);
      } else {
        final lastSlot = currentGroup.last;

        // Check if current slot is consecutive to the last slot in the group
        if (currentSlot.difference(lastSlot).inHours == 1) {
          // Consecutive hour, add to current group
          currentGroup.add(currentSlot);
        } else {
          // Not consecutive, finalize current group and start a new one
          if (currentGroup.length == 1) {
            // Single slot
            timeRanges.add(
                '${currentGroup.first.hour.toString().padLeft(2, '0')}:${currentGroup.first.minute.toString().padLeft(2, '0')}');
          } else {
            // Range of slots
            timeRanges.add(
                '${currentGroup.first.hour.toString().padLeft(2, '0')}:${currentGroup.first.minute.toString().padLeft(2, '0')} - ${currentGroup.last.add(const Duration(hours: 1)).hour.toString().padLeft(2, '0')}:${currentGroup.last.add(const Duration(hours: 1)).minute.toString().padLeft(2, '0')}');
          }

          // Start new group
          currentGroup = [currentSlot];
        }
      }
    }

    // Add the last group
    if (currentGroup.isNotEmpty) {
      if (currentGroup.length == 1) {
        // Single slot
        timeRanges.add(
            '${currentGroup.first.hour.toString().padLeft(2, '0')}:${currentGroup.first.minute.toString().padLeft(2, '0')}');
      } else {
        // Range of slots
        timeRanges.add(
            '${currentGroup.first.hour.toString().padLeft(2, '0')}:${currentGroup.first.minute.toString().padLeft(2, '0')} - ${currentGroup.last.add(const Duration(hours: 1)).hour.toString().padLeft(2, '0')}:${currentGroup.last.add(const Duration(hours: 1)).minute.toString().padLeft(2, '0')}');
      }
    }

    return timeRanges.join(', ');
  }

  int _calculateTotalHours(List<DateTime> timeSlots) {
    return timeSlots.length;
  }

  String _calculateTotalPrice(List<DateTime> timeSlots) {
    final pricePerHour = widget.field.normalPricePerHour.toInt();
    final totalPrice = pricePerHour * timeSlots.length;
    return _formatCurrency(totalPrice);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Modern header with gradient
            BookingHeader(
              onBack: () => Navigator.of(context).pop(),
            ),
            // Content area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Field information card
                        FieldInfoCard(
                          field: widget.field,
                          selectedSmallField: _selectedSmallField,
                        ),
                        const SizedBox(height: 20),
                        // Voucher selection section (moved above booking details)
                        VoucherSelectionSection(
                          isExpanded: _voucherSectionExpanded,
                          isVoucherApplied: _isVoucherApplied,
                          selectedVoucher: _selectedVoucher,
                          userVouchers: _userVouchers,
                          isLoadingVouchers: _isLoadingVouchers,
                          voucherErrorMessage: _voucherErrorMessage,
                          onToggleExpand: () {
                            setState(() {
                              _voucherSectionExpanded = !_voucherSectionExpanded;
                            });
                            // Fetch vouchers when expanding the section
                            if (_voucherSectionExpanded) {
                              _fetchUserVouchers();
                            }
                          },
                          onFetchVouchers: _fetchUserVouchers,
                          onVoucherSelected: (voucher) {
                            setState(() {
                              _selectedVoucher = voucher;
                            });
                          },
                          onApplyVoucher: () {
                            setState(() {
                              _isVoucherApplied = true;
                              _voucherSectionExpanded = false;
                            });
                          },
                          onRemoveVoucher: () {
                            setState(() {
                              _selectedVoucher = null;
                              _isVoucherApplied = false;
                            });
                          },
                          getVoucherEligibilityMessage: _getVoucherEligibilityMessage,
                          calculateVoucherDiscount: _calculateVoucherDiscount,
                          calculateTotalPrice: _calculateTotalPrice,
                          selectedTimeSlots: widget.selectedTimeSlots,
                        ),
                        const SizedBox(height: 20),
                        // Booking details card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BookingDetailsSection(
                                selectedTimeSlots: widget.selectedTimeSlots,
                                formatDateTime: _formatDateTime,
                                formatTimeRange: _formatTimeRange,
                              ),
                              const SizedBox(height: 20),
                              // Pricing information with enhanced visibility
                              PricingInfoSection(
                                pricePerHour: widget.field.normalPricePerHour.toInt(),
                                selectedTimeSlots: widget.selectedTimeSlots,
                                selectedVoucher: _selectedVoucher,
                                isVoucherApplied: _isVoucherApplied,
                                formatCurrency: _formatCurrency,
                                calculateTotalPrice: _calculateTotalPrice,
                                calculateVoucherDiscount: _calculateVoucherDiscount,
                                calculateTotalPriceWithVoucher: _calculateTotalPriceWithVoucher,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Booking button
            BookingConfirmationButton(
              onPressed: _handleBookingConfirmation,
            ),
          ],
        ),
      ),
    );
  }

  // Calculate voucher discount
  String _calculateVoucherDiscount(UserVoucher userVoucher) {
    final originalPrice = _calculateTotalPrice(widget.selectedTimeSlots);
    final originalPriceInt = int.parse(originalPrice.replaceAll(',', ''));

    if (userVoucher.voucher.percentage) {
      // Percentage discount
      final discount =
          (originalPriceInt * userVoucher.voucher.discountValue / 100).toInt();
      return _formatCurrency(discount);
    } else {
      // Fixed amount discount
      final discount = userVoucher.voucher.discountValue.toInt();
      return _formatCurrency(discount);
    }
  }

  // Calculate total price with voucher discount
  String _calculateTotalPriceWithVoucher() {
    final originalPrice = _calculateTotalPrice(widget.selectedTimeSlots);
    final originalPriceInt = int.parse(originalPrice.replaceAll(',', ''));

    if (_selectedVoucher == null || !_isVoucherApplied) {
      return originalPrice;
    }

    int discount = 0;
    if (_selectedVoucher!.voucher.percentage) {
      // Percentage discount
      discount =
          (originalPriceInt * _selectedVoucher!.voucher.discountValue / 100)
              .toInt();
    } else {
      // Fixed amount discount
      discount = _selectedVoucher!.voucher.discountValue.toInt();
    }

    // Ensure discount doesn't exceed the original price
    final finalPrice =
        originalPriceInt - discount > 0 ? originalPriceInt - discount : 0;
    return _formatCurrency(finalPrice);
  }

  // Get voucher eligibility message
  String _getVoucherEligibilityMessage() {
    final originalPrice = _calculateTotalPrice(widget.selectedTimeSlots);
    final originalPriceInt = int.parse(originalPrice.replaceAll(',', ''));

    // Check if any vouchers exist and if any are eligible
    if (_userVouchers.isEmpty) {
      return 'Bạn không có voucher nào';
    }

    final eligibleVouchers = _userVouchers.where((voucher) {
      return originalPriceInt >= voucher.voucher.minOrderValue &&
          voucher.voucher.active &&
          !voucher.used;
    }).toList();

    if (eligibleVouchers.isEmpty) {
      return 'Chưa đủ điều kiện áp dụng voucher';
    }

    return 'Có ${eligibleVouchers.length} voucher có thể áp dụng';
  }

  // Fetch user vouchers
  Future<void> _fetchUserVouchers() async {
    setState(() {
      _isLoadingVouchers = true;
      _voucherErrorMessage = null;
    });

    try {
      final voucherViewModel = VoucherViewModel();
      final success = await voucherViewModel.fetchUserVouchers();

      if (success) {
        // Filter for active and unused vouchers only
        final activeVouchers = voucherViewModel.userVouchers
            .where((voucher) => voucher.voucher.active && !voucher.used)
            .toList();

        setState(() {
          _userVouchers = activeVouchers;
          _isLoadingVouchers = false;
        });
      } else {
        setState(() {
          _voucherErrorMessage =
              voucherViewModel.errorMessage ?? 'Không thể tải voucher';
          _isLoadingVouchers = false;
        });
      }
    } catch (e) {
      setState(() {
        _voucherErrorMessage = 'Đã có lỗi xảy ra khi tải voucher';
        _isLoadingVouchers = false;
      });
    }
  }

  void _handleBookingConfirmation() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingConfirmationDialog(
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
          onConfirm: () async {
            Navigator.of(context).pop(); // Close dialog
            // Create booking
            await _createBookingAndProceedToPayment();
          },
          selectedVoucher: _selectedVoucher,
          isVoucherApplied: _isVoucherApplied,
        );
      },
    );
  }

  Future<void> _createBookingAndProceedToPayment() async {
    final bookingViewModel = BookingViewModel();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
          ),
        );
      },
    );

    try {
      // Create booking
      final bookingSuccess = await bookingViewModel.createBooking(
        widget.selectedSmallFieldId,
        widget.selectedTimeSlots,
      );

      if (!bookingSuccess) {
        Navigator.of(context).pop(); // Close loading dialog
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingViewModel.errorMessage ?? 'Đặt sân thất bại!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get all booking IDs from the response data (it's a list now)
      List<String> bookingIds = [];
      if (bookingViewModel.bookingDataList != null && 
          bookingViewModel.bookingDataList!.isNotEmpty) {
        // Extract all booking IDs from the list
        for (var bookingData in bookingViewModel.bookingDataList!) {
          if (bookingData['id'] is String) {
            bookingIds.add(bookingData['id'] as String);
          }
        }
      }
      
      // If we couldn't get any booking IDs from the response, generate a placeholder
      if (bookingIds.isEmpty) {
        bookingIds.add('booking-${DateTime.now().millisecondsSinceEpoch}');
      }
      
      Navigator.of(context).pop(); // Close loading dialog
      
      // Get voucher code if a voucher is applied, otherwise don't include code field
      String? voucherCode;
      if (_selectedVoucher != null && _isVoucherApplied) {
        voucherCode = _selectedVoucher!.voucher.code;
      }
      
      // Create payment with all booking IDs
      await _createPayment(bookingIds, voucherCode);
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã có lỗi xảy ra!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createPayment(List<String> bookingIds, String? voucherCode) async {
    final paymentViewModel = PaymentViewModel();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
          ),
        );
      },
    );

    try {
      // Create payment with voucher code (if provided)
      final paymentSuccess = await paymentViewModel.createPayment(
        bookingIds,
        voucherCode ?? '', // Pass empty string if voucherCode is null
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (!paymentSuccess) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentViewModel.errorMessage ?? 'Tạo thanh toán thất bại!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show payment screen with QR code
      if (paymentViewModel.payment != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              payment: paymentViewModel.payment!,
              onPaymentCompleted: () {
                // Show success message when payment is completed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thanh toán thành công!'),
                    backgroundColor: Color(0xFF7FD957),
                  ),
                );
              },
              onBack: () {
                Navigator.of(context).pop(); // Close payment screen
                // Navigate back to home or show success message
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã có lỗi xảy ra khi tạo thanh toán!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}