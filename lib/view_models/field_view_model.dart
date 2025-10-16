import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/api_service.dart';
import '../models/field_model.dart';

class FieldViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<FieldModel> _fields = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FieldModel> get fields => _fields;

  Future<bool> fetchAllFields() async {
    print('=== FieldViewModel.fetchAllFields ===');
    _isLoading = true;
    _errorMessage = null;
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

      final result = await _apiService.getAllFields(accessToken);
      print('API Response: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> fieldsData = result['data'];
        print('Fields data count: ${fieldsData.length}');
        
        // Debug: Print first item structure
        if (fieldsData.isNotEmpty) {
          print('First field data: ${fieldsData[0]}');
        }
        
        _fields = fieldsData.map((item) {
          try {
            print('Mapping field item: $item');
            return FieldModel.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('Error mapping field item: $e');
            rethrow;
          }
        }).toList();
        
        print('Successfully parsed ${_fields.length} fields');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Lấy thông tin sân thất bại';
        print('API Error: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in fetchAllFields: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi lấy thông tin sân';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    print('=== FieldViewModel.refresh ===');
    await fetchAllFields();
  }
}