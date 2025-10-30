import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/order_view_model.dart';
import '../../models/order_model.dart';
import '../../models/booking_model.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late OrderViewModel _orderViewModel;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;
  String? _selectedStatus; // For status filtering

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
      _orderViewModel.fetchUserOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    List<OrderModel> filteredOrders = List.from(orders);

    // Filter by search query (order ID)
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) {
        return order.id.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by date
    if (_selectedDate != null) {
      filteredOrders = filteredOrders.where((order) {
        final orderDate = order.createdDate;
        return orderDate.year == _selectedDate!.year &&
               orderDate.month == _selectedDate!.month &&
               orderDate.day == _selectedDate!.day;
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      filteredOrders = filteredOrders.where((order) {
        return order.status == _selectedStatus;
      }).toList();
    }

    return filteredOrders;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7FD957), // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7FD957), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  void _selectStatus(String status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _clearStatusFilter() {
    setState(() {
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with enhanced design
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
                    color: const Color(0xFF7FD957).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đơn hàng',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Quản lý đơn đặt sân của bạn',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Search bar and filters
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
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
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo mã đơn hàng...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                          size: 22,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date filter
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: _selectedDate != null
                                      ? const Color(0xFF7FD957)
                                      : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? 'Ngày: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                        : 'Chọn ngày tạo đơn',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedDate != null
                                          ? const Color(0xFF7FD957)
                                          : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
                                    ),
                                  ),
                                ),
                                if (_selectedDate != null)
                                  IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                                      size: 20,
                                    ),
                                    onPressed: _clearDateFilter,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Status filter
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          color: _selectedStatus != null
                              ? const Color(0xFF7FD957)
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        if (_selectedStatus == null) ...[
                          Text(
                            'Trạng thái:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status options
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildStatusFilterChip('Tất cả', null),
                                  const SizedBox(width: 8),
                                  _buildStatusFilterChip('Đã hoàn thành', 'COMPLETED'),
                                  const SizedBox(width: 8),
                                  _buildStatusFilterChip('Đang xử lý', 'PENDING'),
                                  const SizedBox(width: 8),
                                  _buildStatusFilterChip('Đã hủy', 'CANCELLED'),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          // Show only selected status and clear button
                          _buildStatusFilterChip(_getStatusText(_selectedStatus!), _selectedStatus!),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: _clearStatusFilter,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Consumer<OrderViewModel>(
                builder: (context, orderViewModel, child) {
                  if (orderViewModel.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7FD957).withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Đang tải đơn hàng...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (orderViewModel.errorMessage != null) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              orderViewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                orderViewModel.fetchUserOrders();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7FD957),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Thử lại',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredOrders = _filterOrders(orderViewModel.orders);

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              _searchQuery.isEmpty && _selectedDate == null && _selectedStatus == null
                                  ? Icons.shopping_bag_outlined 
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _searchQuery.isEmpty && _selectedDate == null && _selectedStatus == null
                                ? 'Chưa có đơn hàng nào'
                                : 'Không tìm thấy đơn hàng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty && _selectedDate == null && _selectedStatus == null
                                ? 'Hãy đặt sân để tạo đơn hàng đầu tiên'
                                : 'Vui lòng thử lại với điều kiện khác',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order, index);
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

  Widget _buildStatusFilterChip(String label, String? statusValue) {
    final bool isSelected = _selectedStatus == statusValue;
    return GestureDetector(
      onTap: () {
        if (statusValue == null) {
          _clearStatusFilter();
        } else {
          _selectStatus(statusValue);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7FD957) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, int index) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
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
          // Order header with gradient
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
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FD957).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Color(0xFF7FD957),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng #${index + 1}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.id,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getOrderStatusColor(order.status),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getOrderStatusColor(order.status).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getOrderStatusText(order.status),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Order details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildOrderInfoRow(
                        Icons.payments_outlined,
                        'Tổng tiền',
                        '${order.totalAmount} VND',
                        isHighlight: true,
                        context: context,
                      ),
                      const SizedBox(height: 14),
                      _buildOrderInfoRow(
                        Icons.access_time_outlined,
                        'Ngày tạo',
                        _formatDateTime(order.createdDate),
                        context: context,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Booking details section with expand/collapse functionality
                _BookingDetailsSection(
                  bookings: order.booking,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoRow(IconData icon, String label, String value, {bool isHighlight = false, BuildContext? context}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlight ? const Color(0xFF7FD957) : (context != null && Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context != null && Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isHighlight ? 16 : 14,
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                  color: isHighlight ? const Color(0xFF7FD957) : (context != null && Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final dayNames = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];
    final monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];

    return '${dayNames[dateTime.weekday - 1]}, ngày ${dateTime.day} ${monthNames[dateTime.month - 1]} ${dateTime.year} lúc ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return const Color(0xFF7FD957);
    }
  }

  String _getOrderStatusText(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'PENDING':
        return 'Đang xử lý';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'PENDING':
        return 'Đang xử lý';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return 'Tất cả';
    }
  }
}

class _BookingDetailsSection extends StatefulWidget {
  final List<BookingModel> bookings;

  const _BookingDetailsSection({required this.bookings});

  @override
  State<_BookingDetailsSection> createState() => _BookingDetailsSectionState();
}

class _BookingDetailsSectionState extends State<_BookingDetailsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF7FD957),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Chi tiết đặt sân',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7FD957).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.bookings.length} sân',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7FD957),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: const Color(0xFF7FD957),
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          Column(
            children: List.generate(
              widget.bookings.length,
              (bookingIndex) {
                final booking = widget.bookings[bookingIndex];
                return _buildBookingCard(booking, bookingIndex);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBookingCard(BookingModel booking, int index) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF7FD957).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7FD957),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7FD957).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Sân ${index + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(booking.status).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field name
                Row(
                  children: [
                    Icon(
                      Icons.stadium_outlined,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        booking.fieldName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Small field name
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    booking.smallFieldName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time and date info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7FD957).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Time information
                      if (booking.startTime != null && booking.endTime != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7FD957).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFF7FD957),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_formatTimeString(booking.startTime!)} - ${_formatTimeString(booking.endTime!)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      if (booking.startTime != null && booking.endTime != null)
                        const SizedBox(height: 12),

                      // Date information
                      if (booking.startTime != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7FD957).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Color(0xFF7FD957),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatDateString(booking.startTime!),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Price
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF7FD957).withOpacity(0.1),
                        const Color(0xFF7FD957).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF7FD957).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments,
                            size: 20,
                            color: const Color(0xFF7FD957),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Thành tiền',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${booking.totalPrice.toInt()} VND',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7FD957),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF7FD957);
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _formatDateString(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final dayNames = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];
    final monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];

    return '${dayNames[dateTime.weekday - 1]}, ngày ${dateTime.day} ${monthNames[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatTimeString(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}