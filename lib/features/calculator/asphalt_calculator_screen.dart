import 'package:flutter/material.dart';

class AsphaltCalculatorScreen extends StatefulWidget {
  const AsphaltCalculatorScreen({super.key});

  @override
  State<AsphaltCalculatorScreen> createState() =>
      _AsphaltCalculatorScreenState();
}

class _AsphaltCalculatorScreenState extends State<AsphaltCalculatorScreen> {
  // 🎨 Soft UI Colors (Extracted from the image style)
  static const Color bgColor = Color(0xFFF7F8FC);
  static const Color textDark = Color(0xFF2C3140);
  static const Color textLight = Color(0xFF7A809B);

  // Gradients for cards
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

  final _formKey = GlobalKey<FormState>();
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _thicknessCtrl = TextEditingController();
  final _densityCtrl = TextEditingController(text: '145');

  double? _areaSqFt;
  double? _volumeCuFt;
  double? _weightLb;
  double? _weightUsTons;
  double? _weightTonnes;

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _thicknessCtrl.dispose();
    _densityCtrl.dispose();
    super.dispose();
  }

  void _clear() {
    _lengthCtrl.clear();
    _widthCtrl.clear();
    _thicknessCtrl.clear();
    _densityCtrl.text = '145';
    setState(() {
      _areaSqFt = null;
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // Keyboard hide karne ke liye

    final length = double.parse(_lengthCtrl.text);
    final width = double.parse(_widthCtrl.text);
    final thicknessIn = double.parse(_thicknessCtrl.text);
    final density = double.parse(_densityCtrl.text);

    final area = length * width;
    final volumeCuFt = area * (thicknessIn / 12);
    final weightLb = volumeCuFt * density;
    final weightKg = weightLb * 0.453592;

    setState(() {
      _areaSqFt = area;
      _volumeCuFt = volumeCuFt;
      _weightLb = weightLb;
      _weightUsTons = weightLb / 2000;
      _weightTonnes = weightKg / 1000;
    });
  }

  // Soft shadow for all cards
  List<BoxShadow> get _softShadow => [
    BoxShadow(
      color: const Color(0xFFDCE1F0).withOpacity(0.6),
      blurRadius: 24,
      spreadRadius: 4,
      offset: const Offset(0, 10),
    )
  ];

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
          'Asphalt Calculator',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          // "Skip" style Clear Button
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
            child: InkWell(
              onTap: _clear,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E9FF), // FIXED: Typo in Hex Color
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(0xFF6B65D8), // Purple text
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
              // 1. Plot Size Style Card (For Length & Width)
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
                    const Text('Paving Area', style: TextStyle(color: textLight, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    _buildWhiteInput(_lengthCtrl, 'Length (ft)'),
                    const SizedBox(height: 12),
                    _buildWhiteInput(_widthCtrl, 'Width (ft)'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Bedrooms / Bathrooms Style Cards (For Thickness & Density)
              Row(
                children: [
                  // Thickness Card (Lilac)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: lilacGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: _softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Thickness', style: TextStyle(color: textLight, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          _buildWhiteInput(_thicknessCtrl, 'Inches', isCenter: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Density Card (Peach)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: peachGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: _softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Density', style: TextStyle(color: textLight, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          _buildWhiteInput(_densityCtrl, 'lb/ft³', isCenter: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Calculate Button (Pill Shaped)
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6F8E),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0xFF2F6131).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  // 👇 YAHAN BUTTON KO PILL SHAPE DIYA HAI 👇
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Calculate Blueprint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),

              if (_areaSqFt != null) ...[
                const SizedBox(height: 32),

                // 3. Results Card
                FittedBox(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: whiteGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _softShadow,
                    ),
                    child: Column(
                      children: [
                        _resultRow('Total Area', '${_areaSqFt!.toStringAsFixed(2)} sq ft', true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF0F1F5), thickness: 1.5),
                        ),
                        _resultRow('Volume', '${_volumeCuFt!.toStringAsFixed(2)} cu ft', false),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFF0F1F5), thickness: 1.5),
                        ),
                        _resultRow('Weight (US Tons)', '${_weightUsTons!.toStringAsFixed(2)} tons', true),
                        const SizedBox(height: 12),
                        _resultRow('Weight (Tonnes)', '${_weightTonnes!.toStringAsFixed(2)} tonnes', false),
                      ],
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

  // White Pill Input Field Widget
  Widget _buildWhiteInput(TextEditingController ctrl, String hint, {bool isCenter = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Agar aapko orange chahiye tha toh 'Colors.orange.withOpacity(0.9)' kar sakte hain
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
        style: const TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textLight.withOpacity(0.5), fontWeight: FontWeight.w400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

          filled: true,
          fillColor: Colors.transparent,

          // 👇 YAHAN BHI BORDERS KO PILL SHAPE DIYA HAI (Taake corners na katein) 👇
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
          if (double.tryParse(value) == null) return '!';
          return null;
        },
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
            fontSize: isPrimary ? 16 : 15,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isPrimary ? const Color(0xFF6B65D8) : textDark,
            fontSize: isPrimary ? 16 : 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}