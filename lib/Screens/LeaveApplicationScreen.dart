import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Providers/leave_provider.dart';

class LeaveApplicationScreen extends ConsumerWidget {
  const LeaveApplicationScreen({super.key});

  Future<void> _selectDate(
      BuildContext context, WidgetRef ref, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (isStart) {
        ref.read(leaveFormProvider.notifier).updateStartDate(picked);
      } else {
        ref.read(leaveFormProvider.notifier).updateEndDate(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveForm = ref.watch(leaveFormProvider);
    final isLoading = ref.watch(leaveRequestProviders);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Apply for Leave",
          style: GoogleFonts.poppins(
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Leave Type:",
                style: GoogleFonts.poppins(fontSize: 16)),
            DropdownButton<String>(
              value: leaveForm.leaveType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref
                      .read(leaveFormProvider.notifier)
                      .updateLeaveType(newValue);
                }
              },
              items: [
                "Sick Leave",
                "Casual Leave",
                "Annual Leave",
                "Emergency Leave"
              ]
                  .map((String leave) => DropdownMenuItem(
                        value: leave,
                        child: Text(leave),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Text("Select Leave Dates:",
                style: GoogleFonts.poppins(fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, ref, true),
                    child: Text(
                        leaveForm.startDate == null
                            ? "Select Start Date"
                            : DateFormat('yyyy-MM-dd')
                                .format(leaveForm.startDate!),
                        style: GoogleFonts.poppins(color: Colors.black)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, ref, false),
                    child: Text(
                        leaveForm.endDate == null
                            ? "Select End Date"
                            : DateFormat('yyyy-MM-dd')
                                .format(leaveForm.endDate!),
                        style: GoogleFonts.poppins(color: Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("Reason:",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black)),
            TextField(
              cursorColor: Colors.black,
              onChanged: (text) =>
                  ref.read(leaveFormProvider.notifier).updateReason(text),
              maxLines: 3,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black))),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.black,
                  ))
                : Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: () {
                        ref.read(leaveRequestProviders.notifier).applyLeave();
                      },
                      child: Text("Submit Leave Request",
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.white)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
