import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/profile_view_model.dart';
import '../../widgets/settings/profile_header.dart';
import '../../widgets/settings/feature_cards.dart';
import '../../widgets/settings/user_info_section.dart';
import '../../widgets/settings/change_password_section.dart';
import '../../widgets/settings/logout_button.dart';
import '../auth/login_screen.dart';
import 'voucher_screen.dart';
import 'order_screen.dart';
import 'app_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = true; // Added loading state
  bool _isProfileLoaded = false; // Track profile loading
  bool _arePointsLoaded = false; // Track points loading
  int _userPoints = 0;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final List<String> _genders = ['Nam', 'Nữ'];
  String _selectedGender = 'Nam';

  @override
  void initState() {
    super.initState();
    _selectedGender = 'Nam'; // Initialize with default value
    _loadProfileData();
    _loadUserPoints();
  }

  void _checkLoadingComplete() {
    if (_isProfileLoaded && _arePointsLoaded) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadProfileData() {
    // Load profile data from the profile view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = context.read<ProfileViewModel>();
      profileViewModel.fetchProfile().then((success) {
        if (success && profileViewModel.profile != null) {
          setState(() {
            _nicknameController.text = profileViewModel.profile!.nickName ?? '';
            _fullnameController.text = profileViewModel.profile!.fullName ?? '';
            _phoneController.text = profileViewModel.profile!.phoneNumber ?? '';
            
            // Format dateOfBirth for display (from ISO 8601 to dd/MM/yyyy)
            if (profileViewModel.profile!.dateOfBirth != null) {
              try {
                // Parse the ISO 8601 date string
                final dateTime = DateTime.parse(profileViewModel.profile!.dateOfBirth!);
                // Format as dd/MM/yyyy
                _dobController.text = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
              } catch (e) {
                // If parsing fails, use the original value
                _dobController.text = profileViewModel.profile!.dateOfBirth ?? '';
              }
            } else {
              _dobController.text = '';
            }
            
            // Map API gender values to UI values
            if (profileViewModel.profile!.gender == 'MALE') {
              _selectedGender = 'Nam';
            } else if (profileViewModel.profile!.gender == 'FEMALE') {
              _selectedGender = 'Nữ';
            } else {
              _selectedGender = profileViewModel.profile!.gender ?? 'Nam';
            }
            
            _isProfileLoaded = true;
            _checkLoadingComplete();
          });
        } else {
          // Even if loading fails, we should stop showing the loading indicator
          setState(() {
            _isProfileLoaded = true;
            _checkLoadingComplete();
          });
        }
      });
    });
  }

  void _loadUserPoints() {
    // Load user points from the profile view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = context.read<ProfileViewModel>();
      profileViewModel.getUserPoint().then((result) {
        if (result != null && result['success'] == true) {
          setState(() {
            _userPoints = result['data'] as int? ?? 0;
            _arePointsLoaded = true;
            _checkLoadingComplete();
          });
        } else {
          // Even if loading fails, we should stop showing the loading indicator
          setState(() {
            _arePointsLoaded = true;
            _checkLoadingComplete();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _fullnameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _toggleChangePassword() {
    setState(() {
      _isChangingPassword = !_isChangingPassword;
    });
  }

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordVisible = !_isNewPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _saveChanges() {
    // Get the ProfileViewModel instance
    final profileViewModel = context.read<ProfileViewModel>();
    
    // Format dateOfBirth for API (ISO 8601 format)
    String? formattedDob;
    if (_dobController.text.isNotEmpty) {
      try {
        // Parse the dd/MM/yyyy format and convert to ISO 8601
        final parts = _dobController.text.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final dateTime = DateTime(year, month, day);
          formattedDob = dateTime.toIso8601String();
        }
      } catch (e) {
        // If parsing fails, use the original value
        formattedDob = _dobController.text;
      }
    }
    
    // Map UI gender values to API values
    String? apiGender;
    if (_selectedGender == 'Nam') {
      apiGender = 'MALE';
    } else if (_selectedGender == 'Nữ') {
      apiGender = 'FEMALE';
    } else {
      apiGender = _selectedGender;
    }
    
    // Get current avatar from profile
    final currentAvatar = context.read<ProfileViewModel>().profile?.avatar;
    
    // Prepare the profile data for update (including all required fields)
    final profileData = {
      'nickName': _nicknameController.text,
      'fullName': _fullnameController.text,
      'phoneNumber': _phoneController.text,
      'dateOfBirth': formattedDob,
      'avatar': currentAvatar, // Include current avatar
      'gender': apiGender,
    };
    
    // Call the updateProfile method
    profileViewModel.updateProfile(profileData).then((success) {
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thông tin đã được cập nhật thành công'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Exit edit mode
        setState(() {
          _isEditing = false;
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileViewModel.errorMessage ?? 'Cập nhật thông tin thất bại'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã có lỗi xảy ra khi cập nhật thông tin'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  void _savePasswordChanges() {
    // Validate passwords
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập mật khẩu hiện tại'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập mật khẩu mới'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mật khẩu phải có ít nhất 6 ký tự'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mật khẩu xác nhận không khớp'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Get the ProfileViewModel instance
    final profileViewModel = context.read<ProfileViewModel>();
    
    // Call the changePassword method
    profileViewModel.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text
    ).then((result) {
      if (result != null && result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mật khẩu đã được thay đổi thành công'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        setState(() {
          _isChangingPassword = false;
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? 'Thay đổi mật khẩu thất bại'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã có lỗi xảy ra khi thay đổi mật khẩu'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  void _cancelChanges() {
    // Reset the controllers to their original values
    _loadProfileData(); // Reload the original profile data

    setState(() {
      _isEditing = false;
    });
  }

  void _cancelPasswordChanges() {
    // Clear password fields
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    setState(() {
      _isChangingPassword = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7FD957), // Use the app's green color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading // Show loading indicator while data is being loaded
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
                ),
              )
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Updated ProfileHeader with user points
                  ProfileHeader(userPoints: _userPoints),
                  const SizedBox(height: 20),
                  const FeatureCards(),
                  const SizedBox(height: 30),
                  UserInfoSection(
                    isEditing: _isEditing,
                    onEditToggle: _toggleEdit,
                    onCancel: _cancelChanges,
                    onSave: _saveChanges,
                    nicknameController: _nicknameController,
                    fullnameController: _fullnameController,
                    phoneController: _phoneController,
                    dobController: _dobController,
                    onSelectDate: _selectDate,
                    genders: _genders,
                    selectedGender: _selectedGender,
                    onGenderChanged: (String? value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  ChangePasswordSection(
                    isChangingPassword: _isChangingPassword,
                    onTogglePasswordChange: _toggleChangePassword,
                    onCancelPasswordChanges: _cancelPasswordChanges,
                    onSavePasswordChanges: _savePasswordChanges,
                    currentPasswordController: _currentPasswordController,
                    newPasswordController: _newPasswordController,
                    confirmPasswordController: _confirmPasswordController,
                    isCurrentPasswordVisible: _isCurrentPasswordVisible,
                    isNewPasswordVisible: _isNewPasswordVisible,
                    isConfirmPasswordVisible: _isConfirmPasswordVisible,
                    onToggleCurrentPasswordVisibility: _toggleCurrentPasswordVisibility,
                    onToggleNewPasswordVisibility: _toggleNewPasswordVisibility,
                    onToggleConfirmPasswordVisibility: _toggleConfirmPasswordVisibility,
                  ),
                  const SizedBox(height: 30),
                  const LogoutButton(),
                  const SizedBox(height: 30),
                  // Add extra padding at the bottom to prevent overlap with bottom navigation bar
                  const SizedBox(height: 60),
                ],
              ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final profileViewModel = context.read<ProfileViewModel>();
    
    try {
      // Pick image from gallery
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Reduce quality to decrease file size
      );

      if (pickedFile != null) {
        // Show loading indicator
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7FD957)),
                ),
              );
            },
          );
        }

        // Read image as base64 for the API (but we'll send as multipart file)
        final String imagePath = pickedFile.path;

        // Upload image
        print('=== STARTING IMAGE UPLOAD ===');
        final result = await profileViewModel.uploadAvatarImage(imagePath);
        print('=== IMAGE UPLOAD RESULT ===');
        print('Result: $result');

        // Close loading indicator
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (result != null && result['success'] == true && context.mounted) {
          print('=== UPLOAD SUCCESS, UPDATING PROFILE ===');
          // Update profile with new avatar URL
          final avatarUrl = result['data'] as String?;
          print('Avatar URL: $avatarUrl');
          
          if (avatarUrl != null) {
            // Get current profile data
            final currentProfile = profileViewModel.profile;
            print('Current Profile: $currentProfile');
            
            // Map API gender values to ensure correct format
            String? apiGender = currentProfile?.gender;
            if (apiGender == 'Nam') {
              apiGender = 'MALE';
            } else if (apiGender == 'Nữ') {
              apiGender = 'FEMALE';
            }
            
            final profileData = {
              'nickName': currentProfile?.nickName ?? '',
              'fullName': currentProfile?.fullName ?? '',
              'phoneNumber': currentProfile?.phoneNumber ?? '',
              'dateOfBirth': currentProfile?.dateOfBirth,
              'avatar': avatarUrl, // Use new avatar URL
              'gender': apiGender,
            };
            
            print('Profile Data to Update: $profileData');

            final success = await profileViewModel.updateProfile(profileData);
            print('=== PROFILE UPDATE RESULT ===');
            print('Success: $success');
            
            if (success && context.mounted) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ảnh đại diện đã được cập nhật thành công'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              // Reload user points after profile update
              _loadUserPoints();
            } else if (context.mounted) {
              // Show error message
              print('=== PROFILE UPDATE FAILED ===');
              print('Error Message: ${profileViewModel.errorMessage}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(profileViewModel.errorMessage ?? 'Cập nhật ảnh đại diện thất bại'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else {
            print('=== NO AVATAR URL ===');
          }
        } else if (context.mounted) {
          print('=== UPLOAD FAILED ===');
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['message'] ?? 'Tải ảnh lên thất bại'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        print('=== NO FILE SELECTED ===');
      }
    } catch (e) {
      print('=== EXCEPTION IN UPLOAD PROCESS ===');
      print('Error: $e');
      // Close loading indicator if it's still open
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã có lỗi xảy ra khi chọn ảnh'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}