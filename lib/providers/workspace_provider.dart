import 'package:flutter/foundation.dart';
import '../models/workspace.dart';
import '../services/firestore_service.dart';

class WorkspaceProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Workspace> _workspaces = [];
  Workspace? _currentWorkspace;
  bool _isLoading = false;
  String? _error;

  List<Workspace> get workspaces => _workspaces;
  Workspace? get currentWorkspace => _currentWorkspace;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkspaces(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _workspaces = await _firestoreService.getUserWorkspaces(userId);

      // Set first workspace as current if none selected
      if (_currentWorkspace == null && _workspaces.isNotEmpty) {
        _currentWorkspace = _workspaces.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createWorkspace(Workspace workspace) async {
    try {
      final newWorkspace = await _firestoreService.createWorkspace(workspace);
      _workspaces.add(newWorkspace);
      
      // Set as current workspace if it's the first one
      if (_workspaces.length == 1) {
        _currentWorkspace = newWorkspace;
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateWorkspace(Workspace workspace) async {
    try {
      await _firestoreService.updateWorkspace(workspace);
      final index = _workspaces.indexWhere((w) => w.id == workspace.id);
      if (index != -1) {
        _workspaces[index] = workspace;
        if (_currentWorkspace?.id == workspace.id) {
          _currentWorkspace = workspace;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addMember(String workspaceId, String userId) async {
    try {
      await _firestoreService.addWorkspaceMember(workspaceId, userId);
      
      // Refresh workspace
      final workspace = _workspaces.firstWhere((w) => w.id == workspaceId);
      final updatedWorkspace = workspace.copyWith(
        memberIds: [...workspace.memberIds, userId],
      );
      await updateWorkspace(updatedWorkspace);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeMember(String workspaceId, String userId) async {
    try {
      await _firestoreService.removeWorkspaceMember(workspaceId, userId);
      
      // Refresh workspace
      final workspace = _workspaces.firstWhere((w) => w.id == workspaceId);
      final updatedWorkspace = workspace.copyWith(
        memberIds: workspace.memberIds.where((id) => id != userId).toList(),
      );
      await updateWorkspace(updatedWorkspace);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void setCurrentWorkspace(Workspace workspace) {
    _currentWorkspace = workspace;
    notifyListeners();
  }
}
