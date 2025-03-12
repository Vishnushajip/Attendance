import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AttendanceViewModel {
  final FirebaseFirestore _firestore;

  AttendanceViewModel(this._firestore);

  Future<void> markAttendance(String email) async {
    try {
      await _firestore.collection("attendance").add({
        "email": email,
        "date": DateTime.now().toIso8601String(),
      });
      Fluttertoast.showToast(msg: "Attendance marked successfully!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error marking attendance: ${e.toString()}");
    }
  }
}
