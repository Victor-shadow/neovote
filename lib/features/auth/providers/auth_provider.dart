import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

//An Authentication provider that manages authentication state, active sessions, and voter profile
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepositoryImpl() {
    _initAuthStateListener();
  }

  //Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;

  ///Listens to auth state changes from the repository
  void _initAuthStateListener() {
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  //Authenticate using Email and Password
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  ///Register new voter account
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? nationalId,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        nationalId: nationalId,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '');
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  //Google Authentication
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.signInWithGoogle();
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  //Login with Github
  Future<bool> loginWithGithub() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.signInWithGithub();
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  //Biometric Authentication
  Future<bool> loginWithBiometrics() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authRepository.signInWithBiometrics();
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '');
      _status = AuthStatus.error;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  //Password reset
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  ///Sign Out
  Future<void> logout() async {
    _setLoading(true);
    await _authRepository.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _setLoading(false);
    notifyListeners();
  }

  //toggle loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //Notify listeners and clears active error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
