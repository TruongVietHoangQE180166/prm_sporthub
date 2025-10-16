import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/api_service.dart';
import '../models/order_status_model.dart';

class OrderStatusViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  OrderStatusModel? _orderStatus;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderStatusModel? get orderStatus => _orderStatus;

  Future<bool> checkOrderStatus(String orderId) async {
    print('=== OrderStatusViewModel.checkOrderStatus ===');
    _isLoading = true;
    _errorMessage = null;
    _orderStatus = null;
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

      final result = await _apiService.checkOrderStatus(accessToken, orderId);
      print('API Response: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final String statusData = result['data'] as String;
        print('Order status data: $statusData');
        
        _orderStatus = OrderStatusModel.fromJson(statusData);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Lấy trạng thái đơn hàng thất bại';
        print('API Error: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in checkOrderStatus: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi lấy trạng thái đơn hàng';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh(String orderId) async {
    print('=== OrderStatusViewModel.refresh ===');
    await checkOrderStatus(orderId);
  }
}