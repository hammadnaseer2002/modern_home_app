import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

void main() {
  runApp(const BlueprintApp());
}

class BlueprintApp extends StatelessWidget {
  const BlueprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Blueprint Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6B73FF), // Soft Purple-Blue
        scaffoldBackgroundColor: const Color(0xFFFDFBFE), // Very soft pastel background
      ),
      home: const MapWizardScreen(),
    );
  }
}

// --- Data Models ---
enum ShapeType { square, wall, doorH, doorV, window, stairs, grass, tree, ots }

class MapItem {
  final String id;
  ShapeType type;
  Offset position;
  double rotation;
  double width;
  double height;
  String label;
  Color? color;

  MapItem({
    required this.id,
    required this.type,
    required this.position,
    this.rotation = 0.0,
    required this.width,
    required this.height,
    this.label = '',
    this.color,
  });
}

// ==========================================
// 1. REUSABLE CLAYMORPHIC COMPONENTS (Dreamy Theme)
// ==========================================
class ClayContainer extends StatelessWidget {
  const ClayContainer({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.all(20),
    this.depth = 1.0,
  });

  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double depth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD3D8EE).withOpacity(0.6 * depth),
            offset: Offset(8 * depth, 12 * depth),
            blurRadius: 20 * depth,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: Offset(-8 * depth, -8 * depth),
            blurRadius: 16 * depth,
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4, 0.8, 1.0],
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.white.withOpacity(0.1),
              color == Colors.white ? Colors.black.withOpacity(0.01) : Colors.black.withOpacity(0.03),
              color == Colors.white ? Colors.black.withOpacity(0.04) : Colors.black.withOpacity(0.1),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class ClayButton extends StatefulWidget {
  const ClayButton({
    super.key,
    required this.child,
    required this.onTap,
    this.color = Colors.white,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: ClayContainer(
          color: widget.color,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          depth: 0.5,
          child: widget.child,
        ),
      ),
    );
  }
}

// ==========================================
// 2. REALISTIC BLUEPRINT GENERATOR WIZARD
// ==========================================
class MapWizardScreen extends StatefulWidget {
  const MapWizardScreen({super.key});

  @override
  State<MapWizardScreen> createState() => _MapWizardScreenState();
}

class _MapWizardScreenState extends State<MapWizardScreen> {
  String _plotSize = '5 Marla (25x45)';
  int _bedrooms = 2;
  int _bathrooms = 2;
  bool _hasLivingRoom = true;
  bool _hasKitchen = true;
  bool _hasGarden = true;

  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();

  final Color primaryText = const Color(0xFF2BA4FF);
  final Color secondaryText = const Color(0xFF1B1B3A);
  final Color cardPeach = const Color(0xFFFFEFEF);
  final Color cardLavender = const Color(0xFFF4F0FF);
  final Color btnPurple = const Color(0xFF6B73FF);

  @override
  void dispose() {
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  void _placeRect(List<MapItem> items, double x, double y, double w, double h, ShapeType type, String label, bool flip, double plotW, double startX, double startY, {double scale = 1.0, Color? fillColor}) {
    double scaledX = x * scale;
    double scaledY = y * scale;
    double scaledW = w * scale;
    double scaledH = h * scale;

    double finalX = flip ? (plotW - (scaledX + scaledW)) : scaledX;
    items.add(MapItem(
        id: 'room_${math.Random().nextInt(100000)}',
        type: type,
        position: Offset(startX + finalX, startY + scaledY),
        width: scaledW, height: scaledH, label: label,
        color: fillColor
    ));
  }

  void _placeDoorH(List<MapItem> items, double x, double y, double gap, bool flip, double plotW, double startX, double startY, {double scale = 1.0}) {
    double scaledX = x * scale;
    double scaledY = y * scale;
    double scaledGap = gap * scale;

    double finalX = flip ? (plotW - (scaledX + scaledGap)) : scaledX;
    items.add(MapItem(
        id: 'doorH_${math.Random().nextInt(100000)}',
        type: ShapeType.doorH,
        position: Offset(startX + finalX, startY + scaledY - 10),
        width: scaledGap, height: 20
    ));
  }

  void _placeDoorV(List<MapItem> items, double x, double y, double gap, bool flip, double plotW, double startX, double startY, {double scale = 1.0}) {
    double scaledX = x * scale;
    double scaledY = y * scale;
    double scaledGap = gap * scale;

    double finalX = flip ? (plotW - scaledX) : scaledX;
    items.add(MapItem(
        id: 'doorV_${math.Random().nextInt(100000)}',
        type: ShapeType.doorV,
        position: Offset(startX + finalX - 10, startY + scaledY),
        width: 20, height: scaledGap
    ));
  }

  void _skipToManualEditor() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CreateNewScreen(initialItems: [])),
    );
  }

  void _generateAndOpenEditor() {
    if (_plotSize == 'Custom Size') {
      if (_widthController.text.trim().isEmpty || _lengthController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter Width and Length for Custom Size!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    List<MapItem> generatedItems = [];

    final Color cBed = const Color(0xFFE8F4FF);
    final Color cBath = const Color(0xFFE0FBFC);
    final Color cKitchen = const Color(0xFFFFF3E0);
    final Color cLounge = const Color(0xFFF4F0FF);
    final Color cDraw = const Color(0xFFFCE4EC);
    final Color cPorch = const Color(0xFFF1F5F9);
    final Color cStore = const Color(0xFFF5F5F5);
    final Color cOts = const Color(0xFFFAFAFA);

    double scale = 1.0;
    double plotWidthFeet = 25.0;

    if (_plotSize == 'Custom Size') {
      plotWidthFeet = double.tryParse(_widthController.text) ?? 25.0;
      scale = plotWidthFeet / 25.0;
    } else if (_plotSize.contains('3 Marla')) { scale = 0.85; plotWidthFeet = 20.0; }
    else if (_plotSize.contains('5 Marla')) { scale = 1.0; plotWidthFeet = 25.0; }
    else if (_plotSize.contains('7 Marla')) { scale = 1.15; plotWidthFeet = 30.0; }
    else if (_plotSize.contains('10 Marla')) { scale = 1.35; plotWidthFeet = 35.0; }
    else if (_plotSize.contains('1 Kanal')) { scale = 1.7; plotWidthFeet = 50.0; }

    String getDim(double w, double h) {
      int ftW = (w * plotWidthFeet / 320).round();
      int ftH = (h * plotWidthFeet / 320).round();
      return "$ftW' x $ftH'";
    }

    String getWide(double val) {
      int ft = (val * plotWidthFeet / 320).round();
      return "$ft' WIDE";
    }

    double plotW = 320 * scale;
    double startX = 100;
    double startY = 100;
    bool flip = math.Random().nextBool();
    double currentY = 0.0;

    // 1. BACK ZONE
    _placeRect(generatedItems, 0, currentY, 320, 50, ShapeType.ots, "BACK LAUNDRY\n${getWide(50)}", flip, plotW, startX, startY, scale: scale, fillColor: cOts);
    currentY += 50;

    // 2. DYNAMIC BEDROOMS LOOP (Restored to handle up to 10 bedrooms dynamically)
    int bedCount = 0;
    int bathsLeft = _bathrooms;

    while (bedCount < _bedrooms) {
      int bedsInThisRow = (_bedrooms - bedCount >= 2) ? 2 : 1;

      if (bedsInThisRow == 2) {
        _placeRect(generatedItems, 0, currentY, 130, 160, ShapeType.square, "BED ROOM\n${getDim(130, 160)}", flip, plotW, startX, startY, scale: scale, fillColor: cBed);

        if (bathsLeft > 0) {
          _placeRect(generatedItems, 130, currentY, 60, 80, ShapeType.square, "BATH\n${getDim(60, 80)}", flip, plotW, startX, startY, scale: scale, fillColor: cBath);
          _placeRect(generatedItems, 130, currentY + 80, 60, 80, ShapeType.ots, "O.T.S\n${getDim(60, 80)}", flip, plotW, startX, startY, scale: scale, fillColor: cOts);
          _placeDoorV(generatedItems, 130, currentY + 50, 25, flip, plotW, startX, startY, scale: scale);
          bathsLeft--;
        } else {
          _placeRect(generatedItems, 130, currentY, 60, 160, ShapeType.square, "STORE\n${getDim(60, 160)}", flip, plotW, startX, startY, scale: scale, fillColor: cStore);
        }

        _placeRect(generatedItems, 190, currentY, 130, 160, ShapeType.square, "BED ROOM\n${getDim(130, 160)}", flip, plotW, startX, startY, scale: scale, fillColor: cBed);
        _placeDoorH(generatedItems, 90, currentY + 160, 30, flip, plotW, startX, startY, scale: scale);
        _placeDoorH(generatedItems, 200, currentY + 160, 30, flip, plotW, startX, startY, scale: scale);

        bedCount += 2;
      } else {
        _placeRect(generatedItems, 0, currentY, 200, 160, ShapeType.square, "MASTER BED\n${getDim(200, 160)}", flip, plotW, startX, startY, scale: scale, fillColor: cBed);
        if (bathsLeft > 0) {
          _placeRect(generatedItems, 200, currentY, 120, 100, ShapeType.square, "BATH\n${getDim(120, 100)}", flip, plotW, startX, startY, scale: scale, fillColor: cBath);
          _placeDoorV(generatedItems, 200, currentY + 60, 30, flip, plotW, startX, startY, scale: scale);
          bathsLeft--;
        } else {
          _placeRect(generatedItems, 200, currentY, 120, 100, ShapeType.square, "DRESSING\n${getDim(120, 100)}", flip, plotW, startX, startY, scale: scale, fillColor: cStore);
        }
        _placeRect(generatedItems, 200, currentY + 100, 120, 60, ShapeType.ots, "O.T.S\n${getDim(120, 60)}", flip, plotW, startX, startY, scale: scale, fillColor: cOts);
        _placeDoorH(generatedItems, 150, currentY + 160, 35, flip, plotW, startX, startY, scale: scale);

        bedCount += 1;
      }
      currentY += 160;
    }

    // 3. MIDDLE ZONE (TV Lounge / Kitchen / Stairs)
    double middleHeight = 140;
    if (_hasLivingRoom) {
      _placeRect(generatedItems, 0, currentY, 200, middleHeight, ShapeType.square, "TV LOUNGE\n${getDim(200, middleHeight)}", flip, plotW, startX, startY, scale: scale, fillColor: cLounge);
    } else {
      _placeRect(generatedItems, 0, currentY, 200, middleHeight, ShapeType.square, "LOBBY / HALL\n${getDim(200, middleHeight)}", flip, plotW, startX, startY, scale: scale, fillColor: cLounge);
    }

    if (_hasKitchen) {
      _placeRect(generatedItems, 200, currentY, 120, 80, ShapeType.square, "KITCHEN\n${getDim(120, 80)}", flip, plotW, startX, startY, scale: scale, fillColor: cKitchen);
      _placeDoorV(generatedItems, 200, currentY + 20, 30, flip, plotW, startX, startY, scale: scale);
      _placeRect(generatedItems, 200, currentY + 80, 120, 60, ShapeType.stairs, "STAIRS\nUP", flip, plotW, startX, startY, scale: scale, fillColor: cOts);
    } else {
      _placeRect(generatedItems, 200, currentY, 120, 80, ShapeType.square, "STORE\n${getDim(120, 80)}", flip, plotW, startX, startY, scale: scale, fillColor: cStore);
      _placeRect(generatedItems, 200, currentY + 80, 120, 60, ShapeType.stairs, "STAIRS\nUP", flip, plotW, startX, startY, scale: scale, fillColor: cOts);
    }
    currentY += middleHeight;

    // 4. FRONT ZONE (Porch / Drawing Room / Garden)
    double frontHeight = 170;
    _placeRect(generatedItems, 0, currentY, 160, frontHeight, ShapeType.square, "CAR PORCH\n${getDim(160, frontHeight)}", flip, plotW, startX, startY, scale: scale, fillColor: cPorch);

    double drawH = _hasGarden ? 120 : 170;
    _placeRect(generatedItems, 160, currentY, 160, drawH, ShapeType.square, "DRAWING ROOM\n${getDim(160, drawH)}", flip, plotW, startX, startY, scale: scale, fillColor: cDraw);

    if (_hasGarden) {
      _placeRect(generatedItems, 160, currentY + 120, 160, 50, ShapeType.grass, "FRONT LAWN\n${getWide(50)}", flip, plotW, startX, startY, scale: scale);
    }

    _placeDoorH(generatedItems, 170, currentY, 30, flip, plotW, startX, startY, scale: scale);
    _placeDoorV(generatedItems, 160, currentY + 30, 30, flip, plotW, startX, startY, scale: scale);
    _placeDoorV(generatedItems, 160, currentY - 40, 40, flip, plotW, startX, startY, scale: scale);

    currentY += frontHeight;

    _placeRect(generatedItems, -2/scale, -2/scale, 320+(4/scale), currentY+(4/scale), ShapeType.wall, "", false, plotW, startX, startY, scale: scale);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CreateNewScreen(initialItems: generatedItems)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEF5F8),
              Color(0xFFF1F6FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: secondaryText),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Smart Blueprint',
                      style: TextStyle(color: secondaryText, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
                    ),
                    TextButton(
                      onPressed: _skipToManualEditor,
                      style: TextButton.styleFrom(
                        backgroundColor: btnPurple.withOpacity(0.15),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: btnPurple,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  children: [
                    ClayContainer(
                      color: cardPeach,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plot Size', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: secondaryText.withOpacity(0.6), letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _plotSize,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: secondaryText),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: secondaryText),
                              items: ['3 Marla (20x34)', '5 Marla (25x45)', '7 Marla (30x53)', '10 Marla (35x65)', '1 Kanal (50x90)', 'Custom Size'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setState(() => _plotSize = val!),
                            ),
                          ),

                          if (_plotSize == 'Custom Size') ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _widthController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: secondaryText),
                                    decoration: InputDecoration(
                                      labelText: 'Width (ft) *',
                                      labelStyle: TextStyle(color: secondaryText.withOpacity(0.5)),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.7),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _lengthController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: secondaryText),
                                    decoration: InputDecoration(
                                      labelText: 'Length (ft) *',
                                      labelStyle: TextStyle(color: secondaryText.withOpacity(0.5)),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.7),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        // <-- RESTORED TO 10
                        Expanded(child: _buildClayCounter('Bedrooms', _bedrooms, (v) { if(v>=1 && v<=10) setState(() => _bedrooms = v); }, cardLavender)),
                        const SizedBox(width: 20),
                        // <-- RESTORED TO 10
                        Expanded(child: _buildClayCounter('Bathrooms', _bathrooms, (v) { if(v>=0 && v<=10) setState(() => _bathrooms = v); }, cardPeach)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ClayContainer(
                      color: cardLavender,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildClaySwitch('TV Lounge / Living', _hasLivingRoom, (v) => setState(() => _hasLivingRoom = v)),
                          Divider(color: Colors.white.withOpacity(0.5), height: 1),
                          _buildClaySwitch('Kitchen', _hasKitchen, (v) => setState(() => _hasKitchen = v)),
                          Divider(color: Colors.white.withOpacity(0.5), height: 1),
                          _buildClaySwitch('Front Lawn / Garden', _hasGarden, (v) => setState(() => _hasGarden = v), isGreen: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: PremiumGenerateButton(
                  onTap: _generateAndOpenEditor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClayCounter(String label, int value, Function(int) onChanged, Color bgColor) {
    return ClayContainer(
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: secondaryText.withOpacity(0.7))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClayButton(
                color: Colors.white,
                padding: const EdgeInsets.all(8), borderRadius: 12,
                onTap: () => onChanged(value - 1),
                child: Icon(Icons.remove_rounded, size: 18, color: secondaryText.withOpacity(0.5)),
              ),
              Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: btnPurple)),
              ClayButton(
                color: Colors.white,
                padding: const EdgeInsets.all(8), borderRadius: 12,
                onTap: () => onChanged(value + 1),
                child: Icon(Icons.add_rounded, size: 18, color: secondaryText.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClaySwitch(String title, bool value, Function(bool) onChanged, {bool isGreen = false}) {
    Color activeColor = isGreen ? const Color(0xFF10B981) : btnPurple;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: secondaryText)),
            ClayContainer(
              color: value ? activeColor : Colors.white,
              padding: const EdgeInsets.all(4),
              borderRadius: 20,
              depth: 0.3,
              child: SizedBox(
                width: 44,
                height: 24,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumGenerateButton extends StatefulWidget {
  final VoidCallback onTap;
  const PremiumGenerateButton({super.key, required this.onTap});

  @override
  State<PremiumGenerateButton> createState() => _PremiumGenerateButtonState();
}

class _PremiumGenerateButtonState extends State<PremiumGenerateButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(234),
            gradient: const LinearGradient(
              colors: [Color(0xFF6B73FF), Color(0xFF555DE6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B73FF).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 12),
              Text(
                'Generate Blueprint',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. THE EDITOR CANVAS (CLAYMORPHIC UI)
// ==========================================
class CreateNewScreen extends StatefulWidget {
  final List<MapItem> initialItems;
  const CreateNewScreen({super.key, required this.initialItems});

  @override
  State<CreateNewScreen> createState() => _CreateNewScreenState();
}

class _CreateNewScreenState extends State<CreateNewScreen> {
  late List<MapItem> _items;
  String? _selectedItemId;
  final GlobalKey _canvasKey = GlobalKey();

  final Color bgColor = const Color(0xFFFDFBFE);
  final Color primaryText = const Color(0xFF2BA4FF);
  final Color secondaryText = const Color(0xFF1B1B3A);
  final Color btnPurple = const Color(0xFF6B73FF);

  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  void _addItem(ShapeType type, String label) {
    double sW = 80, sH = 80;
    Color? itemColor;

    switch(type) {
      case ShapeType.square:
        sW=100; sH=100;
        itemColor = const Color(0xFFF1F5F9);
        break;
      case ShapeType.doorH: sW=40; sH=20; break;
      case ShapeType.doorV: sW=20; sH=40; break;
      case ShapeType.stairs: sW=60; sH=80; break;
      case ShapeType.grass: sW=100; sH=50; break;
      case ShapeType.ots: sW=60; sH=60; break;
      default: break;
    }
    setState(() {
      _items.add(MapItem(id: DateTime.now().toString(), type: type, position: const Offset(120, 200), width: sW, height: sH, label: label, color: itemColor));
      _selectedItemId = _items.last.id;
    });
  }

  void _updateItemPosition(String id, Offset delta) {
    setState(() {
      final item = _items.firstWhere((e) => e.id == id);
      item.position += delta;
    });
  }

  void _updateItemSize(String id, double dx, double dy) {
    setState(() {
      final item = _items.firstWhere((e) => e.id == id);
      item.width = math.max(10.0, item.width + dx);
      item.height = math.max(5.0, item.height + dy);
    });
  }

  Future<void> _saveMapAsPng() async {
    setState(() => _selectedItemId = null);
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final String fileName = 'map_${DateTime.now().millisecondsSinceEpoch}';

      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/my_creations');
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      final file = File('${folder.path}/$fileName.png');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Saved to My Creations!'),
                backgroundColor: Colors.green
            )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: secondaryText), onPressed: () => Navigator.pop(context)),
        title: Text('Blueprint Editor', style: TextStyle(color: secondaryText, fontWeight: FontWeight.w900)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: Center(
                child: ClayButton(
                    onTap: _saveMapAsPng,
                    color: const Color(0xECE2D5BE),
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                    child: Text('SAVE', style: TextStyle(color: primaryText, fontWeight: FontWeight.w900))
                )
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _canvasKey,
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(5000),
              minScale: 0.1,
              maxScale: 5.0,
              constrained: false,
              panEnabled: !_isInteracting,
              scaleEnabled: !_isInteracting,
              child: GestureDetector(
                onTap: () => setState(() => _selectedItemId = null),
                child: Container(
                  width: 4000, height: 4000, color: const Color(0xFFFAFAFC),
                  child: GridPaper(
                    color: btnPurple.withOpacity(0.05), divisions: 2, subdivisions: 4,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: _items.map((item) {
                        final isSelected = item.id == _selectedItemId;
                        return Positioned(
                          left: item.position.dx, top: item.position.dy,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedItemId = item.id),
                            onPanStart: isSelected ? (_) => setState(() => _isInteracting = true) : null,
                            onPanUpdate: isSelected ? (details) => _updateItemPosition(item.id, details.delta) : null,
                            onPanEnd: isSelected ? (_) => setState(() => _isInteracting = false) : null,
                            onPanCancel: isSelected ? () => setState(() => _isInteracting = false) : null,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CustomPaint(size: Size(item.width, item.height), painter: ShapeRenderer(type: item.type, isSelected: isSelected, fillColor: item.color)),
                                if (item.label.isNotEmpty)
                                  Positioned.fill(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          item.label, textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: item.type == ShapeType.grass ? Colors.white : const Color(0xFF334155),
                                            fontWeight: FontWeight.w800, fontSize: 11, height: 1.3, letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                if (isSelected) Positioned(right: -14, top: item.height / 2 - 14, child: _buildDragHandle(
                                    onPanStart: (_) => setState(() => _isInteracting = true),
                                    onPanUpdate: (d) => _updateItemSize(item.id, d.delta.dx, 0),
                                    onPanEnd: (_) => setState(() => _isInteracting = false),
                                    onPanCancel: () => setState(() => _isInteracting = false),
                                    icon: Icons.compare_arrows_rounded
                                )),
                                if (isSelected) Positioned(bottom: -14, left: item.width / 2 - 14, child: _buildDragHandle(
                                    onPanStart: (_) => setState(() => _isInteracting = true),
                                    onPanUpdate: (d) => _updateItemSize(item.id, 0, d.delta.dy),
                                    onPanEnd: (_) => setState(() => _isInteracting = false),
                                    onPanCancel: () => setState(() => _isInteracting = false),
                                    icon: Icons.height_rounded
                                )),
                                if (isSelected) Positioned(right: -14, bottom: -14, child: _buildDragHandle(
                                    onPanStart: (_) => setState(() => _isInteracting = true),
                                    onPanUpdate: (d) => _updateItemSize(item.id, d.delta.dx, d.delta.dy),
                                    onPanEnd: (_) => setState(() => _isInteracting = false),
                                    onPanCancel: () => setState(() => _isInteracting = false),
                                    icon: Icons.open_in_full_rounded
                                )),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_selectedItemId != null)
            Positioned(
                bottom: 110, right: 20,
                child: ClayButton(
                  onTap: () {
                    setState(() { _items.removeWhere((e) => e.id == _selectedItemId); _selectedItemId = null; });
                  },
                  color: const Color(0xFFFF6B6B), padding: const EdgeInsets.all(14),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                )
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: ClayContainer(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                borderRadius: 32,
                child: SizedBox(
                  height: 70,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _ToolButton(label: 'Room', icon: Icons.crop_square_rounded, onTap: () => _addItem(ShapeType.square, 'ROOM')),
                      _ToolButton(label: 'Door (H)', icon: Icons.door_front_door, onTap: () => _addItem(ShapeType.doorH, '')),
                      _ToolButton(label: 'Door (V)', icon: Icons.door_front_door, onTap: () => _addItem(ShapeType.doorV, '')),
                      _ToolButton(label: 'O.T.S', icon: Icons.highlight_off_rounded, onTap: () => _addItem(ShapeType.ots, 'OTS')),
                      _ToolButton(label: 'Stairs', icon: Icons.stairs_rounded, onTap: () => _addItem(ShapeType.stairs, 'STAIRS')),
                      _ToolButton(label: 'Lawn', icon: Icons.grass_rounded, onTap: () => _addItem(ShapeType.grass, 'LAWN')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle({
    required GestureDragStartCallback onPanStart,
    required GestureDragUpdateCallback onPanUpdate,
    required GestureDragEndCallback onPanEnd,
    required GestureDragCancelCallback onPanCancel,
    required IconData icon
  }) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: btnPurple, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: btnPurple.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))]),
          child: Icon(icon, size: 14, color: Colors.white)
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ToolButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClayButton(
        color: const Color(0xFFF4F0FF),
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: 20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: const Color(0xFF6B73FF)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1B1B3A))),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. THE CUSTOM RENDERER (CAD STYLE)
// ==========================================
class ShapeRenderer extends CustomPainter {
  final ShapeType type;
  final bool isSelected;
  final Color? fillColor;

  ShapeRenderer({required this.type, required this.isSelected, this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    final thickBlackStroke = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 3.5;
    final thinBlackStroke = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final doorPaint = Paint()..color = const Color(0xFFD97706)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final eraserPaint = Paint()..color = const Color(0xFFFAFAFC)..style = PaintingStyle.fill;

    final dynamicFillPaint = Paint()..color = fillColor ?? const Color(0xFFFAFAFC)..style = PaintingStyle.fill;

    switch (type) {
      case ShapeType.square:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), dynamicFillPaint);
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), thickBlackStroke);
        break;

      case ShapeType.wall:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), thickBlackStroke);
        break;

      case ShapeType.ots:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), dynamicFillPaint);
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), thickBlackStroke);
        canvas.drawLine(const Offset(0, 0), Offset(w, h), thinBlackStroke);
        canvas.drawLine(Offset(w, 0), Offset(0, h), thinBlackStroke);
        break;

      case ShapeType.doorH:
        canvas.drawRect(Rect.fromLTWH(0, h*0.25, w, h*0.5), eraserPaint);
        canvas.drawLine(Offset(0, h/2), Offset(0, h/2 - w), doorPaint);
        canvas.drawArc(Rect.fromLTWH(-w, h/2 - w, w*2, w*2), -math.pi/2, math.pi/2, false, Paint()..color = const Color(0xFFD97706)..style = PaintingStyle.stroke..strokeWidth = 1.0);
        break;

      case ShapeType.doorV:
        canvas.drawRect(Rect.fromLTWH(w*0.25, 0, w*0.5, h), eraserPaint);
        canvas.drawLine(Offset(w/2, 0), Offset(w/2 + h, 0), doorPaint);
        canvas.drawArc(Rect.fromLTWH(w/2 - h, -h, h*2, h*2), 0, math.pi/2, false, Paint()..color = const Color(0xFFD97706)..style = PaintingStyle.stroke..strokeWidth = 1.0);
        break;

      case ShapeType.stairs:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), dynamicFillPaint);
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), thickBlackStroke);
        int steps = 10;
        for (int i = 1; i < steps; i++) {
          double stepY = (h / steps) * i;
          canvas.drawLine(Offset(0, stepY), Offset(w, stepY), thinBlackStroke);
        }
        canvas.drawLine(Offset(w/2, 0), Offset(w/2, h), thinBlackStroke);
        break;

      case ShapeType.grass:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF10B981).withOpacity(0.15)..style = PaintingStyle.fill);
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), thickBlackStroke);
        break;

      default:
        break;
    }

    if (isSelected) {
      canvas.drawRect(Rect.fromLTWH(-2, -2, w+4, h+4), Paint()..color = const Color(0xFF6B73FF)..style = PaintingStyle.stroke..strokeWidth = 3.0);
    }
  }

  @override
  bool shouldRepaint(covariant ShapeRenderer oldDelegate) {
    return oldDelegate.type != type || oldDelegate.isSelected != isSelected || oldDelegate.fillColor != fillColor;
  }
}