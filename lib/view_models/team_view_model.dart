import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/team_model.dart';
import '../core/services/api_service.dart';

class TeamViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  bool _isJoiningTeam = false;
  bool _isProcessingRequest = false; // New flag for processing team requests
  String? _errorMessage;
  List<Team> _teams = [];

  bool get isLoading => _isLoading;
  bool get isJoiningTeam => _isJoiningTeam;
  bool get isProcessingRequest => _isProcessingRequest; // New getter
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

  Future<bool> requestJoinTeam(String teamId) async {
    print('=== TeamViewModel.requestJoinTeam ===');
    _isJoiningTeam = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      print('Access token: ${accessToken != null ? "Present" : "Missing"}');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isJoiningTeam = false;
        notifyListeners();
        print('Error: User not logged in');
        return false;
      }

      final result = await _apiService.requestJoinTeam(accessToken, teamId);
      
      print('API Response: $result');
      
      if (result['success'] == true) {
        _isJoiningTeam = false;
        notifyListeners();
        // Refresh the teams list after successful join request
        await fetchAllTeams();
        return true;
      } else {
        _errorMessage = result['message'] is Map<String, dynamic> 
            ? (result['message'] as Map<String, dynamic>)['messageDetail'] as String? 
            : result['message'] as String? ?? 'Yêu cầu tham gia đội nhóm thất bại';
        print('API Error: $_errorMessage');
        _isJoiningTeam = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in requestJoinTeam: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi yêu cầu tham gia đội nhóm: $e';
      _isJoiningTeam = false;
      notifyListeners();
      return false;
    }
  }

  /// Accept or reject a team join request
  ///
  /// Parameters:
  /// - teamJoinRequestId: ID of the join request to process
  /// - status: Either 'APPROVED' or 'REJECTED'
  ///
  /// Returns true if the operation was successful, false otherwise
  Future<bool> acceptOrRejectTeamRequest(String teamJoinRequestId, String status) async {
    print('=== TeamViewModel.acceptOrRejectTeamRequest ===');
    print('teamJoinRequestId: $teamJoinRequestId');
    print('status: $status');
    
    _isProcessingRequest = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      print('Access token: ${accessToken != null ? "Present" : "Missing"}');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isProcessingRequest = false;
        notifyListeners();
        print('Error: User not logged in');
        return false;
      }

      final result = await _apiService.acceptOrRejectTeamRequest(accessToken, teamJoinRequestId, status);
      
      print('API Response: $result');
      
      if (result['success'] == true) {
        _isProcessingRequest = false;
        notifyListeners();
        // Refresh the teams list after successful processing
        await fetchAllTeams();
        return true;
      } else {
        _errorMessage = result['message'] is Map<String, dynamic> 
            ? (result['message'] as Map<String, dynamic>)['messageDetail'] as String? 
            : result['message'] as String? ?? 'Xử lý yêu cầu tham gia thất bại';
        print('API Error: $_errorMessage');
        _isProcessingRequest = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in acceptOrRejectTeamRequest: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi xử lý yêu cầu tham gia: $e';
      _isProcessingRequest = false;
      notifyListeners();
      return false;
    }
  }

  /// Kick a user from a team or leave a team
  ///
  /// Parameters:
  /// - teamId: ID of the team to kick/leave
  /// - userId: ID of the user to kick or the user leaving
  /// - isKick: true if kicking another user, false if leaving the team
  ///
  /// Returns true if the operation was successful, false otherwise
  Future<bool> kichOrLeftTeam(String teamId, String userId, bool isKick) async {
    print('=== TeamViewModel.kichOrLeftTeam ===');
    print('teamId: $teamId');
    print('userId: $userId');
    print('isKick: $isKick');
    
    _isProcessingRequest = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      print('Access token: ${accessToken != null ? "Present" : "Missing"}');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isProcessingRequest = false;
        notifyListeners();
        print('Error: User not logged in');
        return false;
      }

      final result = await _apiService.kichOrLeftTeam(accessToken, teamId, userId, isKick);
      
      print('API Response: $result');
      
      if (result['success'] == true) {
        _isProcessingRequest = false;
        notifyListeners();
        // Refresh the teams list after successful operation
        await fetchAllTeams();
        return true;
      } else {
        _errorMessage = result['message'] is Map<String, dynamic> 
            ? (result['message'] as Map<String, dynamic>)['messageDetail'] as String? 
            : result['message'] as String? ?? 
              (isKick ? 'Không thể xóa người dùng khỏi đội nhóm' : 'Không thể rời khỏi đội nhóm');
        print('API Error: $_errorMessage');
        _isProcessingRequest = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in kichOrLeftTeam: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = isKick 
          ? 'Đã có lỗi xảy ra khi xóa người dùng khỏi đội nhóm: $e'
          : 'Đã có lỗi xảy ra khi rời khỏi đội nhóm: $e';
      _isProcessingRequest = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a team
  ///
  /// Parameters:
  /// - teamId: ID of the team to delete
  ///
  /// Returns true if the operation was successful, false otherwise
  Future<bool> deleteTeam(String teamId) async {
    print('=== TeamViewModel.deleteTeam ===');
    print('teamId: $teamId');
    
    _isProcessingRequest = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      print('Access token: ${accessToken != null ? "Present" : "Missing"}');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isProcessingRequest = false;
        notifyListeners();
        print('Error: User not logged in');
        return false;
      }

      final result = await _apiService.deleteTeam(accessToken, teamId);
      
      print('API Response: $result');
      
      if (result['success'] == true) {
        _isProcessingRequest = false;
        notifyListeners();
        // Refresh the teams list after successful deletion
        await fetchAllTeams();
        return true;
      } else {
        _errorMessage = result['message'] is Map<String, dynamic> 
            ? (result['message'] as Map<String, dynamic>)['messageDetail'] as String? 
            : result['message'] as String? ?? 'Không thể xóa đội nhóm';
        print('API Error: $_errorMessage');
        _isProcessingRequest = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in deleteTeam: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi xóa đội nhóm: $e';
      _isProcessingRequest = false;
      notifyListeners();
      return false;
    }
  }

  /// Create a new team
  ///
  /// Parameters:
  /// - teamData: Map containing team information
  ///
  /// Returns true if the operation was successful, false otherwise
  Future<bool> createTeam(Map<String, dynamic> teamData) async {
    print('=== TeamViewModel.createTeam ===');
    print('teamData: $teamData');
    
    _isProcessingRequest = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Retrieve accessToken from secure storage
      final accessToken = await _secureStorage.read(key: 'accessToken');
      print('Access token: ${accessToken != null ? "Present" : "Missing"}');
      
      if (accessToken == null) {
        _errorMessage = 'Người dùng chưa đăng nhập';
        _isProcessingRequest = false;
        notifyListeners();
        print('Error: User not logged in');
        return false;
      }

      final result = await _apiService.createTeam(accessToken, teamData);
      
      print('API Response: $result');
      
      if (result['success'] == true) {
        _isProcessingRequest = false;
        notifyListeners();
        // Refresh the teams list after successful creation
        await fetchAllTeams();
        return true;
      } else {
        _errorMessage = result['message'] is Map<String, dynamic> 
            ? (result['message'] as Map<String, dynamic>)['messageDetail'] as String? 
            : result['message'] as String? ?? 'Không thể tạo đội nhóm';
        print('API Error: $_errorMessage');
        _isProcessingRequest = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in createTeam: $e');
      print('Stack trace: $stackTrace');
      _errorMessage = 'Đã có lỗi xảy ra khi tạo đội nhóm: $e';
      _isProcessingRequest = false;
      notifyListeners();
      return false;
    }
  }
}