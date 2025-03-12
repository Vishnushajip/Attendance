import 'package:attendance/Screens/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


final userProvider = StateProvider<String?>((ref) => null);

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

class LoginViewModel {
  final FirebaseFirestore _firestore;
  final WidgetRef _ref;

  LoginViewModel(this._firestore, this._ref);

  Future<bool> registerUser(
      BuildContext context, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_email', email);
    try {
      await _firestore.collection('users').doc(email).set({
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(msg: "Employee registered successfully!");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Registration failed");
      return false;
    }
    return true;
  }

  Future<void> logout() async {
    _ref.read(userProvider.notifier).state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    Fluttertoast.showToast(msg: "✅ Logged out successfully!");
  }
}
