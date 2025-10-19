import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bamx/screens/home.dart';
import 'package:bamx/screens/sign_up.dart';
import 'package:bamx/screens/widget_testing.dart';
import 'package:bamx/screens/form_creation.dart';
import 'package:bamx/utils/color_palette.dart';
import 'package:bamx/screens/admin/admin.dart';

import 'package:bamx/widgets/login/login_form.dart';
import 'package:bamx/widgets/login/login_footer.dart';
import 'package:bamx/widgets/container_widget.dart';

import 'package:bamx/utils/warning.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorMessage(context, "Por favor completa todos los campos.");
      return;
    }

    if (hasUnsafeCharacters(email) || hasUnsafeCharacters(password)) {
      showErrorMessage(
        context,
        "El correo o la contraseña contienen caracteres no permitidos (<, > o invisibles).",
      );
      return;
    }

    if (!isValidEmail(email)) {
      showErrorMessage(context, "Correo electrónico inválido");
      return;
    }

    if (!isValidPassword(password)) {
      showErrorMessage(context, "La contraseña es incorrecta");
      return;
    }

    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final adminSnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (!mounted) return;

      if (adminSnapshot.docs.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPanel()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (_) {
      if (!mounted) return;
      showErrorMessage(
        context,
        "No se pudo iniciar sesión. Verifica tu usuario y contraseña.",
      );
    } catch (e) {
      if (!mounted) return;
      showErrorMessage(context, "Ocurrió un error inesperado");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NokeyColorPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isLoading)
                                    const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(),
                                    )
                                  else
                                    LoginForm(
                                      emailController: emailController,
                                      passwordController: passwordController,
                                      onLogin: login,
                                      onRegister: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SignUpScreen(),
                                          ),
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

                      LoginFooter(
                        onTestWidgets: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TestGridScreen(),
                            ),
                          );
                        },
                        onTestFormCreation: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FormCreationScreen(),
                            ),
                          );
                        },
                        onAdmin: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminPanel(),
                            ),
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