import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bamx/screens/home.dart';
import 'package:bamx/utils/warning.dart';
import 'package:bamx/utils/validators.dart';
import 'package:bamx/utils/color_palette.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
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

    // Validación local antes de mandar a Firebase
    if (!isValidEmail(email)) {
      showErrorMessage(context, "Correo inválido. Use un formato correcto.");
      return;
    }

    if (!isValidPassword(password)) {
      showErrorMessage(
        context,
        "Contraseña insegura. Use al menos 6 caracteres, una mayúscula y un número.",
      );
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;

      if (user != null && mounted) {
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
          "Correo o contraseña inválida. Asegúrese de que su correo sea válido y que la contraseña tenga mínimo 6 caracteres",
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
      appBar: AppBar(
        title: const Text("Registro"),
        iconTheme: IconThemeData(
          color: NokeyColorPalette.white, // Arrow back - color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: "Correo"),
              keyboardType: TextInputType.emailAddress,
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
