// ignore_for_file: unused_result

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveFormState {
  final String leaveType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String reason;

  LeaveFormState({
    this.leaveType = "Sick Leave",
    this.startDate,
    this.endDate,
    this.reason = "",
  });

  LeaveFormState copyWith({
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
  }) {
    return LeaveFormState(
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
    );
  }
}

final leaveFormProvider =
    StateNotifierProvider<LeaveFormNotifier, LeaveFormState>(
  (ref) => LeaveFormNotifier(),
);

class LeaveFormNotifier extends StateNotifier<LeaveFormState> {
  LeaveFormNotifier() : super(LeaveFormState());

  void updateLeaveType(String leaveType) {
    state = state.copyWith(leaveType: leaveType);
  }

  void updateStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
  }

  void updateEndDate(DateTime date) {
    state = state.copyWith(endDate: date);
  }

  void updateReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void resetForm() {
    state = LeaveFormState();
  }
}

final leaveRequestProviders =
    StateNotifierProvider<LeaveRequestNotifier, bool>((ref) {
  return LeaveRequestNotifier(ref);
});

class LeaveRequestNotifier extends StateNotifier<bool> {
  final Ref ref;
  LeaveRequestNotifier(this.ref) : super(false);

  Future<void> applyLeave() async {
    state = true;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('user_email');
      if (userEmail == null) throw Exception("User email not found");

      final leaveForm = ref.read(leaveFormProvider);

      if (leaveForm.startDate == null ||
          leaveForm.endDate == null ||
          leaveForm.reason.isEmpty) {
        throw Exception("Please fill all fields");
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('leave_requests').add({
        'userEmail': userEmail,
        'leaveType': leaveForm.leaveType,
        'reason': leaveForm.reason,
        'startDate': DateFormat('yyyy-MM-dd').format(leaveForm.startDate!),
        'endDate': DateFormat('yyyy-MM-dd').format(leaveForm.endDate!),
        'status': 'Pending',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      ref.read(leaveFormProvider.notifier).resetForm();
      ref.refresh(leaveFormProvider);
      ref.refresh(leaveRequestProviders);
    } catch (e) {
      print("Error saving leave request: $e");
    } finally {
      state = false;
    }
  }
}
