// stats_state.dart
import 'package:equatable/equatable.dart';
import 'package:stats_coach/models/player.dart';
import 'package:flutter/material.dart';
import 'package:stats_coach/models/player_stats_detail.dart';

class StatsState extends Equatable {
  final List<Player> players;
  final DateTimeRange? dateRange;
  final List<Player> selectedPlayers;
  final double overallPercentage;
  final int totalMadeShots;
  final int totalShots;
  final Map<int, PlayerStatsDetail> playerStatsDetails;
  final String? errorMessage;
  final bool isLoading;

  const StatsState({
    this.players = const [],
    this.dateRange,
    this.selectedPlayers = const [],
    this.overallPercentage = 0,
    this.totalMadeShots = 0,
    this.totalShots = 0,
    this.playerStatsDetails = const {},
    this.errorMessage,
    this.isLoading = false,
  });

  StatsState copyWith({
    List<Player>? players,
    DateTimeRange? dateRange,
    List<Player>? selectedPlayers,
    double? overallPercentage,
    int? totalMadeShots,
    int? totalShots,
    Map<int, PlayerStatsDetail>? playerStatsDetails,
    String? errorMessage,
    bool? isLoading,
  }) {
    return StatsState(
      players: players ?? this.players,
      dateRange: dateRange ?? this.dateRange,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      overallPercentage: overallPercentage ?? this.overallPercentage,
      totalMadeShots: totalMadeShots ?? this.totalMadeShots,
      totalShots: totalShots ?? this.totalShots,
      playerStatsDetails: playerStatsDetails ?? this.playerStatsDetails,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    players,
    dateRange,
    selectedPlayers,
    overallPercentage,
    totalMadeShots,
    totalShots,
    playerStatsDetails,
    errorMessage,
    isLoading,
  ];
}
