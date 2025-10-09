import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bamx/screens/home.dart';
import 'package:bamx/screens/sign_up.dart';
import 'package:bamx/screens/widget_testing.dart';
import 'package:bamx/widgets/login/login_form.dart';
import 'package:bamx/widgets/login/login_footer.dart';
import 'package:bamx/widgets/container_widget.dart';
import 'package:bamx/utils/warning.dart';

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
    }  on FirebaseAuthException catch (_) {
    if (!mounted) return;

    // Error Managment for Authentication
    showErrorMessage(context, "No se pudo iniciar sesión. Verifica tu usuario y contraseña");

  } catch (e) {
    if (!mounted) return;
    showErrorMessage(context, "Ocurrió un error inesperado");
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Blue container takes flexible space
                      Expanded(
                        flex: 6,
                        child: FlexibleContainer(
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
                                            builder: (_) =>
                                                const SignUpScreen()),
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

                      // Footer stays at bottom
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
            );
          },
        ),
      ),
    );
  }
}