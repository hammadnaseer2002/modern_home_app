import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/template_model.dart';

/// A category card used by both the 3D gallery (Bathroom, Front,
/// Kitchen…) and the Interior Designs gallery. Has an overlay image preview
/// and an edit toggle in the corner.
class Category3DCard extends StatefulWidget {
  const Category3DCard({super.key, required this.template, this.onPreview});

  final TemplateModel template;
  final VoidCallback? onPreview;

  @override
  State<Category3DCard> createState() => _Category3DCardState();
}

class _Category3DCardState extends State<Category3DCard> {
  bool _editMode = false;

  void _openFullScreenImage(BuildContext context) {
    final heroTag = '3d_card_${widget.template.id}';

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.92),
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Hero(
                      tag: heroTag,
                      child: CachedNetworkImage(
                        imageUrl: widget.template.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        // Yahan hum ne dark background diya hai taake white image par bhi saaf dikhe
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
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = '3d_card_${widget.template.id}';

    // ===============================================
    // MULTI-COLOR GLOW STYLES (Soft Yellow, Blue, Pink)
    // ===============================================
    final cardColor = const Color(0xFFF8FAFC);
    final mainCardRadius = BorderRadius.circular(24);
    final imageClipRadius = BorderRadius.circular(20);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPreview ?? () => _openFullScreenImage(context),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: mainCardRadius,
          boxShadow: [
            // 1. Soft Yellow Glow (Top-Left)
            BoxShadow(
              color: const Color(0xFFFFE082).withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(-6, -6),
            ),
            // 2. Soft Blue Shadow (Bottom-Right)
            BoxShadow(
              color: const Color(0xFF90CAF9).withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(8, 8),
            ),
            // 3. Soft Pink/Purple Ambient Glow (Bottom-Left)
            BoxShadow(
              color: const Color(0xFFF48FB1).withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(-4, 6),
            ),
            // 4. Clean White base to maintain the card's shape
            const BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0), // Image ke qareeb ka patla border
          child: ClipRRect(
            borderRadius: imageClipRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. BACKGROUND IMAGE
                Positioned.fill(
                  child: widget.template.imageUrl.isNotEmpty
                      ? Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: widget.template.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => _fallback(),
                    ),
                  )
                      : _fallback(),
                ),

                           ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFFE4E9F2),
    alignment: Alignment.center,
    child: const Icon(
      Icons.view_in_ar_rounded,
      size: 40,
      color: Color(0xFFB5C1D6),
    ),
  );
}