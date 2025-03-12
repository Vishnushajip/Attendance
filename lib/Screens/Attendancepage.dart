import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/FetchAttendanceModel.dart';

class AttendanceLogScreen extends ConsumerWidget {
  const AttendanceLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceLogs = ref.watch(attendanceLogProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Attendance Log",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: attendanceLogs.when(
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Text(
                "No attendance records found.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.access_time_filled,
                    color:
                        log["clockOutTime"] != null ? Colors.red : Colors.green,
                  ),
                  title: Text(
                    "Clocked In: ${log["clockInTime"] ?? "--:--"}",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Clocked Out: ${log["clockOutTime"] ?? "--:--"}",
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[700]),
                  ),
                  trailing: Text(
                    log["date"] != null ? log["date"].split("T")[0] : "Unknown",
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.black54),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text("Error fetching data",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
        ),
      ),
    );
  }
}
