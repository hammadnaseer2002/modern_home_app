import 'package:flutter/material.dart';
import "package:url_launcher/url_launcher.dart";

/// Hosted policy page — wired up below.
const _privacyPolicyUrl = 'https://modrehousedesgin.netlify.app/';

/// Opens [url] in the device's browser. Shows a snackbar if it fails
/// (e.g. no browser available) instead of failing silently.
Future<void> _openUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open link.')),
    );
  }
}

/// Shows the Premium 3D Claymorphic "Other Options" sheet with Custom Vibe Icons.
void showOptionsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    builder: (context) => const OptionsBottomSheet(),
  );
}

class OptionsBottomSheet extends StatelessWidget {
  const OptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3), // Soft pink background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withValues(alpha: 0.15),
            offset: const Offset(0, -10),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 0.8, 1.0],
              colors: [
                Colors.white.withValues(alpha: 0.6),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.02),
                Colors.black.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 60,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDA4AF),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 3,
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(0, -2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Other Options',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 👇 The Vibe is here now! 👇
                  _ClayOptionTile(
                    icon: Icons.support_agent_rounded,
                    label: 'Customer Support',
                    accentColor: const Color(0xFF3B82F6),
                    onTap: () {
                      // TODO: point this at your support email, WhatsApp,
                      // or in-app chat — no contact channel confirmed yet.
                    },
                  ),
                  _ClayOptionTile(
                    icon: Icons.shield_rounded,
                    label: 'Privacy Policy',
                    accentColor: const Color(0xFF10B981),
                    onTap: () {
                      _openUrl(context, _privacyPolicyUrl);
                    },
                  ),
                  _ClayOptionTile(
                    icon: Icons.article_rounded,
                    label: 'Terms Of Service',
                    accentColor: const Color(0xFFF59E0B),
                    onTap: () {
                      // TODO: point this at your Terms of Service URL
                      // once that page is hosted (same site works fine,
                      // e.g. https://modrehousedesgin.netlify.app/terms).
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Component: Puffy 3D Clay Option Tile (With Custom 3D Extruded Icons!)
// -----------------------------------------------------------------------------
class _ClayOptionTile extends StatefulWidget {
  const _ClayOptionTile({
    required this.icon,
    required this.label,
    required this.accentColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  State<_ClayOptionTile> createState() => _ClayOptionTileState();
}

class _ClayOptionTileState extends State<_ClayOptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseCardColor = Color.lerp(Colors.white, widget.accentColor, 0.12)!;
    final shadowColor = widget.accentColor.withValues(alpha: 0.35);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _pressController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: _pressController,
            builder: (context, child) {
              final pressVal = _pressController.value;
              const depth = 1.0;

              return Container(
                decoration: BoxDecoration(
                  color: baseCardColor,
                  borderRadius: BorderRadius.circular(28), // Thicker, friendlier card border
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.5 * depth),
                      offset: Offset(6 * depth * (1 - pressVal), 10 * depth * (1 - pressVal)),
                      blurRadius: 16 * depth,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-4 * depth, -6 * depth),
                      blurRadius: 12 * depth,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.3, 0.75, 1.0],
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.0),
                        widget.accentColor.withValues(alpha: 0.03),
                        widget.accentColor.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // 👇 THE NEW "VIBE" ICON CONTAINER (Perfect Sphere) 👇
                      Container(
                        width: 52, // Thicker and rounder
                        height: 52,
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          shape: BoxShape.circle, // Circular shape feels much more custom and premium
                          boxShadow: [
                            // Big colored glow behind the icon
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.5),
                              offset: const Offset(3, 6),
                              blurRadius: 12,
                            ),
                            // Top left inner white highlight making the sphere pop
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              offset: const Offset(-2, -2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.5),
                                Colors.black.withValues(alpha: 0.15),
                              ],
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 26,
                            color: Colors.white,
                            // 👇 THE SECRET SAUCE: Shadows ON the icon itself makes it look extruded!
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Label
                      Expanded(
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // Refined, softer arrow button
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.15),
                              offset: const Offset(-2, -2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded, // Chevron looks slightly more premium than arrow_forward
                          size: 22,
                          color: widget.accentColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}