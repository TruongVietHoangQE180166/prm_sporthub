import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../view_models/team_view_model.dart';

import '../../widgets/custom_confirmation_modal.dart';

class MyMatchesScreen extends StatelessWidget {
  const MyMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamViewModel(),
      child: const MyMatchesScreenContent(),
    );
  }
}

class MyMatchesScreenContent extends StatefulWidget {
  const MyMatchesScreenContent({super.key});

  @override
  State<MyMatchesScreenContent> createState() => _MyMatchesScreenContentState();
}

class _MyMatchesScreenContentState extends State<MyMatchesScreenContent>
    with WidgetsBindingObserver {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _currentUserId;
  // Set to track expanded state of match cards (similar to FindTeamScreen)
  final Set<String> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUserId();
    // Fetch teams when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
      // Call fetchAllTeams with userId to get user-specific teams
      teamViewModel.fetchAllTeams();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app resumes
      final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
      teamViewModel.fetchAllTeams();
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final userId = await _secureStorage.read(key: 'userId');
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      // Handle error silently
      setState(() {
        _currentUserId = null;
      });
    }
  }

  // Function to toggle expanded state of a match card (similar to FindTeamScreen)
  void _toggleExpanded(String matchId) {
    setState(() {
      if (_expandedCards.contains(matchId)) {
        _expandedCards.remove(matchId);
      } else {
        _expandedCards.add(matchId);
      }
    });
  }

  // Function to show cancel request confirmation dialog
  void _showCancelRequestConfirmation(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationModal(
          title: 'Xác nhận hủy yêu cầu',
          message: 'Bạn có chắc chắn muốn hủy yêu cầu tham gia trận đấu này?',
          confirmButtonText: 'Hủy yêu cầu',
          confirmButtonColor: Colors.red,
          icon: Icons.cancel,
          iconColor: Colors.red,
          onConfirm: () {
            Navigator.of(context).pop(); // Close dialog
            // Use the same approach as kick/leave functionality
            _kickOrLeaveTeam(match['id'], _currentUserId ?? '', false, 'yêu cầu tham gia');
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  // Function to show cancel match confirmation dialog
  void _showCancelMatchConfirmation(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationModal(
          title: 'Xác nhận hủy trận đấu',
          message: 'Bạn có chắc chắn muốn hủy trận đấu "${match['nameMatch']}"? Hành động này không thể hoàn tác.',
          confirmButtonText: 'Hủy trận đấu',
          confirmButtonColor: Colors.red,
          icon: Icons.cancel,
          iconColor: Colors.red,
          onConfirm: () {
            Navigator.of(context).pop(); // Close dialog
            // Implement actual cancel match functionality using the new ViewModel method
            _deleteTeam(match['id'], match['nameMatch']);
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  // Function to show kick confirmation dialog
  void _showKickConfirmation(Map<String, dynamic> member, Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationModal(
          title: 'Xác nhận loại bỏ thành viên',
          message: 'Bạn có chắc chắn muốn loại ${member['username'] ?? 'người dùng'} khỏi trận đấu?',
          confirmButtonText: 'Loại bỏ',
          confirmButtonColor: Colors.red,
          icon: Icons.delete,
          iconColor: Colors.red,
          onConfirm: () {
            Navigator.of(context).pop(); // Close dialog
            // Implement actual kick functionality using the new ViewModel method
            _kickOrLeaveTeam(match['id'], member['userId'], true, member['username'] ?? 'người dùng');
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  // Function to show leave match confirmation dialog
  void _showLeaveMatchConfirmation(Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationModal(
          title: 'Xác nhận rời khỏi trận đấu',
          message: 'Bạn có chắc chắn muốn rời khỏi trận đấu "${match['nameMatch']}"?',
          confirmButtonText: 'Rời khỏi',
          confirmButtonColor: Colors.red,
          icon: Icons.exit_to_app,
          iconColor: Colors.red,
          onConfirm: () {
            Navigator.of(context).pop(); // Close dialog
            // Implement actual leave match functionality using the new ViewModel method
            _kickOrLeaveTeam(match['id'], _currentUserId ?? '', false, match['nameMatch']);
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  // Function to show accept request confirmation dialog
  void _showAcceptRequestConfirmation(Map<String, dynamic> request, Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationModal(
          title: 'Xác nhận chấp nhận yêu cầu',
          message: 'Bạn có chắc chắn muốn chấp nhận yêu cầu tham gia của ${request['username'] ?? 'người dùng'}?',
          confirmButtonText: 'Chấp nhận',
          confirmButtonColor: Colors.green,
          icon: Icons.check,
          iconColor: Colors.green,
          onConfirm: () {
            Navigator.of(context).pop(); // Close dialog
            _processRequest(request, match, 'APPROVED');
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  // Function to show reject request confirmation dialog
  void _showRejectRequestConfirmation(Map<String, dynamic> request, Map<String, dynamic> match) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationModal(
          title: 'Xác nhận từ chối yêu cầu',
          message: 'Bạn có chắc chắn muốn từ chối yêu cầu tham gia của ${request['username'] ?? 'người dùng'}?',
          confirmButtonText: 'Từ chối',
          confirmButtonColor: Colors.red,
          icon: Icons.close,
          iconColor: Colors.red,
          onConfirm: () {
            Navigator.of(context).pop(); // Close dialog
            _processRequest(request, match, 'REJECTED');
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  // Generic function to process (accept/reject) a join request
  void _processRequest(Map<String, dynamic> request, Map<String, dynamic> match, String status) {
    final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
    
    // Get the teamJoinRequestId from the request
    final String teamJoinRequestId = request['id'] ?? '';
    
    if (teamJoinRequestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy ID yêu cầu'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    // Call the view model method to process the request
    teamViewModel.acceptOrRejectTeamRequest(teamJoinRequestId, status).then((success) {
      if (context.mounted) {
        if (success) {
          // Show success message
          final isApprove = status == 'APPROVED';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isApprove 
                  ? 'Đã chấp nhận yêu cầu tham gia' 
                  : 'Đã từ chối yêu cầu tham gia'),
              backgroundColor: const Color(0xFF7FD957),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          
          // Refresh the teams list
          teamViewModel.fetchAllTeams();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(teamViewModel.errorMessage ?? 
                  (status == 'APPROVED' 
                      ? 'Không thể chấp nhận yêu cầu tham gia' 
                      : 'Không thể từ chối yêu cầu tham gia')),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    });
  }

  // Generic function to kick or leave a team
  void _kickOrLeaveTeam(String teamId, String userId, bool isKick, String userName) {
    final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
    
    if (teamId.isEmpty || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy thông tin trận đấu hoặc người dùng'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    // Call the view model method to kick or leave the team
    teamViewModel.kichOrLeftTeam(teamId, userId, isKick).then((success) {
      if (context.mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isKick 
                  ? 'Đã loại $userName khỏi trận đấu' 
                  : 'Đã rời khỏi trận đấu'),
              backgroundColor: const Color(0xFF7FD957),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(teamViewModel.errorMessage ?? 
                  (isKick 
                      ? 'Không thể loại $userName khỏi trận đấu' 
                      : 'Không thể rời khỏi trận đấu')),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    });
  }

  // Function to delete a team
  void _deleteTeam(String teamId, String teamName) {
    final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
    
    if (teamId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không tìm thấy thông tin trận đấu'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    // Call the view model method to delete the team
    teamViewModel.deleteTeam(teamId).then((success) {
      if (context.mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã hủy trận đấu $teamName'),
              backgroundColor: const Color(0xFF7FD957),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(teamViewModel.errorMessage ?? 'Không thể hủy trận đấu'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: null, // Hide default app bar
      body: SafeArea(
        child: Column(
          children: [
            // Custom header similar to create_match_screen
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7FD957),
                    const Color(0xFF7FD957).withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7FD957).withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trận đấu của tôi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Danh sách trận đấu đã tạo và tham gia',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Content area
            Expanded(
              child: Consumer<TeamViewModel>(
                builder: (context, teamViewModel, child) {
                  if (teamViewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7FD957),
                      ),
                    );
                  }

                  if (teamViewModel.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            teamViewModel.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              teamViewModel.fetchAllTeams();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7FD957),
                            ),
                            child: const Text(
                              'Thử lại',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter teams to show only those where current user is owner, member, or has pending request
                  final List filteredTeams = teamViewModel.teams.where((team) {
                    // Check if current user is the owner
                    final bool isOwner = _currentUserId != null && _currentUserId == team.ownerId;
                    
                    // Check if current user is a member
                    final bool isMember = _currentUserId != null && 
                        team.members.any((member) => member.userId == _currentUserId);
                    
                    // Check if current user has a pending join request
                    final bool hasPendingRequest = _currentUserId != null && 
                        team.teamJoinRequest.any((request) => 
                            request.userId == _currentUserId && request.status == 'PENDING');
                    
                    // Check if current user has a rejected join request
                    final bool hasRejectedRequest = _currentUserId != null && 
                        team.teamJoinRequest.any((request) => 
                            request.userId == _currentUserId && request.status == 'REJECTED');
                    
                    // Show team if user is owner, member, or has pending request
                    // But don't show if they only have a rejected request (and no pending request)
                    // This prioritizes PENDING requests over REJECTED ones
                    if (isOwner || isMember) {
                      // Owners and members always see the team
                      return true;
                    } else if (hasPendingRequest) {
                      // Users with pending requests see the team
                      return true;
                    } else if (hasRejectedRequest && !hasPendingRequest) {
                      // Users with only rejected requests (and no pending) don't see the team
                      return false;
                    } else {
                      // Users with no relationship to the team don't see it
                      return false;
                    }
                  }).toList();

                  if (filteredTeams.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = filteredTeams[index];
                      // Convert Team model to Map for compatibility with existing _buildMatchCard
                      final teamMap = team.toJson();
                      return _buildMatchCard(context, teamMap);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'Bạn chưa tham gia trận đấu nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hãy tạo hoặc tham gia một trận đấu để bắt đầu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to create match screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7FD957),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tạo trận đấu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Map<String, dynamic> match) {
    // Parse date
    final DateTime matchTime = match['timeMatch'] is String 
        ? DateTime.parse(match['timeMatch']) 
        : match['timeMatch'] as DateTime;
    final DateTime now = DateTime.now();
    final String formattedDate = 
        '${matchTime.day}/${matchTime.month}/${matchTime.year}';
    final String formattedTime = 
        '${matchTime.hour.toString().padLeft(2, '0')}:${matchTime.minute.toString().padLeft(2, '0')}';
    
    // Check if match has ended
    final bool isMatchEnded = matchTime.isBefore(now);
    
    // Check if team is full
    final int currentPlayers = (match['members'] as List).length + 1; // +1 for owner
    final bool isTeamFull = currentPlayers >= match['maxPlayers'];
    
    // Determine team status for badge
    String statusText = '';
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.withOpacity(0.1);
    
    if (isMatchEnded) {
      statusText = 'Đã kết thúc';
      statusColor = Colors.red;
      statusBgColor = Colors.red.withOpacity(0.1);
    } else if (isTeamFull) {
      statusText = 'Đã đầy';
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withOpacity(0.1);
    } else {
      statusText = 'Đang tuyển';
      statusColor = const Color(0xFF7FD957);
      statusBgColor = const Color(0xFF7FD957).withOpacity(0.1);
    }
    
    // Check if current user is the owner
    final bool isOwner = _currentUserId != null && _currentUserId == match['ownerId'];
    
    // Check if current user is a member (in the members list)
    final bool isMember = _currentUserId != null && 
        (match['members'] as List).any((member) => member['userId'] == _currentUserId);
    
    // Check if current user has a pending join request
    final bool hasPendingRequest = _currentUserId != null && 
        (match['teamJoinRequest'] as List).any((request) => 
            request['userId'] == _currentUserId && request['status'] == 'PENDING');
    
    // Check if current user has a rejected join request
    final bool hasRejectedRequest = _currentUserId != null && 
        (match['teamJoinRequest'] as List).any((request) => 
            request['userId'] == _currentUserId && request['status'] == 'REJECTED');
    
    // Get sport icon
    IconData sportIcon = Icons.sports;
    switch(match['nameSport']) {
      case 'Football':
      case 'Bóng đá':
        sportIcon = Icons.sports_soccer;
        break;
      case 'Basketball':
      case 'Bóng rổ':
        sportIcon = Icons.sports_basketball;
        break;
      case 'Tennis':
        sportIcon = Icons.sports_tennis;
        break;
      default:
        sportIcon = Icons.sports;
    }
    
    // Get level info
    final String level = match['level'] ?? 'UNKNOWN';
    String levelText = 'Không xác định';
    Color levelColor = Colors.grey;
    Color levelBgColor = Colors.grey.withOpacity(0.1);
    
    switch(level) {
      case 'LOW':
        levelText = 'Mới chơi';
        levelColor = Colors.green;
        levelBgColor = Colors.green.withOpacity(0.1);
        break;
      case 'MEDIUM':
        levelText = 'Trung bình';
        levelColor = Colors.orange;
        levelBgColor = Colors.orange.withOpacity(0.1);
        break;
      case 'HIGH':
        levelText = 'Chuyên nghiệp';
        levelColor = Colors.red;
        levelBgColor = Colors.red.withOpacity(0.1);
        break;
    }
    
    // Check if this card is expanded (similar to FindTeamScreen)
    final bool isExpanded = _expandedCards.contains(match['id']);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with sport icon and team name
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF7FD957).withOpacity(0.12),
                  const Color(0xFF7FD957).withOpacity(0.08),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7FD957).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    sportIcon,
                    color: const Color(0xFF7FD957),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match name with icon
                      Row(
                        children: [
                          const Icon(
                            Icons.sports_soccer,
                            color: Color(0xFF7FD957),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              match['nameMatch'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Organizer/Participation status with icon
                      Row(
                        children: [
                          Icon(
                            isOwner ? Icons.star : (hasPendingRequest ? Icons.access_time : Icons.person),
                            color: isOwner ? const Color(0xFF7FD957) : (hasPendingRequest ? Colors.orange : Colors.grey),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOwner ? 'Bạn là người tổ chức' : (hasPendingRequest ? 'Đang chờ xác nhận' : (hasRejectedRequest ? 'Yêu cầu bị từ chối' : 'Bạn đã tham gia')),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isOwner
                                ? const Color(0xFF7FD957)
                                : (hasPendingRequest
                                    ? Colors.orange
                                    : (hasRejectedRequest
                                        ? Colors.red
                                        : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.grey[600])),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badges column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: levelBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        levelText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: levelColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Team details - Collapsed view shows only essential information
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location and time (always visible)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FD957).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF7FD957),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        match['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FD957).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Color(0xFF7FD957),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$formattedDate lúc $formattedTime',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Show "Đã kết thúc" badge if match has ended
                    if (isMatchEnded)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Đã kết thúc',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Player count (always visible)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FD957).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.group,
                        color: Color(0xFF7FD957),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Số người: $currentPlayers/${match['maxPlayers']}', // Show current count
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Show "Đã đầy" badge if team is full
                    if (isTeamFull && !isMatchEnded)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Đã đầy',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Expand/Collapse button (similar to FindTeamScreen)
                Center(
                  child: GestureDetector(
                    onTap: () => _toggleExpanded(match['id']),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Ẩn bớt' : 'Xem thêm',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7FD957),
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: const Color(0xFF7FD957),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Add extra spacing between expand button and expanded content or action buttons
                const SizedBox(height: 20),
                
                // Expanded content (only visible when expanded)
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  
                  // Description
                  if (match['descriptionMatch'] != null && match['descriptionMatch'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mô tả:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          match['descriptionMatch'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.grey[700],
                          ),
                          // Apply truncation preference from memory
                          maxLines: isExpanded ? null : 4,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  
                  // Contact information
                  const Text(
                    'Thông tin liên hệ:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Phone number
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7FD957).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Color(0xFF7FD957),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        match['numberPhone'] ?? 'Chưa cung cấp',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Facebook link
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7FD957).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.facebook,
                          color: Color(0xFF7FD957),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match['linkFacebook'] ?? 'Chưa cung cấp',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Participants section
                  const Text(
                    'Người tham gia:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Owner
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FD957).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7FD957),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${match['ownerName']} (Người tổ chức)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7FD957),
                                ),
                              ),
                              // Show owner email if available
                              if ((match['members'] as List).isNotEmpty && 
                                  (match['members'] as List).any((member) => 
                                      member['userId'] == match['ownerId'] && 
                                      member['email'] != null))
                                Text(
                                  (match['members'] as List)
                                      .firstWhere(
                                        (member) => member['userId'] == match['ownerId'],
                                        orElse: () => {'email': ''}
                                      )['email'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Show kick button for owners to remove themselves (transfer ownership)
                        // Only show if there are other members
                        if (isOwner && (match['members'] as List).length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            onPressed: () {
                              // TODO: Implement transfer ownership or leave functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chức năng rời khỏi trận sẽ được triển khai sau'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Other participants
                  if ((match['members'] as List).isEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Chưa có người tham gia khác',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: (match['members'] as List).map<Widget>((member) {
                        // Skip owner as they're displayed separately
                        if (member['userId'] == match['ownerId']) {
                          return const SizedBox.shrink();
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['username'] ?? 'Người dùng',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (member['email'] != null)
                                      Text(
                                        member['email'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Only show kick button for owners, and not for the owner themselves
                              if (isOwner && member['userId'] != _currentUserId)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  onPressed: () {
                                    _showKickConfirmation(member, match);
                                  },
                                ),
                              // Show leave button for the current user if they are a member
                              if (!isOwner && member['userId'] == _currentUserId)
                                IconButton(
                                  icon: const Icon(Icons.exit_to_app, color: Colors.red, size: 18),
                                  onPressed: () {
                                    _showLeaveMatchConfirmation(match);
                                  },
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Team join requests section (only for owners)
                  if (isOwner && match['teamJoinRequest'] != null && (match['teamJoinRequest'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yêu cầu tham gia:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: (match['teamJoinRequest'] as List)
                              .where((request) => request['status'] == 'PENDING') // Only show pending requests
                              .map<Widget>((request) {
                            return Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7FD957).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.person_add,
                                      color: Color(0xFF7FD957),
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          request['username'] ?? 'Người dùng',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Chờ xác nhận',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Show leave button for the current user if they have a pending request
                                  if (request['userId'] == _currentUserId)
                                    IconButton(
                                      icon: const Icon(Icons.exit_to_app, color: Colors.red, size: 18),
                                      onPressed: () {
                                        _showLeaveMatchConfirmation(match);
                                      },
                                    ),
                                  // Action buttons for owner to accept/reject
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green, size: 18),
                                        onPressed: () {
                                          _showAcceptRequestConfirmation(request, match);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                        onPressed: () {
                                          _showRejectRequestConfirmation(request, match);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 20),
                ],
                
                // Action buttons (always visible)
                Row(
                  children: [
                    if (isOwner)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showCancelMatchConfirmation(match); // Use confirmation dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Hủy trận đấu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else if (hasPendingRequest)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showCancelRequestConfirmation(match); // Pass match data
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Hủy yêu cầu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else if (hasRejectedRequest)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: null, // Disabled for rejected requests
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Yêu cầu bị từ chối',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showLeaveMatchConfirmation(match); // Use confirmation dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Rời khỏi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}