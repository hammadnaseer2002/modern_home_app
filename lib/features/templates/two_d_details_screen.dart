import 'package:flutter/material.dart';
import 'package:house_design/models/template_model.dart';
import 'package:house_design/services/api_service.dart';
import 'package:house_design/features/templates/widgets/template_card_2d.dart';
import 'package:house_design/features/templates/full_image_view_screen.dart';

class TwoDDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const TwoDDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<TwoDDetailsScreen> createState() => _TwoDDetailsScreenState();
}

class _TwoDDetailsScreenState extends State<TwoDDetailsScreen> {
  final HouseApiService _apiService = HouseApiService();
  List<TemplateModel> _templates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    try {
      final templates = await _apiService.fetch2DTemplates(widget.categoryId);
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text("Error: $_errorMessage"))
          : _templates.isEmpty
          ? const Center(child: Text("Is category mein koi tasweer nahi hai."))
          : GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.72,
        ),
        itemCount: _templates.length,
        itemBuilder: (context, index) {
          return Template2DCard(
            template: _templates[index],
            showFooter: false, // <-- yahan banner hide
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullImageViewScreen(
                    templates: _templates,
                    initialIndex: index,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}