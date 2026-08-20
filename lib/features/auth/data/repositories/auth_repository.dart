import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';

//Authentication operations in the Neovote ecosystem
abstract class AuthRepository {
  ///Stream emitting changes in the authentication state
  Stream<UserModel?> get authStateChanges;

  //Fetches the current authenticated user profile
  Future<UserModel?> getCurrentUser();

  ///Signs in a user with Email and Password Credentials
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  //Register a new voter account with name, email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? nationalId,
  });

  //Authenticate a user using Google OAuth
  Future<UserModel> signInWithGoogle();
  //Authenticate a user with Github OAuth
  Future<UserModel> signInWithGithub();
  //Authenticate a user via device biometrics
  Future<UserModel> signInWithBiometrics();
  //Sends a password recovery email to the specified address
  Future<void> sendPasswordResetEmail(String email);

  ///Exchanges and verifies the FirebaseID token with the NeoVote Rust Backend
  Future<bool> verifyTokenWithNeovote(String idToken);

  ///Signs the current user out of all sessions and clears cached tokens
  Future<void> signOut();
}

//[AuthRepository]
class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final LocalAuthentication _localAuth;
  final GoogleSignIn _googleSignIn;
  final String _neoVoteUrl;

  AuthRepositoryImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    LocalAuthentication? localAuth,
    GoogleSignIn? googleSignIn,
    String backendBaseUrl = '',
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _localAuth = localAuth ?? LocalAuthentication(),
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _neoVoteUrl = backendBaseUrl;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return await _fetchUserProfile(fbUser.uid);
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return await _fetchUserProfile(fbUser.uid);
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Sign in failed: User record not found.');
      }

      await _firestore.collection('users').doc(user.uid).set({
        'last_login_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final token = await user.getIdToken();
      if (token != null) {
        verifyTokenWithNeovote(token).catchError((e) {
          debugPrint('Backend token verification notice: $e');
          return false;
        });
      }

      final profile = await _fetchUserProfile(user.uid);
      return profile ??
          UserModel(
            uid: user.uid,
            email: user.email ?? email,
            displayName: user.displayName ?? 'Voter',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
    } on fb.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? nationalId,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Registration failed: User creation returned null.');
      }
      await user.updateDisplayName(displayName.trim());
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? email.trim(),
        displayName: displayName.trim(),
        nationalId: nationalId?.trim(),
        isVerified: false,
        biometricEnabled: false,
        role: UserRole.voter,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      return newUser;
    } on fb.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Google authentication failed.');
      }

      UserModel? profile = await _fetchUserProfile(user.uid);
      if (profile == null) {
        profile = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? googleUser.displayName ?? 'Voter',
          photoUrl: user.photoURL ?? googleUser.photoUrl,
          isVerified: false,
          role: UserRole.voter,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(profile.toMap());
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'last_login_at': FieldValue.serverTimestamp(),
        });
      }
      return profile;
    } catch (e) {
      throw Exception('Google Sign-In error: $e');
    }
  }

  @override
  Future<UserModel> signInWithGithub() async {
    try {
      final githubProvider = fb.GithubAuthProvider();
      githubProvider.addScope('read:user');
      githubProvider.addScope('user:email');

      final userCredential = await _firebaseAuth.signInWithProvider(
        githubProvider,
      );
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Github Authentication returned null.');
      }

      UserModel? profile = await _fetchUserProfile(user.uid);
      if (profile == null) {
        profile = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Github Voter',
          photoUrl: user.photoURL,
          isVerified: false,
          role: UserRole.voter,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(profile.toMap());
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'last_login_at': FieldValue.serverTimestamp(),
        });
      }
      return profile;
    } catch (e) {
      throw Exception('Github Sign-In error: $e');
    }
  }

  @override
  Future<UserModel> signInWithBiometrics() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        throw Exception('Biometrics is not available or supported on this device.');
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access NeoVote securely',
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );

      if (!authenticated) {
        throw Exception('Biometric authentication cancelled or failed.');
      }

      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null) {
        throw Exception('No active session found for biometric login. Please sign in with email or OAuth first.');
      }

      final profile = await _fetchUserProfile(fbUser.uid);
      if (profile == null) {
        throw Exception('Voter profile not found.');
      }

      await _firestore.collection('users').doc(fbUser.uid).update({
        'last_login_at': FieldValue.serverTimestamp(),
      });

      return profile;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Biometric login error: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Password reset error: $e');
    }
  }

  @override
  Future<bool> verifyTokenWithNeovote(String idToken) async {
    if (_neoVoteUrl.isEmpty) {
      debugPrint('NeoVote backend URL not configured, skipping token verification.');
      return true;
    }

    try {
      final url = Uri.parse('$_neoVoteUrl/auth/verify');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        debugPrint('NeoVote backend token verification failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error verifying token with NeoVote backend: $e');
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }

  Future<UserModel?> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Failed to load user profile from Firestore: $e');
      return null;
    }
  }

  Exception _handleFirebaseAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No voter account found with this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Incorrect password or credentials provided.');
      case 'email-already-in-use':
        return Exception('An account with this email already exists.');
      case 'invalid-email':
        return Exception('The provided email address is invalid.');
      case 'weak-password':
        return Exception('Password should be at least 6 characters');
      case 'user-disabled':
        return Exception('This voter account has been suspended.');
      default:
        return Exception(e.message ?? 'Authentication failed.');
    }
  }
}
