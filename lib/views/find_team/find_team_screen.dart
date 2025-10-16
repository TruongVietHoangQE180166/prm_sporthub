import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../view_models/team_view_model.dart';
import 'create_match_screen.dart';
import 'my_matches_screen.dart';
import 'match_detail_screen.dart';

class FindTeamScreen extends StatelessWidget {
  const FindTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeamViewModel(),
      child: const FindTeamScreenContent(),
    );
  }
}

class FindTeamScreenContent extends StatefulWidget {
  const FindTeamScreenContent({super.key});

  @override
  State<FindTeamScreenContent> createState() => _FindTeamScreenContentState();
}

class _FindTeamScreenContentState extends State<FindTeamScreenContent> {
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
      // This will include teamJoinRequest data needed for checking user status
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

  // Function to get disabled button color based on user status
  Color _getDisabledButtonColor(bool isOwner, bool isMember, bool hasPendingRequest, bool isTeamFull, bool isMatchEnded) {
    if (isOwner) {
      return Colors.orange; // Orange for owner
    } else if (isMember) {
      return Colors.red; // Red for member
    } else if (hasPendingRequest) {
      return Colors.orange; // Orange for pending request
    } else if (isTeamFull) {
      return Colors.grey; // Grey for full team
    } else if (isMatchEnded) {
      return Colors.red; // Red for ended match
    }
    return Colors.grey; // Default grey
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: null, // Hide default app bar
      body: SafeArea( // Add SafeArea to handle notches and cutouts properly
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đội bóng...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF7FD957)),
                    suffixIcon: Icon(Icons.tune, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            
            // Action buttons row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyMatchesScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF7FD957),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFF7FD957)),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.sports_soccer, size: 20),
                        label: const Text(
                          'Trận đấu của tôi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateMatchScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7FD957),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Tạo trận đấu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Content area
            Expanded(
              child: Container(
                color: Colors.white,
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
                                teamViewModel.fetchAllTeams(userId: 'public');
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

                    if (teamViewModel.teams.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không có đội bóng nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: teamViewModel.teams.length,
                      itemBuilder: (context, index) {
                        final team = teamViewModel.teams[index];
                        // Convert Team model to Map for compatibility with existing _buildTeamCard
                        final teamMap = team.toJson();
                        return _buildTeamCard(context, teamMap);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, Map<String, dynamic> team) {
    // Parse date
    final DateTime matchTime = team['timeMatch'] is String 
        ? DateTime.parse(team['timeMatch']) 
        : team['timeMatch'] as DateTime;
    final DateTime now = DateTime.now();
    final String formattedDate = 
        '${matchTime.day}/${matchTime.month}/${matchTime.year}';
    final String formattedTime = 
        '${matchTime.hour.toString().padLeft(2, '0')}:${matchTime.minute.toString().padLeft(2, '0')}';
    
    // Check if match has ended
    final bool isMatchEnded = matchTime.isBefore(now);
    
    // Check if team is full
    final int currentPlayers = (team['members'] as List).length + 1; // +1 for owner
    final bool isTeamFull = currentPlayers >= team['maxPlayers'];
    
    // Check if current user is the owner
    final bool isOwner = _currentUserId != null && _currentUserId == team['ownerId'];
    
    // Check if current user is already a member
    final bool isMember = _currentUserId != null && 
        (team['members'] as List).any((member) => member['userId'] == _currentUserId);
    
    // Check if current user has a pending join request
    final bool hasPendingRequest = _currentUserId != null && 
        (team['teamJoinRequest'] as List).any((request) => 
            request['userId'] == _currentUserId && request['status'] == 'PENDING');
    
    // Check if current user has a rejected request
    final bool hasRejectedRequest = _currentUserId != null && 
        (team['teamJoinRequest'] as List).any((request) => 
            request['userId'] == _currentUserId && request['status'] == 'REJECTED');
    
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
    
    // Get sport icon
    IconData sportIcon = Icons.sports;
    switch(team['nameSport']) {
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
    final String level = team['level'] ?? 'UNKNOWN';
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
                              team['nameMatch'],
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
                        // Organizer name with icon
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            team['ownerName'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
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
          
          // Team details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (team['descriptionMatch'] != null && team['descriptionMatch'].isNotEmpty)
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
                        team['descriptionMatch'],
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
                        team['location'],
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
                      'Số người: $currentPlayers/${team['maxPlayers']}', // Show current count
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
                              builder: (context) => MatchDetailScreen(matchData: team),
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (isOwner || isMember || hasPendingRequest || isTeamFull || isMatchEnded) && !hasRejectedRequest ? null : () {
                          // TODO: Implement join team functionality
                          // Users with rejected requests can join as new users
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return _getDisabledButtonColor(isOwner, isMember, hasPendingRequest, isTeamFull, isMatchEnded);
                              }
                              return const Color(0xFF7FD957);
                            },
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        child: Text(
                          isOwner 
                              ? 'Bạn là người tạo' 
                              : (isMember 
                                  ? 'Đã tham gia' 
                                  : (hasPendingRequest 
                                      ? 'Đang chờ xác nhận' 
                                      : (isMatchEnded 
                                          ? 'Đã kết thúc' 
                                          : (isTeamFull ? 'Đã đầy' : 'Tham gia')))),
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