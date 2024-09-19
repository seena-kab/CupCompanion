// lib/models/item.dart

class Item {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String description;
  final double price;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.price,
  });
}