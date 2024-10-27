// models/player_stats_detail.dart
class PlayerStatsDetail {
  final int playerId;
  final double overallPercentage;

  // Updated structures
  final List<String> positions;
  final List<double> positionPercentages;

  final List<String> shotCategories;
  final List<double> shotCategoryPercentages;

  final List<String> drills;
  final List<double> drillPercentages;

  final List<String> locations;
  final List<double> locationPercentages;

  final int totalMadeShots; 
  final int totalShots; 

  PlayerStatsDetail({
    required this.playerId,
    required this.overallPercentage,
    required this.positions,
    required this.positionPercentages,
    required this.shotCategories,
    required this.shotCategoryPercentages,
    required this.drills,
    required this.drillPercentages,
    required this.locations,
    required this.locationPercentages,
    required this.totalMadeShots, 
    required this.totalShots, 
  });
}
