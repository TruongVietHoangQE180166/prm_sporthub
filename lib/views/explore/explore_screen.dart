import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/field_view_model.dart';
import '../../models/field_model.dart';
import '../field/field_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isGridView = true;
  int _selectedSportIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 500000); // Default price range
  bool _showPriceFilter = false; // To toggle price filter visibility
  bool _showSortOptions = false; // To toggle sort options visibility
  String _sortOption = 'default'; // default, rating_asc, rating_desc

  final List<Map<String, dynamic>> _sports = [
    {'name': 'Tất cả', 'icon': Icons.sports},
    {'name': 'Bóng Đá', 'icon': Icons.sports_soccer},
    {'name': 'Cầu Lông', 'icon': Icons.sports_tennis_sharp},
    {'name': 'Pickleball', 'icon': Icons.sports_cricket_rounded},
    {'name': 'Bóng Rổ', 'icon': Icons.sports_basketball},
    {'name': 'Bóng Chuyền', 'icon': Icons.sports_volleyball},
    {'name': 'Bơi Lội', 'icon': Icons.pool},
    {'name': 'Tennis', 'icon': Icons.sports_tennis},
    {'name': 'Gym', 'icon': Icons.fitness_center},
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to search controller to trigger filtering when text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce the search to avoid too many rebuilds
    setState(() {
      // This will trigger a rebuild which will call _getFilteredFields
    });
  }

  // Get filtered fields based on selected sport, search text, price range, and sort option
  List<FieldModel> _getFilteredFields(List<FieldModel> allFields) {
    List<FieldModel> filteredFields = List.from(allFields);
    
    // Apply sport filter first
    if (_selectedSportIndex != 0) {
      // Get the selected sport name
      final selectedSport = _sports[_selectedSportIndex]['name'];
      
      // Map sport names to field types (matching the API response format)
      final sportTypeMap = {
        'Bóng Đá': 'Bóng Đá',
        'Cầu Lông': 'Cầu Lông',
        'Pickleball': 'PickleBall', // Fixed the case to match API response
        'Bóng Rổ': 'Bóng Rổ',
        'Bóng Chuyền': 'Bóng Chuyền',
        'Bơi Lội': 'Bơi Lội',
        'Tennis': 'Tennis',
        'Gym': 'Gym',
      };
      
      final fieldType = sportTypeMap[selectedSport];
      
      if (fieldType != null) {
        // Filter fields by type
        filteredFields = filteredFields.where((field) => field.typeFieldName == fieldType).toList();
      }
    }
    
    // Apply search filter
    final searchText = _searchController.text.trim().toLowerCase();
    if (searchText.isNotEmpty) {
      filteredFields = filteredFields.where((field) {
        return field.fieldName.toLowerCase().contains(searchText) || 
               field.location.toLowerCase().contains(searchText);
      }).toList();
    }
    
    // Apply price filter
    filteredFields = filteredFields.where((field) {
      return field.normalPricePerHour >= _priceRange.start && 
             field.normalPricePerHour <= _priceRange.end;
    }).toList();
    
    // Apply sorting
    if (_sortOption == 'rating_asc') {
      filteredFields.sort((a, b) => a.averageRating.compareTo(b.averageRating));
    } else if (_sortOption == 'rating_desc') {
      filteredFields.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    }
    // 'default' sorting keeps the original order from the API
    
    return filteredFields;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FieldViewModel()..fetchAllFields(),
      child: Consumer<FieldViewModel>(
        builder: (context, fieldViewModel, child) {
          // Get filtered fields
          final filteredFields = _getFilteredFields(fieldViewModel.fields);
          
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: SafeArea(
              child: Column(
                children: [
                  // Header with enhanced design (matching order_screen header)
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
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Title with back button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // Back button with enhanced styling
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
                                    'Khám phá',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Khám phá sân thể thao gần bạn',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Search box
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                // Trigger search immediately when text changes
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm sân thể thao...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF7FD957)),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, color: Colors.grey),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Sort and filter buttons row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // Sort button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showSortOptions = !_showSortOptions;
                                      _showPriceFilter = false; // Close price filter when opening sort
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: _showSortOptions 
                                          ? const Color(0xFF7FD957) 
                                          : Colors.white,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.sort,
                                              size: 20,
                                              color: _showSortOptions 
                                                  ? Colors.white 
                                                  : const Color(0xFF7FD957),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Sắp xếp',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _showSortOptions 
                                                    ? Colors.white 
                                                    : const Color(0xFF7FD957),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          _showSortOptions 
                                              ? Icons.expand_less 
                                              : Icons.expand_more,
                                          size: 20,
                                          color: _showSortOptions 
                                              ? Colors.white 
                                              : const Color(0xFF7FD957),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Price filter button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showPriceFilter = !_showPriceFilter;
                                      _showSortOptions = false; // Close sort options when opening price filter
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: _showPriceFilter 
                                          ? const Color(0xFF7FD957) 
                                          : Colors.white,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.price_change,
                                              size: 20,
                                              color: _showPriceFilter 
                                                  ? Colors.white 
                                                  : const Color(0xFF7FD957),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Lọc giá',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _showPriceFilter 
                                                    ? Colors.white 
                                                    : const Color(0xFF7FD957),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          _showPriceFilter 
                                              ? Icons.expand_less 
                                              : Icons.expand_more,
                                          size: 20,
                                          color: _showPriceFilter 
                                              ? Colors.white 
                                              : const Color(0xFF7FD957),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Sort options (shown when toggled)
                        if (_showSortOptions) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sắp xếp theo đánh giá',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _sortOption = 'rating_desc';
                                        _showSortOptions = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _sortOption == 'rating_desc' 
                                            ? const Color(0xFF7FD957).withOpacity(0.1) 
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _sortOption == 'rating_desc' 
                                              ? const Color(0xFF7FD957) 
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_downward,
                                            size: 18,
                                            color: _sortOption == 'rating_desc' 
                                                ? const Color(0xFF7FD957) 
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Đánh giá cao nhất',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: _sortOption == 'rating_desc' 
                                                  ? const Color(0xFF7FD957) 
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _sortOption = 'rating_asc';
                                        _showSortOptions = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _sortOption == 'rating_asc' 
                                            ? const Color(0xFF7FD957).withOpacity(0.1) 
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _sortOption == 'rating_asc' 
                                              ? const Color(0xFF7FD957) 
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_upward,
                                            size: 18,
                                            color: _sortOption == 'rating_asc' 
                                                ? const Color(0xFF7FD957) 
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Đánh giá thấp nhất',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: _sortOption == 'rating_asc' 
                                                  ? const Color(0xFF7FD957) 
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _sortOption = 'default';
                                        _showSortOptions = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _sortOption == 'default' 
                                            ? const Color(0xFF7FD957).withOpacity(0.1) 
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _sortOption == 'default' 
                                              ? const Color(0xFF7FD957) 
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.refresh,
                                            size: 18,
                                            color: _sortOption == 'default' 
                                                ? const Color(0xFF7FD957) 
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Mặc định',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: _sortOption == 'default' 
                                                  ? const Color(0xFF7FD957) 
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Price filter (shown when toggled)
                        if (_showPriceFilter) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Lọc theo giá (VNĐ/giờ)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  RangeSlider(
                                    values: _priceRange,
                                    min: 0,
                                    max: 1000000,
                                    divisions: 100,
                                    activeColor: const Color(0xFF7FD957), // Match app's green color
                                    inactiveColor: Colors.grey[300], // Subtle inactive color
                                    labels: RangeLabels(
                                      '${(_priceRange.start ~/ 1000)}K',
                                      '${(_priceRange.end ~/ 1000)}K',
                                    ),
                                    onChanged: (RangeValues values) {
                                      setState(() {
                                        _priceRange = values;
                                      });
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Từ: ${(_priceRange.start ~/ 1000)}K',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Đến: ${(_priceRange.end ~/ 1000)}K',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Sports categories
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: _sports.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedSportIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _buildSportCategory(
                                  _sports[index]['name'],
                                  _sports[index]['icon'],
                                  isSelected,
                                  index,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  // Content area
                  Expanded(
                    child: fieldViewModel.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF7FD957),
                            ),
                          )
                        : fieldViewModel.errorMessage != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      fieldViewModel.errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        fieldViewModel.fetchAllFields();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7FD957),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Thử lại'),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    // Section header
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Sân gần bạn',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${filteredFields.length} sân phù hợp',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Toggle button
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                _isGridView
                                                    ? Icons.view_list_rounded
                                                    : Icons.grid_view_rounded,
                                                color: const Color(0xFF7FD957),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isGridView = !_isGridView;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Field cards
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: _isGridView
                                          ? LayoutBuilder(
                                              builder: (context, constraints) {
                                                // Ensure proper alignment even with single card
                                                return Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Wrap(
                                                    alignment: WrapAlignment.start,
                                                    spacing: 16,
                                                    runSpacing: 16,
                                                    children: List.generate(
                                                      filteredFields.length,
                                                      (index) {
                                                        final field = filteredFields[index];
                                                        return SizedBox(
                                                          width: (constraints.maxWidth - 16) / 2,
                                                          child: _buildFieldCardFromModel(field),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : ListView.separated(
                                              separatorBuilder: (context, index) =>
                                                  const SizedBox(height: 16),
                                              itemCount: filteredFields.length,
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                final field = filteredFields[index];
                                                return _buildFieldCardFromModel(field);
                                              },
                                            ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSportCategory(String name, IconData icon, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSportIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 85,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7FD957) : Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldCardFromModel(FieldModel field) {
    // Use the first image from the images array as the primary source
    String? imageUrl;
    if (field.images.isNotEmpty) {
      imageUrl = field.images.first;
    } else {
      imageUrl = field.avatar;
    }
    
    return GestureDetector(
      onTap: () {
        // Navigate to field detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldDetailScreen(field: field),
          ),
        );
      },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF7FD957).withOpacity(0.8),
                        const Color(0xFF7FD957),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.sports_soccer,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.sports_soccer,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          field.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.fieldName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          field.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${field.openTime} - ${field.closeTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${field.normalPricePerHour ~/ 1000}K/giờ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7FD957),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to field detail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FieldDetailScreen(field: field),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7FD957),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text(
                          'Đặt sân',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}