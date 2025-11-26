import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String action; // 'created', 'updated', 'completed', 'commented', etc.
  final String details;
  final DateTime timestamp;
  final String workspaceId;

  ActivityLog({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.details,
    required this.timestamp,
    required this.workspaceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'userName': userName,
      'action': action,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'workspaceId': workspaceId,
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      action: map['action'] ?? '',
      details: map['details'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      workspaceId: map['workspaceId'] ?? '',
    );
  }

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLog.fromMap({...data, 'id': doc.id});
  }

  String get displayText {
    switch (action) {
      case 'created':
        return '$userName created this task';
      case 'updated':
        return '$userName updated $details';
      case 'completed':
        return '$userName completed this task';
      case 'reopened':
        return '$userName reopened this task';
      case 'commented':
        return '$userName commented: $details';
      case 'assigned':
        return '$userName assigned this task to $details';
      default:
        return '$userName $action: $details';
    }
  }
}
