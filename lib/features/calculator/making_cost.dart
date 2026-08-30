import 'package:flutter/material.dart';
import '../home/widgets/menu_card.dart';
import 'asphalt_calculator_screen.dart';
import 'bricks_calculator_screen.dart';
import 'cement_concrete_calculator_screen.dart';
import 'excavation_calculator_screen.dart';
import 'flooring_calculator_screen.dart';
import 'plastering_calculator_screen.dart';
import 'steel_weight_calculator_screen.dart';
import 'tank_volume_calculator_screen.dart';

class MakingCostScreen extends StatelessWidget {
  const MakingCostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Cost Calculations',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          // 1. PURE WHITE BASE
          Container(color: Colors.white),

          // 2. Purple Orb (Top Left)
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

          // 3. Blue Orb (Middle Right)
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

          // 4. Smooth Scrolling Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
                    child: Text(
                      'Select a Calculator',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(10.10),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.95,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return _buildAnimatedCard(
                            context,
                            _getCardsList(context)[index],
                            index
                        );
                      },
                      childCount: _getCardsList(context).length,
                    ),
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getCardsList(BuildContext context) {
    return [
      MenuCard(
        title: 'Bricks',
        imageAsset: 'assets/images/br.png',
        color: Colors.orangeAccent,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BricksCalculatorScreen())),
      ),
      MenuCard(
        title: 'Cement\nEstimate',
        imageAsset: 'assets/images/ce.png',
        color: Colors.blueGrey,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CementConcreteCalculatorScreen())),
      ),
      MenuCard(
        title: 'Floor',
        imageAsset: 'assets/images/fl.png',
        color: Colors.teal,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlooringCalculatorScreen())),
      ),
      MenuCard(
        title: 'Steel Weight',
        imageAsset: 'assets/images/1.png',
        color: Colors.green,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SteelWeightCalculatorScreen())),
      ),
      MenuCard(
        title: 'Excavation',
        imageAsset: 'assets/images/ex.png',
        color: Colors.deepPurple,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExcavationCalculatorScreen())),
      ),
      MenuCard(
        title: 'Water Sump\nTank Volume',
        imageAsset: 'assets/images/wa.png',
        color: Colors.blue,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TankVolumeCalculatorScreen())),
      ),
      MenuCard(
        title: 'Asphalt',
        imageAsset: 'assets/images/as.png',
        color: Colors.brown,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AsphaltCalculatorScreen())),
      ),
      MenuCard(
        title: 'Plastering',
        imageAsset: 'assets/images/pl.png',
        color: Colors.pinkAccent,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlasteringCalculatorScreen())),
      ),

      // 👇 YAHAN AAKHRI CARD KO NAYI SCREEN KE SATH LINK KIYA HAI 👇
      // MenuCard(
      //   title: 'Total Project\nSummary',
      //   imageAsset: 'assets/images/pl.png',
      //   color: Colors.deepPurpleAccent,
      //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectSummaryScreen())),
      // ),
    ];
  }

  Widget _buildAnimatedCard(BuildContext context, Widget card, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutQuart,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: card,
    );
  }
}