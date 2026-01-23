// Plugins
import 'dart:async';

/// One-off UI events (snackbars, navigation, etc.)
sealed class UiEvent {
  const UiEvent();
}

class SnackBarEvent extends UiEvent {
  final String message;
  final bool isError;

  const SnackBarEvent(this.message, {this.isError = false});
}

class NavigationEvent extends UiEvent {
  final String route;
  final Object? arguments;

  const NavigationEvent({required this.route, this.arguments});
}

/// Helper to emit and listen to UI events from view models.
class UiEventNotifier {
  UiEventNotifier();

  final StreamController<UiEvent> _controller =
      StreamController<UiEvent>.broadcast();

  Stream<UiEvent> get stream => _controller.stream;

  void emit(UiEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
