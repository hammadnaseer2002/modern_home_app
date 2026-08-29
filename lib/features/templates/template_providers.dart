import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/template_model.dart';
import '../../models/category_model.dart';
import '../../services/api_service.dart';

/// Single shared instance of the API service — every provider below
/// reads from this one, so there's only one http.Client for the app.
final houseApiServiceProvider = Provider<HouseApiService>((ref) {
  final service = HouseApiService();
  ref.onDispose(service.dispose);
  return service;
});

// ==========================================
// SqF Categories (2D Templates grid ke liye)
// ==========================================
final categories2DProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(houseApiServiceProvider).fetch2DCategories();
});

// ==========================================
// Purana provider — kahin aur use ho raha hai isliye wapas rakh diya
// ==========================================
final templates2DProvider = FutureProvider<List<TemplateModel>>((ref) {
  return ref.watch(houseApiServiceProvider).fetch2DTemplates('1');
});

final templates3DProvider = FutureProvider<List<TemplateModel>>((ref) {
  return ref.watch(houseApiServiceProvider).fetch3DTemplates();
});

final interiorTemplatesProvider = FutureProvider<List<TemplateModel>>((ref) {
  return ref.watch(houseApiServiceProvider).fetchInteriorTemplates('1');
});