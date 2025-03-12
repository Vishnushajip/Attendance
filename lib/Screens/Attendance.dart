// ignore_for_file: unused_result

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../Models/FetchAttendanceModel.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>(
  (ref) => AttendanceNotifier(),
);

class AttendanceState {
  final String status;
  final String? clockInTime;
  final String? clockOutTime;

  AttendanceState({required this.status, this.clockInTime, this.clockOutTime});

  AttendanceState copyWith({
    String? status,
    String? clockInTime,
    String? clockOutTime,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(AttendanceState(status: "Clock In")) {
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('attendance_status') ?? 'Clock In';
    String? clockInTime = prefs.getString('clocked_in_time');
    String? clockOutTime = prefs.getString('clocked_out_time');

    state = AttendanceState(
      status: status,
      clockInTime: clockInTime,
      clockOutTime: clockOutTime,
    );
  }

  Future<void> toggleAttendance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String? userEmail = prefs.getString('user_email');
    if (userEmail == null) {
      print("Error: User email not found in SharedPreferences");
      return;
    }

    String newStatus = (state.status == "Mark In") ? "Mark Out" : "Mark In";
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    if (state.status == "Mark In") {
      await prefs.setString('clocked_in_time', formattedTime);
      state = state.copyWith(status: newStatus, clockInTime: formattedTime);

      await firestore.collection('attendance').doc(userEmail).set({
        'userEmail': userEmail,
        'clockInTime': formattedTime,
        'clockOutTime': null,
        'status': newStatus,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      }, SetOptions(merge: true));
    } else {
      await prefs.setString('clocked_out_time', state.clockInTime ?? '');
      state =
          state.copyWith(status: newStatus, clockOutTime: state.clockInTime);

      await firestore.collection('attendance').doc(userEmail).update({
        'clockOutTime': formattedTime,
        'status': newStatus,
      });
    }

    await prefs.setString('attendance_status', newStatus);
  }

  Future<void> clearAttendanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    state = AttendanceState(
        status: "Mark In", clockInTime: null, clockOutTime: null);
  }
}

final liveTimeProvider = StreamProvider<String>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return DateFormat('hh:mm:ss a').format(DateTime.now());
  });
});

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider);
    final liveTime = ref.watch(liveTimeProvider).value ?? '';

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            "Attendance",
            style: GoogleFonts.poppins(),
          )),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  liveTime,
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    ref.refresh(attendanceLogProvider);
                    ref.read(attendanceProvider.notifier).toggleAttendance();
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.pink, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        attendanceState.status == 'Mark In'
                            ? Icons.login
                            : Icons.logout,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  attendanceState.status,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (attendanceState.clockInTime != null)
            Positioned(
              left: 20,
              bottom: 20,
              child: Text(
                "Mark In: ${attendanceState.clockInTime ?? '--:--'}",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.green),
              ),
            ),
          if (attendanceState.clockOutTime != null)
            Positioned(
              right: 20,
              bottom: 20,
              child: Text(
                "Mark Out: ${attendanceState.clockOutTime ?? '--:--'}",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
