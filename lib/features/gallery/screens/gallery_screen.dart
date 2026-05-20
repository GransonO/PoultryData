import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/capture_item.dart';
import '../providers/gallery_provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, gallery, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${AppStrings.galleryTitle} (${gallery.totalCount})',
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppColors.secondary,
              tabs: [
                Tab(text: '${AppStrings.allCaptures} (${gallery.totalCount})'),
                Tab(text: '${AppStrings.photos} (${gallery.photoCount})'),
                Tab(text: '${AppStrings.videos} (${gallery.videoCount})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _CaptureGrid(items: gallery.items.reversed.toList()),
              _CaptureGrid(items: gallery.photos.reversed.toList()),
              _CaptureGrid(items: gallery.videos.reversed.toList()),
            ],
          ),
        );
      },
    );
  }
}

class _CaptureGrid extends StatelessWidget {
  final List<CaptureItem> items;

  const _CaptureGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined,
                size: 72, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              AppStrings.noCaptures,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noCapturesSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _CaptureCard(item: items[index]);
      },
    );
  }
}

class _CaptureCard extends StatelessWidget {
  final CaptureItem item;

  const _CaptureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy, HH:mm').format(item.capturedAt);

    return GestureDetector(
      onTap: () => context.push('/gallery/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              _buildThumbnail(),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.captureModeLabel,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Type badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isVideo
                        ? AppColors.recordingRed
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isVideo ? Icons.videocam : Icons.photo_camera,
                        color: Colors.white,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.typeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Video play icon overlay
              if (item.isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white70,
                    size: 44,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final file = File(item.filePath);
    if (!file.existsSync()) {
      return Container(
        color: Colors.grey[850],
        child: const Center(
          child: Icon(Icons.broken_image_outlined,
              color: Colors.white38, size: 40),
        ),
      );
    }

    if (item.isPhoto) {
      return Image.file(file, fit: BoxFit.cover);
    }

    return Container(
      color: Colors.grey[850],
      child: const Center(
        child: Icon(Icons.videocam_outlined, color: Colors.white38, size: 40),
      ),
    );
  }
}
