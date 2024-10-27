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
  final Map<int, PlayerStatsDetail> playerStatsDetails; // Updated
  final String? errorMessage;
  final bool isLoading;

  const StatsState({
    this.players = const [],
    this.dateRange,
    this.selectedPlayers = const [],
    this.overallPercentage = 0,
    this.playerStatsDetails = const {}, // Updated
    this.errorMessage,
    this.isLoading = false,
  });

  StatsState copyWith({
    List<Player>? players,
    DateTimeRange? dateRange,
    List<Player>? selectedPlayers,
    double? overallPercentage,
    Map<int, PlayerStatsDetail>? playerStatsDetails, // Updated
    String? errorMessage,
    bool? isLoading,
  }) {
    return StatsState(
      players: players ?? this.players,
      dateRange: dateRange ?? this.dateRange,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      overallPercentage: overallPercentage ?? this.overallPercentage,
      playerStatsDetails: playerStatsDetails ?? this.playerStatsDetails, // Updated
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
    playerStatsDetails, // Updated
    errorMessage,
    isLoading,
  ];
}
