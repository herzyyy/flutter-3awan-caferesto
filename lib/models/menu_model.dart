class Menu {
  final int id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      imageUrl: json['image_url'] ?? '',
    );
  }
}
