class OrderStatusModel {
  final String status;

  OrderStatusModel({
    required this.status,
  });

  factory OrderStatusModel.fromJson(String status) {
    return OrderStatusModel(
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}