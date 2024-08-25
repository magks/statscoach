class Player {
  final int? id; // Nullable because it will be null when a player is first created
  final String name;
  final String position; // Optional: You can add more attributes like position, jersey number, etc.

  Player({this.id, required this.name, this.position = ''});

  // Convert a Player into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
    };
  }

  // Implement toString to make it easier to see information about each player when using the print statement.
  @override
  String toString() {
    return 'Player{id: $id, name: $name, position: $position}';
  }
}

