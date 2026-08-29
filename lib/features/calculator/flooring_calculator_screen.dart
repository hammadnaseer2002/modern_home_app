import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlooringCalculatorScreen extends StatefulWidget {
  const FlooringCalculatorScreen({super.key});

  @override
  State<FlooringCalculatorScreen> createState() =>
      _FlooringCalculatorScreenState();
}

class _FlooringCalculatorScreenState extends State<FlooringCalculatorScreen>
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
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _tileLengthCtrl = TextEditingController();
  final _tileWidthCtrl = TextEditingController();
  double _wastage = 5;

  double? _areaSqFt;
  double? _areaSqM;
  double? _totalAreaWithWastage;
  int? _tilesNeeded;

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
    _tileLengthCtrl.dispose();
    _tileWidthCtrl.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  void _clear() {
    _formKey.currentState?.reset();
    _lengthCtrl.clear();
    _widthCtrl.clear();
    _tileLengthCtrl.clear();
    _tileWidthCtrl.clear();
    _wastage = 5;
    _resultAnimController.reverse();
    setState(() {
      _areaSqFt = null;
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final length = double.parse(_lengthCtrl.text);
    final width = double.parse(_widthCtrl.text);

    final area = length * width;
    final totalArea = area * (1 + _wastage / 100);

    int? tiles;
    if (_tileLengthCtrl.text.isNotEmpty && _tileWidthCtrl.text.isNotEmpty) {
      final tileLength = double.tryParse(_tileLengthCtrl.text);
      final tileWidth = double.tryParse(_tileWidthCtrl.text);
      if (tileLength != null &&
          tileWidth != null &&
          tileLength > 0 &&
          tileWidth > 0) {
        final tileAreaSqFt = (tileLength * tileWidth) / 144; // inches -> sq ft
        tiles = (totalArea / tileAreaSqFt).ceil();
      }
    }

    setState(() {
      _areaSqFt = area;
      _areaSqM = area * 0.092903;
      _totalAreaWithWastage = totalArea;
      _tilesNeeded = tiles;
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
          'Flooring Calculator',
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

              // 1. Room Dimensions (Peach Gradient)
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
                    const Text('Room Dimensions', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 16),
                    _buildWhiteInput(_lengthCtrl, 'Room Length (ft)'),
                    const SizedBox(height: 12),
                    _buildWhiteInput(_widthCtrl, 'Room Width (ft)'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Tile Size (Lilac Gradient)
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
                    const Text('Tile Size — Optional (inches)', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildWhiteInput(_tileLengthCtrl, 'Length', isRequired: false, isCenter: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildWhiteInput(_tileWidthCtrl, 'Width', isRequired: false, isCenter: true)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Wastage Slider (White/Grey Gradient)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: _softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Wastage Margin', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                        Text('${_wastage.toStringAsFixed(0)}%', style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryPurple,
                        inactiveTrackColor: primaryPurple.withOpacity(0.15),
                        thumbColor: primaryPurple,
                        overlayColor: primaryPurple.withOpacity(0.2),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                      ),
                      child: Slider(
                        value: _wastage,
                        min: 0,
                        max: 20,
                        divisions: 20,
                        onChanged: (v) => setState(() => _wastage = v),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. Calculate Button (Pill Shaped)
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
                child: const Text('Calculate Flooring', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),

              // 5. Results Card
              if (_areaSqFt != null) ...[
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
                        children: [
                          const Text('Flooring Estimation', style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 20),
                          _resultRow('Room Area', '${_areaSqFt!.toStringAsFixed(2)} sq ft', false),
                          const SizedBox(height: 8),
                          _resultRow('', '${_areaSqM!.toStringAsFixed(2)} sq m', false),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Color(0xFFF0F1F5), thickness: 1.5),
                          ),
                          _resultRow('Total With Wastage', '${_totalAreaWithWastage!.toStringAsFixed(2)} sq ft', true),

                          if (_tilesNeeded != null) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: Color(0xFFF0F1F5), thickness: 1.5),
                            ),
                            _resultRow('Tiles Needed', '$_tilesNeeded pcs', true),
                          ]
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
  Widget _buildWhiteInput(TextEditingController ctrl, String hint, {bool isRequired = true, bool isCenter = false}) {
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
          if (!isRequired) return null;
          if (value == null || value.trim().isEmpty) return '*';
          if (double.tryParse(value) == null || double.parse(value) <= 0) return '!';
          return null;
        },
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
            color: isPrimary ? primaryPurple : textDark,
            fontSize: isPrimary ? 18 : 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}