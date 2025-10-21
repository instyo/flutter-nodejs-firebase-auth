import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auth_test/core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
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

  // Sign in with Apple
  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      // Generate a random nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        webAuthenticationOptions: Platform.isIOS
            ? null
            : WebAuthenticationOptions(
                clientId: 'dev.ikhwan.authTest.authTest.service',
                redirectUri: Uri.parse(
                  '${Constants.baseUrl}/api/callbacks/sign_in_with_apple',
                ),
              ),
      );

      print(">> HEELLOO : ${appleCredential.authorizationCode}");

      // Create Firebase credential from Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Send to backend
      final result = await http.post(
        Uri.parse('${Constants.baseUrl}/api/apple-sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idToken': idToken,
          'appleUser': {
            'email': appleCredential.email ?? userCredential.user?.email,
            'familyName': appleCredential.familyName,
            'givenName': appleCredential.givenName,
            'userIdentifier': appleCredential.userIdentifier,
          },
        }),
      );

      return json.decode(result.body);
    } catch (e) {
      print('Apple Sign In error: $e');
      return null;
    }
  }

  // Generate a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  // SHA256 hash function for the nonce
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
