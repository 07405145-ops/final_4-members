import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool available;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.available,
  });

  factory MenuItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return MenuItem(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? 'Others',
      price: (d['price'] ?? 0).toDouble(),
      available: d['available'] ?? true,
    );
  }
}
