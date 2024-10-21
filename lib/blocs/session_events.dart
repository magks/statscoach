import 'package:equatable/equatable.dart';
import 'package:stats_coach/models/training_set.dart';
import 'package:stats_coach/viewmodels/training_set_view_model.dart';
import '../models/player.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

class SendPlayerToSession extends SessionEvent {
  final Player player;
  const SendPlayerToSession(this.player);
  @override
  List<Object> get props => [player];
}

class DedupPlayerDisplayNames extends SessionEvent {
  final Player player;
  const DedupPlayerDisplayNames(this.player);
  @override
  List<Object> get props => [player];
}

class UpdatePlayerInSession extends SessionEvent {
  final Player updatedPlayer;
  const UpdatePlayerInSession(this.updatedPlayer);
  @override
  List<Object> get props => [updatedPlayer];
}


class AddPlayer extends SessionEvent {
  final TrainingSetViewModel newTrainingSetViewModel;

  const AddPlayer(this.newTrainingSetViewModel);

  @override
  List<Object> get props => [newTrainingSetViewModel];
}

class RemovePlayer extends SessionEvent {
  final int tabIndex;

  const RemovePlayer(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}

class UpdateCurrentTab extends SessionEvent {
  final int tabIndex;

  const UpdateCurrentTab(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}

class RemoveFromSession extends SessionEvent {
  final int tabIndex;

  const RemoveFromSession(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}

// New event to update the TrainingSetViewModel fields
class TrainingSetViewModelUpdated extends SessionEvent {
  final int tabIndex;
  final TrainingSetViewModel trainingSet;

  const TrainingSetViewModelUpdated(this.tabIndex, this.trainingSet);

  @override
  List<Object> get props => [tabIndex, trainingSet];
}

// Event when a player is selected in the tab
class PlayerSelected extends SessionEvent {
  final int tabIndex;
  final Player player;

  const PlayerSelected(this.tabIndex, this.player);

  @override
  List<Object> get props => [tabIndex, player];
}

// Event when shots are updated (made/missed)
class ShotRecorded extends SessionEvent {
  final int tabIndex;
  final bool isMade;

  const ShotRecorded(this.tabIndex, this.isMade);

  @override
  List<Object> get props => [tabIndex, isMade];
}

