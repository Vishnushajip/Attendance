import 'package:attendance/Screens/Attendance.dart';
import 'package:attendance/Screens/SplashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'Models/FetchAttendanceModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final container = ProviderContainer();
  try {
    container.read(attendanceLogProvider);
    container.read(attendanceLogProvider);
    container.read(attendanceProvider);
    container.read(liveTimeProvider);

    print("Data prefetched successfully.");
  } catch (e) {
    print("Error prefetching addresses: $e");
  }

  runApp(
    ProviderScope(
      parent: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: const Color(0xFF273847),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      home: SplashScreen(),
    );
  }
}
