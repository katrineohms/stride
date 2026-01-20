// Packages
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// Files
import '../model/_models.dart';
import '../view_model/client_detail_view_model.dart';
import '../view/movesense_connect_view.dart';

// Widgets
import '../widgets/client_card_widget.dart';
import '../widgets/movesense_status_widget.dart';


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
    widget.viewModel.attach();
    widget.viewModel.addListener(_onClientChanged);
    _initializeExerciseState(_client);
  }

  void _initializeExerciseState(Client client) {
    _exerciseDone.clear();
    for (final ex in _stopWatches.values) {
      ex.dispose();
    }
    _stopWatches.clear();

      for (final ex in client.exerciseTemplates) {
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
    widget.viewModel.removeListener(_onClientChanged);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _toggleDone(String exerciseId, bool? value) {
    setState(() {
      _exerciseDone[exerciseId] = value ?? false;
    });
  }

  void _onClientChanged() {
    setState(() {
      _initializeExerciseState(widget.viewModel.client);
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
            listenable: widget.viewModel.movesense,
            builder: (context, _) {
              return MovesenseStatusIcon(
                connected: widget.viewModel.movesense.isConnected,
                heartRate: 0,
                heartRateStream: widget.viewModel.movesense.heartRateStream,
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
              builder: (context) => MovesenseConnectView(
                viewModel: widget.viewModel.movesense,
              ),
            ),
          );
        },
      ),
    );
  }
}
