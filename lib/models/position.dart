class Position {
  final int?  id;
  final String name;

  Position({
    this.id,
    required this.name,
  });

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      id: map['id'],
      name: map['name'],
    );
  }
}
