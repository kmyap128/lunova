import 'package:cloud_firestore/cloud_firestore.dart';

// Class representing an item of clothing
class ClothingItem {
  final String id;      
  final String category;      // i.e. tops, bottoms, shoes, etc
  final String imageUrl;
  final DateTime createdAt;   // used for displaying most recently added items

  ClothingItem({
    required this.id,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
  });

  // Convert Firestore doc to ClothingItem object
  factory ClothingItem.fromMap(Map<String, dynamic> data, String docId) {
    return ClothingItem(
      id: docId,
      category: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert ClothingItem object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
