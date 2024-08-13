class Procedure {
  final String name;
  final int price;

  Procedure({required this.name, required this.price});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}
