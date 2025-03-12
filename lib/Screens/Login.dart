import 'package:attendance/Screens/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/LoginModel.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.read(firestoreProvider);
    final loginViewModel = LoginViewModel(firestore, ref);
    final user = ref.watch(userProvider);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            user != null ? "Welcome, $user" : "Login",
            style: GoogleFonts.poppins(),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width: 350,
            height: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                        ),
                        onPressed: () async {
                          ref.read(loadingProvider.notifier).state = true;

                          bool success = await loginViewModel.registerUser(
                            context,
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );

                          ref.read(loadingProvider.notifier).state = false;

                          if (success) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => BottomNavBarScreen()),
                            );
                          }
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
