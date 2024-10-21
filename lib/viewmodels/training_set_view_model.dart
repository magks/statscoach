class TrainingSetViewModel {
  final int? id;
  final int? campId;
  final int? playerId;
  final String? playerName;
  final String? playerDisplayName;
  final int? dupPlayerIdx; // if this player is in multiple sets in a session, can store relative idx here
  final bool? isDummyName;
  final DateTime? startTimestamp;
  final DateTime? endTimestamp;
  final String? position;
  final String? shotCategory;
  final String? drill;
  final String? location;
  final int? madeShots;
  final int? totalShots;


  const TrainingSetViewModel({
    this.id,
    this.campId,
    this.playerId,
    this.playerName,
    this.playerDisplayName,
    this.dupPlayerIdx,
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
      'playerDisplayName': playerDisplayName,
      'dupPlayerIdx': dupPlayerIdx,
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

  factory TrainingSetViewModel.fromMap(Map<String, dynamic> map) {
    return TrainingSetViewModel(
      id: map['id'],
      campId: map['campId'],
      playerId: map['playerId'],
      playerName: map['playerName'],
      playerDisplayName: map['playerDisplayName'],
      dupPlayerIdx: map['dupPlayerIdx'],
      isDummyName: map['isDummyName'] == 1 ? true : false,
      startTimestamp: map['startTimestamp'] != null ? DateTime.parse(
          map['date']) : null,
      endTimestamp: map['endTimestamp'] != null
          ? DateTime.parse(map['date'])
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
  TrainingSetViewModel copyWith({
    int? id,
    int? campId,
    int? playerId,
    String? playerName,
    String? playerDisplayName,
    int? dupPlayerIdx,
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
    return TrainingSetViewModel(
      id: id ?? this.id,
      campId: campId ?? this.campId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      playerDisplayName: playerDisplayName ?? this.playerDisplayName,
      dupPlayerIdx: dupPlayerIdx ?? this.dupPlayerIdx,
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
