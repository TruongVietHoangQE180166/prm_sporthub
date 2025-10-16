import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/api_service.dart';
import '../models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<OrderModel> _orders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage {
    return _errorMessage;
  }
  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }
  List<OrderModel> get orders => _orders;

  Future<bool> fetchUserOrders() async {
    print('=== OrderViewModel.fetchUserOrders ===');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve userId from secure storage
      final userId = await _secureStorage.read(key: 'userId');
      print('User ID: ${userId != null ? "Present" : "Missing"}');
      
      if (userId == null) {
        _errorMessage = 'Không tìm thấy thông tin người dùng';
        _isLoading = false;
        notifyListeners();
        print('Error: User ID not found');
        return false;
      }

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

      final result = await _apiService.getUserOrders(accessToken, userId);
      print('API Response: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> ordersData = result['data'];
        print('Orders data count: ${ordersData.length}');
        
        // Debug: Print first item structure
        if (ordersData.isNotEmpty) {
          print('First order data: ${ordersData[0]}');
        }
        
        _orders = ordersData.map((item) {
          try {
            print('Mapping order item: $item');
            return OrderModel.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('Error mapping order item: $e');
            rethrow;
          }
        }).toList();
        
        print('Successfully parsed ${_orders.length} orders');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Lấy thông tin đơn hàng thất bại';
        print('API Error: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in fetchUserOrders: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi lấy thông tin đơn hàng: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    print('=== OrderViewModel.refresh ===');
    await fetchUserOrders();
  }
}