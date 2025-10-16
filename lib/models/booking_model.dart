class BookingModel {
  final String id;
  final String userId;
  final String fieldId;
  final String fieldName;
  final String smallFieldId;
  final String smallFieldName;
  final String? avatar;
  final String? email;
  final String? startTime;
  final String? endTime;
  final double totalPrice;
  final String status;
  final String createdDate;

  BookingModel({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.fieldName,
    required this.smallFieldId,
    required this.smallFieldName,
    this.avatar,
    this.email,
    this.startTime,
    this.endTime,
    required this.totalPrice,
    required this.status,
    required this.createdDate,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Extract small field information
    final smallField = json['smallField'] as Map<String, dynamic>?;
    
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fieldId: json['fieldId'] as String,
      fieldName: json['fieldName'] as String,
      smallFieldId: smallField?['id'] as String? ?? '',
      smallFieldName: smallField?['smallFiledName'] as String? ?? '',
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      startTime: json['startTime'] as String?, // Make nullable
      endTime: json['endTime'] as String?,     // Make nullable
      totalPrice: (json['totalPrice'] is int) 
          ? (json['totalPrice'] as int).toDouble() 
          : (json['totalPrice'] as double?) ?? 0.0,
      status: json['status'] as String,
      createdDate: json['createdDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fieldId': fieldId,
      'fieldName': fieldName,
      'smallField': {
        'id': smallFieldId,
        'smallFiledName': smallFieldName,
      },
      'avatar': avatar,
      'email': email,
      'startTime': startTime,
      'endTime': endTime,
      'totalPrice': totalPrice,
      'status': status,
      'createdDate': createdDate,
    };
  }
  
  // Helper method to get booking date from startTime
  String? get bookingDate {
    // Extract date part from ISO format startTime (e.g., "2025-10-16T11:00:00")
    if (startTime != null) {
      return startTime!.split('T')[0];
    }
    return null;
  }
}