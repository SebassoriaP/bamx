import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bamx/screens/home.dart';
import 'package:bamx/screens/sign_up.dart';
import 'package:bamx/screens/widget_testing.dart';
import 'package:bamx/widgets/login/login_form.dart';
import 'package:bamx/widgets/login/login_footer.dart';
import 'package:bamx/widgets/blue_container_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se pudo iniciar sesión. Verifica tu usuario y contraseña.",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shorter Blue container
                  SizedBox(
                    height: screenHeight * 0.6, // Adjust height here
                    child: BlueContainer(
                      overlays: const [
                        Positioned(
                          bottom: -42,
                          left: -11,
                          child: Text(
                            "NOKEY",
                            style: TextStyle(
                              fontSize: 110,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LoginForm(
                                emailController: emailController,
                                passwordController: passwordController,
                                onLogin: login,
                                onRegister: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SignUpScreen()),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Footer stays at the bottom
                  LoginFooter(
                    onTestWidgets: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TestGridScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}