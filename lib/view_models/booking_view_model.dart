import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/services/api_service.dart';
import '../models/booking_model.dart';

class BookingViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<BookingModel> _bookings = [];
  List<Map<String, dynamic>>? _bookingDataList; // Change to store list of booking data

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BookingModel> get bookings => _bookings;
  List<Map<String, dynamic>>? get bookingDataList => _bookingDataList; // Add getter for booking data list

  Future<bool> fetchBookingsForSmallField(String smallFieldIdOrFieldId) async {
    print('=== BookingViewModel.fetchBookingsForSmallField ===');
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

      final result = await _apiService.getBookingSmallField(accessToken, smallFieldIdOrFieldId);
      print('API Response: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> bookingsData = result['data'];
        print('Bookings data count: ${bookingsData.length}');
        
        // Debug: Print first item structure
        if (bookingsData.isNotEmpty) {
          print('First booking data: ${bookingsData[0]}');
        }
        
        _bookings = bookingsData.map((item) {
          try {
            print('Mapping booking item: $item');
            return BookingModel.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('Error mapping booking item: $e');
            rethrow;
          }
        }).toList();
        
        print('Successfully parsed ${_bookings.length} bookings');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Lấy thông tin đặt sân thất bại';
        print('API Error: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in fetchBookingsForSmallField: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi lấy thông tin đặt sân';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh(String smallFieldIdOrFieldId) async {
    print('=== BookingViewModel.refresh ===');
    await fetchBookingsForSmallField(smallFieldIdOrFieldId);
  }

  Future<bool> createBooking(String smallFieldId, List<DateTime> startTimes) async {
    print('=== BookingViewModel.createBooking ===');
    _isLoading = true;
    _errorMessage = null;
    _bookingDataList = null; // Reset booking data list
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

      final result = await _apiService.createBooking(accessToken, smallFieldId, startTimes);
      print('API Response: $result');
      
      if (result['success'] == true && result['data'] != null) {
        // Store the booking data list which should contain the booking objects
        final dataList = result['data'] as List;
        _bookingDataList = dataList.cast<Map<String, dynamic>>().toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Đặt sân thất bại';
        print('API Error: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in createBooking: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi đặt sân';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}