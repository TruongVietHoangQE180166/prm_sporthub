import 'booking_model.dart';

class OrderModel {
  final String id;
  final String status;
  final double totalAmount;
  final String userId;
  final String email;
  final List<BookingModel> booking;
  final String location;
  final DateTime createdDate;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.userId,
    required this.email,
    required this.booking,
    required this.location,
    required this.createdDate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<BookingModel> bookings = [];
    if (json['booking'] != null) {
      bookings = (json['booking'] as List)
          .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Handle totalAmount as double
    double totalAmountValue = 0.0;
    if (json['totalAmount'] != null) {
      if (json['totalAmount'] is int) {
        totalAmountValue = (json['totalAmount'] as int).toDouble();
      } else if (json['totalAmount'] is double) {
        totalAmountValue = json['totalAmount'] as double;
      }
    }

    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      totalAmount: totalAmountValue,
      userId: json['userId'] as String,
      email: json['email'] as String,
      booking: bookings,
      location: json['location'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'totalAmount': totalAmount,
      'userId': userId,
      'email': email,
      'booking': booking.map((b) => b.toJson()).toList(),
      'location': location,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}