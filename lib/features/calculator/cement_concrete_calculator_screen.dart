import 'package:flutter/material.dart';

class CementConcreteCalculatorScreen extends StatefulWidget {
  const CementConcreteCalculatorScreen({super.key});

  @override
  State<CementConcreteCalculatorScreen> createState() =>
      _CementConcreteCalculatorScreenState();
}

class _CementConcreteCalculatorScreenState
    extends State<CementConcreteCalculatorScreen> with TickerProviderStateMixin {

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

  // Constants
  static const double _dryVolumeFactor = 1.54;
  static const double _cementBagVolumeM3 = 0.0347; // 1 bag (50kg) in m3

  // Controllers & State
  final _formKey = GlobalKey<FormState>();
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _thicknessCtrl = TextEditingController();

  final Map<String, List<double>> _mixRatios = const {
    '1 : 1.5 : 3 (M20)': [1, 1.5, 3],
    '1 : 2 : 4 (M15)': [1, 2, 4],
    '1 : 3 : 6 (M10)': [1, 3, 6],
    '1 : 4 : 8 (M7.5)': [1, 4, 8],
  };
  late String _selectedMix;

  double? _wetVolumeCuFt;
  double? _wetVolumeM3;
  double? _dryVolumeM3;
  double? _cementBags;
  double? _cementKg;
  double? _sandCuFt;
  double? _sandM3;
  double? _aggregateCuFt;
  double? _aggregateM3;

  // Animations
  late AnimationController _resultAnimController;
  late Animation<double> _resultFadeAnimation;
  late Animation<Offset> _resultSlideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedMix = _mixRatios.keys.first;

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
    _thicknessCtrl.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  void _clear() {
    _formKey.currentState?.reset();
    _lengthCtrl.clear();
    _widthCtrl.clear();
    _thicknessCtrl.clear();
    _selectedMix = _mixRatios.keys.first;
    _resultAnimController.reverse();
    setState(() {
      _wetVolumeCuFt = null;
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // Hide keyboard

    final length = double.parse(_lengthCtrl.text);
    final width = double.parse(_widthCtrl.text);
    final thicknessIn = double.parse(_thicknessCtrl.text);

    final wetVolumeCuFt = length * width * (thicknessIn / 12);
    final wetVolumeM3 = wetVolumeCuFt * 0.0283168;
    final dryVolumeM3 = wetVolumeM3 * _dryVolumeFactor;

    final ratio = _mixRatios[_selectedMix]!;
    final sumRatio = ratio[0] + ratio[1] + ratio[2];

    final cementM3 = dryVolumeM3 * (ratio[0] / sumRatio);
    final sandM3 = dryVolumeM3 * (ratio[1] / sumRatio);
    final aggregateM3 = dryVolumeM3 * (ratio[2] / sumRatio);

    setState(() {
      _wetVolumeCuFt = wetVolumeCuFt;
      _wetVolumeM3 = wetVolumeM3;
      _dryVolumeM3 = dryVolumeM3;
      _cementBags = cementM3 / _cementBagVolumeM3;
      _cementKg = _cementBags! * 50;
      _sandM3 = sandM3;
      _sandCuFt = sandM3 * 35.3147;
      _aggregateM3 = aggregateM3;
      _aggregateCuFt = aggregateM3 * 35.3147;
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
          'Cement Concrete',
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

              // 1. Dimensions Card (Peach Gradient)
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
                    const Text('Slab / Area Dimensions', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 16),
                    _buildWhiteInput(_lengthCtrl, 'Length (ft)'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildWhiteInput(_widthCtrl, 'Width (ft)', isCenter: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildWhiteInput(_thicknessCtrl, 'Thickness (in)', isCenter: true)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Mix Ratio Card (Lilac Gradient)
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
                    const Text('Concrete Mix Ratio', style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 16),
                    _buildWhiteDropdown(),
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
                child: const Text('Calculate Estimation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),

              // 4. Results Card (White Gradient with slide animation)
              if (_wetVolumeCuFt != null) ...[
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
                              'Material Requirements',
                              style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Volumes Section
                          _resultRow('Wet Volume', '${_wetVolumeCuFt!.toStringAsFixed(2)} cu ft  (${_wetVolumeM3!.toStringAsFixed(2)} m³)', false),
                          const SizedBox(height: 8),
                          _resultRow('Dry Volume (1.54x)', '${_dryVolumeM3!.toStringAsFixed(3)} m³', false),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Color(0xFFF0F1F5), thickness: 1.5),
                          ),

                          // Materials Section
                          _resultRow('Cement Needed', '${_cementBags!.toStringAsFixed(2)} Bags', true),
                          const SizedBox(height: 4),
                          _resultRow('', '${_cementKg!.toStringAsFixed(1)} kg', false),

                          const SizedBox(height: 16),

                          _resultRow('Sand Required', '${_sandCuFt!.toStringAsFixed(2)} cu ft', true),
                          const SizedBox(height: 4),
                          _resultRow('', '${_sandM3!.toStringAsFixed(3)} m³', false),

                          const SizedBox(height: 16),

                          _resultRow('Aggregate Required', '${_aggregateCuFt!.toStringAsFixed(2)} cu ft', true),
                          const SizedBox(height: 4),
                          _resultRow('', '${_aggregateM3!.toStringAsFixed(3)} m³', false),
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
          value: _selectedMix,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textLight),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          style: const TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 16),
          items: _mixRatios.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
          onChanged: (v) => setState(() => _selectedMix = v!),
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