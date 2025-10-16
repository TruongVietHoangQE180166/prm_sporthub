import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _items = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get items => _items;

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _apiService.fetchHomeData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchData();
  }
}