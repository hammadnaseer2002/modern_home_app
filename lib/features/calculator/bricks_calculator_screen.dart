import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BricksCalculatorScreen extends StatefulWidget {
  const BricksCalculatorScreen({super.key});

  @override
  State<BricksCalculatorScreen> createState() => _BricksCalculatorScreenState();
}

class _BricksCalculatorScreenState extends State<BricksCalculatorScreen>
    with TickerProviderStateMixin {

  // 🎨 Soft UI Colors & Gradients
  static const Color bgColor = Color(0xFFF7F8FC);
  static const Color textDark = Color(0xFF2C3140);
  static const Color textLight = Color(0xFF7A809B);
  static const Color primaryPurple = Color(0xFF6B65D8);
  static const Color activeSelectorColor = Color(0xFFFB7185);

  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFFCF3EF), Color(0xFFF4E3DD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lilacGradient = LinearGradient(
    colors: [Color(0xFFF2F3FB), Color(0xFFE4E5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient whiteGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFBFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Soft shadow for all cards
  List<BoxShadow> get _softShadow => [
    BoxShadow(
      color: const Color(0xFFDCE1F0).withOpacity(0.6),
      blurRadius: 24,
      spreadRadius: 4,
      offset: const Offset(0, 10),
    )
  ];

  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  String _wallThickness = 'Half Brick';
  int? _resultBricks;
  double? _calculatedAreaSqFt;

  late AnimationController _resultAnimController;
  late Animation<double> _resultFadeAnimation;
  late Animation<Offset> _resultSlideAnimation;

  static const double _brickLengthIn = 9;
  static const double _brickHeightIn = 3;
  static const double _mortarJointIn = 0.5;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resultFadeAnimation = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOutCubic,
    );
    _resultSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final length = double.parse(_lengthController.text.trim());
    final width = double.parse(_widthController.text.trim());
    final height = double.parse(_heightController.text.trim());

    final wallAreaSqFt = 2 * (length + width) * height;
    const brickFaceAreaSqFt =
        ((_brickLengthIn + _mortarJointIn) * (_brickHeightIn + _mortarJointIn)) / 144;

    final thicknessMultiplier = _wallThickness == 'Full Brick' ? 2 : 1;
    final bricksNeeded = (wallAreaSqFt / brickFaceAreaSqFt) * thicknessMultiplier;

    setState(() {
      _calculatedAreaSqFt = wallAreaSqFt;
      _resultBricks = bricksNeeded.ceil();
    });

    _resultAnimController.forward(from: 0.0);
  }

  void _clear() {
    _formKey.currentState?.reset();
    _lengthController.clear();
    _widthController.clear();
    _heightController.clear();
    _resultAnimController.reverse();
    setState(() {
      _resultBricks = null;
      _calculatedAreaSqFt = null;
      _wallThickness = 'Half Brick';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text(
          'Bricks Calculator',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
            child: InkWell(
              onTap: _clear,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E9FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // 1. Info Banner (Lilac Gradient)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: lilacGradient,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: _softShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'STANDARD METRIC',
                                style: TextStyle(color: primaryPurple, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '9" × 4.5" × 3"',
                              style: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -1),
                            ),
                            const SizedBox(height: 14),
                            const Text('+ 0.5" mortar allowance', style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const _BrickWallGraphic(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Wall Dimensions (Peach Gradient)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: peachGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wall Dimensions', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 16),
                      _buildWhiteInput(_lengthController, 'Length (ft)'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildWhiteInput(_widthController, 'Width (ft)', isCenter: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildWhiteInput(_heightController, 'Height (ft)', isCenter: true)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Wall Thickness (Lilac Gradient)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: lilacGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wall Thickness', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _thicknessOption('Half Brick', '4.5" Single')),
                          const SizedBox(width: 12),
                          Expanded(child: _thicknessOption('Full Brick', '9.0" Double')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Calculate Button (Pill Shaped)
                ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: primaryPurple.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    // 👇 YAHAN BUTTON KO PILL SHAPE DIYA HAI 👇
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Calculate Bricks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),

                // 4. Result Card (White Gradient with soft dividers)
                if (_resultBricks != null) ...[
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _resultSlideAnimation,
                    child: FadeTransition(
                      opacity: _resultFadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: whiteGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: _softShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Estimated Bricks', style: TextStyle(color: textLight, fontWeight: FontWeight.w500, fontSize: 15)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$_resultBricks',
                                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: textDark, letterSpacing: -1),
                                ),
                                const SizedBox(width: 8),
                                const Text('Pcs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textLight)),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: Color(0xFFF0F1F5), thickness: 1.5),
                            ),
                            _resultRow('Total Wall Area', '${_calculatedAreaSqFt!.toStringAsFixed(1)} sq ft', false),
                            const SizedBox(height: 12),
                            _resultRow('Wall Structure', _wallThickness, false),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: Color(0xFFF0F1F5), thickness: 1.5),
                            ),
                            _resultRow('With 5% Wastage', '${(_resultBricks! * 1.05).ceil()} Pcs', true),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets for Soft UI ---

  // White Pill Text Input
  Widget _buildWhiteInput(TextEditingController ctrl, String hint, {bool isCenter = false}) {
    return Container(
      decoration: BoxDecoration(
        // Aapne jo gray color diya tha wo outer container pe laga diya hai taake corners perfect aayein
        color: const Color(0xFFD3C4C4),
        // 👇 YAHAN INPUT FIELD KO PERFECT PILL SHAPE DIYA HAI 👇
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: ctrl,
        textAlign: isCenter ? TextAlign.center : TextAlign.left,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        style: const TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textLight.withOpacity(0.5), fontWeight: FontWeight.w400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

          filled: true,
          fillColor: Colors.transparent, // Transparent taake peeche wala gray color nazar aaye

          // 👇 YAHAN BHI BORDERS KO PILL SHAPE DIYA HAI 👇
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return '*';
          if (double.tryParse(value) == null || double.parse(value) <= 0) return '!';
          return null;
        },
      ),
    );
  }

  // Segmented Thickness Toggle (Pill Shaped)
  Widget _thicknessOption(String title, String subtitle) {
    final isSelected = _wallThickness == title;
    return GestureDetector(
      onTap: () => setState(() => _wallThickness = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeSelectorColor : Colors.white.withOpacity(0.9),
          // 👇 YAHAN WALL THICKNESS WALE BOX KO PILL SHAPE DIYA HAI 👇
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            if (isSelected) BoxShadow(color: activeSelectorColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : textDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white.withOpacity(0.8) : textLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Result Row Widget
  Widget _resultRow(String label, String value, bool isPrimary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isPrimary ? textDark : textLight,
            fontSize: isPrimary ? 16 : 14,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isPrimary ? primaryPurple : textDark,
            fontSize: isPrimary ? 18 : 15,
            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Component: Enhanced Isometric Wall Graphic (Softened Colors for Pastel UI)
// -----------------------------------------------------------------------------
class _BrickWallGraphic extends StatelessWidget {
  const _BrickWallGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(color: const Color(0xFF6B65D8).withOpacity(0.1), offset: const Offset(2, 6), blurRadius: 100)
        ],
      ),
      child: const SizedBox(
        width: 70,
        height: 70,
        child: CustomPaint(painter: _SoftBrickWallPainter()),
      ),
    );
  }
}

class _SoftBrickWallPainter extends CustomPainter {
  const _SoftBrickWallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final top = Offset(w * 0.5, h * 0.08);
    final left = Offset(w * 0.08, h * 0.32);
    final right = Offset(w * 0.92, h * 0.32);
    final bottomLeft = Offset(w * 0.08, h * 0.88);
    final bottomRight = Offset(w * 0.92, h * 0.88);
    final bottomCenter = Offset(w * 0.5, h * 0.64);

    final leftFace = Path()..moveTo(top.dx, top.dy)..lineTo(left.dx, left.dy)..lineTo(bottomLeft.dx, bottomLeft.dy)..lineTo(bottomCenter.dx, bottomCenter.dy)..close();
    final rightFace = Path()..moveTo(top.dx, top.dy)..lineTo(right.dx, right.dy)..lineTo(bottomRight.dx, bottomRight.dy)..lineTo(bottomCenter.dx, bottomCenter.dy)..close();

    // Soft Pastel Brick Colors (Aap ka green color)
    canvas.drawPath(leftFace, Paint()..color = const Color(0xFF29DF5C)); // Green
    canvas.drawPath(rightFace, Paint()..color = const Color(0xFFFB7185)); // Coral Red

    final jointPaint = Paint()..color = Colors.white.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 2.0;

    for (var i = 1; i < 4; i++) {
      final t = i / 4;
      canvas.drawLine(Offset.lerp(top, left, t)!, Offset.lerp(bottomCenter, bottomLeft, t)!, jointPaint);
      canvas.drawLine(Offset.lerp(top, right, t)!, Offset.lerp(bottomCenter, bottomRight, t)!, jointPaint);
    }
    canvas.drawPath(leftFace, jointPaint);
    canvas.drawPath(rightFace, jointPaint);
  }

  @override
  bool shouldRepaint(covariant _SoftBrickWallPainter oldDelegate) => false;
}