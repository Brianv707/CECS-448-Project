import 'package:flutter/foundation.dart';
import 'package:pokemon_card_tracker/models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  
  // Hardcoded credentials for demo
  final Map<String, String> _users = {
    'user@example.com': 'password123',
    'admin@pokemon.com': 'admin123',
  };
  
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (_users[email] == password) {
      _currentUser = User(
        id: '1',
        email: email,
        username: email.split('@')[0],
      );
      notifyListeners();
      return true;
    }
    return false;
  }
  
  Future<bool> signup(String email, String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes, always succeed
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      username: username,
    );
    notifyListeners();
    return true;
  }
  
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}