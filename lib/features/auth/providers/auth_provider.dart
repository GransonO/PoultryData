import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> register({
    required String name,
    required String phone,
    required String email,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate async registration (replace with real API call)
    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = UserModel(
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      registeredAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
