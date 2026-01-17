import 'package:flutter/material.dart';
import '../model/clients.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../widgets/client_card_widget.dart';
import '../widgets/movesense_status_widget.dart';

/// ViewModel for client details
class ClientDetailViewModel {
  final Client client;

  ClientDetailViewModel({required this.client});

  Color get statusColor {
    switch (client.active) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Client detail page UI
class ClientDetailPage extends StatefulWidget {
  final ClientDetailViewModel viewModel;

  const ClientDetailPage({super.key, required this.viewModel});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  final Map<String, bool> _exerciseDone = {};
  final Map<String, StopWatchTimer> _stopWatches = {};

  @override
  void initState() {
    super.initState();
    for (final ex in widget.viewModel.client.exercises) {
      if (ex is CountableExercise) {
        _exerciseDone[ex.exerciseId] = false;
      } else if (ex is TimeableExercise) {
        _stopWatches[ex.exerciseId] = StopWatchTimer(
          mode: StopWatchMode.countDown,
          presetMillisecond: ex.time * 1000,
        );
      }
    }
  }

  @override
  void dispose() {
    for (final timer in _stopWatches.values) {
      timer.dispose();
    }
    super.dispose();
  }

  void _toggleDone(String exerciseId, bool? value) {
    setState(() {
      _exerciseDone[exerciseId] = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.viewModel.client;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        centerTitle: true,
        actions: [
          MovesenseStatusIcon(connected: true, heartRate: 72),
        ],
      ),
      body: ClientDetailViewWidget(
        viewModel: widget.viewModel,
        exerciseDone: _exerciseDone,
        stopWatches: _stopWatches,
        onToggleDone: _toggleDone,
        onMovesenseTap: () {
          // TODO: handle tap
        },
      ),
    );
  }
}

