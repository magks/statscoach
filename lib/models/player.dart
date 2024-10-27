class Player {
  final int?  id;
  final String name;
  final int? jerseyNumber;
  final String? position;
  final double? height;
  final double? weight;
  final int? age;
  final int?  teamId;
  final String? photo;

  const Player({
    this.id,
    required this.name,
    this.jerseyNumber,
    this.position,
    this.height,
    this.weight,
    this.age,
    this.teamId,
    this.photo,
  });

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'jerseyNumber': jerseyNumber,
      'position': position,
      'height': height,
      'weight': weight,
      'age': age,
      'teamId': teamId,
      'photo': photo,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      jerseyNumber: map['jerseyNumber'],
      position: map['position'],
      height: map['height'],
      weight: map['weight'],
      age: map['age'],
      teamId: map['teamId'],
      photo: map['photo'],
    );
  }

  // CopyWith method
  Player copyWith({
    int? id,
    String? name,
    int? jerseyNumber,
    String? position,
    double? height,
    double? weight,
    int? age,
    int? teamId,
    String? photo,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      position: position ?? this.position,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      teamId: teamId ?? this.teamId,
      photo: photo ?? this.photo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id ?? 0;
}
