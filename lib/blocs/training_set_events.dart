import 'package:equatable/equatable.dart';
import '../models/player.dart';
import 'session_events.dart';

abstract class TrainingSetEvent extends SessionEvent {
  const TrainingSetEvent();

  @override
  List<Object> get props => [];
}

// Event when a player is selected in the tab
class PlayerSelectedForSet extends TrainingSetEvent {
  final int tabIndex;
  final Player player;

  const PlayerSelectedForSet(this.tabIndex, this.player);

  @override
  List<Object> get props => [tabIndex, player];
}

