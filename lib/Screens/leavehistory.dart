import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final leaveHistoryProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userEmail = prefs.getString('user_email');

  if (userEmail == null) {
    yield [];
    return;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  yield* firestore
      .collection("leave_requests")
      .where("userEmail", isEqualTo: userEmail)
      .orderBy("appliedAt", descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

class LeaveHistoryScreen extends ConsumerWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveHistory = ref.watch(leaveHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Leave History", style: GoogleFonts.poppins(fontSize: 20)),
      ),
      body: leaveHistory.when(
        data: (leaves) => leaves.isEmpty
            ? Center(
                child: Text(
                  "No leave history found.",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: leaves.length,
                itemBuilder: (context, index) {
                  final leave = leaves[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300)),
                      child: ExpansionTile(
                        title: Text(
                          "${leave['leaveType']} (${leave['status']})",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: leave['status'] == 'Approved'
                                ? Colors.green
                                : leave['status'] == 'Rejected'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Colors.blue),
                            title: Text("From: ${leave['startDate']}"),
                            subtitle: Text("To: ${leave['endDate']}"),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.message, color: Colors.grey),
                            title: Text("Reason: ${leave['reason']}"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (e, _) => Center(child: Text("Error fetching leave history")),
      ),
    );
  }
}
