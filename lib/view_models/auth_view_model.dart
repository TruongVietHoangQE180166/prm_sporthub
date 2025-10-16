import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';
import '../models/response_model.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(username, password);
      final response = ResponseModel.fromJson(result);

      if (response.success) {
        _user = UserModel.fromJson(response.data);
        
        // Save user data to secure storage
        await _secureStorage.write(key: 'userId', value: _user!.userId);
        await _secureStorage.write(key: 'username', value: _user!.username);
        await _secureStorage.write(key: 'email', value: _user!.email);
        await _secureStorage.write(key: 'accessToken', value: _user!.accessToken);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(username, email, password);
      final response = ResponseModel.fromJson(result);

      if (response.success) {
        // For registration, we don't save user data to secure storage
        // Just confirm that registration was successful
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Method to set user data from secure storage
  void setUserFromStorage(String userId, String username, String email, String accessToken) {
    _user = UserModel(
      userId: userId,
      username: username,
      email: email,
      accessToken: accessToken,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    
    // Clear user data from secure storage
    _secureStorage.delete(key: 'userId');
    _secureStorage.delete(key: 'username');
    _secureStorage.delete(key: 'email');
    _secureStorage.delete(key: 'accessToken');
    
    notifyListeners();
  }

  Future<bool> verifyOTP(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.verifyOTP(email, otp);
      final response = ResponseModel.fromJson(result);

      if (response.success) {
        // For OTP verification, we only need to confirm success
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOTP(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.sendOTP(email);
      final response = ResponseModel.fromJson(result);

      if (response.success) {
        // For sending OTP, we only need to confirm success
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String otp, String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.resetPassword(otp, email, newPassword);
      final response = ResponseModel.fromJson(result);

      if (response.success) {
        // For password reset, we only need to confirm success
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}