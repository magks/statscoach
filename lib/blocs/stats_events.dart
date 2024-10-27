import 'package:equatable/equatable.dart';
import 'package:stats_coach/models/player.dart';
import 'package:flutter/material.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateDateRange extends StatsEvent {
  final DateTimeRange dateRange;

  const UpdateDateRange(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

class InitializeStats extends StatsEvent {
  const InitializeStats();
}

class AddNewPlayer extends StatsEvent {
  final Player player;

  const AddNewPlayer(this.player);

  @override
  List<Object?> get props => [player];
}
class UpdateSelectedPlayers extends StatsEvent {
  final List<Player> selectedPlayers;

  const UpdateSelectedPlayers(this.selectedPlayers);

  @override
  List<Object?> get props => [selectedPlayers];
}

class FetchStats extends StatsEvent {
  const FetchStats();
}
