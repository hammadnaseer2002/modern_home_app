import 'package:flutter/material.dart';

class MenuCard extends StatefulWidget {
  const MenuCard({
    super.key,
    required this.title,
    required this.imageAsset, // 👇 CHANGED: Yahan ab image ka path aayega
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String imageAsset; // Path to your PNG
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 200),
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
    final baseColor = Color.lerp(Colors.white, widget.color, 0.12)!;
    final shadowColor = widget.color.withValues(alpha: 0.25);

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            final pressVal = _pressController.value;

            return Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: Offset(8 - (pressVal * 4), 16 - (pressVal * 8)),
                    blurRadius: 24 - (pressVal * 12),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.3, 0.8, 1.0],
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.0),
                      widget.color.withValues(alpha: 0.04),
                      widget.color.withValues(alpha: 0.12),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 👇 The glowing circle with your Image 👇
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.3),
                                offset: const Offset(4, 6),
                                blurRadius: 12,
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-2, -2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            // 🖼️ AAPKI IMAGE YAHAN RENDER HOGI
                            child: Image.asset(
                              widget.imageAsset,
                              width: 200, // Size adjust kar sakte hain
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.2),
                                offset: const Offset(-2, -2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: widget.color.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),

                    const Expanded(child: SizedBox()),

                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.3,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}