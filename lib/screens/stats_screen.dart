import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stats_coach/blocs/stats_bloc.dart';
import 'package:stats_coach/blocs/stats_events.dart';
import 'package:stats_coach/blocs/stats_state.dart';
import 'package:stats_coach/models/player.dart';
import 'package:stats_coach/models/player_stats_detail.dart';
import 'package:stats_coach/services/database_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(InitializeStats());
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 7)),
      currentDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        //var lastDateStr = picked.end.toString().split(" ").first;
        //var lastMomentOfEndDateStr = "$lastDateStr 23:59:59.999";
        final DateTimeRange selectedDateRange = DateTimeRange(
            start: picked.start,
            end: DateTime(
              picked.end.year,
              picked.end.month,
              picked.end.day,
              23, 59, 59, 999
            )
        );
        context.read<StatsBloc>().add(UpdateDateRange(selectedDateRange));
        // Dispatch FetchStats event
        context.read<StatsBloc>().add(FetchStats());
      });
    }
  }

  void _togglePlayerSelection(Player player) {
    final currentSelectedPlayers =
    List<Player>.from(context.read<StatsBloc>().state.selectedPlayers);
    if (currentSelectedPlayers.contains(player)) {
      currentSelectedPlayers.remove(player);
    } else {
      currentSelectedPlayers.add(player);
    }
    context.read<StatsBloc>().add(UpdateSelectedPlayers(currentSelectedPlayers));
    context.read<StatsBloc>().add(FetchStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text('Stats'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: _selectDateRange,
              child: Text(
                state.dateRange == null
                    ? 'Select Date Range'
                    : '${state.dateRange!.start.toLocal()} - ${state.dateRange!.end.toLocal()}',
              ),
            ),
            Expanded(
              child: ListView(
                children: state.players.map((player) {
                  return CheckboxListTile(
                    title: Text(player.name),
                    value: state.selectedPlayers.contains(player),
                    onChanged: (bool? value) {
                      _togglePlayerSelection(player);
                    },
                  );
                }).toList(),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     context.read<StatsBloc>().add(FetchStats());
            //   },
            //   child: Text('Get Stats'),
            // ),
            Expanded(
              child: BlocBuilder<StatsBloc, StatsState>(
                builder: (context, state) {
                  debugPrint("Checking Stats State!");
                  if (state.isLoading) {
                    debugPrint("StatsLoading State detected");
                    return Center(child: CircularProgressIndicator());
                  } else if (state.errorMessage != null) {
                    return Center(child: Text('Error: ${state.errorMessage}'));
                  } else {
                    debugPrint("StatsLoaded State detected");
                    // Display stats
                    return ListView(
                      children: [
                        Text('Overall Shot Percentage: ${state.overallPercentage.toStringAsFixed(2)}%'),
                        Divider(),
                        Text('Player Statistics:'),
                        ...state.selectedPlayers.map((player) {
                          if (player.id == null) return SizedBox();
                          PlayerStatsDetail? detail =
                          state.playerStatsDetails[player.id];
                          if (detail == null) return SizedBox();

                          return ExpansionTile(
                            title: Text(
                                '${player.name} - Overall: ${detail.overallPercentage.toStringAsFixed(2)}%'),
                            children: [
                              _buildBreakdownSection(
                                  'Position', detail.positionPercentages),
                              _buildBreakdownSection('Shot Category',
                                  detail.shotCategoryPercentages),
                              _buildBreakdownSection(
                                  'Drill', detail.drillPercentages),
                              _buildBreakdownSection(
                                  'Location', detail.locationPercentages),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
    ));
  }


Widget _buildBreakdownSection(
    String title, Map<String, double> percentages) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$title Breakdown:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      ...percentages.entries.map((entry) {
        return ListTile(
          title: Text('${entry.key}: ${entry.value.toStringAsFixed(2)}%'),
        );
      }).toList(),
    ],
  );
}
}


/*
*
                             );
                            * */