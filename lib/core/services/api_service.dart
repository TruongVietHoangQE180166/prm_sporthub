import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // Login API call
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');

      final requestBody = {
        'username': username,
        'password': password,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Đăng nhập thành công',
            'data': {
              'userId': userData['userId'],
              'username': userData['username'],
              'email': userData['email'],
              'accessToken': userData['accessToken'],
            }
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Đăng nhập thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Đăng nhập thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Register API call
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');

      final requestBody = {
        'username': username,
        'password': password,
        'email': email,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          // For registration, we only need to confirm success, not store user data
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Đăng ký thành công',
          };
        } else {
          return {
            'success': false,
            'message':
                responseData['message']?['messageDetail'] ?? 'Đăng ký thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Đăng ký thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Fetch home data
  Future<List<Map<String, dynamic>>> fetchHomeData() async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock data cho home screen
    return [
      {'id': 1, 'title': 'Item 1', 'description': 'Mô tả item 1'},
      {'id': 2, 'title': 'Item 2', 'description': 'Mô tả item 2'},
      {'id': 3, 'title': 'Item 3', 'description': 'Mô tả item 3'},
      {'id': 4, 'title': 'Item 4', 'description': 'Mô tả item 4'},
      {'id': 5, 'title': 'Item 5', 'description': 'Mô tả item 5'},
    ];
  }

  // Verify OTP API call
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyOTPEndpoint}');

      final requestBody = {
        'email': email,
        'otp': otp,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          // For OTP verification, we only need to confirm success, not store user data
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Xác minh OTP thành công',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Xác minh OTP thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Xác minh OTP thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Send OTP API call
  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendOTPEndpoint}');

      final requestBody = {
        'email': email,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          // For sending OTP, we only need to confirm success
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Gửi OTP thành công',
          };
        } else {
          return {
            'success': false,
            'message':
                responseData['message']?['messageDetail'] ?? 'Gửi OTP thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Gửi OTP thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Reset Password API call
  Future<Map<String, dynamic>> resetPassword(
      String otp, String email, String newPassword) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resetPasswordEndpoint}');

      final requestBody = {
        'otp': otp,
        'email': email,
        'newPassword': newPassword,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          // For password reset, we only need to confirm success
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Đặt lại mật khẩu thành công',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Đặt lại mật khẩu thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Đặt lại mật khẩu thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Change Password API call
  Future<Map<String, dynamic>> changePassword(
      String accessToken, String oldPassword, String newPassword) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.changePasswordEndpoint}');

      final requestBody = {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Thay đổi mật khẩu thành công',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Thay đổi mật khẩu thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Thay đổi mật khẩu thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Get Profile API call
  Future<Map<String, dynamic>> getProfile(
      String userId, String accessToken) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.getProfileEndpoint}/$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin profile thành công',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin profile thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Lấy thông tin profile thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Get User Point API call
  Future<Map<String, dynamic>> getUserPoint(String accessToken) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserPointEndpoint}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin điểm thành công',
            'data': responseData['data']
                ['currentPoints'], // Only return currentPoints
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin điểm thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Lấy thông tin điểm thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Update Profile API call
  Future<Map<String, dynamic>> updateProfile(
      String accessToken, Map<String, dynamic> profileData) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateProfileEndpoint}');

      // Filter only the required fields
      final filteredData = {
        'nickName': profileData['nickName'],
        'fullName': profileData['fullName'],
        'phoneNumber': profileData['phoneNumber'],
        'dateOfBirth': profileData['dateOfBirth'],
        'avatar': profileData['avatar'],
        'gender': profileData['gender'],
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(filteredData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Cập nhật thông tin profile thành công',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Cập nhật thông tin profile thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Cập nhật thông tin profile thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Upload Avatar Image API call
  Future<Map<String, dynamic>> uploadAvatarImage(
      String accessToken, String imagePath) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadAvatarImage}');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
      });

      // Add image as multipart file with the correct field name "file"
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // field name - changed from 'image' to 'file'
        imagePath,
        filename: 'avatar.png',
      );
      request.files.add(multipartFile);

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);

        // Handle the actual API response structure
        // Note: The API returns success: false even when successful, so we check for data
        final hasData = responseData['data'] != null;
        return {
          'success': hasData, // Changed from responseData['success'] to hasData
          'message': responseData['message']?['messageDetail'] ?? '',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              'Upload ảnh thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Exchange Voucher API call
  Future<Map<String, dynamic>> exchangeVoucher(
      String accessToken, Map<String, dynamic> voucherTemplate) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.exchangeVoucherEndpoint}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(voucherTemplate),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        return {
          'success': true,
          'message': responseData['message']?['messageDetail'] ??
              'Đổi voucher thành công',
        };
      } else {
        return {
          'success': false,
          'message':
              'Đổi voucher thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Get User Voucher API call
  Future<Map<String, dynamic>> getUserVoucher(
      String accessToken, String userId) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserVoucherEndpoint}');

      // Add query parameters
      final uri = Uri(
        scheme: url.scheme,
        host: url.host,
        port: url.port,
        path: url.path,
        queryParameters: {
          'page': '1',
          'size': '1000',
          'field': 'createdDate',
          'direction': 'desc',
          'userId': userId,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          // Extract the content array which contains the user vouchers
          final content = responseData['data']['content'] as List;
          final userVouchers =
              content.map((item) => item as Map<String, dynamic>).toList();

          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin voucher thành công',
            'data': userVouchers,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin voucher thất bại',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Lấy thông tin voucher thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Get All Fields API call
  Future<Map<String, dynamic>> getAllFields(String accessToken) async {
    print('=== ApiService.getAllFields ===');
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getAllFieldEndpoint}');
      print('API URL: $url');

      // Add query parameters
      final uri = Uri(
        scheme: url.scheme,
        host: url.host,
        port: url.port,
        path: url.path,
        queryParameters: {
          'page': '1',
          'size': '1000',
          'field': 'createdDate',
          'direction': 'desc',
        },
      );
      print('Full URI with params: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response body: ${response.body}');

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          // Extract the content array which contains the fields
          final content = responseData['data']['content'] as List;
          print('Content array length: ${content.length}');

          // Debug: Print first item structure
          if (content.isNotEmpty) {
            print('First field structure: ${content[0]}');
          }

          final fields =
              content.map((item) => item as Map<String, dynamic>).toList();

          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin sân thành công',
            'data': fields,
          };
        } else {
          print('API returned success=false or data is null');
          print('Response data: $responseData');
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin sân thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Lấy thông tin sân thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in getAllFields: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Get Booking for Small Field API call
  Future<Map<String, dynamic>> getBookingSmallField(
      String accessToken, String smallFieldIdOrFieldId) async {
    print('=== ApiService.getBookingSmallField ===');
    try {
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.getBookingSmallFieldEndpoint}');
      print('API URL: $url');

      // Add query parameters
      final uri = Uri(
        scheme: url.scheme,
        host: url.host,
        port: url.port,
        path: url.path,
        queryParameters: {
          'page': '1',
          'size': '100',
          'field': 'createdDate',
          'direction': 'desc',
          'smallFieldIdOrFieldId': smallFieldIdOrFieldId,
        },
      );
      print('Full URI with params: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response body: ${response.body}');

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          // Extract the content array which contains the bookings
          final content = responseData['data']['content'] as List;
          print('Content array length: ${content.length}');

          // Debug: Print first item structure
          if (content.isNotEmpty) {
            print('First booking structure: ${content[0]}');
          }

          final bookings =
              content.map((item) => item as Map<String, dynamic>).toList();

          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin đặt sân thành công',
            'data': bookings,
          };
        } else {
          print('API returned success=false or data is null');
          print('Response data: $responseData');
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin đặt sân thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Lấy thông tin đặt sân thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in getBookingSmallField: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Create Booking API call
  Future<Map<String, dynamic>> createBooking(String accessToken,
      String smallFieldId, List<DateTime> startTimes) async {
    print('=== ApiService.createBooking ===');
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createBookingEndpoint}');
      print('API URL: $url');

      // Format DateTime objects to ISO 8601 strings
      final formattedStartTimes =
          startTimes.map((dateTime) => dateTime.toIso8601String()).toList();

      final requestBody = {
        'smallFieldId': smallFieldId,
        'startTimes': formattedStartTimes,
      };

      print('Request body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Đặt sân thành công',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message':
                responseData['message']?['messageDetail'] ?? 'Đặt sân thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Đặt sân thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in createBooking: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Create Payment API call
  Future<Map<String, dynamic>> createPayment(
      String accessToken, List<String> bookingIds, String code) async {
    print('=== ApiService.createPayment ===');
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createPaymentEndpoint}');
      print('API URL: $url');

      // Create request body
      final Map<String, dynamic> requestBody = {
        'bookingId': bookingIds,
      };

      // Only include code field if it's not empty
      if (code.isNotEmpty) {
        requestBody['code'] = code;
      }

      print('Request body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Tạo thanh toán thành công',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Tạo thanh toán thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Tạo thanh toán thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in createPayment: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Check Order Status API call
  Future<Map<String, dynamic>> checkOrderStatus(
      String accessToken, String orderId) async {
    print('=== ApiService.checkOrderStatus ===');
    try {
      // Create URL with orderId as query parameter instead of path parameter
      final uri = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.orderCheckStatusEndpoint}');
      final url = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port,
        path: uri.path,
        queryParameters: {
          'orderId': orderId,
        },
      );
      print('API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy trạng thái đơn hàng thành công',
            'data':
                responseData['data'], // This will be a string like "PENDING"
          };
        } else {
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy trạng thái đơn hàng thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Lấy trạng thái đơn hàng thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in checkOrderStatus: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Get User Orders API call
  Future<Map<String, dynamic>> getUserOrders(
      String accessToken, String userId) async {
    print('=== ApiService.getUserOrders ===');
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getOrderUserEndpoint}');
      print('API URL: $url');

      // Add query parameters
      final uri = Uri(
        scheme: url.scheme,
        host: url.host,
        port: url.port,
        path: url.path,
        queryParameters: {
          'page': '1',
          'size': '1000',
          'field': 'createdDate',
          'direction': 'desc',
          'userId': userId,
        },
      );
      print('Full URI with params: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          // Extract the content array which contains the orders
          final content = responseData['data']['content'] as List;
          print('Orders content array length: ${content.length}');

          // Debug: Print first item structure
          if (content.isNotEmpty) {
            print('First order structure: ${content[0]}');
          }

          final orders =
              content.map((item) => item as Map<String, dynamic>).toList();

          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin đơn hàng thành công',
            'data': orders,
          };
        } else {
          print('API returned success=false or data is null');
          print('Response data: $responseData');
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin đơn hàng thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Lấy thông tin đơn hàng thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in getUserOrders: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Get All Teams API call
  Future<Map<String, dynamic>> getAllTeams(
    String accessToken,
    String userId, {
    required int page,
    required int size,
    required String field,
    required String direction,
  }) async {
    print('=== ApiService.getAllTeams ===');
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getAllTeamEndpoint}');
      print('API URL: $url');

      // Add query parameters
      final uri = Uri(
        scheme: url.scheme,
        host: url.host,
        port: url.port,
        path: url.path,
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          'field': field,
          'direction': direction,
          'userId': userId,
        },
      );
      print('Full URI with params: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          // Extract the content array which contains the teams
          final content = responseData['data']['content'] as List;
          print('Teams content array length: ${content.length}');

          // Debug: Print first item structure
          if (content.isNotEmpty) {
            print('First team structure: ${content[0]}');
          }

          final teams =
              content.map((item) => item as Map<String, dynamic>).toList();

          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin đội nhóm thành công',
            'data': teams,
          };
        } else {
          print('API returned success=false or data is null');
          print('Response data: $responseData');
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin đội nhóm thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Lấy thông tin đội nhóm thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in getAllTeams: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  // Get All Teams Public API call (without userId)
  Future<Map<String, dynamic>> getAllTeamsPublic(
    String accessToken, {
    required int page,
    required int size,
    required String field,
    required String direction,
  }) async {
    print('=== ApiService.getAllTeamsPublic ===');
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getAllTeamEndpoint}');
      print('API URL: $url');

      // Add query parameters (without userId)
      final uri = Uri(
        scheme: url.scheme,
        host: url.host,
        port: url.port,
        path: url.path,
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          'field': field,
          'direction': direction,
        },
      );
      print('Full URI with params: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Handle the actual API response structure
        if (responseData['success'] == true && responseData['data'] != null) {
          // Extract the content array which contains the teams
          final content = responseData['data']['content'] as List;
          print('Teams content array length: ${content.length}');

          // Debug: Print first item structure
          if (content.isNotEmpty) {
            print('First team structure: ${content[0]}');
          }

          final teams =
              content.map((item) => item as Map<String, dynamic>).toList();

          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin đội nhóm thành công',
            'data': teams,
          };
        } else {
          print('API returned success=false or data is null');
          print('Response data: $responseData');
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Lấy thông tin đội nhóm thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Lấy thông tin đội nhóm thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in getAllTeamsPublic: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  Future<Map<String, dynamic>> requestJoinTeam(
      String accessToken, String teamId) async {
    print('=== ApiService.requestJoinTeam ===');
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.requestTeamEndpoint}');
      print('API URL: $url');

      // Add query parameters
      final uri = Uri(
        scheme: url.scheme,
        host: url.host,
        port: url.port,
        path: url.path,
        queryParameters: {
          'teamId': teamId,
        },
      );
      print('Full URI with params: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          // For join requests, data might be null which is normal
          List<Map<String, dynamic>> teams = [];
          if (responseData['data'] != null) {
            // Extract the content array which contains the teams
            final content = responseData['data']['content'] as List;
            print('Teams content array length: ${content.length}');

            // Debug: Print first item structure
            if (content.isNotEmpty) {
              print('First team structure: ${content[0]}');
            }

            teams = content.map((item) => item as Map<String, dynamic>).toList();
          }

          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'yêu cầu tham gia đội nhóm thành công',
            'data': teams,
          };
        } else {
          print('API returned success=false');
          print('Response data: $responseData');
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'yêu cầu tham gia đội nhóm thất bại',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'yêu cầu tham gia đội nhóm thất bại với mã trạng thái: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in requestJoinTeam: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối đến máy chủ',
      };
    }
  }

  /// Accept or reject a team join request
  /// 
  /// Parameters:
  /// - accessToken: User's access token for authentication
  /// - teamJoinRequestId: ID of the join request to process
  /// - status: Either 'APPROVED' or 'REJECTED'
  ///
  /// Returns a standard API response with success flag and message
  Future<Map<String, dynamic>> acceptOrRejectTeamRequest(
      String accessToken, String teamJoinRequestId, String status) async {
    print('=== ApiService.acceptOrRejectTeamRequest ===');
    print('teamJoinRequestId: $teamJoinRequestId');
    print('status: $status');
    
    try {
      // Construct the URL with the teamJoinRequestId in the path and status as query parameter
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.acceptOrRejectTeamRequestEndpoint}/$teamJoinRequestId');
      
      // Add status as query parameter
      final uri = Uri(
        scheme: url.scheme,
        host: url.host,
        port: url.port,
        path: url.path,
        queryParameters: {
          'status': status, // Either 'APPROVED' or 'REJECTED'
        },
      );
      
      print('API URL: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                'Join request has been processed',
            'data': responseData['data'],
          };
        } else {
          print('API returned success=false');
          print('Response data: $responseData');
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                'Failed to process join request',
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              'Failed to process join request with status code: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in acceptOrRejectTeamRequest: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'An error occurred while connecting to the server',
      };
    }
  }

  /// Kick or leave a team
  /// 
  /// Parameters:
  /// - accessToken: User's access token for authentication
  /// - teamId: ID of the team to kick/leave
  /// - userId: ID of the user to kick or the user leaving
  /// - isKick: true if kicking another user, false if leaving the team
  ///
  /// Returns a standard API response with success flag and message
  Future<Map<String, dynamic>> kichOrLeftTeam(
      String accessToken, String teamId, String userId, bool isKick) async {
    print('=== ApiService.kichOrLeftTeam ===');
    print('teamId: $teamId');
    print('userId: $userId');
    print('isKick: $isKick');
    
    try {
      // Construct the URL with teamId and userId in the path and isKick as query parameter
      final baseUrl = '${ApiConfig.baseUrl}${ApiConfig.kichOrLeftTeamEndpoint}'
          .replaceAll('{teamId}', teamId)
          .replaceAll('{userId}', userId);
      
      // Add isKick as a query parameter
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'isKick': isKick.toString(),
      });
      
      print('API URL: $uri');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Handle the actual API response structure
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message']?['messageDetail'] ??
                (isKick ? 'User has been kicked from the team' : 'User left the team'),
            'data': responseData['data'],
          };
        } else {
          print('API returned success=false');
          print('Response data: $responseData');
          return {
            'success': false,
            'message': responseData['message']?['messageDetail'] ??
                (isKick ? 'Failed to kick user from the team' : 'Failed to leave the team'),
          };
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message':
              '${isKick ? 'Failed to kick user from the team' : 'Failed to leave the team'} with status code: ${response.statusCode}',
        };
      }
    } catch (error, stackTrace) {
      print('Exception in kichOrLeftTeam: $error');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'An error occurred while connecting to the server',
      };
    }
  }
}
