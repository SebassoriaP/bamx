import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:bamx/widgets/button_widget.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onRegister,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Usuario
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "usuario",
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Contraseña
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "contraseña",
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
    
        ButtonWidget(
            text: "Iniciar Sesión",
            color: const Color(0xFFFFC107),
            textColor: Colors.black,
            onPressed: onLogin,
        ),

        const SizedBox(height: 32),

        // Registro
        Column(
          children: [
            const Text(
                "No tengo usuario?",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16,
                ),
            ),
            TextButton(
              onPressed: onRegister,
              child: const Text(
                "REGISTRARME",
                style: TextStyle(
                  color: Colors.purple,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}