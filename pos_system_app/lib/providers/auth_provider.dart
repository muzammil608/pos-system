import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String role = "";
  bool isLoading = false;

  bool get isAdmin => role == "admin";
  bool get isEmployee => role == "employee";
  bool get isLoggedIn => user != null;

  /// ================= GOOGLE LOGIN =================
  Future<bool> loginWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      user = result.user;

      await _loadUserRole();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Google Login Error: $e");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ================= LOAD ROLE =================
  Future<void> _loadUserRole() async {
    if (user == null) return;

    final doc = _firestore.collection("users").doc(user!.uid);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      // First time user → default employee
      await doc.set({
        "name": user!.displayName ?? "",
        "email": user!.email ?? "",
        "role": "employee",
        "createdAt": FieldValue.serverTimestamp(),
      });
      role = "employee";
    } else {
      role = snapshot.data()?["role"] ?? "employee";
    }
  }

  /// ================= AUTO LOGIN CHECK =================
  Future<void> checkCurrentUser() async {
    user = _auth.currentUser;

    if (user != null) {
      await _loadUserRole();
    }

    notifyListeners();
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    user = null;
    role = "";
    notifyListeners();
  }
}
