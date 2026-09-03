import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class MyCreationScreen extends StatefulWidget {
  const MyCreationScreen({super.key});

  @override
  State<MyCreationScreen> createState() => _MyCreationScreenState();
}

class _MyCreationScreenState extends State<MyCreationScreen> {
  List<File> _savedMaps = [];
  bool _isLoading = true;

  // Clay Theme Colors
  final Color bgColor = const Color(0xFFF1F5F9);
  final Color accentBlue = const Color(0xFF3B82F6);
  final Color accentRed = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _loadSavedMaps();
  }

  Future<void> _loadSavedMaps() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/my_creations');

      if (await folder.exists()) {
        final files = folder.listSync();
        _savedMaps = files
            .whereType<File>()
            .where((file) => file.path.endsWith('.png'))
            .toList();
        _savedMaps.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      }
    } catch (e) {
      debugPrint('Error loading maps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMap(File file) async {
    try {
      await file.delete();
      _loadSavedMaps();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Blueprint deleted', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting map: $e');
    }
  }

  Future<void> _downloadToGallery(File file) async {
    try {
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }
      await Gal.putImage(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Downloaded to Gallery!', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading: $e'), backgroundColor: accentRed),
        );
      }
    }
  }

  void _openFullScreenPreview(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageView(
          file: file,
          onDownload: () => _downloadToGallery(file),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Creations',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
            color: Color(0xFF1E293B),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedMaps.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          // Adjusted ratio to accommodate the thick clay borders and buttons
          childAspectRatio: 0.65,
        ),
        itemCount: _savedMaps.length,
        itemBuilder: (context, index) {
          final file = _savedMaps[index];
          return _buildMapCard(file);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: _ClayContainer(
        padding: const EdgeInsets.all(40),
        borderRadius: 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Extruded Icon Block
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.white.withOpacity(0.9), offset: const Offset(-4, -4), blurRadius: 10),
                  BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.4), offset: const Offset(4, 4), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.image, size: 60, color: Color(0xFF94A7B8)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No blueprints yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF334155), letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Go to "Create New" to\ndraw your first map!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(File file) {
    return _ClayContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 28,
      child: Column(
        children: [
          // The Image (Tap to open fullscreen)
          Expanded(
            child: GestureDetector(
              onTap: () => _openFullScreenPreview(file),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    file,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ClayButton(
                onTap: () => _downloadToGallery(file),
                color: accentBlue,
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                depth: 0.6,
                child: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
              ),
              _ClayButton(
                onTap: () => _deleteMap(file),
                color: accentRed,
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                depth: 0.6,
                child: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// FULL SCREEN IMAGE PREVIEWER (CLAY STYLE)
// ==========================================
class FullScreenImageView extends StatelessWidget {
  final File file;
  final VoidCallback onDownload;

  const FullScreenImageView({
    super.key,
    required this.file,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Deeper clay background for viewing
      body: Stack(
        children: [
          // Interactive Viewer
          Center(
            child: InteractiveViewer(
              minScale: 0.1,
              maxScale: 5.0,
              child: Hero(
                tag: file.path, // Optional: Adds a smooth transition if you add Hero tags to the grid
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating Clay App Bar Elements
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ClayButton(
                    onTap: () => Navigator.pop(context),
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    borderRadius: 20,
                    child: const Icon(Icons.close_rounded, color: Color(0xFF1E293B), size: 24),
                  ),
                  _ClayButton(
                    onTap: onDownload,
                    color: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    borderRadius: 20,
                    child: const Row(
                      children: [
                        Icon(Icons.download_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// REUSABLE CLAYMORPHIC COMPONENTS
// ==========================================

class _ClayContainer extends StatelessWidget {
  const _ClayContainer({
    required this.child,
    this.color = Colors.white,
    this.borderRadius = 24,
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
    final isWhite = color == Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Outer Drop Shadow (bottom right)
          BoxShadow(
            color: (isWhite ? const Color(0xFF94A3B8) : color).withOpacity(0.35 * depth),
            offset: Offset(6 * depth, 10 * depth),
            blurRadius: 16 * depth,
          ),
          // Outer Highlight (top left)
          BoxShadow(
            color: Colors.white.withOpacity(isWhite ? 0.9 : 0.4),
            offset: Offset(-4 * depth, -6 * depth),
            blurRadius: 12 * depth,
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          // Inner Clay Volume Gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.75, 1.0],
            colors: [
              Colors.white.withOpacity(isWhite ? 0.7 : 0.4),
              Colors.white.withOpacity(0.0),
              Colors.black.withOpacity(isWhite ? 0.02 : 0.05),
              Colors.black.withOpacity(isWhite ? 0.08 : 0.15),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class _ClayButton extends StatefulWidget {
  const _ClayButton({
    required this.child,
    required this.onTap,
    this.color = Colors.white,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.depth = 1.0,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double depth;

  @override
  State<_ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<_ClayButton> with SingleTickerProviderStateMixin {
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
        child: _ClayContainer(
          color: widget.color,
          padding: widget.padding,
          borderRadius: widget.borderRadius,
          depth: widget.depth,
          child: widget.child,
        ),
      ),
    );
  }
}