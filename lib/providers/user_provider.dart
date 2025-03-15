import 'package:flutter/material.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/services/user_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool  get isLoading => _isLoading;

  Future<void> fetchUser(String id, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserModel? userData = await _userService.getUserById(id, role);
      _user = userData;
      
    } catch (e) {
      Helpers.debugPrintWithBorder("Error fetching user: $e");
    }

    await Future.delayed(Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }
}