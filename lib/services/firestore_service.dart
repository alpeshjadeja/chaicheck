import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../models/workspace.dart';
import '../models/category.dart' as models;
import '../models/activity_log.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    // Enable offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // ========== TASK OPERATIONS ==========
  
  Future<List<Task>> getWorkspaceTasks(String workspaceId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getTodayTasks(String workspaceId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('dueDate', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('dueDate', isLessThan: endOfDay.toIso8601String())
        .where('isCompleted', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getOverdueTasks(String workspaceId) async {
    final now = DateTime.now();

    final snapshot = await _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('dueDate', isLessThan: now.toIso8601String())
        .where('isCompleted', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Stream<List<Task>> watchWorkspaceTasks(String workspaceId) {
    return _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  Future<Task> createTask(Task task) async {
    final docRef = await _firestore.collection('tasks').add(task.toMap());
    final doc = await docRef.get();
    return Task.fromFirestore(doc);
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> batchUpdateTasks(List<Task> tasks) async {
    final batch = _firestore.batch();
    for (var task in tasks) {
      final docRef = _firestore.collection('tasks').doc(task.id);
      batch.update(docRef, task.toMap());
    }
    await batch.commit();
  }

  // ========== USER OPERATIONS ==========

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  // ========== WORKSPACE OPERATIONS ==========

  Future<List<Workspace>> getUserWorkspaces(String userId) async {
    final snapshot = await _firestore
        .collection('workspaces')
        .where('memberIds', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) => Workspace.fromFirestore(doc)).toList();
  }

  Future<Workspace> createWorkspace(Workspace workspace) async {
    final docRef = await _firestore.collection('workspaces').add(workspace.toMap());
    final doc = await docRef.get();
    return Workspace.fromFirestore(doc);
  }

  Future<void> updateWorkspace(Workspace workspace) async {
    await _firestore.collection('workspaces').doc(workspace.id).update(workspace.toMap());
  }

  Future<void> addWorkspaceMember(String workspaceId, String userId) async {
    await _firestore.collection('workspaces').doc(workspaceId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeWorkspaceMember(String workspaceId, String userId) async {
    await _firestore.collection('workspaces').doc(workspaceId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  // ========== CATEGORY OPERATIONS ==========

  Future<List<models.Category>> getCategories(String workspaceId) async {
    final snapshot = await _firestore
        .collection('categories')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();

    return snapshot.docs.map((doc) => models.Category.fromFirestore(doc)).toList();
  }

  Future<models.Category> createCategory(models.Category category) async {
    final docRef = await _firestore.collection('categories').add(category.toMap());
    final doc = await docRef.get();
    return models.Category.fromFirestore(doc);
  }

  Future<void> updateCategory(models.Category category) async {
    await _firestore.collection('categories').doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  // ========== ACTIVITY LOG OPERATIONS ==========

  Future<List<ActivityLog>> getTaskActivityLogs(String taskId) async {
    final snapshot = await _firestore
        .collection('activityLogs')
        .where('taskId', isEqualTo: taskId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => ActivityLog.fromFirestore(doc)).toList();
  }

  Future<void> createActivityLog(ActivityLog log) async {
    await _firestore.collection('activityLogs').add(log.toMap());
  }
}
