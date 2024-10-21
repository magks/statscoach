import 'package:equatable/equatable.dart';
import 'package:stats_coach/models/training_session.dart';
import 'package:stats_coach/models/training_set.dart';
import '../models/player.dart';

class TrainingSetState extends Equatable {
  final Player player;
  final TrainingSet trainingSet;

  const TrainingSetState({
    this.player = const Player(name: ''),
    this.trainingSet = const TrainingSet(),
  });

  // Copy of the state to update it immutably
  TrainingSetState copyWith({
    Player? player,
    TrainingSet? trainingSet,
  }) {
    return TrainingSetState(
      player: player ?? this.player,
      trainingSet: trainingSet ?? this.trainingSet,
    );
  }

  @override
  List<Object> get props => [player, trainingSet];
}

