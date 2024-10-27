import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stats_coach/blocs/stats_bloc.dart';
import 'package:stats_coach/blocs/stats_events.dart';
import 'package:stats_coach/blocs/stats_state.dart';
import 'package:stats_coach/models/player.dart';
import 'package:stats_coach/models/player_stats_detail.dart';

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _selectDateRange,
                child: Text(
                  state.dateRange == null
                      ? 'Select Date Range'
                      : '${state.dateRange!.start.toLocal()} - ${state.dateRange!.end.toLocal()}',
                ),
              ),
              _getListOfPlayers(state),
              _buildStatsContent(state),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildOverallTextStats(StatsState state) {
    double madePercentage = state.overallPercentage;
    double missedPercentage = 100 - madePercentage;
    int totalMadeShots = state.totalMadeShots; // We'll need to store this in the state
    int totalShots = state.totalShots; // We'll need to store this in the state

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Total Shots: $totalShots',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Made Shots: $totalMadeShots (${madePercentage.toStringAsFixed(2)}%)',
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
          Text(
            'Missed Shots: ${totalShots - totalMadeShots} (${missedPercentage.toStringAsFixed(2)}%)',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }


  Widget _buildOverallPieChart(StatsState state) {
    double madePercentage = state.overallPercentage;
    double missedPercentage = 100 - madePercentage;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: madePercentage,
            color: Colors.green,
            title: '${madePercentage.toStringAsFixed(1)}%',
            radius: 60,
            // badgeWidget: Text(
            //   'Made',
            //   style: TextStyle(fontSize: 12, color: Colors.white),
            // ),
            badgePositionPercentageOffset: 0.5,
            titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: missedPercentage,
            color: Colors.red,
            title: 'Missed ${missedPercentage.toStringAsFixed(1)}%',
            radius: 60,
            // badgeWidget: Text(
            //   'Missed',
            //   style: TextStyle(fontSize: 12, color: Colors.white),
            // ),
            badgePositionPercentageOffset: 0.5,
            titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildPlayerTextStats(PlayerStatsDetail detail) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Shots: ${detail.totalShots}',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Made Shots: ${detail.totalMadeShots} (${detail.overallPercentage.toStringAsFixed(2)}%)',
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
          Text(
            'Missed Shots: ${detail.totalShots - detail.totalMadeShots} (${(100 - detail.overallPercentage).toStringAsFixed(2)}%)',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBarChart(String title, List<String> categories, List<double> percentages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Text(
            '$title Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: List.generate(categories.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      fromY: 0,
                      toY: percentages[index],
                      color: Colors.blueAccent,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  //showingTooltipIndicators: [0],
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < categories.length) {
                        String text = categories[index];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0,
                          child: Transform.rotate(
                            angle: -45 * (3.1415927 / 180),
                            child: Text(
                              text,
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 40,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownSection(String title, Map<String, double> percentages) {
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

  _getListOfPlayers(StatsState state) {
    return // Replace the Expanded widget containing the ListView of players with this:
      ExpansionTile(
        title: Text(
          'Select Players',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: false, // You can set this to true if you want it expanded by default
        children: [
          ListView(
            shrinkWrap: true, // Important to set this when inside a scrollable widget
            physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
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
        ],
      );

  }

  Widget _buildStatsContent(StatsState state) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state.errorMessage != null) {
      return Center(child: Text('Error: ${state.errorMessage}'));
    } else {
      final playerList = state.selectedPlayers.isEmpty
          ? state.players
          : state.selectedPlayers;
      return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ExpansionTile(
            title: Text(
              'Overall Shot Percentage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            children: [
              SizedBox(height: 200, child: _buildOverallPieChart(state)),
              _buildOverallTextStats(state),
            ],
          ),
          Divider(),
          Text('Player Statistics:'),
          ...playerList.map((player) {
            if (player.id == null) return SizedBox();
            PlayerStatsDetail? detail = state.playerStatsDetails[player.id];
            if (detail == null) return SizedBox();

            return ExpansionTile(
              title: Text(
                '${player.name} - Overall: ${detail.overallPercentage.toStringAsFixed(2)}%',
              ),
              children: [
                SizedBox(),
                _buildPlayerBarChart('Position', detail.positions, detail.positionPercentages),
                _buildPlayerBarChart('Shot Category', detail.shotCategories, detail.shotCategoryPercentages),
                _buildPlayerBarChart('Drill', detail.drills, detail.drillPercentages),
                _buildPlayerBarChart('Location', detail.locations, detail.locationPercentages),
                _buildPlayerTextStats(detail),
              ],
            );
          }).toList(),
        ]
      );
    }
  }

}
