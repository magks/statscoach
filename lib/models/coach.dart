class Coach {
  final int?  id;
  final String? name;
  final int?  teamId;

  Coach({
    this.id,
    this.name,
    this.teamId,
  });

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teamId': teamId,
    };
  }

  factory Coach.fromMap(Map<String, dynamic> map) {
    return Coach(
      id: map['id'],
      name: map['name'],
      teamId: map['teamId'],
    );
  }
}
