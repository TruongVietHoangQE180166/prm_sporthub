import 'package:flutter/material.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final TextEditingController _nameMatchController = TextEditingController();
  final TextEditingController _descriptionMatchController = TextEditingController();
  final TextEditingController _nameSportController = TextEditingController();
  final TextEditingController _timeMatchController = TextEditingController();
  final TextEditingController _maxPlayersController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _numberPhoneController = TextEditingController();
  final TextEditingController _linkFacebookController = TextEditingController();
  
  // Level selection
  String _selectedLevel = 'LOW';
  
  // Sport options
  final List<String> _sportOptions = [
    'Bóng đá',
    'Bóng rổ',
    'Cầu lông',
    'Tennis',
    'Bơi lội',
    'Pickleball',
    'Bóng chuyền',
    'Gym',
    'Khác'
  ];
  
  // Level options
  final Map<String, String> _levelOptions = {
    'LOW': 'Mới chơi',
    'MEDIUM': 'Trung bình',
    'HIGH': 'Chuyên nghiệp'
  };

  @override
  void dispose() {
    // Dispose controllers
    _nameMatchController.dispose();
    _descriptionMatchController.dispose();
    _nameSportController.dispose();
    _timeMatchController.dispose();
    _maxPlayersController.dispose();
    _locationController.dispose();
    _numberPhoneController.dispose();
    _linkFacebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
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
                          'Tạo trận đấu',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tạo trận đấu mới',
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
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match name
                      const Text(
                        'Tên trận đấu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameMatchController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên trận đấu',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.title,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên trận đấu';
                          }
                          if (value.length < 3) {
                            return 'Tên trận đấu phải có ít nhất 3 ký tự';
                          }
                          if (value.length > 100) {
                            return 'Tên trận đấu không được vượt quá 100 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      const Text(
                        'Mô tả',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionMatchController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Nhập mô tả trận đấu',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.description,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.length > 500) {
                            return 'Mô tả không được vượt quá 500 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Sport
                      const Text(
                        'Môn thể thao',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _nameSportController.text.isEmpty ? null : _nameSportController.text,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.sports_soccer,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        items: _sportOptions.map((String sport) {
                          return DropdownMenuItem<String>(
                            value: sport,
                            child: Text(sport),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _nameSportController.text = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (_nameSportController.text.isEmpty) {
                            return 'Vui lòng chọn môn thể thao';
                          }
                          return null;
                        },
                        hint: const Text('Chọn môn thể thao'),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date and time
                      const Text(
                        'Thời gian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _timeMatchController,
                        decoration: InputDecoration(
                          hintText: 'Chọn ngày và giờ',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.access_time,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today, color: Color(0xFF7FD957)),
                            onPressed: _selectDateTime,
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn thời gian';
                          }
                          // Validate date format
                          try {
                            DateTime.parse(value);
                          } catch (e) {
                            return 'Định dạng thời gian không hợp lệ';
                          }
                          // Check if date is in the past
                          if (DateTime.parse(value).isBefore(DateTime.now())) {
                            return 'Thời gian không thể là trong quá khứ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Max players
                      const Text(
                        'Số người tối đa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _maxPlayersController,
                        decoration: InputDecoration(
                          hintText: 'Nhập số người tối đa',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.group,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số người tối đa';
                          }
                          final intValue = int.tryParse(value);
                          if (intValue == null) {
                            return 'Vui lòng nhập số hợp lệ';
                          }
                          if (intValue <= 0) {
                            return 'Số người phải lớn hơn 0';
                          }
                          if (intValue > 100) {
                            return 'Số người không được vượt quá 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Location
                      const Text(
                        'Địa điểm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Nhập địa điểm',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.location_on,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập địa điểm';
                          }
                          if (value.length < 5) {
                            return 'Địa điểm phải có ít nhất 5 ký tự';
                          }
                          if (value.length > 200) {
                            return 'Địa điểm không được vượt quá 200 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Level
                      const Text(
                        'Trình độ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.signal_cellular_alt,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        items: _levelOptions.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLevel = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn trình độ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone number
                      const Text(
                        'Số điện thoại',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _numberPhoneController,
                        decoration: InputDecoration(
                          hintText: 'Nhập số điện thoại',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          // Remove spaces and special characters for validation
                          final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)\+\.]'), '');
                          if (cleanedValue.length < 10) {
                            return 'Số điện thoại phải có ít nhất 10 chữ số';
                          }
                          if (cleanedValue.length > 15) {
                            return 'Số điện thoại không được vượt quá 15 chữ số';
                          }
                          // Check if all characters are digits
                          if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
                            return 'Số điện thoại chỉ được chứa chữ số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Facebook link
                      const Text(
                        'Link Facebook',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _linkFacebookController,
                        decoration: InputDecoration(
                          hintText: 'Nhập link Facebook',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.facebook,
                            color: Color(0xFF7FD957),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            // Simple URL validation
                            if (!RegExp(r'^https?:\/\/(?:www\.)?facebook\.com\/.+').hasMatch(value)) {
                              if (!RegExp(r'^https?:\/\/(?:www\.)?fb\.com\/.+').hasMatch(value)) {
                                return 'Vui lòng nhập link Facebook hợp lệ (bắt đầu với https://facebook.com/ hoặc https://fb.com/)';
                              }
                            }
                            if (value.length > 200) {
                              return 'Link không được vượt quá 200 ký tự';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7FD957),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Tạo trận đấu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  // Function to select date and time
  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF7FD957),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        // Format as ISO 8601 string
        final String formattedDateTime = dateTime.toIso8601String();
        
        setState(() {
          _timeMatchController.text = formattedDateTime;
        });
      }
    }
  }

  // Function to submit form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Prepare data
      final Map<String, dynamic> matchData = {
        'nameMatch': _nameMatchController.text,
        'descriptionMatch': _descriptionMatchController.text,
        'nameSport': _nameSportController.text,
        'timeMatch': _timeMatchController.text,
        'maxPlayers': int.parse(_maxPlayersController.text),
        'location': _locationController.text,
        'level': _selectedLevel,
        'numberPhone': _numberPhoneController.text,
        'linkFacebook': _linkFacebookController.text,
      };
      
      // TODO: Send data to API
      // For now, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo trận đấu thành công!'),
          backgroundColor: Color(0xFF7FD957),
        ),
      );
      
      // Navigate back
      Navigator.of(context).pop();
    }
  }
}