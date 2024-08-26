class Shot {
  final int? id;
  final int playerId;
  final String shotType;
  final bool wasBlocked;
  final bool involvedDribble;
  final double xLocation; // X coordinate on the court
  final double yLocation; // Y coordinate on the court
  final DateTime timestamp;

  Shot({
    this.id,
    required this.playerId,
    required this.shotType,
    required this.wasBlocked,
    required this.involvedDribble,
    required this.xLocation,
    required this.yLocation,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerId': playerId,
      'shotType': shotType,
      'wasBlocked': wasBlocked ? 1 : 0,
      'involvedDribble': involvedDribble ? 1 : 0,
      'xLocation': xLocation,
      'yLocation': yLocation,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Shot{id: $id, playerId: $playerId, shotType: $shotType, '
        'wasBlocked: $wasBlocked, involvedDribble: $involvedDribble, '
        'xLocation: $xLocation, yLocation: $yLocation, timestamp: $timestamp}';
  }
}

