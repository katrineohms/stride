import 'package:flutter/material.dart';
import '../model/clients.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../widgets/client_card_widget.dart';
import '../widgets/movesense_status_widget.dart';
import 'package:stride/view/movesense_connect_view.dart';
import 'package:stride/service/movesense_service.dart';

/// ViewModel for client details
class ClientDetailViewModel {
  ClientDetailViewModel({required Client client}) : _client = client;

  Client _client;

  Client get client => _client;

  void updateClient(Client updated) {
    _client = updated;
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

  Client get _client => widget.viewModel.client;

  @override
  void initState() {
    super.initState();
    _initializeExerciseState(_client);
  }

  void _initializeExerciseState(Client client) {
    _exerciseDone.clear();
    for (final ex in _stopWatches.values) {
      ex.dispose();
    }
    _stopWatches.clear();

    for (final ex in client.exercises) {
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
    final client = _client;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        centerTitle: true,
        actions: [
          ListenableBuilder(
            listenable: MovesenseService().viewModel,
            builder: (context, _) {
              return MovesenseStatusIcon(
                connected: MovesenseService().viewModel.isConnected,
                heartRate: 0,
                heartRateStream: MovesenseService().viewModel.heartRateStream,
              );
            },
          ),
        ],
      ),
      body: ClientDetailViewWidget(
        viewModel: widget.viewModel,
        exerciseDone: _exerciseDone,
        stopWatches: _stopWatches,
        onToggleDone: _toggleDone,
        onClientUpdated: (updatedClient) {
          setState(() {
            widget.viewModel.updateClient(updatedClient);
            _initializeExerciseState(updatedClient);
          });
        },
        onMovesenseTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MovesenseConnectView(),
            ),
          );
        },
      ),
    );
  }
}
