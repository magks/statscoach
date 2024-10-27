// models/player_stats_detail.dart
class PlayerStatsDetail {
  final int playerId;
  final double overallPercentage;
  final Map<String, double> positionPercentages;
  final Map<String, double> shotCategoryPercentages;
  final Map<String, double> drillPercentages;
  final Map<String, double> locationPercentages;

  PlayerStatsDetail({
    required this.playerId,
    required this.overallPercentage,
    required this.positionPercentages,
    required this.shotCategoryPercentages,
    required this.drillPercentages,
    required this.locationPercentages,
  });
}
