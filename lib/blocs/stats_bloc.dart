// stats_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stats_coach/blocs/stats_events.dart';
import 'package:stats_coach/blocs/stats_state.dart';
import 'package:stats_coach/models/player.dart';
import 'package:stats_coach/models/player_stats_detail.dart';
import 'package:stats_coach/models/training_set.dart';
import 'package:stats_coach/services/database_helper.dart';
import 'package:flutter/material.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc() : super(StatsState()) {
    on<InitializeStats>(_onInitializeStats);
    on<AddNewPlayer>(_onAddNewPlayer);
    on<UpdateDateRange>(_onUpdateDateRange);
    on<UpdateSelectedPlayers>(_onUpdateSelectedPlayers);
    on<FetchStats>(_onFetchStats);
  }

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _onInitializeStats(
      InitializeStats event, Emitter<StatsState> emit) async {
    try {
      final db = await _dbHelper.database;
      List<Map<String, dynamic>> playerMaps = await db.query('players');
      List<Player> players =
      playerMaps.map((map) => Player.fromMap(map)).toList();
      emit(state.copyWith(players: players));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load players: $e'));
    }
  }

  void _onAddNewPlayer(AddNewPlayer event, Emitter<StatsState> emit) {
    List<Player> updatedPlayers = List.from(state.players)..add(event.player);
    emit(state.copyWith(players: updatedPlayers));
  }

  void _onUpdateDateRange(UpdateDateRange event, Emitter<StatsState> emit) {
    emit(state.copyWith(dateRange: event.dateRange));
  }

  void _onUpdateSelectedPlayers(
      UpdateSelectedPlayers event, Emitter<StatsState> emit) {
    emit(state.copyWith(selectedPlayers: event.selectedPlayers));
  }

  Future<void> _onFetchStats(FetchStats event, Emitter<StatsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final db = await _dbHelper.database;

      // Build the query based on filters
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (state.dateRange != null) {
        whereClause += '(startTimestamp >= ? AND endTimestamp <= ?)';
        whereArgs.add(state.dateRange!.start.toIso8601String());
        whereArgs.add(state.dateRange!.end.toIso8601String());
      }

      if (state.selectedPlayers.isNotEmpty) {
        if (whereClause.isNotEmpty) {
          whereClause += ' AND ';
        }
        whereClause +=
        'playerId IN (${List.filled(state.selectedPlayers.length, '?').join(',')})';
        whereArgs.addAll(state.selectedPlayers.map((p) => p.id));
      }

      List<Map<String, dynamic>> result = await db.query(
        'TrainingSet',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );

      List<TrainingSet> trainingSets =
      result.map((map) => TrainingSet.fromMap(map)).toList();

      // Compute overall statistics
      int totalMadeShots =
      trainingSets.fold(0, (sum, item) => sum + (item.madeShots ?? 0));
      int totalShots =
      trainingSets.fold(0, (sum, item) => sum + (item.totalShots ?? 0));
      double overallPercentage =
      totalShots > 0 ? (totalMadeShots / totalShots) * 100 : 0;

      // Compute detailed stats per player
      Map<int, PlayerStatsDetail> playerStatsDetails = {};

      for (var player in state.selectedPlayers) {
        // Filter training sets for this player
        List<TrainingSet> playerSets =
        trainingSets.where((set) => set.playerId == player.id).toList();

        // Compute overall stats for this player
        int playerMadeShots =
        playerSets.fold(0, (sum, item) => sum + (item.madeShots ?? 0));
        int playerTotalShots =
        playerSets.fold(0, (sum, item) => sum + (item.totalShots ?? 0));
        double playerOverallPercentage = playerTotalShots > 0
            ? (playerMadeShots / playerTotalShots) * 100
            : 0;

        // Compute stats breakdowns
        Map<String, double> positionPercentages =
        _computeBreakdown(playerSets, (set) => set.position);
        Map<String, double> shotCategoryPercentages =
        _computeBreakdown(playerSets, (set) => set.shotCategory);
        Map<String, double> drillPercentages =
        _computeBreakdown(playerSets, (set) => set.drill);
        Map<String, double> locationPercentages =
        _computeBreakdown(playerSets, (set) => set.location);

        // Create PlayerStatsDetail
        playerStatsDetails[player.id!] = PlayerStatsDetail(
          playerId: player.id!,
          overallPercentage: playerOverallPercentage,
          positionPercentages: positionPercentages,
          shotCategoryPercentages: shotCategoryPercentages,
          drillPercentages: drillPercentages,
          locationPercentages: locationPercentages,
        );
      }

      emit(state.copyWith(
        overallPercentage: overallPercentage,
        playerStatsDetails: playerStatsDetails,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to fetch stats: $e',
        isLoading: false,
      ));
    }
  }

  // Helper method to compute breakdowns
  Map<String, double> _computeBreakdown(
      List<TrainingSet> sets, String? Function(TrainingSet) keySelector) {
    Map<String, int> madeShotsMap = {};
    Map<String, int> totalShotsMap = {};

    for (var set in sets) {
      String? key = keySelector(set) ?? 'Unknown';
      int madeShots = set.madeShots ?? 0;
      int totalShots = set.totalShots ?? 0;

      madeShotsMap.update(key, (value) => value + madeShots,
          ifAbsent: () => madeShots);
      totalShotsMap.update(key, (value) => value + totalShots,
          ifAbsent: () => totalShots);
    }

    Map<String, double> percentages = {};
    totalShotsMap.forEach((key, totalShots) {
      int madeShots = madeShotsMap[key] ?? 0;
      double percentage = totalShots > 0 ? (madeShots / totalShots) * 100 : 0;
      percentages[key] = percentage;
    });

    return percentages;
  }

}
