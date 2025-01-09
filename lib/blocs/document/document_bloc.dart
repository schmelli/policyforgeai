import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/document.dart';
import '../../services/storage_service.dart';

/// Events for the document bloc
abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a document
class LoadDocument extends DocumentEvent {
  final PolicyDocument document;

  const LoadDocument(this.document);

  @override
  List<Object?> get props => [document];
}

/// Event to update document content
class UpdateDocument extends DocumentEvent {
  final String documentId;
  final String content;

  const UpdateDocument({
    required this.documentId,
    required this.content,
  });

  @override
  List<Object?> get props => [documentId, content];
}

/// Event to save document changes
class SaveDocument extends DocumentEvent {
  const SaveDocument();
}

/// States for the document bloc
abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DocumentInitial extends DocumentState {}

/// Loading state
class DocumentLoading extends DocumentState {}

/// Loaded state with document
class DocumentLoaded extends DocumentState {
  final PolicyDocument document;
  final bool isDirty;

  const DocumentLoaded({
    required this.document,
    this.isDirty = false,
  });

  /// Creates a copy with the given fields replaced
  DocumentLoaded copyWith({
    PolicyDocument? document,
    bool? isDirty,
  }) {
    return DocumentLoaded(
      document: document ?? this.document,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [document, isDirty];
}

/// Error state
class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}

/// BLoC for managing document state
class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final StorageService _storageService;
  final String projectId;

  DocumentBloc({
    required StorageService storageService,
    required this.projectId,
  })  : _storageService = storageService,
        super(DocumentInitial()) {
    on<LoadDocument>(_onLoadDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<SaveDocument>(_onSaveDocument);
  }

  /// Handles the LoadDocument event
  Future<void> _onLoadDocument(
    LoadDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      final document = await _storageService.loadDocument(
        projectId,
        event.document.id,
      );
      if (document != null) {
        emit(DocumentLoaded(document: document));
      } else {
        emit(const DocumentError('Document not found'));
      }
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  /// Handles the UpdateDocument event
  Future<void> _onUpdateDocument(
    UpdateDocument event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentLoaded) {
      emit(const DocumentError('No document loaded'));
      return;
    }

    try {
      final currentState = state as DocumentLoaded;
      final updatedDocument = currentState.document.copyWith(
        content: event.content,
        modifiedAt: DateTime.now(),
      );

      // Save the updated document to storage
      await _storageService.saveDocument(projectId, updatedDocument);

      emit(DocumentLoaded(
        document: updatedDocument,
        isDirty: false,
      ));
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  /// Handles the SaveDocument event
  Future<void> _onSaveDocument(
    SaveDocument event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentLoaded) {
      emit(const DocumentError('No document loaded'));
      return;
    }

    final currentState = state as DocumentLoaded;
    try {
      await _storageService.saveDocument(
        projectId,
        currentState.document,
      );
      emit(currentState.copyWith(isDirty: false));
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }
}
