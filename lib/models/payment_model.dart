class PaymentModel {
  final double amount;
  final String status;
  final String method;
  final String qrCode;
  final String ordersId;

  PaymentModel({
    required this.amount,
    required this.status,
    required this.method,
    required this.qrCode,
    required this.ordersId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      amount: (json['amount'] is int) 
          ? (json['amount'] as int).toDouble() 
          : (json['amount'] as double?) ?? 0.0,
      status: json['status'] as String? ?? '',
      method: json['method'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      ordersId: json['ordersId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'status': status,
      'method': method,
      'qrCode': qrCode,
      'ordersId': ordersId,
    };
  }
}