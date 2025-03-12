import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final attendanceLogProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userEmail = prefs.getString('user_email') ?? "unknown@example.com";

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot snapshot = await firestore
      .collection("attendance")
      .where("userEmail", isEqualTo: userEmail)
      .orderBy("date", descending: true)
      .get();

  return snapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
});
