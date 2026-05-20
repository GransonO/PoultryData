import 'package:flutter/foundation.dart';
import '../models/capture_item.dart';

class GalleryProvider extends ChangeNotifier {
  final List<CaptureItem> _items = [];

  List<CaptureItem> get items => List.unmodifiable(_items);

  List<CaptureItem> get photos =>
      _items.where((i) => i.type == CaptureType.photo).toList();

  List<CaptureItem> get videos =>
      _items.where((i) => i.type == CaptureType.video).toList();

  int get totalCount => _items.length;
  int get photoCount => photos.length;
  int get videoCount => videos.length;

  List<CaptureItem> get recentItems => _items.reversed.take(6).toList();

  void addCapture(CaptureItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeCapture(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  CaptureItem? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
