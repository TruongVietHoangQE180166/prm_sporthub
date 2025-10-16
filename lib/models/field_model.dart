class SmallFieldResponse {
  final String id;
  final String createdDate;
  final String smallFiledName;
  final String description;
  final String capacity;
  final bool booked;
  final bool available;

  SmallFieldResponse({
    required this.id,
    required this.createdDate,
    required this.smallFiledName,
    required this.description,
    required this.capacity,
    required this.booked,
    required this.available,
  });

  factory SmallFieldResponse.fromJson(Map<String, dynamic> json) {
    // Debug logging
    print('=== SmallFieldResponse.fromJson ===');
    print('Input JSON: $json');
    
    return SmallFieldResponse(
      id: json['id'] as String,
      createdDate: json['createdDate'] as String,
      smallFiledName: json['smallFiledName'] as String,
      description: json['description'] as String,
      capacity: json['capacity'] as String,
      booked: json['booked'] as bool,
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdDate': createdDate,
      'smallFiledName': smallFiledName,
      'description': description,
      'capacity': capacity,
      'booked': booked,
      'available': available,
    };
  }
}

class FieldModel {
  final String id;
  final String createdDate;
  final String fieldName;
  final String location;
  final double normalPricePerHour;
  final double peakPricePerHour;
  final String openTime;
  final String closeTime;
  final String description;
  final String typeFieldName;
  final String ownerName;
  final String typeFieldId;
  final String? numberPhone;
  final String? avatar;
  final List<String> images;
  final List<dynamic> rateResponses;
  final List<SmallFieldResponse> smallFieldResponses;
  final double averageRating;
  final int totalBookings;
  final bool available;

  FieldModel({
    required this.id,
    required this.createdDate,
    required this.fieldName,
    required this.location,
    required this.normalPricePerHour,
    required this.peakPricePerHour,
    required this.openTime,
    required this.closeTime,
    required this.description,
    required this.typeFieldName,
    required this.ownerName,
    required this.typeFieldId,
    this.numberPhone,
    this.avatar,
    required this.images,
    required this.rateResponses,
    required this.smallFieldResponses,
    required this.averageRating,
    required this.totalBookings,
    required this.available,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    // Debug logging
    print('=== FieldModel.fromJson ===');
    print('Input JSON: $json');
    
    try {
      // Handle smallFieldResponses
      List<SmallFieldResponse> smallFieldResponses = [];
      if (json['smallFieldResponses'] is List) {
        var smallFieldList = json['smallFieldResponses'] as List;
        smallFieldResponses = smallFieldList
            .map((item) => SmallFieldResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      // Handle images array - take first image if available
      List<String> images = [];
      String? firstImage;
      if (json['images'] is List) {
        var imageList = json['images'] as List;
        images = imageList.whereType<String>().toList();
        if (images.isNotEmpty) {
          firstImage = images.first;
        }
      }
      
      // Handle avatar - use first image from images array if avatar is null
      String? avatar = json['avatar'] as String?;
      if (avatar == null && firstImage != null) {
        avatar = firstImage;
      }
      
      // Handle openTime and closeTime
      String openTime = '';
      String closeTime = '';
      
      // Try to get openTime and closeTime directly
      if (json['openTime'] != null) {
        openTime = json['openTime'] as String;
      }
      
      if (json['closeTime'] != null) {
        closeTime = json['closeTime'] as String;
      }
      
      // If they're not directly available, try to parse from a different format
      if (openTime.isEmpty && json['open_time'] != null) {
        openTime = json['open_time'] as String;
      }
      
      if (closeTime.isEmpty && json['close_time'] != null) {
        closeTime = json['close_time'] as String;
      }
      
      print('Parsed values:');
      print('Open time: $openTime');
      print('Close time: $closeTime');
      print('Avatar: $avatar');
      print('First image: $firstImage');
      print('Images count: ${images.length}');

      return FieldModel(
        id: json['id'] as String,
        createdDate: json['createdDate'] as String,
        fieldName: json['fieldName'] as String,
        location: json['location'] as String,
        normalPricePerHour: json['normalPricePerHour'] as double,
        peakPricePerHour: json['peakPricePerHour'] as double,
        openTime: openTime,
        closeTime: closeTime,
        description: json['description'] as String,
        typeFieldName: json['typeFieldName'] as String,
        ownerName: json['ownerName'] as String,
        typeFieldId: json['typeFieldId'] as String,
        numberPhone: json['numberPhone'] as String?,
        avatar: avatar,
        images: images,
        rateResponses: json['rateResponses'] as List<dynamic>? ?? [],
        smallFieldResponses: smallFieldResponses,
        averageRating: (json['averageRating'] is int)
            ? (json['averageRating'] as int).toDouble()
            : json['averageRating'] as double? ?? 0.0,
        totalBookings: json['totalBookings'] as int? ?? 0,
        available: json['available'] as bool? ?? true,
      );
    } catch (e, stackTrace) {
      print('Error in FieldModel.fromJson: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdDate': createdDate,
      'fieldName': fieldName,
      'location': location,
      'normalPricePerHour': normalPricePerHour,
      'peakPricePerHour': peakPricePerHour,
      'openTime': openTime,
      'closeTime': closeTime,
      'description': description,
      'typeFieldName': typeFieldName,
      'ownerName': ownerName,
      'typeFieldId': typeFieldId,
      'numberPhone': numberPhone,
      'avatar': avatar,
      'images': images,
      'rateResponses': rateResponses,
      'smallFieldResponses':
          smallFieldResponses.map((item) => item.toJson()).toList(),
      'averageRating': averageRating,
      'totalBookings': totalBookings,
      'available': available,
    };
  }
}