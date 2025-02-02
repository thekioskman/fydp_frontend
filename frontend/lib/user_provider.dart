import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  // Load user ID from SharedPreferences when the app starts
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    notifyListeners(); // Notify UI to update
  }

  // Save user ID to SharedPreferences
  Future<void> setUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    _userId = id;
    notifyListeners();
  }

  // Remove user ID from SharedPreferences (Logout)
  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _userId = null;
    notifyListeners();
  }
}