class UserModel {
  final String userId;
  final String username;
  final String email;
  final String accessToken;
  final String? nickName;
  final String? fullName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? avatar;
  final String? gender;
  final List<dynamic> addresses;
  final String? information;
  final String? bankNo;
  final String? accountNo;
  final String? bankName;
  final String? qrCode;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.accessToken,
    this.nickName,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.avatar,
    this.gender,
    this.addresses = const [],
    this.information,
    this.bankNo,
    this.accountNo,
    this.bankName,
    this.qrCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      accessToken: json['accessToken'],
      nickName: json['nickName'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
      avatar: json['avatar'],
      gender: json['gender'],
      addresses: json['addresses'] as List<dynamic>? ?? [],
      information: json['information'],
      bankNo: json['bankNo'],
      accountNo: json['accountNo'],
      bankName: json['bankName'],
      qrCode: json['qrCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'accessToken': accessToken,
      'nickName': nickName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'avatar': avatar,
      'gender': gender,
      'addresses': addresses,
      'information': information,
      'bankNo': bankNo,
      'accountNo': accountNo,
      'bankName': bankName,
      'qrCode': qrCode,
    };
  }
}