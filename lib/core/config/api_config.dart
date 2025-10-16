class ApiConfig {
  // Base URL for the backend API
  static const String baseUrl = 'https://sporthub-gdefgpgtf9h0g6gk.malaysiawest-01.azurewebsites.net';
  
  // API endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String verifyOTPEndpoint = '/api/auth/verifyOTP';
  static const String sendOTPEndpoint = '/api/auth/sendOTP';
  static const String resetPasswordEndpoint = '/api/user/reset-password';
  static const String getProfileEndpoint = '/api/profile/user';
  static const String updateProfileEndpoint = '/api/profile';
  static const String uploadAvatarImage = '/api/images/upload';
  static const String changePasswordEndpoint = '/api/user/change-password';
  static const String getUserPointEndpoint = '/api/point/detail';
  static const String getUserVoucherEndpoint = '/api/user-vouchers';
  static const String exchangeVoucherEndpoint = '/api/user-vouchers/exchange';
  static const String getAllFieldEndpoint = '/api/field';
  static const String getBookingSmallFieldEndpoint = '/api/booking/smallfield-or-field';
  static const String createBookingEndpoint = '/api/booking';
  static const String createPaymentEndpoint = '/api/payment';
  static const String orderCheckStatusEndpoint = '/api/orders/status';
  static const String getOrderUserEndpoint = '/api/orders/user';
  static const String getAllTeamEndpoint = '/api/team/all';

  
  // Timeout configuration (in seconds)
  static const int connectionTimeout = 300; 
  static const int receiveTimeout = 300;
}