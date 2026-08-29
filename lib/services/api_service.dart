import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/template_model.dart';
import '../models/category_model.dart';

class HouseApiService {
  HouseApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // ==========================================
  // HELPER METHOD (Error Fix)
  // Yeh method server ke response ko safely list mein convert karta hai
  // ==========================================
  List<dynamic> _extractList(dynamic decodedData) {
    if (decodedData is Map<String, dynamic>) {
      // Aksar PHP APIs list ko in keys ke andar bhejti hain
      final data = decodedData['data'] ??
          decodedData['categories'] ??
          decodedData['templates'] ??
          decodedData['result'] ??
          [];
      return data;
    } else if (decodedData is List) {
      return decodedData;
    }
    return [];
  }

  // ==========================================
  // 2D TEMPLATES API
  // ==========================================

  Future<List<CategoryModel>> fetch2DCategories() async {
    final uri = Uri.parse('https://alameensoft.tech/apps/HouseDesign/2d_categories.php');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      final List<dynamic> data = _extractList(decodedData);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load 2D Categories');
  }

  Future<List<TemplateModel>> fetch2DTemplates(String categoryId) async {
    final uri = Uri.parse('https://alameensoft.tech/apps/HouseDesign/2d_templates.php');

    // POST Request with form-data (category=id)
    final response = await _client.post(
      uri,
      body: {'category': categoryId},
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      final List<dynamic> data = _extractList(decodedData);
      return data.map((e) => TemplateModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load 2D Templates');
  }

  // ==========================================
  // INTERIOR DESIGN API
  // ==========================================

  Future<List<CategoryModel>> fetchInteriorCategories() async {
    final uri = Uri.parse('https://alameensoft.tech/apps/HouseDesign/interior_categories.php');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      final List<dynamic> data = _extractList(decodedData);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load Interior Categories');
  }

  Future<List<TemplateModel>> fetchInteriorTemplates(String categoryId) async {
    final uri = Uri.parse('https://alameensoft.tech/apps/HouseDesign/interior_templates.php');

    // POST Request with form-data (category=id)
    final response = await _client.post(
      uri,
      body: {'category': categoryId},
    );

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      final List<dynamic> data = _extractList(decodedData);
      return data.map((e) => TemplateModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load Interior Templates');
  }

  // ==========================================
  // 3D TEMPLATES API
  // ==========================================

  Future<List<TemplateModel>> fetch3DTemplates() async {
    final uri = Uri.parse('https://alameensoft.tech/apps/HouseDesign/3d_templates.php');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final dynamic decodedData = jsonDecode(response.body);
      final List<dynamic> data = _extractList(decodedData);
      return data.map((e) => TemplateModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load 3D Templates');
  }

  void dispose() => _client.close();
}