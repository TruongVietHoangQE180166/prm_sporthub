class ResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  ResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle the message structure from the API
    String messageText;
    if (json['message'] is Map<String, dynamic>) {
      messageText = json['message']['messageDetail'] as String? ?? 'Unknown message';
    } else {
      messageText = json['message'] as String? ?? 'Unknown message';
    }

    return ResponseModel(
      success: json['success'] as bool? ?? false,
      message: messageText,
      data: json['data'],
    );
  }
}