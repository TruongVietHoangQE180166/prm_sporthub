import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../view_models/profile_view_model.dart';
import '../../view_models/auth_view_model.dart';

class ProfileHeader extends StatelessWidget {
  final int userPoints;

  const ProfileHeader({super.key, this.userPoints = 0});

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

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final profileViewModel = context.watch<ProfileViewModel>();
    final user = authViewModel.user;
    final profile = profileViewModel.profile;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF7FD957),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              profile?.avatar != null && profile!.avatar!.isNotEmpty
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profile.avatar!),
                      backgroundColor: Colors.white,
                    )
                  : const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Color(0xFF7FD957)),
                    ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickAndUploadImage(context),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                profile?.username?.isNotEmpty == true
                    ? profile!.username
                    : (user?.username?.isNotEmpty == true ? user!.username : 'Chưa thêm'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: (profile?.username?.isNotEmpty == true || user?.username?.isNotEmpty == true)
                      ? Colors.white
                      : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                user?.email?.isNotEmpty == true ? user!.email! : 'Chưa thêm',
                style: TextStyle(
                  fontSize: 16,
                  color: user?.email?.isNotEmpty == true ? Colors.white70 : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Color(0xFF7FD957), size: 20),
                const SizedBox(width: 8),
                Text(
                  '$userPoints điểm',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7FD957),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}