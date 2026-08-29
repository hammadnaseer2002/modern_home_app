import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TankVolumeCalculatorScreen extends StatefulWidget {
  const TankVolumeCalculatorScreen({super.key});

  @override
  State<TankVolumeCalculatorScreen> createState() =>
      _TankVolumeCalculatorScreenState();
}

class _TankVolumeCalculatorScreenState
    extends State<TankVolumeCalculatorScreen>
    with TickerProviderStateMixin {

  // 🎨 Soft UI Colors & Gradients
  static const Color bgColor = Color(0xFFF7F8FC);
  static const Color textDark = Color(0xFF2C3140);
  static const Color textLight = Color(0xFF7A809B);
  static const Color primaryPurple = Color(0xFF6B65D8);

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
  String _shape = 'Rectangular';

  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _diameterCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  double? _volumeCuFt;
  double? _volumeCuM;
  double? _liters;
  double? _usGallons;
  double? _impGallons;

  late AnimationController _resultAnimController;
  late Animation<double> _resultFadeAnimation;
  late Animation<Offset> _resultSlideAnimation;

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
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _diameterCtrl.dispose();
    _heightCtrl.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  void _clear() {
    _formKey.currentState?.reset();
    _lengthCtrl.clear();
    _widthCtrl.clear();
    _diameterCtrl.clear();
    _heightCtrl.clear();
    _shape = 'Rectangular';
    _resultAnimController.reverse();
    setState(() {
      _volumeCuFt = null;
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // Hide keyboard

    final height = double.parse(_heightCtrl.text);
    double volumeCuFt;

    if (_shape == 'Rectangular') {
      final length = double.parse(_lengthCtrl.text);
      final width = double.parse(_widthCtrl.text);
      volumeCuFt = length * width * height;
    } else {
      final diameter = double.parse(_diameterCtrl.text);
      final radius = diameter / 2;
      volumeCuFt = math.pi * radius * radius * height;
    }

    setState(() {
      _volumeCuFt = volumeCuFt;
      _volumeCuM = volumeCuFt * 0.0283168;
      _liters = volumeCuFt * 28.3168;
      _usGallons = volumeCuFt * 7.48052;
      _impGallons = volumeCuFt * 6.22884;
    });

    _resultAnimController.forward(from: 0.0);
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
          'Tank Volume Calculator',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // 1. Tank Shape Card (Lilac Gradient)
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
                    const Text('Tank Shape', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 16),
                    _buildWhiteDropdown(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Dimensions Card (Peach Gradient)
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
                    const Text('Dimensions (ft)', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 16),

                    // Animated Size for smooth transition between shapes
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _shape == 'Rectangular'
                          ? Row(
                        children: [
                          Expanded(child: _buildWhiteInput(_lengthCtrl, 'Length', isCenter: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildWhiteInput(_widthCtrl, 'Width', isCenter: true)),
                        ],
                      )
                          : _buildWhiteInput(_diameterCtrl, 'Diameter (ft)', isCenter: true),
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteInput(_heightCtrl, 'Height / Depth (ft)', isCenter: true),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 3. Calculate Button (Pill Shaped)
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
                child: const Text('Calculate Capacity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),

              // 4. Results Card (White Gradient with slide animation)
              if (_volumeCuFt != null) ...[
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Volume & Capacity',
                              style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Volumes
                          _resultRow('Volume (cu ft)', '${_volumeCuFt!.toStringAsFixed(2)} cu ft', false),
                          const SizedBox(height: 8),
                          _resultRow('Volume (cu m)', '${_volumeCuM!.toStringAsFixed(3)} m³', false),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Color(0xFFF0F1F5), thickness: 1.5),
                          ),

                          // Capacities
                          _resultRow('Liquid Capacity', '${_liters!.toStringAsFixed(1)} Liters', true),
                          const SizedBox(height: 8),
                          _resultRow('US Gallons', '${_usGallons!.toStringAsFixed(1)} gal', false),
                          const SizedBox(height: 8),
                          _resultRow('Imperial Gallons', '${_impGallons!.toStringAsFixed(1)} gal', false),
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
    );
  }

  // --- Styled Widgets ---

  // White Pill Text Input
  Widget _buildWhiteInput(TextEditingController ctrl, String hint, {bool isCenter = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        // 👇 YAHAN INPUT FIELD KO PERFECT PILL SHAPE DIYA HAI 👇
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
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
          fillColor: Colors.transparent,

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

  // Styled Custom Dropdown (Pill Shaped)
  Widget _buildWhiteDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        // 👇 YAHAN DROPDOWN KO BHI PILL SHAPE DIYA HAI 👇
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _shape,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textLight),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          style: const TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 16),
          items: const [
            DropdownMenuItem(value: 'Rectangular', child: Text('Rectangular Tank')),
            DropdownMenuItem(value: 'Cylindrical', child: Text('Cylindrical Tank')),
          ],
          onChanged: (v) {
            setState(() {
              _shape = v!;
              _lengthCtrl.clear();
              _widthCtrl.clear();
              _diameterCtrl.clear();
            });
          },
        ),
      ),
    );
  }

  // Result Row Custom Styling
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
            color: isPrimary ? primaryPurple : textDark.withOpacity(0.8),
            fontSize: isPrimary ? 18 : 15,
            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}