import 'package:flutter/material.dart';
import 'package:lux/progress_store.dart';

class CompletedPuzzleScreen extends StatefulWidget {
  const CompletedPuzzleScreen({super.key});

  @override
  State<CompletedPuzzleScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedPuzzleScreen> {
  List<ProgressStore>? completed;

   Future<void> loadCompleted() async {
    List<ProgressStore> val = [];
    try {
      val = await Progress.loadCompletedPuzzles();
    } catch (e) {
      debugPrint('couldnt load solved puzzles: $e');
    }
    if (!mounted) return;
    setState(() => completed = val);
  }

   @override
  void initState() {
    super.initState();
    loadCompleted();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B12),
        foregroundColor: const Color(0xFFE8C46A),
        elevation: 0,
        title: const Text('solved puzzles', style: TextStyle(fontSize: 18)),
      ),
      body: completed == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8C46A)))
          : completed!.isEmpty
              ? const Center(
                  child: Text('nothing yet. go solve something',
                      style: TextStyle(color: Colors.white38)),
                )
              : buildList(),
    );
  }

  Widget buildList() {
  final groupedVals = <int, Map<String, int>>{};
  for (final vals in completed!) {
    final data = groupedVals.putIfAbsent(vals.word.length, () => {});
    data[vals.word] = (data[vals.word] ?? 0) + 1;
  }
  final sectionsVal = <Widget>[];
    for (int len = 1; len <= 4; len++) {
      final dataVal = groupedVals[len];
      if (dataVal == null) continue;
      sectionsVal.add(Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(
          '$len letter${len > 1 ? 's' : ''} - ${dataVal.length} different',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ));
      sectionsVal.add(Wrap(
        spacing: 8,
        runSpacing: 8,
        children: dataVal.entries.map((e) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8C46A).withValues(alpha: 0.4)),
            ),
            child: Text(
              e.value > 1 ? '${e.key}  x${e.value}' : e.key,
              style: const TextStyle(color: Color(0xFFE8C46A), fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          );
        }).toList(),
      ));
    }

        return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            Text('${completed!.length} total',
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ...sectionsVal,
          ],
        ),
      ),
    );
  }
}
