import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/project.dart';
import '../../services/storage_service.dart';

// Events
abstract class DocumentTreeEvent extends Equatable {
  const DocumentTreeEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocumentTree extends DocumentTreeEvent {
  final String projectId;

  const LoadDocumentTree(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class CreateFolder extends DocumentTreeEvent {
  final String name;
  final String? parentId;

  const CreateFolder(this.name, {this.parentId});

  @override
  List<Object?> get props => [name, parentId];
}

class CreateDocument extends DocumentTreeEvent {
  final String name;
  final String? parentId;

  const CreateDocument(this.name, {this.parentId});

  @override
  List<Object?> get props => [name, parentId];
}

class SelectNode extends DocumentTreeEvent {
  final DocumentNode node;

  const SelectNode(this.node);

  @override
  List<Object?> get props => [node];
}

// States
abstract class DocumentTreeState extends Equatable {
  const DocumentTreeState();

  @override
  List<Object?> get props => [];
}

class DocumentTreeInitial extends DocumentTreeState {}

class DocumentTreeLoading extends DocumentTreeState {}

class DocumentTreeLoaded extends DocumentTreeState {
  final List<DocumentNode> nodes;
  final DocumentNode? selectedNode;

  const DocumentTreeLoaded({
    required this.nodes,
    this.selectedNode,
  });

  @override
  List<Object?> get props => [nodes, selectedNode];

  DocumentTreeLoaded copyWith({
    List<DocumentNode>? nodes,
    DocumentNode? selectedNode,
  }) {
    return DocumentTreeLoaded(
      nodes: nodes ?? this.nodes,
      selectedNode: selectedNode ?? this.selectedNode,
    );
  }
}

class DocumentTreeError extends DocumentTreeState {
  final String message;

  const DocumentTreeError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DocumentTreeBloc extends Bloc<DocumentTreeEvent, DocumentTreeState> {
  final StorageService _storageService;
  final String projectId;

  DocumentTreeBloc({
    required StorageService storageService,
    required this.projectId,
  })  : _storageService = storageService,
        super(DocumentTreeInitial()) {
    on<LoadDocumentTree>(_onLoadDocumentTree);
    on<CreateFolder>(_onCreateFolder);
    on<CreateDocument>(_onCreateDocument);
    on<SelectNode>(_onSelectNode);
  }

  void _onLoadDocumentTree(
    LoadDocumentTree event,
    Emitter<DocumentTreeState> emit,
  ) async {
    emit(DocumentTreeLoading());
    try {
      final nodes = await _storageService.loadProjectTree(projectId);
      emit(DocumentTreeLoaded(nodes: nodes));
    } catch (e) {
      emit(DocumentTreeError(e.toString()));
    }
  }

  void _onCreateFolder(
    CreateFolder event,
    Emitter<DocumentTreeState> emit,
  ) async {
    if (state is! DocumentTreeLoaded) {
      emit(const DocumentTreeError('Document tree not loaded'));
      return;
    }

    final currentState = state as DocumentTreeLoaded;
    try {
      final newFolder = FolderNode.create(
        name: event.name,
        createdBy: 'current-user', // TODO: Get from auth
        parentId: event.parentId,
      );

      final updatedNodes = _addNodeToTree(
        currentState.nodes,
        newFolder,
        event.parentId,
      );

      await _storageService.saveProjectTree(projectId, updatedNodes);
      
      // Reload the tree to ensure we have the latest state
      final reloadedNodes = await _storageService.loadProjectTree(projectId);
      
      emit(currentState.copyWith(
        nodes: reloadedNodes,
        selectedNode: newFolder, // Automatically select the new folder
      ));
    } catch (e) {
      print('Error creating folder: $e');
      emit(DocumentTreeError('Failed to create folder: ${e.toString()}'));
      // Restore the previous state after error
      emit(currentState);
    }
  }

  void _onCreateDocument(
    CreateDocument event,
    Emitter<DocumentTreeState> emit,
  ) async {
    if (state is! DocumentTreeLoaded) {
      emit(const DocumentTreeError('Document tree not loaded'));
      return;
    }

    final currentState = state as DocumentTreeLoaded;
    try {
      final newDocument = DocumentLeafNode.create(
        name: event.name,
        createdBy: 'current-user', // TODO: Get from auth
        projectId: projectId,
        parentId: event.parentId,
      );

      final updatedNodes = _addNodeToTree(
        currentState.nodes,
        newDocument,
        event.parentId,
      );

      // First save the document content
      await _storageService.saveDocument(projectId, newDocument);
      
      // Then update the tree structure
      await _storageService.saveProjectTree(projectId, updatedNodes);
      
      // Reload the tree to ensure we have the latest state
      final reloadedNodes = await _storageService.loadProjectTree(projectId);
      
      // Finally, emit the new state with the updated tree
      emit(currentState.copyWith(
        nodes: reloadedNodes,
        selectedNode: newDocument, // Automatically select the new document
      ));
    } catch (e) {
      print('Error creating document: $e');
      emit(DocumentTreeError('Failed to create document: ${e.toString()}'));
      // Restore the previous state after error
      emit(currentState);
    }
  }

  void _onSelectNode(
    SelectNode event,
    Emitter<DocumentTreeState> emit,
  ) {
    if (state is! DocumentTreeLoaded) return;

    final currentState = state as DocumentTreeLoaded;
    emit(currentState.copyWith(selectedNode: event.node));
  }

  List<DocumentNode> _addNodeToTree(
    List<DocumentNode> nodes,
    DocumentNode newNode,
    String? parentId,
  ) {
    if (parentId == null || parentId.isEmpty) {
      return [...nodes, newNode];
    }

    return nodes.map((node) {
      if (node is! FolderNode) return node;
      if (node.id != parentId) {
        return FolderNode(
          id: node.id,
          name: node.name,
          createdAt: node.createdAt,
          modifiedAt: node.modifiedAt,
          createdBy: node.createdBy,
          parentId: node.parentId,
          children: _addNodeToTree(node.children, newNode, parentId),
        );
      }
      return FolderNode(
        id: node.id,
        name: node.name,
        createdAt: node.createdAt,
        modifiedAt: node.modifiedAt,
        createdBy: node.createdBy,
        parentId: node.parentId,
        children: [...node.children, newNode],
      );
    }).toList();
  }
}
