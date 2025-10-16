import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/api_service.dart';
import '../models/user_voucher_model.dart';
import '../models/voucher_model.dart';

class VoucherViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<UserVoucher> _userVouchers = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserVoucher> get userVouchers => _userVouchers;

  // Add a flag to track if data has been loaded
  bool _isInitialized = false;

  // Method to initialize and fetch data if not already loaded
  Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = true;
      await fetchUserVouchers();
    }
  }

  Future<bool> fetchUserVouchers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve userId and accessToken from secure storage
      final userId = await _secureStorage.read(key: 'userId');
      final accessToken = await _secureStorage.read(key: 'accessToken');
      
      if (userId == null || accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _apiService.getUserVoucher(accessToken, userId);
      
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> vouchersData = result['data'];
        _userVouchers = vouchersData
            .map((voucherData) => UserVoucher.fromJson(voucherData as Map<String, dynamic>))
            .toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Lấy thông tin voucher thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra khi lấy thông tin voucher';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> exchangeVoucher(VoucherTemplate voucherTemplate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'Người dùng chưa đăng nhập'
        };
      }

      // Convert VoucherTemplate to the required format for API
      final voucherData = {
        'discountValue': voucherTemplate.discountValue,
        'minOrderValue': voucherTemplate.minOrderValue,
        'image': voucherTemplate.image,
        'exchangePoint': voucherTemplate.exchangePoint,
        'active': voucherTemplate.active,
        'percentage': voucherTemplate.percentage,
      };

      final result = await _apiService.exchangeVoucher(accessToken, voucherData);
      
      _isLoading = false;
      notifyListeners();
      
      // Refresh user vouchers after successful exchange
      if (result['success'] == true) {
        await fetchUserVouchers();
      }
      
      return result;
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra khi đổi voucher';
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra khi đổi voucher'
      };
    }
  }
}