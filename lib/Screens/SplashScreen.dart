import 'package:attendance/Screens/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('user_email');

      if (userEmail == null || userEmail.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBarScreen()),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "AttendEase",
              style: GoogleFonts.poppins(
                  fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              "Simplify Attendance, Maximize Productivity!",
              style: GoogleFonts.padauk(fontSize: 8),
            )
          ],
        ),
      ),
    );
  }
}
