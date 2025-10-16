import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../view_models/team_view_model.dart';
import 'my_match_detail_screen.dart';

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

class _MyMatchesScreenContentState extends State<MyMatchesScreenContent> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    // Fetch teams when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
      // Call fetchAllTeams with userId: null to let it retrieve userId from storage
      teamViewModel.fetchAllTeams();
    });
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

  // Function to cancel join request
  void _cancelJoinRequest() {
    // TODO: Implement cancel join request functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng hủy yêu cầu tham gia sẽ được triển khai sau'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
                    
                    // Show team if user is owner, member, or has pending request
                    return isOwner || isMember || hasPendingRequest;
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
    
    // Check if current user is the owner
    final bool isOwner = _currentUserId != null && _currentUserId == match['ownerId'];
    
    // Check if current user is a member (in the members list)
    final bool isMember = _currentUserId != null && 
        (match['members'] as List).any((member) => member['userId'] == _currentUserId);
    
    // Check if current user has a pending join request
    final bool hasPendingRequest = _currentUserId != null && 
        (match['teamJoinRequest'] as List).any((request) => 
            request['userId'] == _currentUserId && request['status'] == 'PENDING');
    
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
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
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
                            isOwner ? 'Bạn là người tổ chức' : (hasPendingRequest ? 'Đang chờ xác nhận' : 'Bạn đã tham gia'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isOwner ? const Color(0xFF7FD957) : (hasPendingRequest ? Colors.orange : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
              ],
            ),
          ),
          
          // Team details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (match['descriptionMatch'] != null && match['descriptionMatch'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mô tả:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        match['descriptionMatch'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
                // Location and time
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
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
                
                // Player count
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
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to match detail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyMatchDetailScreen(matchData: match),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF7FD957)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Xem chi tiết',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7FD957),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isOwner)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement edit match functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Chỉnh sửa',
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
                          onPressed: _cancelJoinRequest,
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
                    else
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement leave match functionality
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