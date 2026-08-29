import 'dart:ui';
import 'package:flutter/material.dart';

// Yeh imports apni file ke hisaab se theek rakhein
import '../../core/theme/app_theme.dart';
import '../calculator/bricks_calculator_screen.dart';
import '../calculator/making_cost.dart';
import '../create/create_new_screen.dart'; // Aap ka naya map generator screen
import '../creations/my_creation_screen.dart';
import '../interior/interior_screen.dart'; // Yeh aapki API wali screen hai
import '../templates/template_screen.dart'; // Yeh aapki API wali screen hai
import 'widgets/gradient_banner.dart';
import 'widgets/menu_card.dart';
import 'widgets/options_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. PURE WHITE BASE
          Container(color: Colors.white),

          // Purple Orb (Top Left)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.18),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Blue Orb (Middle Right)
          Positioned(
            top: 250,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.15),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          // 2. The Main Foreground UI
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top App Bar Buttons
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Glass Menu Button
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: InkWell(
                              onTap: () => showOptionsBottomSheet(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.8),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.grid_view_rounded,
                                  size: 24,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Glass Streak Badge
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                // children: [
                                //   Icon(Icons.whatshot_rounded,
                                //       color: Colors.orange.shade700, size: 20),
                                //   const SizedBox(width: 6),
                                //   Text(
                                //     '5 Days',
                                //     style: TextStyle(
                                //       color: Colors.orange.shade900,
                                //       fontWeight: FontWeight.w800,
                                //       fontSize: 13,
                                //     ),
                                //   ),
                                // ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Typography Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color:
                                Colors.purpleAccent.shade700.withOpacity(0.8),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explore House\nDesigns',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1.0,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // The Hero Banner
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: GradientBanner(),
                  ),
                ),

                // Grid Section
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 29, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildListDelegate(_buildMenuCards(context)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // YAHAN API SCREENS CONNECT HO RAHI HAIN
  List<Widget> _buildMenuCards(BuildContext context) {
    return [
      MenuCard(
        title: 'Create\nNew',
        imageAsset: 'assets/images/cre1.png',
        color: AppColors.createNew,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MapWizardScreen())),
      ),
      MenuCard(
        title: 'Interior\n Designs',
        imageAsset: 'assets/images/in1.png',
        color: AppColors.interior,
        // Yahan se API wali InteriorScreen khulegi
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const InteriorScreen())),
      ),
      MenuCard(
        title: '2D\nTemplates',
        imageAsset: 'assets/images/2d.png',
        color: AppColors.templates2D,
        // Yahan se 2D Templates wali API fetch hogi
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const TemplateScreen(is2D: true))),
      ),
      MenuCard(
        title: '3D\nTemplates',
        imageAsset: 'assets/images/3d.png',
        color: AppColors.templates3D,
        // Yahan se 3D Templates wali API fetch hogi
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const TemplateScreen(is2D: false))),
      ),
      MenuCard(
        title: 'Cost \n calculator ',
        imageAsset: 'assets/images/co1.png',
        color: AppColors.makingCost,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MakingCostScreen())),
      ),
      MenuCard(
        title: 'My\nCreation',
        imageAsset: 'assets/images/f1.png',
        color: AppColors.myCreation,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MyCreationScreen())),
      ),
    ];
  }
}
