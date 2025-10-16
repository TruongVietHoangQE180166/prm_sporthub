import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/api_service.dart';
import '../models/profile_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  ProfileModel? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileModel? get profile => _profile;

  Future<bool> fetchProfile() async {
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

      final result = await _apiService.getProfile(userId, accessToken);
      
      if (result['success'] == true && result['data'] != null) {
        _profile = ProfileModel.fromJson(result['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Lấy thông tin profile thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra khi lấy thông tin profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Debug logging - Request data
      print('=== UPDATE PROFILE VIEWMODEL REQUEST ===');
      print('Profile Data: $profileData');
      print('======================================');

      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _apiService.updateProfile(accessToken, profileData);
      
      // Debug logging - Response
      print('=== UPDATE PROFILE VIEWMODEL RESPONSE ===');
      print('Result: $result');
      print('========================================');
      
      if (result['success'] == true) {
        // If we have updated data, update the local profile
        if (result['data'] != null) {
          _profile = ProfileModel.fromJson(result['data']);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Cập nhật thông tin profile thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Debug logging - Error
      print('=== UPDATE PROFILE VIEWMODEL ERROR ===');
      print('Error: $e');
      print('==========================');
      
      _errorMessage = 'Đã có lỗi xảy ra khi cập nhật thông tin profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> uploadAvatarImage(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Debug logging - Request data
      print('=== UPLOAD AVATAR VIEWMODEL REQUEST ===');
      print('Image Path: $imagePath');
      print('=====================================');

      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isLoading = false;
        notifyListeners();
        print('=== UPLOAD AVATAR - NO ACCESS TOKEN ===');
        return null;
      }

      final result = await _apiService.uploadAvatarImage(accessToken, imagePath);
      
      // Debug logging - Response
      print('=== UPLOAD AVATAR VIEWMODEL RESPONSE ===');
      print('Result: $result');
      print('=======================================');
      
      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      // Debug logging - Error
      print('=== UPLOAD AVATAR VIEWMODEL ERROR ===');
      print('Error: $e');
      print('===================================');
      
      _errorMessage = 'Đã có lỗi xảy ra khi tải ảnh lên';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Debug logging - Request data
      print('=== CHANGE PASSWORD VIEWMODEL REQUEST ===');
      print('Old Password: $oldPassword');
      print('New Password: $newPassword');
      print('=====================================');

      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isLoading = false;
        notifyListeners();
        print('=== CHANGE PASSWORD - NO ACCESS TOKEN ===');
        return null;
      }

      final result = await _apiService.changePassword(accessToken, oldPassword, newPassword);
      
      // Debug logging - Response
      print('=== CHANGE PASSWORD VIEWMODEL RESPONSE ===');
      print('Result: $result');
      print('=======================================');
      
      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      // Debug logging - Error
      print('=== CHANGE PASSWORD VIEWMODEL ERROR ===');
      print('Error: $e');
      print('===================================');
      
      _errorMessage = 'Đã có lỗi xảy ra khi thay đổi mật khẩu';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserPoint() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Debug logging - Request data
      print('=== GET USER POINT VIEWMODEL REQUEST ===');
      print('=====================================');

      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isLoading = false;
        notifyListeners();
        print('=== GET USER POINT - NO ACCESS TOKEN ===');
        return null;
      }

      final result = await _apiService.getUserPoint(accessToken);
      
      // Debug logging - Response
      print('=== GET USER POINT VIEWMODEL RESPONSE ===');
      print('Result: $result');
      print('=======================================');
      
      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      // Debug logging - Error
      print('=== GET USER POINT VIEWMODEL ERROR ===');
      print('Error: $e');
      print('===================================');
      
      _errorMessage = 'Đã có lỗi xảy ra khi lấy thông tin điểm';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}