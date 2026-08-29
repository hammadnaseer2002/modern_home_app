import 'package:flutter/material.dart';

/// A 3D Claymorphic hero banner in Soft Pink tones.
class GradientBanner extends StatelessWidget {
  const GradientBanner({super.key});

  // Dynamic Soft Pink Clay Gradient Palette
  static const Color clayPinkStart = Color(0xFFFCE4EC);
  static const Color clayPinkEnd = Color(0xFFA4CEFD);   // Deep Rose Pink

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          // Outer Pink Floating Drop Shadow
          BoxShadow(
            color: clayPinkEnd.withValues(alpha: 0.4),
            offset: const Offset(8, 16),
            blurRadius: 24,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                clayPinkStart,
                clayPinkEnd,
              ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Volumetric Clay Lighting Layer
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.2, 0.8, 1.0],
                colors: [
                  Colors.white.withValues(alpha: 0.45), // Bright Top-Left Highlight
                  Colors.white.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.25), // Bottom-Right Depth Shadow
                ],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Clay Bubble Accent
                Positioned(
                  right: 20,
                  top: -20,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                ),

                // Extruded Background Icon
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: Icon(
                      Icons.home_work_rounded,
                      size: 150,
                      color: Colors.white.withValues(alpha: 0.2),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.25),
                          offset: const Offset(-2, -2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find your\nPlace Of Dreams',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.brown,
                        fontWeight: FontWeight.w900,

                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Claymorphic Inset Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            offset: const Offset(2, 4),
                            blurRadius: 8,
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: Text(
                        "Let's find your beautiful\nhouse designs.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}