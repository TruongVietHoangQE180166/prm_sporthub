import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../view_models/team_view_model.dart';
import '../../widgets/custom_confirmation_modal.dart';
import '../../models/team_model.dart';
import 'create_match_screen.dart';
import 'my_matches_screen.dart';

class FindTeamScreen extends StatelessWidget {
  const FindTeamScreen({super.key});

  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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

class _FindTeamScreenContentState extends State<FindTeamScreenContent>
    with WidgetsBindingObserver, RouteAware {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _currentUserId;
  String? _selectedLevelFilter;
  String? _selectedTimeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUserId();
    // Fetch teams when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
      // Call fetchAllTeams without userId to get all public teams
      teamViewModel.fetchAllTeams(userId: 'public');
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
      _refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FindTeamScreen.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void disposeRoute() {
    FindTeamScreen.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh data when returning from other screens
    _refreshData();
  }

  void _refreshData() {
    final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
    teamViewModel.fetchAllTeams(userId: 'public');
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

  // Function to get disabled button color - now returns grey for all disabled states
  Color _getDisabledButtonColor(bool isOwner, bool isMember, bool hasPendingRequest, bool isTeamFull, bool isMatchEnded) {
    // Return grey for all disabled button states as per user preference
    return Colors.grey;
  }

  // Add this new method to track expanded cards
  final Set<String> _expandedCards = {};

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
                        onPressed: () async {
                          // Get the TeamViewModel instance
                          final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
                            
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateMatchScreen(teamViewModel: teamViewModel),
                            ),
                          );
                          // If result is true, it means a team was created successfully
                          if (result == true) {
                            // Refresh data after creating a team
                            _refreshData();
                          }
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
            
            // Filter section with level and time filters stacked vertically
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Level filter dropdown
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLevelFilter,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.signal_cellular_alt, color: Color(0xFF7FD957), size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Trình độ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7FD957),
                                ),
                              ),
                            ],
                          ),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7FD957)),
                        elevation: 16,
                        style: const TextStyle(
                          color: Color(0xFF7FD957),
                          fontSize: 14,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLevelFilter = newValue;
                          });
                        },
                        items: <String?>[null, 'LOW', 'MEDIUM', 'HIGH']
                            .map<DropdownMenuItem<String>>((String? value) {
                          String displayText;
                          if (value == null) {
                            displayText = 'Tất cả trình độ';
                          } else {
                            switch (value) {
                              case 'LOW':
                                displayText = 'Mới chơi';
                                break;
                              case 'MEDIUM':
                                displayText = 'Trung bình';
                                break;
                              case 'HIGH':
                                displayText = 'Chuyên nghiệp';
                                break;
                              default:
                                displayText = value;
                            }
                          }
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                displayText,
                                style: const TextStyle(color: Color(0xFF7FD957)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Time filter dropdown
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTimeFilter,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Color(0xFF7FD957), size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Thời gian',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7FD957),
                                ),
                              ),
                            ],
                          ),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7FD957)),
                        elevation: 16,
                        style: const TextStyle(
                          color: Color(0xFF7FD957),
                          fontSize: 14,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTimeFilter = newValue;
                          });
                        },
                        items: <String?>[null, 'today', 'tomorrow', 'this_week', 'next_week', 'future']
                            .map<DropdownMenuItem<String>>((String? value) {
                          String displayText;
                          if (value == null) {
                            displayText = 'Tất cả thời gian';
                          } else {
                            switch (value) {
                              case 'today':
                                displayText = 'Hôm nay';
                                break;
                              case 'tomorrow':
                                displayText = 'Ngày mai';
                                break;
                              case 'this_week':
                                displayText = 'Tuần này';
                                break;
                              case 'next_week':
                                displayText = 'Tuần sau';
                                break;
                              case 'future':
                                displayText = 'Tương lai';
                                break;
                              default:
                                displayText = value;
                            }
                          }
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                displayText,
                                style: const TextStyle(color: Color(0xFF7FD957)),
                              ),
                            ),
                          );
                        }).toList(),
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

                    // Filter teams based on selected level and time
                    List<Team> filteredTeams = teamViewModel.teams;
                    
                    // Apply level filter
                    if (_selectedLevelFilter != null) {
                      filteredTeams = filteredTeams
                          .where((team) => team.level == _selectedLevelFilter)
                          .toList();
                    }
                    
                    // Apply time filter
                    if (_selectedTimeFilter != null) {
                      filteredTeams = filteredTeams.where((team) {
                        final DateTime matchTime = team.timeMatch;
                        final DateTime now = DateTime.now();
                        
                        switch (_selectedTimeFilter) {
                          case 'today':
                            return matchTime.day == now.day && 
                                   matchTime.month == now.month && 
                                   matchTime.year == now.year;
                          case 'tomorrow':
                            final DateTime tomorrow = now.add(const Duration(days: 1));
                            return matchTime.day == tomorrow.day && 
                                   matchTime.month == tomorrow.month && 
                                   matchTime.year == tomorrow.year;
                          case 'this_week':
                            final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                            final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
                            return matchTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
                                   matchTime.isBefore(endOfWeek.add(const Duration(days: 1)));
                          case 'next_week':
                            final DateTime startOfNextWeek = now.subtract(Duration(days: now.weekday - 1)).add(const Duration(days: 7));
                            final DateTime endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
                            return matchTime.isAfter(startOfNextWeek.subtract(const Duration(days: 1))) && 
                                   matchTime.isBefore(endOfNextWeek.add(const Duration(days: 1)));
                          case 'future':
                            return matchTime.isAfter(now);
                          default:
                            return true;
                        }
                      }).toList();
                    }

                    if (filteredTeams.isEmpty) {
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
                      itemCount: filteredTeams.length,
                      itemBuilder: (context, index) {
                        final team = filteredTeams[index];
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
    
    // Check for pending and rejected requests
    bool hasPendingRequest = false;
    bool hasRejectedRequest = false;
    
    if (_currentUserId != null) {
      final List requests = team['teamJoinRequest'] as List;
      
      // Check for pending requests (priority)
      hasPendingRequest = requests.any((request) => 
          request is Map && 
          request['userId'] == _currentUserId && 
          request['status'] == 'PENDING');
      
      // Only check for rejected if no pending request exists
      if (!hasPendingRequest) {
        hasRejectedRequest = requests.any((request) => 
            request is Map && 
            request['userId'] == _currentUserId && 
            request['status'] == 'REJECTED');
      }
    }
    
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
    
    // Check if this card is expanded
    final bool isExpanded = _expandedCards.contains(team['id']);
    
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
          
          // Expandable content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description (always visible, but truncated)
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
                        maxLines: isExpanded ? null : 2, // Show all lines when expanded
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
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
                
                // Expand button
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedCards.remove(team['id']);
                        } else {
                          _expandedCards.add(team['id']);
                        }
                      });
                    },
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
                
                // Expanded content (only visible when expanded)
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  
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
                        team['numberPhone'] ?? 'Chưa cung cấp',
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
                          team['linkFacebook'] ?? 'Chưa cung cấp',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Participants section title
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
                          child: Text(
                            '${team['ownerName'] ?? 'Unknown'} (Người tổ chức)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7FD957),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Other participants
                  if (team['members'] == null || (team['members'] as List).isEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Chưa có người tham gia khác',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: (team['members'] as List).map<Widget>((member) {
                        // Skip owner as they're displayed separately
                        if (member is Map && member['userId'] == team['ownerId']) {
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
                                child: Text(
                                  member is Map ? (member['username'] ?? 'Người dùng') : 'Người dùng',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
                
                const SizedBox(height: 20),
                
                // Action buttons (only one button now)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (isOwner || isMember || hasPendingRequest || isTeamFull || isMatchEnded) && !hasRejectedRequest ? null : () async {
                          // Implement join team functionality
                          // Users with rejected requests can join as new users
                          final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
                          await teamViewModel.requestJoinTeam(team['id']);
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
                        child: Consumer<TeamViewModel>(
                          builder: (context, teamViewModel, child) {
                            if (teamViewModel.isJoiningTeam && !isOwner && !isMember && !hasPendingRequest && !isTeamFull && !isMatchEnded) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            
                            return Text(
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
                            );
                          },
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