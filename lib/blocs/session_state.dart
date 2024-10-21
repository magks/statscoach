import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:stats_coach/models/training_session.dart';
import 'package:stats_coach/models/training_set.dart';
import 'package:stats_coach/viewmodels/training_set_view_model.dart';
import '../models/player.dart';

class SessionState extends Equatable {
  final int currentTabIndex;
  final List<Player> players;
  final List<TrainingSetViewModel> trainingSets;
  final Map<Player, List<TrainingSetViewModel>> playerSets;
  final List<int> madeShots;
  final List<int> totalShots;

  const SessionState({
    this.currentTabIndex = 0,
    this.players = const [],
    this.trainingSets = const [],
    this.playerSets = const {},
    this.madeShots = const [],
    this.totalShots = const [],
  });

  // Copy of the state to update it immutably
  SessionState copyWith({
    int? currentTabIndex,
    List<Player>? players,
    List<TrainingSetViewModel>? trainingSets,
    Map<Player, List<TrainingSetViewModel>>? playerSets,
    List<int>? madeShots,
    List<int>? totalShots,
  }) {
    return SessionState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      players: players ?? this.players,
      trainingSets: trainingSets ?? this.trainingSets,
      playerSets: playerSets ?? this.playerSets,
      madeShots: madeShots ?? this.madeShots,
      totalShots: totalShots ?? this.totalShots,
    );
  }

  @override
  List<Object> get props => [currentTabIndex, players, trainingSets, playerSets, madeShots, totalShots];
}

