import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Session? build() {
    final session = Supabase.instance.client.auth.currentSession;
    _listenToAuthChanges();
    return session;
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      state = data.session;
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      
      // Google SignIn v7.x uses authenticate() which returns GoogleSignInAccount.
      // authentication is now a property, not a Future.
      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'No ID Token found.';

      // Sign in to Supabase with ID Token (Google)
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) throw 'No ID Token found.';

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } catch (e) {
      rethrow;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
