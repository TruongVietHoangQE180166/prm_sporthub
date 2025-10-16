import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/team_model.dart';
import '../core/services/api_service.dart';

class TeamViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<Team> _teams = [];

  bool get isLoading => _isLoading;
  String? get errorMessage {
    return _errorMessage;
  }
  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }
  List<Team> get teams => _teams;

  Future<bool> fetchAllTeams({String? userId}) async {
    print('=== TeamViewModel.fetchAllTeams ===');
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

      // If userId is provided, use getAllTeams with userId
      // If userId is null, retrieve it from secure storage and use getAllTeams with userId
      // Only use getAllTeamsPublic when explicitly requested (e.g., userId = 'public')
      Map<String, dynamic> result;
      if (userId == 'public') {
        result = await _apiService.getAllTeamsPublic(
          accessToken,
          page: 1,
          size: 1000,
          field: 'createdDate',
          direction: 'desc',
        );
      } else {
        // Use provided userId or retrieve from secure storage
        String? finalUserId = userId;
        if (finalUserId == null) {
          // Retrieve userId from secure storage
          finalUserId = await _secureStorage.read(key: 'userId');
          print('User ID: ${finalUserId != null ? "Present" : "Missing"}');
          
          if (finalUserId == null) {
            _errorMessage = 'Không tìm thấy thông tin người dùng';
            _isLoading = false;
            notifyListeners();
            print('Error: User ID not found');
            return false;
          }
        }
        
        result = await _apiService.getAllTeams(
          accessToken,
          finalUserId,
          page: 1,
          size: 1000,
          field: 'createdDate',
          direction: 'desc',
        );
      }
      
      print('API Response: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> teamsData = result['data'];
        print('Teams data count: ${teamsData.length}');
        
        // Debug: Print first item structure
        if (teamsData.isNotEmpty) {
          print('First team data: ${teamsData[0]}');
        }
        
        _teams = teamsData.map((item) {
          try {
            print('Mapping team item: $item');
            return Team.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('Error mapping team item: $e');
            rethrow;
          }
        }).toList();
        
        print('Successfully parsed ${_teams.length} teams');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Lấy thông tin đội nhóm thất bại';
        print('API Error: $_errorMessage');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in fetchAllTeams: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi lấy thông tin đội nhóm: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh({String? userId}) async {
    print('=== TeamViewModel.refresh ===');
    await fetchAllTeams(userId: userId);
  }
}