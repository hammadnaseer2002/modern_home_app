/// A single template/category item shown in the 2D, 3D, or Interior
/// galleries. One shared model keeps `HouseApiService` and the UI in sync.
class TemplateModel {
  const TemplateModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    this.sqft,
    this.rooms,
    this.subCategory, // Dynamic tabs ke liye
  });

  final String id;
  final String title;
  final String imageUrl;

  /// 'square feet' badge — only used by 2D plan cards.
  final int? sqft;

  /// room count badge — only used by 2D plan cards.
  final int? rooms;

  /// '2d' | '3d' | 'interior'
  final String category;

  /// Sub-category for filtering (e.g., 'Kitchen', 'Lounge')
  final String? subCategory;

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    // 1. API se aane wali image key catch karna (Ab 'template' key add kar di gayi hai)
    String rawImageUrl = json['template']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['imageUrl']?.toString() ??
        '';

    // 2. Agar API sirf relative path de rahi hai, toh base URL add karein
    if (rawImageUrl.isNotEmpty && !rawImageUrl.startsWith('http')) {
      if (rawImageUrl.startsWith('/')) {
        rawImageUrl = rawImageUrl.substring(1);
      }
      rawImageUrl = 'https://alameensoft.tech/apps/HouseDesign/$rawImageUrl';
    }

    return TemplateModel(
      // ID parsing
      id: json['id']?.toString() ?? json['template_id']?.toString() ?? '',

      // Title ya Name
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Design',

      // Final theek kiya hua Image URL
      imageUrl: rawImageUrl,

      // Strings/Ints ko safely parse karna
      sqft: json['sqft'] != null ? int.tryParse(json['sqft'].toString()) : null,
      rooms: json['rooms'] != null ? int.tryParse(json['rooms'].toString()) : null,

      category: json['category']?.toString() ?? 'interior',
      subCategory: json['subCategory']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image_url': imageUrl,
    'sqft': sqft,
    'rooms': rooms,
    'category': category,
    'subCategory': subCategory,
  };
}