class UserVoucher {
  final Voucher voucher;
  final bool used;

  UserVoucher({
    required this.voucher,
    required this.used,
  });

  factory UserVoucher.fromJson(Map<String, dynamic> json) {
    return UserVoucher(
      voucher: Voucher.fromJson(json['voucher']),
      used: json['used'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucher': voucher.toJson(),
      'used': used,
    };
  }
}

// Remove the User class since it's not needed

class Voucher {
  final String id;
  final String code;
  final double discountValue;
  final double minOrderValue;
  final DateTime createdDate;
  final String? image;
  final int exchangePoint;
  final bool active;
  final bool percentage;

  Voucher({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.minOrderValue,
    required this.createdDate,
    this.image,
    required this.exchangePoint,
    required this.active,
    required this.percentage,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      code: json['code'],
      discountValue: (json['discountValue'] is int) 
          ? (json['discountValue'] as int).toDouble()
          : json['discountValue'].toDouble(),
      minOrderValue: (json['minOrderValue'] is int) 
          ? (json['minOrderValue'] as int).toDouble()
          : json['minOrderValue'].toDouble(),
      createdDate: DateTime.parse(json['createdDate']),
      image: json['image'],
      exchangePoint: (json['exchangePoint'] is double) 
          ? (json['exchangePoint'] as double).toInt()
          : json['exchangePoint'],
      active: json['active'],
      percentage: json['percentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discountValue': discountValue,
      'minOrderValue': minOrderValue,
      'createdDate': createdDate.toIso8601String(),
      'image': image,
      'exchangePoint': exchangePoint,
      'active': active,
      'percentage': percentage,
    };
  }

  String get discountText {
    if (percentage) {
      return '${discountValue.round()}%';
    } else {
      return '${(discountValue / 1000).round()}K';
    }
  }

  String get minOrderText {
    return '${(minOrderValue / 1000).round()}K';
  }
}