import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/field_model.dart';
import '../../models/booking_model.dart';
import '../../view_models/booking_view_model.dart';
import '../booking/verify_booking_screen.dart';

class FieldCalendarScreen extends StatefulWidget {
  final FieldModel field;
  final String? selectedSmallFieldId; // Add selected small field ID

  const FieldCalendarScreen({super.key, required this.field, this.selectedSmallFieldId});

  @override
  State<FieldCalendarScreen> createState() => _FieldCalendarScreenState();
}

class _FieldCalendarScreenState extends State<FieldCalendarScreen> {
  late DateTime _currentWeekStart;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;
  // Add a set to track selected time slots
  final Set<String> _selectedSlots = {};
  late BookingViewModel _bookingViewModel;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getStartOfWeek(DateTime.now());
    
    // Parse open and close times
    _openTime = _parseTimeString(widget.field.openTime);
    _closeTime = _parseTimeString(widget.field.closeTime);
    
    // Initialize booking view model and fetch bookings
    _bookingViewModel = BookingViewModel();
    _fetchBookings();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    // Only fetch bookings if a small field is selected
    if (widget.selectedSmallFieldId != null && widget.selectedSmallFieldId!.isNotEmpty) {
      await _bookingViewModel.fetchBookingsForSmallField(widget.selectedSmallFieldId!);
    }
  }

  // Debounced version of fetchBookings to prevent excessive API calls
  void _fetchBookingsDebounced() {
    // Only debounce if a small field is selected
    if (widget.selectedSmallFieldId != null && widget.selectedSmallFieldId!.isNotEmpty) {
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _fetchBookings();
      });
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Get the Monday of the current week
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Default to 8:00 AM if parsing fails
      return const TimeOfDay(hour: 8, minute: 0);
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  bool _isTimeSlotAvailable(DateTime date, int hour) {
    final now = DateTime.now();
    
    // Check if the time slot is in the past
    final slotDateTime = DateTime(date.year, date.month, date.day, hour);
    if (slotDateTime.isBefore(now)) {
      return false;
    }
    
    // Check if the time slot is within business hours
    try {
      // Parse open and close times (expected format: "HH:mm:ss" or "HH:mm")
      final openParts = widget.field.openTime.split(':');
      final closeParts = widget.field.closeTime.split(':');
      
      // Handle both "HH:mm:ss" (3 parts) and "HH:mm" (2 parts) formats
      if ((openParts.length == 2 || openParts.length == 3) && 
          (closeParts.length == 2 || closeParts.length == 3)) {
        final openHour = int.parse(openParts[0]);
        final closeHour = int.parse(closeParts[0]);
        
        // Check if the hour is within business hours
        // Note: If closeHour is 0 or 24, it means closing at midnight
        if (closeHour == 0 || closeHour == 24) {
          // Business hours span overnight (e.g., 20:00 to 00:00 or 20:00 to 24:00)
          return hour >= openHour || hour < 24;
        } else if (closeHour < openHour) {
          // Business hours span overnight (e.g., 20:00 to 06:00)
          return hour >= openHour || hour < closeHour;
        } else {
          // Normal business hours (e.g., 05:00 to 22:00)
          return hour >= openHour && hour < closeHour;
        }
      }
    } catch (e) {
      // If parsing fails, default to business hours 8:00 to 22:00
      return hour >= 8 && hour < 22;
    }
    
    // Default to business hours 8:00 to 22:00 if parsing fails
    return hour >= 8 && hour < 22;
  }

  // Check if a time slot is booked based on existing bookings
  BookingModel? _getBookingForTimeSlot(DateTime date, int hour) {
    if (widget.selectedSmallFieldId == null) return null;
    
    // Check each booking to see if it matches this time slot
    for (var booking in _bookingViewModel.bookings) {
      // Make sure this booking is for the correct small field
      if (booking.smallFieldId != widget.selectedSmallFieldId) continue;
      
      // Skip bookings with null startTime or endTime
      if (booking.startTime == null || booking.endTime == null) continue;
      
      // Parse booking date from startTime (ISO format: "2025-10-16T11:00:00")
      try {
        // Extract date part and parse it
        final datePart = booking.startTime!.split('T')[0];
        final bookingDate = DateTime.parse(datePart);
        
        // Check if this booking is for the same date
        if (bookingDate.year == date.year && 
            bookingDate.month == date.month && 
            bookingDate.day == date.day) {
          
          // Parse start and end times
          final startTimePart = booking.startTime!.split('T')[1];
          final endTimePart = booking.endTime!.split('T')[1];
          
          final startParts = startTimePart.split(':');
          final endParts = endTimePart.split(':');
          
          if (startParts.length >= 2 && endParts.length >= 2) {
            final startHour = int.parse(startParts[0]);
            final endHour = int.parse(endParts[0]);
            
            // Check if the hour falls within the booking time range
            if (hour >= startHour && hour < endHour) {
              return booking;
            }
          }
        }
      } catch (e) {
        // If parsing fails, continue to the next booking
        continue;
      }
    }
    
    return null;
  }

  // Get the color for a time slot based on its status
  Color _getTimeSlotColor(DateTime date, int hour, bool isAvailable) {
    if (!isAvailable) {
      // Outside business hours - red
      return Colors.red[100]!;
    }
    
    final booking = _getBookingForTimeSlot(date, hour);
    if (booking != null) {
      // Has booking - check status
      switch (booking.status) {
        case 'PENDING':
          // Pending - yellow
          return Colors.yellow[200]!;
        case 'CONFIRMED':
          // Complete - blue
          return Colors.blue[200]!;
        default:
          // Other status - use default available color
          return Colors.white;
      }
    }
    
    // No booking - available
    return Colors.white;
  }

  // Get the border color for a time slot
  Color _getTimeSlotBorderColor(DateTime date, int hour, bool isAvailable) {
    if (!isAvailable) {
      // Outside business hours - darker red
      return Colors.red[200]!;
    }
    
    final booking = _getBookingForTimeSlot(date, hour);
    if (booking != null) {
      // Has booking - check status
      switch (booking.status) {
        case 'PENDING':
          // Pending - yellow border
          return Colors.yellow[400]!;
        case 'COMPLETE':
          // Complete - blue border
          return Colors.blue[400]!;
        default:
          // Other status - use default border color
          return Colors.grey[300]!;
      }
    }
    
    // No booking - available border
    return Colors.grey[300]!;
  }

  // Get the text for a time slot
  String _getTimeSlotText(DateTime date, int hour, bool isAvailable) {
    if (!isAvailable) {
      return 'Ngoài giờ';
    }
    
    final booking = _getBookingForTimeSlot(date, hour);
    if (booking != null) {
      // Has booking - show status
      switch (booking.status) {
        case 'PENDING':
          return 'Đang xử lý';
        case 'COMPLETE':
          return 'Đã đặt';
        default:
          return 'Đã đặt';
      }
    }
    
    // No booking - available
    return 'Trống';
  }

  // Get the text color for a time slot
  Color _getTimeSlotTextColor(DateTime date, int hour, bool isAvailable) {
    if (!isAvailable) {
      // Outside business hours - darker red
      return Colors.red[700]!;
    }
    
    final booking = _getBookingForTimeSlot(date, hour);
    if (booking != null) {
      // Has booking - check status
      switch (booking.status) {
        case 'PENDING':
          // Pending - dark yellow
          return Colors.yellow[800]!;
        case 'COMPLETE':
          // Complete - dark blue
          return Colors.blue[800]!;
        default:
          // Other status - dark gray
          return Colors.grey[700]!;
      }
    }
    
    // No booking - available text color
    return Colors.grey[700]!;
  }

  String _getDayName(DateTime date) {
    const dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return dayNames[date.weekday - 1];
  }

  String _getDateString(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _getMonthYearString(DateTime date) {
    const monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  void _goToPreviousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
    // Refresh bookings when week changes with debounce
    _fetchBookingsDebounced();
  }

  void _goToNextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
    // Refresh bookings when week changes with debounce
    _fetchBookingsDebounced();
  }

  void _goToCurrentWeek() {
    setState(() {
      _currentWeekStart = _getStartOfWeek(DateTime.now());
    });
    // Refresh bookings when week changes with debounce
    _fetchBookingsDebounced();
  }

  String _getSmallFieldName(String smallFieldId) {
    final smallField = widget.field.smallFieldResponses
        .firstWhere((field) => field.id == smallFieldId, orElse: () => SmallFieldResponse(
          id: '',
          createdDate: '',
          smallFiledName: 'Unknown Field',
          description: '',
          capacity: '',
          booked: false,
          available: true,
        ));
    return 'Đặt sân: ${smallField.smallFiledName}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _bookingViewModel,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Modern header with enhanced design (matching order_screen header)
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
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lịch đặt sân',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Xem và đặt lịch sân',
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
              
              // Week navigation
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: _goToPreviousWeek,
                    ),
                    Column(
                      children: [
                        Text(
                          'Tuần ${_getWeekNumber(_currentWeekStart)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${_getDateString(_currentWeekStart)} - ${_getDateString(_currentWeekStart.add(const Duration(days: 6)))}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${_getMonthYearString(_currentWeekStart)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: _goToNextWeek,
                    ),
                  ],
                ),
              ),
              
              // Field name (moved here to match field_detail_screen structure)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Always show the main field name
                    Text(
                      widget.field.fieldName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Show the selected small field name when one is selected
                    if (widget.selectedSmallFieldId != null)
                      Text(
                        _getSmallFieldName(widget.selectedSmallFieldId!),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7FD957),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Today button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToCurrentWeek,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7FD957),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tuần hiện tại',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Calendar grid with loading indicator
              Expanded(
                child: Consumer<BookingViewModel>(
                  builder: (context, bookingViewModel, child) {
                    if (bookingViewModel.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF7FD957)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Đang tải dữ liệu đặt sân...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (bookingViewModel.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              bookingViewModel.errorMessage!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchBookings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7FD957),
                              ),
                              child: const Text(
                                'Thử lại',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Days header row
                              _buildDaysHeader(),
                              const SizedBox(height: 8),
                              // Time slots grid
                              _buildTimeSlotsGrid(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Booking button that appears when time slots are selected
              if (_selectedSlots.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to verify booking screen
                          _navigateToVerifyBooking();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7FD957),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Đặt sân',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    return (daysSinceStart ~/ 7) + 1;
  }

  Widget _buildDaysHeader() {
    return Row(
      children: [
        // Empty top-left cell
        Container(
          width: 60,
          height: 40,
        ),
        // Day columns
        ...List.generate(7, (index) {
          final date = _currentWeekStart.add(Duration(days: index));
          final isToday = date.day == DateTime.now().day && 
                         date.month == DateTime.now().month && 
                         date.year == DateTime.now().year;
          
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                Text(
                  _getDayName(date),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isToday ? const Color(0xFF7FD957) : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFF7FD957) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getDateString(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeSlotsGrid() {
    return Column(
      children: List.generate(24, (hourIndex) {
        return Row(
          children: [
            // Hour label
            Container(
              width: 60,
              height: 40,
              alignment: Alignment.center,
              child: Text(
                '$hourIndex:00',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Day cells for this hour
            ...List.generate(7, (dayIndex) {
              final date = _currentWeekStart.add(Duration(days: dayIndex));
              final isAvailable = _isTimeSlotAvailable(date, hourIndex);
              // Create a unique key for each time slot
              final slotKey = '${date.year}-${date.month}-${date.day}-$hourIndex';
              final isSelected = _selectedSlots.contains(slotKey);
              
              // Get booking information for this slot
              final booking = _getBookingForTimeSlot(date, hourIndex);
              final slotColor = _getTimeSlotColor(date, hourIndex, isAvailable);
              final borderColor = _getTimeSlotBorderColor(date, hourIndex, isAvailable);
              final slotText = _getTimeSlotText(date, hourIndex, isAvailable);
              final textColor = _getTimeSlotTextColor(date, hourIndex, isAvailable);
              
              return GestureDetector(
                onTap: isAvailable && booking == null ? () {
                  // Toggle selection only for available slots without bookings
                  setState(() {
                    if (isSelected) {
                      _selectedSlots.remove(slotKey);
                    } else {
                      _selectedSlots.add(slotKey);
                    }
                  });
                } : null,
                child: Container(
                  width: 80,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7FD957) : slotColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF7FD957) : borderColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isSelected 
                          ? 'Đã chọn' 
                          : slotText,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected 
                            ? Colors.white 
                            : textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  void _navigateToVerifyBooking() {
    // Convert selected slots to DateTime objects
    final selectedTimeSlots = <DateTime>[];
    
    for (final slotKey in _selectedSlots) {
      // Parse the slot key format: 'YYYY-M-D-H'
      final parts = slotKey.split('-');
      if (parts.length == 4) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final hour = int.parse(parts[3]);
        
        selectedTimeSlots.add(DateTime(year, month, day, hour));
      }
    }
    
    // Sort the time slots by date and time
    selectedTimeSlots.sort((a, b) => a.compareTo(b));
    
    // Navigate to verify booking screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerifyBookingScreen(
          field: widget.field,
          selectedSmallFieldId: widget.selectedSmallFieldId!,
          selectedTimeSlots: selectedTimeSlots,
        ),
      ),
    );
  }
}