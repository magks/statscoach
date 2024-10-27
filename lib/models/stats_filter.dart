import 'package:flutter/material.dart';

class StatsFilter {
  DateTimeRange? dateRange;
  List<int>? playerIds;
  String? shotCategory; // Add this line

  StatsFilter({
    this.dateRange,
    this.playerIds,
    this.shotCategory,
  });
}