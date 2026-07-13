class Category {
  final int id;
  final String name;
  final String type; // 'income' | 'expense'
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'] ?? '',
        type: json['type'] ?? 'expense',
        color: json['color'] ?? '#7D8AA8',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'color': color,
      };
}
