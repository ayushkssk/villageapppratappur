class VillageImage {
  final String id;
  final String url;
  final String category;
  final DateTime uploadedAt;

  VillageImage({
    required this.id,
    required this.url,
    required this.category,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'category': category,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory VillageImage.fromMap(Map<String, dynamic> map) {
    return VillageImage(
      id: map['id'],
      url: map['url'],
      category: map['category'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
} 