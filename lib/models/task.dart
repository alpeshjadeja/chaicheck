import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String? categoryId;
  final DateTime? dueDate;
  final String priority; // 'high', 'medium', 'low'
  final String workspaceId;
  final List<String> assignedTo;
  final List<String> attachments;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.categoryId,
    this.dueDate,
    this.priority = 'medium',
    required this.workspaceId,
    this.assignedTo = const [],
    this.attachments = const [],
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'workspaceId': workspaceId,
      'assignedTo': assignedTo,
      'attachments': attachments,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  // Create from Firestore document
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: map['priority'] ?? 'medium',
      workspaceId: map['workspaceId'] ?? '',
      assignedTo: List<String>.from(map['assignedTo'] ?? []),
      attachments: List<String>.from(map['attachments'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      createdBy: map['createdBy'] ?? '',
    );
  }

  // Create from Firestore DocumentSnapshot
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task.fromMap({...data, 'id': doc.id});
  }

  // Copy with method for updates
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    DateTime? dueDate,
    String? priority,
    String? workspaceId,
    List<String>? assignedTo,
    List<String>? attachments,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      workspaceId: workspaceId ?? this.workspaceId,
      assignedTo: assignedTo ?? this.assignedTo,
      attachments: attachments ?? this.attachments,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Computed properties
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }
}
