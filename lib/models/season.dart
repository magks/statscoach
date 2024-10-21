class Season {
  final int?  id;
  final String? name;
  final DateTime? startDate;
  final DateTime? endDate;

  Season({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
  });

  // Database conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      id: map['id'],
      name: map['name'],
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }
}
