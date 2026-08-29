import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category_model.dart';
import '../../models/template_model.dart';
import 'template_providers.dart';
import 'package:house_design/features/templates/two_d_details_screen.dart';
import 'widgets/category_card_3d.dart';
import 'widgets/template_card_2d.dart';

/// Shared gallery screen for both 2D and 3D templates — pass [is2D] to
/// pick which provider/card style is used.
class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key, required this.is2D});

  final bool is2D;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(is2D ? '2D House Templates' : '3D House Templates')),
      body: is2D ? const _TwoDCategoryGrid() : const _ThreeDGrid(),
    );
  }
}

// ==========================================
// ERROR UI WIDGET (Donon 2D aur 3D ke liye)
// ==========================================
Widget _buildErrorUI(Object err, VoidCallback onRetry) {
  final errorMessage = err.toString();
  bool isNetworkError = errorMessage.contains('SocketException') ||
      errorMessage.contains('Failed host lookup');

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
            size: 64,
            color: const Color(0xFFB5C1D6),
          ),
          const SizedBox(height: 16),
          Text(
            isNetworkError ? 'No Internet Connection' : 'Something went wrong',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isNetworkError
                ? 'Please check your internet connection and try again.'
                : 'Could not load templates. Please try again later.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF48FB1), // Yahan aap AppColors.primary bhi use kar sakte hain
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ==========================================
// 2D — SqF Categories
// ==========================================
class _TwoDCategoryGrid extends ConsumerWidget {
  const _TwoDCategoryGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categories2DProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No categories available yet.'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final CategoryModel category = categories[index];
                final categoryAsTemplate = TemplateModel(
                  id: category.id,
                  title: category.name,
                  imageUrl: category.imageUrl,
                  category: '2d',
                );

                return Template2DCard(
                  template: categoryAsTemplate,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TwoDDetailsScreen(
                          categoryId: category.id,
                          categoryName: category.name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      // ERROR HANDLER UPDATE KIA GAYA HAI
      error: (err, _) => _buildErrorUI(err, () {
        // ref.invalidate call karne se Provider dubara API fetch karega
        ref.invalidate(categories2DProvider);
      }),
    );
  }
}

// ==========================================
// 3D — Templates
// ==========================================
class _ThreeDGrid extends ConsumerWidget {
  const _ThreeDGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templates3DProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(child: Text('No templates available yet.'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return Category3DCard(template: templates[index]);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      // ERROR HANDLER UPDATE KIA GAYA HAI
      error: (err, _) => _buildErrorUI(err, () {
        // ref.invalidate call karne se Provider dubara API fetch karega
        ref.invalidate(templates3DProvider);
      }),
    );
  }
}