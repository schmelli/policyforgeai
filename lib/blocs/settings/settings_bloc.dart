import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/settings.dart';
import '../../services/storage_service.dart';

/// Events for the settings bloc
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load settings for a project
class LoadSettings extends SettingsEvent {
  final String projectId;

  const LoadSettings(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Event to update settings
class UpdateSettings extends SettingsEvent {
  final ProjectSettings settings;

  const UpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Event to save settings
class SaveSettings extends SettingsEvent {
  const SaveSettings();
}

/// States for the settings bloc
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SettingsInitial extends SettingsState {}

/// Loading state
class SettingsLoading extends SettingsState {}

/// Loaded state with settings
class SettingsLoaded extends SettingsState {
  final ProjectSettings settings;
  final bool isDirty;

  const SettingsLoaded({
    required this.settings,
    this.isDirty = false,
  });

  /// Creates a copy with the given fields replaced
  SettingsLoaded copyWith({
    ProjectSettings? settings,
    bool? isDirty,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [settings, isDirty];
}

/// Error state
class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// BLoC for managing project settings
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final StorageService _storageService;
  final String projectId;

  SettingsBloc({
    required StorageService storageService,
    required this.projectId,
  })  : _storageService = storageService,
        super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<SaveSettings>(_onSaveSettings);
  }

  /// Handles the LoadSettings event
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await _storageService.loadProjectSettings(event.projectId);
      if (settings != null) {
        emit(SettingsLoaded(settings: settings));
      } else {
        emit(const SettingsError('Settings not found'));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  /// Handles the UpdateSettings event
  void _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) {
    if (state is! SettingsLoaded) return;

    emit(SettingsLoaded(
      settings: event.settings,
      isDirty: true,
    ));
  }

  /// Handles the SaveSettings event
  Future<void> _onSaveSettings(
    SaveSettings event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    final currentState = state as SettingsLoaded;
    try {
      await _storageService.saveProjectSettings(
        projectId,
        currentState.settings,
      );
      emit(currentState.copyWith(isDirty: false));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
