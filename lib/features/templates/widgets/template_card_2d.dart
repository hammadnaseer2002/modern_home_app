import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/template_model.dart';

class Template2DCard extends StatelessWidget {
  const Template2DCard({
    super.key,
    required this.template,
    this.onTap,
    this.showFooter = true,
  });

  final TemplateModel template;
  final VoidCallback? onTap;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    final cardColor = const Color(0xFFF7D6D);
    final imageClipRadius = BorderRadius.circular(30);
    final mainCardRadius = BorderRadius.circular(36);
    final heroTag = 'template_image_${template.id}';

    String footerText = '-- SFT';
    if (template.title.isNotEmpty && template.title != 'Design' && template.title != 'Untitled') {
      footerText = template.title;
    } else if (template.sqft != null) {
      footerText = '${template.sqft} SFT';
    } else if (template.subCategory != null && template.subCategory!.isNotEmpty) {
      footerText = template.subCategory!;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () {
        // print("Click hua! ID: ${template.id} - Name: $footerText");
      },
      child: ClipRRect(
        borderRadius: mainCardRadius,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: mainCardRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 18,
                offset: const Offset(-8, -8),
              ),
              BoxShadow(
                color: const Color(0xFFC4D5F4).withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(8, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: imageClipRadius,
                    child: template.imageUrl.isNotEmpty
                        ? Hero(
                      tag: heroTag,
                      child: CachedNetworkImage(
                        imageUrl: template.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.grey.shade100,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => _fallback(),
                      ),
                    )
                        : _fallback(),
                  ),
                ),
              ),
              if (template.rooms != null)
                Positioned(
                  top: 18,
                  right: 18,
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.0,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.06),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFf7D6D).withValues(alpha: 0.25),
                          blurRadius: 6,
                          spreadRadius: -3,
                          offset: const Offset(4, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.45),
                          blurRadius: 61,
                          spreadRadius: -3,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFC0A6F4),
                      ),
                      child: Text(
                        '${template.rooms}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              if (showFooter)
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: imageClipRadius,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC4D5F4).withValues(alpha: 0.28),
                          blurRadius: 10,
                          spreadRadius: -2,
                          offset: const Offset(6, 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.65),
                          blurRadius: 10,
                          spreadRadius: -2,
                          offset: const Offset(-6, -6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      footerText,
                      style: const TextStyle(
                        color: Color(0xFF212121),
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFFEDEBF7),
    alignment: Alignment.center,
    child: const Icon(Icons.home_work_rounded, size: 60, color: Color(0xFFB9AEE8)),
  );
}