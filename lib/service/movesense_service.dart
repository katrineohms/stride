import '../view_model/movesense_connect_view_model.dart';

/// Service to provide global access to the Movesense ViewModel
class MovesenseService {
  static final MovesenseService _instance = MovesenseService._internal();
  
  late MovesenseConnectViewModel _viewModel;
  
  MovesenseService._internal() {
    _viewModel = MovesenseConnectViewModel();
  }
  
  factory MovesenseService() {
    return _instance;
  }
  
  /// Get the shared Movesense ViewModel instance
  MovesenseConnectViewModel get viewModel => _viewModel;
}
