class TrainingSession {
  final int?  id;
  final int?  campId;
  final DateTime? date;

  TrainingSession({
    this.id,
    this.campId,
    this.date,
  });

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campId': campId,
      'date': date?.toIso8601String(),
    };
  }

  factory TrainingSession.fromMap(Map<String, dynamic> map) {
    return TrainingSession(
      id: map['id'],
      campId: map['campId'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
    );
  }
}
