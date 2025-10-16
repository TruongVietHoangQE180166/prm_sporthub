class ProfileModel {
  final String id;
  final String userId;
  final String username;
  final String? nickName;
  final String? fullName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? avatar;
  final String? gender;
  final List<dynamic> addresses;
  final dynamic information; // Changed from String? to dynamic to match the API response
  final String? bankNo;
  final String? accountNo;
  final String? bankName;
  final String? qrCode;
  final DateTime createdDate;
  final DateTime updatedDate;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.username,
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
    required this.createdDate,
    required this.updatedDate,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Map API gender values (MALE/FEMALE) to UI values (Nam/Nữ)
    String? mappedGender;
    if (json['gender'] == 'MALE') {
      mappedGender = 'Nam';
    } else if (json['gender'] == 'FEMALE') {
      mappedGender = 'Nữ';
    } else {
      mappedGender = json['gender'] as String?;
    }

    return ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      nickName: json['nickName'] as String?,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      avatar: json['avatar'] as String?,
      gender: mappedGender,
      addresses: json['addresses'] as List<dynamic>? ?? [],
      information: json['information'], // Keep as dynamic
      bankNo: json['bankNo'] as String?,
      accountNo: json['accountNo'] as String?,
      bankName: json['bankName'] as String?,
      qrCode: json['qrCode'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // Map UI gender values (Nam/Nữ) back to API values (MALE/FEMALE)
    String? mappedGender;
    if (gender == 'Nam') {
      mappedGender = 'MALE';
    } else if (gender == 'Nữ') {
      mappedGender = 'FEMALE';
    } else {
      mappedGender = gender;
    }

    return {
      'id': id,
      'userId': userId,
      'username': username,
      'nickName': nickName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'avatar': avatar,
      'gender': mappedGender,
      'addresses': addresses,
      'information': information,
      'bankNo': bankNo,
      'accountNo': accountNo,
      'bankName': bankName,
      'qrCode': qrCode,
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
    };
  }
}