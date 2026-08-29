class CategoryModel {
  final String id;
  final String name; // API se aane wala asal naam (jaise "1125SqF")
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // JSON keys aapke PHP API ke mutabiq hain
      id: json['categoryId']?.toString() ?? '',
      name: json['categoryName'] ?? 'Unnamed Category',
      imageUrl: json['categoryImage'] ?? '',
    );
  }

  // ==========================================
  // HELPER GETTER FOR SQUARE FOOTAGE
  // ==========================================
  /// Yeh function "1125SqF" me se sirf "1125" nikal kar dega
  String get squareFeet {
    final RegExp regex = RegExp(r'^\d+');
    final match = regex.matchAsPrefix(name);

    if (match != null) {
      return match.group(0) ?? ''; // Sirf number return karega
    }

    // Agar koi number nahi milta, toh asal naam bhej dega
    return name;
  }
}