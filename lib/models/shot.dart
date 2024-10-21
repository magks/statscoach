import 'package:flutter/foundation.dart';

class Shot {
  final int?  id;
  final int?  playerId;
  final DateTime timestamp;
  final int?  gameId;
  final int?  sessionId;
  final String? category; // twoball,threeball,freethrow
  final String? drill;
  final String? position;
  final String? courtLocation;
  final String? shotType;
  final double? xLocation;
  final double? yLocation;
  final bool? wasBlocked;
  final bool? involvedDribble;
  final bool? success;

  Shot({
    this.id,
    required this.playerId,
    required this.timestamp,
    this.gameId,
    this.sessionId,
    this.category,
    this.drill,
    this.position,
    this.courtLocation,
    this.shotType,
    this.xLocation,
    this.yLocation,
    this.wasBlocked,
    this.involvedDribble,
    this.success,
  });

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerId': playerId,
      'timestamp': timestamp.toIso8601String(),
      'gameId': gameId,
      'sessionId': sessionId,
      'drill': drill,
      'position': position,
      'courtLocation': courtLocation,
      'shotType': shotType,
      'xLocation': xLocation,
      'yLocation': yLocation,
      'wasBlocked': ( wasBlocked ?? false ) ? 1 : 0 ,
      'involvedDribble': (involvedDribble ?? false ) ? 1 : 0,
      'success': (success ?? false ) ? 1 : 0,
    };
  }

  factory Shot.fromMap(Map<String, dynamic> map) {

    debugPrint('shotFromMap::map.id=$map');

    return Shot(
      id: map['id'],
      playerId: map['playerId'],
      timestamp: DateTime.parse(map['timestamp']),
      gameId: map['gameId'],
      sessionId: map['sessionId'],
      drill: map['drill'],
      position: map['position'],
      courtLocation: map['courtLocation'],
      shotType: map['shotType'],
      xLocation: map['xLocation'],
      yLocation: map['yLocation'],
      wasBlocked: map['wasBlocked'] == 1 ? true : false,
      involvedDribble: map['involvedDribble'] == 1 ? true : false,
      success: map['success'] == 1 ? true : false,
    );
  }
}
