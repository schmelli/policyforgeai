import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/project.dart';
import '../../services/storage_service.dart';

// Events
abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocument extends DocumentEvent {
  final DocumentLeafNode document;

  const LoadDocument(this.document);

  @override
  List<Object?> get props => [document];
}

class UpdateDocument extends DocumentEvent {
  final String content;

  const UpdateDocument(this.content);

  @override
  List<Object?> get props => [content];
}

class SaveDocument extends DocumentEvent {}

// States
abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final DocumentLeafNode document;
  final bool isDirty;

  const DocumentLoaded({
    required this.document,
    this.isDirty = false,
  });

  @override
  List<Object?> get props => [document, isDirty];

  DocumentLoaded copyWith({
    DocumentLeafNode? document,
    bool? isDirty,
  }) {
    return DocumentLoaded(
      document: document ?? this.document,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
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

  void _onLoadDocument(
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

  void _onUpdateDocument(
    UpdateDocument event,
    Emitter<DocumentState> emit,
  ) {
    if (state is! DocumentLoaded) return;

    final currentState = state as DocumentLoaded;
    final updatedDocument = PolicyDocument(
      id: currentState.document.document.id,
      title: currentState.document.document.title,
      content: event.content,
      createdAt: currentState.document.document.createdAt,
      modifiedAt: DateTime.now(),
      createdBy: currentState.document.document.createdBy,
      version: currentState.document.document.version,
      metadata: currentState.document.document.metadata,
      comments: currentState.document.document.comments,
    );

    final updatedNode = DocumentLeafNode(
      id: currentState.document.id,
      name: currentState.document.name,
      createdAt: currentState.document.createdAt,
      modifiedAt: DateTime.now(),
      createdBy: currentState.document.createdBy,
      parentId: currentState.document.parentId,
      document: updatedDocument,
    );

    emit(DocumentLoaded(
      document: updatedNode,
      isDirty: true,
    ));
  }

  void _onSaveDocument(
    SaveDocument event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentLoaded) return;

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
