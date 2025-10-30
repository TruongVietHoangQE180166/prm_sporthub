import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../models/field_model.dart';
import '../../models/team_model.dart';
import '../../view_models/field_view_model.dart';
import '../../view_models/team_view_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isLoading = false;
  bool _isInitializing = true;
  String _fieldsData = '';
  String _teamsData = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    setState(() => _isInitializing = true);
    
    try {
      // Fetch dữ liệu sân từ FieldViewModel
      await _fetchFieldsDataFromViewModel();
      
      // Fetch dữ liệu đội từ TeamViewModel
      await _fetchTeamsDataFromViewModel();
      
      // Khởi tạo Gemini với data động
      _initializeGemini();
      
      // Thêm tin nhắn chào mừng
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Xin chào! Mình là trợ lý AI của SportHub - nền tảng đặt sân thể thao số 1 tại Quy Nhơn 🏃‍♂️\n\nMình có thể giúp bạn:\n✅ Tìm và đặt sân bóng đá, pickleball\n✅ Tư vấn sân phù hợp với nhu cầu\n✅ Kiểm tra giá và tình trạng sân\n✅ Tìm bạn chơi thể thao cùng\n\nBạn muốn đặt sân gì hôm nay? 😊',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Xin lỗi, có lỗi khi khởi tạo hệ thống. Vui lòng thử lại sau.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isInitializing = false;
      });
    }
  }

  Future<void> _fetchFieldsDataFromViewModel() async {
    try {
      final fieldViewModel = Provider.of<FieldViewModel>(context, listen: false);
      await fieldViewModel.fetchAllFields();
      
      // Format dữ liệu để AI dễ đọc dựa trên FieldModel thực tế
      _formatFieldsDataForAI(fieldViewModel.fields);
    } catch (e) {
      // Fallback data nếu không connect được API
      _fieldsData = _getDefaultFieldsData();
      print('Error fetching fields data: $e');
    }
  }

  Future<void> _fetchTeamsDataFromViewModel() async {
    try {
      final teamViewModel = Provider.of<TeamViewModel>(context, listen: false);
      await teamViewModel.fetchAllTeams(userId: 'public');
      
      // Format dữ liệu để AI dễ đọc dựa trên TeamModel thực tế
      _formatTeamsDataForAI(teamViewModel.teams);
    } catch (e) {
      // Fallback data nếu không connect được API
      _teamsData = _getDefaultTeamsData();
      print('Error fetching teams data: $e');
    }
  }

  void _formatFieldsDataForAI(List<FieldModel> fields) {
    // Format dữ liệu từ FieldModel để AI dễ đọc
    StringBuffer buffer = StringBuffer();
    buffer.writeln('THÔNG TIN CÁC SÂN HIỆN CÓ:');
    buffer.writeln('');
    
    for (var field in fields) {
      buffer.writeln('---');
      buffer.writeln('ID sân: ${field.id}');
      buffer.writeln('Tên sân: ${field.fieldName}');
      buffer.writeln('Loại sân: ${field.typeFieldName}');
      buffer.writeln('Địa chỉ: ${field.location}');
      buffer.writeln('Giờ mở cửa: ${field.openTime} - ${field.closeTime}');
      buffer.writeln('Giá thường: ${field.normalPricePerHour} VNĐ/giờ');
      buffer.writeln('Giá cao điểm: ${field.peakPricePerHour} VNĐ/giờ');
      buffer.writeln('Mô tả: ${field.description}');
      buffer.writeln('Chủ sở hữu: ${field.ownerName}');
      buffer.writeln('Số điện thoại: ${field.numberPhone ?? "Không có"}');
      buffer.writeln('Tình trạng: ${field.available ? "Đang hoạt động" : "Không khả dụng"}');
      buffer.writeln('Tổng số lượt đặt: ${field.totalBookings}');
      buffer.writeln('Đánh giá trung bình: ${field.averageRating}');
      
      // Thông tin các sân nhỏ
      if (field.smallFieldResponses.isNotEmpty) {
        buffer.writeln('Các sân con:');
        for (var smallField in field.smallFieldResponses) {
          buffer.writeln('  - ${smallField.smallFiledName}: ${smallField.description}, Sức chứa: ${smallField.capacity}, ${smallField.available ? "Còn trống" : "Đã đặt"}');
        }
      }
      buffer.writeln('');
    }
    
    _fieldsData = buffer.toString();
  }

  void _formatTeamsDataForAI(List<Team> teams) {
    // Format dữ liệu từ TeamModel để AI dễ đọc
    StringBuffer buffer = StringBuffer();
    buffer.writeln('THÔNG TIN CÁC ĐỘI BÓNG ĐANG TÌM THÀNH VIÊN:');
    buffer.writeln('');
    
    for (var team in teams) {
      buffer.writeln('---');
      buffer.writeln('ID đội: ${team.id}');
      buffer.writeln('Tên trận đấu: ${team.nameMatch}');
      buffer.writeln('Môn thể thao: ${team.nameSport}');
      buffer.writeln('Địa điểm: ${team.location}');
      buffer.writeln('Thời gian: ${team.timeMatch}');
      buffer.writeln('Trình độ: ${_getLevelText(team.level)}');
      buffer.writeln('Số người hiện tại: ${team.members.length + 1}/${team.maxPlayers}'); // +1 for owner
      buffer.writeln('Người tổ chức: ${team.ownerName}');
      buffer.writeln('Mô tả: ${team.descriptionMatch ?? "Không có mô tả"}');
      buffer.writeln('Số điện thoại liên hệ: ${team.numberPhone ?? "Không có"}');
      buffer.writeln('Link Facebook: ${team.linkFacebook ?? "Không có"}');
      
      // Danh sách thành viên
      if (team.members.isNotEmpty) {
        buffer.writeln('Thành viên đã tham gia:');
        buffer.writeln('  - ${team.ownerName} (Người tổ chức)');
        for (var member in team.members) {
          buffer.writeln('  - ${member.username}');
        }
      } else {
        buffer.writeln('Thành viên đã tham gia: ${team.ownerName} (Người tổ chức)');
      }
      
      buffer.writeln('');
    }
    
    _teamsData = buffer.toString();
  }

  String _getLevelText(String level) {
    switch (level) {
      case 'LOW':
        return 'Mới chơi';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HIGH':
        return 'Chuyên nghiệp';
      default:
        return level;
    }
  }

  String _getDefaultFieldsData() {
    // Dữ liệu mẫu khi không connect được API
    return '''
THÔNG TIN CÁC SÂN HIỆN CÓ:

---
Tên sân: Sân Bóng Đá Mai Hắc Đế
Loại sân: Sân bóng đá 
Địa chỉ: Đường Mai Hắc Đế, Quy Nhơn, Bình Định
Mặt sân: Cỏ nhân tạo cao cấp
Giờ hoạt động: 5:00 - 23:00 hàng ngày
Giá tham khảo: 300,000 - 500,000 VNĐ/giờ (tùy khung giờ)
Tình trạng: Đang hoạt động
Tiện ích: Phòng thay đồ, đèn chiếu sáng, bãi đỗ xe rộng rãi
Đặc điểm: Sân rộng, mát mẻ, phù hợp đá buổi tối

---
Tên sân: Sân Pickleball Quy Nhơn Center
Loại sân: Sân Pickleball chuẩn quốc tế
Địa chỉ: Trung tâm thành phố Quy Nhơn
Số lượng: 4 sân trong nhà có điều hòa
Mặt sân: Sàn gỗ chuyên dụng
Giờ hoạt động: 6:00 - 22:00 hàng ngày
Giá tham khảo: 150,000 - 250,000 VNĐ/giờ
Tình trạng: Đang hoạt động
Tiện ích: Điều hòa, phòng thay đồ, khu vực nghỉ ngơi, cho thuê vợt và bóng
Đặc điểm: Hiện đại, sạch sẽ, phù hợp mọi lứa tuổi

---
Tên sân: Sân Bóng Đá Thông Tin
Loại sân: Sân bóng đá
Địa chỉ: Khu vực Thông Tin, Quy Nhơn
Mặt sân: Cỏ nhân tạo
Giờ hoạt động: 5:30 - 22:30 hàng ngày
Giá tham khảo: 250,000 - 450,000 VNĐ/giờ
Tình trạng: Đang hoạt động
Tiện ích: Đèn chiếu sáng tốt, phòng thay đồ, nước uống miễn phí
Đặc điểm: Gần trung tâm, dễ tìm, giá cả phải chăng
''';
  }

  String _getDefaultTeamsData() {
    // Dữ liệu mẫu khi không connect được API
    return '''
THÔNG TIN CÁC ĐỘI BÓNG ĐANG TÌM THÀNH VIÊN:

---
Tên trận đấu: Giao hữu cuối tuần
Môn thể thao: Bóng đá
Địa điểm: Sân Bóng Đá Mai Hắc Đế
Thời gian: 15/10/2025 lúc 17:00
Trình độ: Trung bình
Số người hiện tại: 8/12
Người tổ chức: Nguyễn Văn A
Mô tả: Đội bóng thân thiện, chơi giao lưu, không tranh chấp. Rất mong bạn mới tham gia!
Số điện thoại liên hệ: 0987654321
Link Facebook: https://facebook.com/nguyenvana

---
Tên trận đấu: Tập luyện Pickleball
Môn thể thao: Pickleball
Địa điểm: Sân Pickleball Quy Nhơn Center
Thời gian: 16/10/2025 lúc 18:00
Trình độ: Mới chơi
Số người hiện tại: 3/6
Người tổ chức: Trần Thị B
Mô tả: Nhóm tập luyện Pickleball cho người mới bắt đầu, hướng dẫn từ cơ bản đến nâng cao.
Số điện thoại liên hệ: 0912345678
Link Facebook: https://facebook.com/tranthib
''';
  }

  void _initializeGemini() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    // System prompt với dữ liệu động từ API
    final systemPrompt = '''Bạn là trợ lý AI chuyên nghiệp của SportHub - nền tảng đặt sân thể thao trực tuyến hàng đầu tại Quy Nhơn, Bình Định.

THÔNG TIN VỀ SPORTHUB:
- SportHub là nền tảng đặt sân trực tuyến chất lượng cao ở Quy Nhơn
- Giúp người dùng dễ dàng tìm kiếm và đặt sân thể thao mọi lúc, mọi nơi
- Thanh toán trực tuyến an toàn, nhanh chóng
- Hỗ trợ 24/7 qua chatbot AI
- Có tính năng tìm bạn chơi thể thao cùng (Tìm đội)

$_fieldsData

$_teamsData

CÁCH TRẢ LỜI:
- Luôn thân thiện, nhiệt tình và chuyên nghiệp
- Sử dụng tiếng Việt tự nhiên, dễ hiểu
- Hỏi thông tin cần thiết: loại sân, ngày giờ muốn đặt, số người chơi
- Gợi ý sân phù hợp dựa trên nhu cầu của khách và DỮ LIỆU THỰC TẾ từ hệ thống
- Nếu có thông tin slot trống, ưu tiên gợi ý những khung giờ đó
- Giải thích rõ ràng về giá cả dựa trên data có sẵn
- Hướng dẫn cách đặt sân qua app SportHub
- Luôn đề xuất giải pháp tham gia đội nếu người dùng muốn tìm bạn chơi cùng
- Luôn đề xuất giải pháp thay thế nếu sân đã kín
- Giới thiệu các ưu đãi, khuyến mãi nếu có trong data

TÍNH NĂNG TÌM BẠN CHƠI THỂ THAO:
- SportHub có tính năng "Tìm đội" giúp người dùng tìm bạn chơi thể thao cùng
- Người dùng có thể tạo trận đấu hoặc tham gia các trận đấu đang tuyển thành viên
- Có thể tìm theo môn thể thao, trình độ, thời gian, địa điểm
- Có thể liên hệ trực tiếp với người tổ chức qua số điện thoại hoặc Facebook

KHUNG GIỜ PHỔ BIẾN:
- Khung giờ sáng (5:00-8:00): Giá thấp, thời tiết mát
- Khung giờ trưa (11:00-14:00): Giá thấp nhất
- Khung giờ chiều (16:00-18:00): Giá trung bình
- Khung giờ tối (18:00-22:00): Giá cao nhất, đông khách

LƯU Ý QUAN TRỌNG:
- Trả lời dựa trên DỮ LIỆU THỰC TẾ được cung cấp ở trên
- Nếu có thông tin tình trạng sân (đang trống/đã kín), sử dụng info đó
- Nếu người dùng muốn tìm bạn chơi cùng, giới thiệu tính năng "Tìm đội" của SportHub
- Nếu không có thông tin cụ thể nào đó, khuyến khích check app để cập nhật real-time
- Luôn đề cập đến SportHub một cách tự nhiên
- Tạo cảm giác thân thiện như một người bạn tư vấn địa phương

Hãy giúp khách hàng tìm được sân phù hợp nhất và kết nối với cộng đồng người chơi thể thao tại Quy Nhơn!''';

    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    _chat = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final responseText = response.text ?? 'Xin lỗi, mình không thể tạo phản hồi lúc này.';

      setState(() {
        _messages.add(
          ChatMessage(
            text: responseText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Xin lỗi, có lỗi xảy ra. Vui lòng thử lại sau.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // Hàm refresh data (gọi khi user muốn cập nhật)
  Future<void> _refreshFieldsData() async {
    await _fetchFieldsDataFromViewModel();
    await _fetchTeamsDataFromViewModel();
    _initializeGemini();
    
    setState(() {
      _messages.add(
        ChatMessage(
          text: 'Đã cập nhật thông tin sân và đội bóng mới nhất! 🔄',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // 🌟 Custom Header (phiên bản phẳng, không bo tròn góc dưới)
Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7FD957),
        Color(0xFF7FD957), // Giữ nguyên tone chủ đạo
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7FD957).withOpacity(0.35),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + Tiêu đề
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.android,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Chat Box AI',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Trợ lý thông minh của bạn',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Nút refresh
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _refreshFieldsData,
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: const [
                    Icon(Icons.refresh, color: Colors.white, size: 24),
                    SizedBox(width: 4),
                    Text(
                      'Làm mới',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),

            
            // Loading indicator khi initialize
            if (_isInitializing)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải thông tin sân và đội bóng...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Chat messages area
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: _TypingIndicator(),
                        );
                      }
                      
                      final message = _messages[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < _messages.length - 1 ? 16 : 0,
                        ),
                        child: _ChatMessageWidget(message: message),
                      );
                    },
                  ),
                ),
              ),
            
            // Message input area
            if (!_isInitializing)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 45),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF7FD957),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: message.isUser
            ? const Color(0xFF7FD957)
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black87),
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            const SizedBox(width: 4),
            _TypingDot(delay: 200),
            const SizedBox(width: 4),
            _TypingDot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade600,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}