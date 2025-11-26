import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String workspaceId;
  final Color color;
  final String icon;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.workspaceId,
    required this.color,
    this.icon = '📋',
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'workspaceId': workspaceId,
      'color': color.value,
      'icon': icon,
      'isDefault': isDefault,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      workspaceId: map['workspaceId'] ?? '',
      color: Color(map['color'] ?? 0xFF2196F3),
      icon: map['icon'] ?? '📋',
      isDefault: map['isDefault'] ?? false,
    );
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category.fromMap({...data, 'id': doc.id});
  }

  Category copyWith({
    String? id,
    String? name,
    String? workspaceId,
    Color? color,
    String? icon,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      workspaceId: workspaceId ?? this.workspaceId,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: 'maintenance',
        name: 'Maintenance',
        workspaceId: '',
        color: Colors.orange,
        icon: '🔧',
        isDefault: true,
      ),
      Category(
        id: 'staff',
        name: 'Staff',
        workspaceId: '',
        color: Colors.blue,
        icon: '👥',
        isDefault: true,
      ),
      Category(
        id: 'vendors',
        name: 'Vendors',
        workspaceId: '',
        color: Colors.green,
        icon: '🏪',
        isDefault: true,
      ),
      Category(
        id: 'accounting',
        name: 'Accounting',
        workspaceId: '',
        color: Colors.purple,
        icon: '💰',
        isDefault: true,
      ),
      Category(
        id: 'family',
        name: 'Family Requests',
        workspaceId: '',
        color: Colors.pink,
        icon: '👨‍👩‍👧‍👦',
        isDefault: true,
      ),
    ];
  }
}
