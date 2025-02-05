import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marvel_info/screens/personajes_marvel.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo no puede estar vacío';
    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Introduce un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }
    return null;
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión exitoso')),
      );

      // Redirigir a la pantalla de personajes
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => PersonajesMarvel()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        errorMessage = 'No existe un usuario con ese correo';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta';
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo_marvel.png', height: 100),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Correo electrónico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu correo electrónico',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 10),
                      const Text('Contraseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu contraseña',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: _loginUser,
                          child: const Text('Inicia sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes usuario? '),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Regístrate', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}