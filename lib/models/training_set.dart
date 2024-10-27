class TrainingSet {
  final int? id;
  final int? campId;
  final int? playerId;
  final String? playerName;
  final bool? isDummyName;
  final DateTime? startTimestamp;
  final DateTime? endTimestamp;
  final String? position;
  final String? shotCategory;
  final String? drill;
  final String? location;
  final int? madeShots;
  final int? totalShots;


  const TrainingSet({
    this.id,
    this.campId,
    this.playerId,
    this.playerName,
    this.isDummyName,
    this.startTimestamp,
    this.endTimestamp,
    this.position,
    this.shotCategory,
    this.drill,
    this.location,
    this.madeShots,
    this.totalShots,
  });

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campId': campId,
      'playerId': playerId,
      'playerName': playerName,
      'isDummyName': ( isDummyName ?? false ) ? 1 : 0 ,
      'startTimestamp': startTimestamp?.toIso8601String(),
      'endTimestamp': endTimestamp?.toIso8601String(),
      'position': position,
      'shotCategory': shotCategory,
      'drill': drill,
      'location': location,
      'madeShots': madeShots,
      'totalShots': totalShots,
    };
  }

  factory TrainingSet.fromMap(Map<String, dynamic> map) {
    return TrainingSet(
      id: map['id'],
      campId: map['campId'],
      playerId: map['playerId'],
      playerName: map['playerName'],
      isDummyName: map['isDummyName'] == 1 ? true : false,
      startTimestamp: map['startTimestamp'] != null ? DateTime.parse(
          map['startTimestamp']) : null,
      endTimestamp: map['endTimestamp'] != null
          ? DateTime.parse(map['endTimestamp'])
          : null,
      position: map['position'],
      shotCategory: map['shotCategory'],
      drill: map['drill'],
      location: map['location'],
      madeShots: map['madeShots'],
      totalShots: map['totalShots'],
    );
  }

  // CopyWith method to create a new instance with updated values
  TrainingSet copyWith({
    int? id,
    int? campId,
    int? playerId,
    String? playerName,
    bool? isDummyName,
    DateTime? startTimestamp,
    DateTime? endTimestamp,
    String? position,
    String? shotCategory,
    String? drill,
    String? location,
    int? madeShots,
    int? totalShots,
  }) {
    return TrainingSet(
      id: id ?? this.id,
      campId: campId ?? this.campId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      isDummyName: isDummyName ?? this.isDummyName,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      position: position ?? this.position,
      shotCategory: shotCategory ?? this.shotCategory,
      drill: drill ?? this.drill,
      location: location ?? this.location,
      madeShots: madeShots ?? this.madeShots,
      totalShots: totalShots ?? this.totalShots,
    );
  }
}
