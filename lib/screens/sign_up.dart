import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bamx/screens/home.dart';
import 'package:bamx/utils/warning.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController(); // optional, only local use

  Future<void> register() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user;

      if (user != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'email-already-in-use') {
        showErrorMessage(context, "Usuario existente");
      } else {
        showErrorMessage(
          context,
          "Correo o constraseña inválida. Asegurese de que su correo sea válido y que la contraseña tenga mínimo 6 caracteres",
        );
      }
    } catch (e) {
      if (!mounted) return;
      showErrorMessage(context, "Ocurrió un error inesperado");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Name field (optional, not stored in FirebaseAuth directly)
            // TextField(
            //   controller: nameController,
            //   decoration: const InputDecoration(hintText: "Nombre (opcional)"),
            // ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: "Correo"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Contraseña"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text("Registrarse"),
            ),
          ],
        ),
      ),
    );
  }
}
