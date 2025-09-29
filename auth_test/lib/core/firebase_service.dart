import 'dart:convert';

import 'package:auth_test/core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // Trigger the authentication flow
    final googleUser = await _googleSignIn.authenticate(
      scopeHint: [
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    );

    final result = await http.post(
      Uri.parse('${Constants.baseUrl}/api/google-sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'idToken': googleUser.authentication.idToken}),
    );

    return json.decode(result.body);
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final result = await http.post(
        Uri.parse('${Constants.baseUrl}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      return json.decode(result.body);
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>?> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final result = await http.post(
        Uri.parse('${Constants.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      return json.decode(result.body);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<bool> isEmailVerified(String uid) async {
    try {
      final result = await http.post(
        Uri.parse('${Constants.baseUrl}/api/checkEmail'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': uid}),
      );

      if (result.statusCode == 200) {
        final data = json.decode(result.body);
        return data['user']['emailVerified'] ?? false;
      }
      return false;
    } catch (e) {
      print('Email verification check error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get ID token for API calls
  Future<String?> getIdToken() async {
    final user = currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  // Make authenticated API call
  Future<http.Response?> authenticatedRequest(String endpoint) async {
    final token = await getIdToken();
    if (token == null) return null;

    return await http.get(
      Uri.parse('${Constants.baseUrl}/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // Make authenticated POST request
  Future<http.Response?> authenticatedPost(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await getIdToken();
    if (token == null) return null;

    return await http.post(
      Uri.parse('${Constants.baseUrl}/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }
}
