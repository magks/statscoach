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
}
