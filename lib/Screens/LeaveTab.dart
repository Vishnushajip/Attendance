import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LeaveApplicationScreen.dart';
import 'leavehistory.dart';

class LeaveTabScreen extends StatelessWidget {
  const LeaveTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Leave Management",
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.event_available), text: "Apply Leave"),
              Tab(icon: Icon(Icons.history), text: "Leave History"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LeaveApplicationScreen(),
            LeaveHistoryScreen(),
          ],
        ),
      ),
    );
  }
}
