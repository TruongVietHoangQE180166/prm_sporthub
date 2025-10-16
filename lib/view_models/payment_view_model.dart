import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/api_service.dart';
import '../models/payment_model.dart';

class PaymentViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  PaymentModel? _payment;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PaymentModel? get payment => _payment;

  Future<bool> createPayment(List<String> bookingIds, String? code) async {
    print('=== PaymentViewModel.createPayment ===');
    _isLoading = true;
    _errorMessage = null;
    _payment = null;
    notifyListeners();

    try {
      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      print('Access token: ${accessToken != null ? "Present" : "Missing"}');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isLoading = false;
        notifyListeners();
        print('Error: User not logged in');
        return false;
      }

      final result = await _apiService.createPayment(accessToken, bookingIds, code ?? '');
      print('API Response: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final Map<String, dynamic> paymentData = result['data'];
        print('Payment data: $paymentData');
        
        _payment = PaymentModel.fromJson(paymentData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Tạo thanh toán thất bại';
        print('API Error: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in createPayment: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi tạo thanh toán';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh(List<String> bookingIds, String? code) async {
    print('=== PaymentViewModel.refresh ===');
    await createPayment(bookingIds, code);
  }
}