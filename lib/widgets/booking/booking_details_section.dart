import 'package:flutter/material.dart';

class BookingDetailsSection extends StatelessWidget {
  final List<DateTime> selectedTimeSlots;
  final String Function(DateTime) formatDateTime;
  final String Function(List<DateTime>) formatTimeRange;

  const BookingDetailsSection({
    super.key,
    required this.selectedTimeSlots,
    required this.formatDateTime,
    required this.formatTimeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết đặt sân',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Grouped booking details by date
        ..._buildBookingDetailsByDate(),
      ],
    );
  }

  // Group time slots by date
  Map<DateTime, List<DateTime>> _groupTimeSlotsByDate() {
    final Map<DateTime, List<DateTime>> groupedSlots = {};

    for (final slot in selectedTimeSlots) {
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

  List<Widget> _buildBookingDetailsByDate() {
    final groupedSlots = _groupTimeSlotsByDate();
    final sortedDates = groupedSlots.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    final List<Widget> widgets = [];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final slots = groupedSlots[date]!;

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                formatDateTime(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildDetailRow(
              icon: Icons.access_time_rounded,
              label: 'Giờ',
              value: formatTimeRange(slots),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.hourglass_bottom_rounded,
              label: 'Thời lượng',
              value: '${slots.length} giờ',
            ),
          ],
        ),
      );

      // Add spacing between dates, except after the last one
      if (i < sortedDates.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7FD957).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF7FD957),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}