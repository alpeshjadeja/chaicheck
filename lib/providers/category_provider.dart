import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../services/firestore_service.dart';

class CategoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<models.Category> get defaultCategories => models.Category.getDefaultCategories();

  Future<void> loadCategories(String workspaceId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _categories = await _firestoreService.getCategories(workspaceId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(models.Category category) async {
    try {
      final newCategory = await _firestoreService.createCategory(category);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCategory(models.Category category) async {
    try {
      await _firestoreService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId, String workspaceId) async {
    try {
      await _firestoreService.deleteCategory(categoryId);
      _categories.removeWhere((cat) => cat.id == categoryId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  models.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}
