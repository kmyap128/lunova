import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lunova/clothing_item.dart';

class Outfit {
  final String id;
  final String name;
  final List<ClothingItem> items; // full objects
  final DateTime createdAt;

  Outfit({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
  });

  factory Outfit.fromMap(Map<String, dynamic> data, String docId, List<ClothingItem> allItems) {
    // 'itemIds' is a list of clothing document IDs in Firestore
    List<String> itemIds = List<String>.from(data['itemIds'] ?? []);
    List<ClothingItem> outfitItems = allItems.where((item) => itemIds.contains(item.id)).toList();

    return Outfit(
      id: docId,
      name: data['name'] ?? '',
      items: outfitItems,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'itemIds': items.map((item) => item.id).toList(), // store only IDs in Firestore
      'createdAt': createdAt,
    };
  }

  // Helper to get a representative image (e.g., first clothing item)
  String get representativeImage => items.isNotEmpty ? items[0].imageUrl : '';
}
