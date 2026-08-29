import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category_model.dart';
import '../../models/template_model.dart';
import '../../services/api_service.dart';

class InteriorScreen extends ConsumerStatefulWidget {
  const InteriorScreen({super.key});

  @override
  ConsumerState<InteriorScreen> createState() => _InteriorScreenState();
}

class _InteriorScreenState extends ConsumerState<InteriorScreen> {
  // Apni API service ka instance yahan use karein
  final HouseApiService _apiService = HouseApiService();

  List<CategoryModel> _categories = [];
  List<TemplateModel> _templates = [];

  String? _selectedCategoryId;
  bool _isLoadingCategories = true;
  bool _isLoadingTemplates = false;
  String? _errorMessage;

  // ==========================================
  // CLAYMORPHISM THEME COLORS
  // ==========================================
  final Color _bgColor = const Color(0xFFF6EEF5); // Soft pastel background
  final Color _darkShadow = const Color(0xFFE2D1E0); // Bottom right shadow
  final Color _lightShadow = Colors.white; // Top left highlight

  // Categories ke liye 3 random soft colors (Pink, Blue, Purple)
  final List<Color> _categoryColors = const [
    Color(0xFFFF8E9B), // Soft Pink
    Color(0xFF6EABFE), // Soft Blue
    Color(0xFFC493FF), // Soft Purple
  ];

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndInitialTemplates();
  }

  Future<void> _loadCategoriesAndInitialTemplates() async {
    try {
      final categories = await _apiService.fetchInteriorCategories();

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });

      if (categories.isNotEmpty) {
        _fetchTemplatesForCategory(categories.first.id);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _fetchTemplatesForCategory(String categoryId) async {
    setState(() {
      _selectedCategoryId = categoryId;
      _isLoadingTemplates = true;
    });

    try {
      final templates = await _apiService.fetchInteriorTemplates(categoryId);

      setState(() {
        _templates = templates;
        _isLoadingTemplates = false;
      });
    } catch (e) {
      setState(() {
        _templates = [];
        _isLoadingTemplates = false;
      });
    }
  }

  // ==========================================
  // CUSTOM ERROR UI FOR INTERIOR SCREEN
  // ==========================================
  Widget _buildErrorUI() {
    bool isNetworkError = _errorMessage != null &&
        (_errorMessage!.contains('SocketException') ||
            _errorMessage!.contains('Failed host lookup'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 64,
              color: const Color(0xFFC493FF), // Theme's Soft Purple
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError ? 'No Internet Connection' : 'Something went wrong',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isNetworkError
                  ? 'Please check your internet connection and try again.'
                  : 'Could not load data. Please try again later.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Jab user Retry dabaye toh state reset karein aur dubara fetch karein
                setState(() {
                  _isLoadingCategories = true;
                  _errorMessage = null;
                });
                _loadCategoriesAndInitialTemplates();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8E9B), // Theme's Soft Pink
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Interior Designs',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF2D3748),
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFBE91)),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorUI();
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories found.',
          style: TextStyle(color: Color(0xFF718096), fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // DYNAMIC TABS (3 Colors + Puffy Shadows)
        // ==========================================
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category.id == _selectedCategoryId;

              final activeColor = _categoryColors[index % _categoryColors.length];

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    if (_selectedCategoryId == category.id) return;
                    _fetchTemplatesForCategory(category.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? activeColor : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white,
                        width: isSelected ? 2 : 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(4, 6),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 10,
                          offset: Offset(-2, -2),
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: _darkShadow,
                          blurRadius: 12,
                          offset: const Offset(6, 6),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 12,
                          offset: Offset(-6, -6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4A5A75),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // ==========================================
        // IMAGES GRID (3D Puffy Clay Cards)
        // ==========================================
        Expanded(
          child: _isLoadingTemplates
              ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF6EABFE)),
          )
              : _templates.isEmpty
              ? const Center(
            child: Text(
              'No designs found in this category.',
              style: TextStyle(color: Color(0xFF718096), fontSize: 16),
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20).copyWith(bottom: 40),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.76,
                ),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  return _ImageClayCard(
                    template: _templates[index],
                    darkShadow: _darkShadow,
                    lightShadow: _lightShadow,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 3D CLAY CARD WIDGET
// ==========================================
class _ImageClayCard extends StatefulWidget {
  final TemplateModel template;
  final Color darkShadow;
  final Color lightShadow;

  const _ImageClayCard({
    required this.template,
    required this.darkShadow,
    required this.lightShadow,
  });

  @override
  State<_ImageClayCard> createState() => _ImageClayCardState();
}

class _ImageClayCardState extends State<_ImageClayCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.template.imageUrl;
    final heroTag = 'template_image_${widget.template.id}';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        // Open Full Screen Image Viewer
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return FullScreenImageViewer(imageUrl: imageUrl, heroTag: heroTag);
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0, // Tactile press animation
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(8), // Inner frame padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: _isPressed
                ? [
              // Pressed Shadow State
              BoxShadow(
                color: widget.darkShadow.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(2, 2),
              ),
            ]
                : [
              // Unpressed 3D Shadow State
              BoxShadow(
                color: widget.darkShadow,
                blurRadius: 14,
                offset: const Offset(8, 8),
              ),
              BoxShadow(
                color: widget.lightShadow,
                blurRadius: 14,
                offset: const Offset(-8, -8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFFE2D1E0),
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF6EEF5),
                      child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 32),
                    ),
                  ),
                ),
                // Neomorphic Arrow Indicator (Top Right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF4A5A75),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// FULL SCREEN ZOOMABLE VIEWER
// ==========================================
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.92),
      body: Stack(
        children: [
          // Pinch to Zoom Interactive Viewer
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: Hero(
                tag: heroTag,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          // Clean Close Button with dark background so it's visible on white images
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}