class VoucherTemplate {
  final int discountValue;
  final int minOrderValue;
  final String image;
  final int exchangePoint;
  final bool active;
  final bool percentage;

  const VoucherTemplate({
    required this.discountValue,
    required this.minOrderValue,
    required this.image,
    required this.exchangePoint,
    required this.active,
    required this.percentage,
  });

  factory VoucherTemplate.fromJson(Map<String, dynamic> json) {
    return VoucherTemplate(
      discountValue: json['discountValue'],
      minOrderValue: json['minOrderValue'],
      image: json['image'],
      exchangePoint: json['exchangePoint'],
      active: json['active'],
      percentage: json['percentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discountValue': discountValue,
      'minOrderValue': minOrderValue,
      'image': image,
      'exchangePoint': exchangePoint,
      'active': active,
      'percentage': percentage,
    };
  }

  String get discountText {
    if (percentage) {
      return '$discountValue%';
    } else {
      return '${(discountValue / 1000).round()}K';
    }
  }

  String get minOrderText {
    return '${(minOrderValue / 1000).round()}K';
  }
}