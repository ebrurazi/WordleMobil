import 'package:flutter/material.dart';
import 'package:yazlab22/araclar/calculate_chart_stats.dart';
import 'package:yazlab22/bilesen/stats_chart.dart';
import 'package:yazlab22/bilesen/stats_tile.dart';
import 'package:yazlab22/klavyeVeri/keys_map.dart';
import 'package:yazlab22/sabitler/answer_stages.dart';
import '../main.dart';

class StatsBox extends StatelessWidget {
  const StatsBox({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(size.width * 0.08, size.height * 0.12,
          size.width * 0.08, size.height * 0.12),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton(
              alignment: Alignment.centerRight,
              onPressed: () {
                Navigator.maybePop(context);
              },
              icon: const Icon(Icons.clear)),
          const Expanded(
              child: Text(
            'STATISTICS',
            textAlign: TextAlign.center,
          )),
          Expanded(
            flex: 2,
            child: FutureBuilder<List<int>?>(
            future: getStats(),
            builder: (context, snapshot) {
              List<int> results = [0, 0, 0, 0, 0];
              if (snapshot.hasData) {
                results = snapshot.data!;
              }
              return Row(
                children: [
                  StatsTile(heading: 'Played', value: results[0]),
                  StatsTile(heading: 'Win %', value: results[2]),
                  StatsTile(heading: 'Current\nStreak', value: results[3]),
                  StatsTile(heading: 'Max\nStreak', value: results[4]),
                ],
              );
            },
          ),

          ),
          const Expanded(
            flex: 8,
            child: StatsChart(),
          ),
          Expanded(
              flex: 2,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    keysMap.updateAll(
                        (key, value) => value = AnswerStage.notAnswered);

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                        (route) => false);
                  },
                  child: const Text(
                    'Replay',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  )
                  )
                  )
        ],
      ),
    );
  }
}
