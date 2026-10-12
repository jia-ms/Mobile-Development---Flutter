import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';
import '../models/app_user.dart';

/// Single source of truth for "who is logged in and what can they do".
/// The router listens to this to guard routes.
class AuthController extends ChangeNotifier {
  AuthController(this._service) {
    _authSub = _service.authChanges().listen(_onAuth);
  }

  final AuthService _service;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  User? user;
  AppUser? profile;
  bool initialized = false;

  bool get isAdmin => profile?.role == 'admin';

  void _onAuth(User? u) {
    user = u;
    _profileSub?.cancel();
    if (u == null) {
      profile = null;
      initialized = true;
      notifyListeners();
      return;
    }
    _profileSub = _service.profile(u.uid).listen(
      (p) {
        profile = p;
        initialized = true;
        notifyListeners();
      },
      onError: (_) {
        initialized = true;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
