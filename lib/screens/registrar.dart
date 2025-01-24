import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marvel_info/screens/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _validateUsername(String? value) {
    final usernameRegex = RegExp(r'^[A-ZÑ][a-zñ]+$');
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario no puede estar vacío';
    } else if (!usernameRegex.hasMatch(value)) {
      return 'Debe comenzar con mayúscula y solo contener letras';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (value == null || value.isEmpty) {
      return 'El correo no puede estar vacío';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Introduce un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (value == null || value.isEmpty) {
      return 'La contraseña no puede estar vacía';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'Debe tener al menos 8 caracteres, una mayúscula, una minúscula y un número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Repite la contraseña';
    } else if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Método para cifrar la contraseña usando SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convierte la contraseña a bytes UTF-8
    final digest = sha256.convert(bytes); // Aplica SHA-256
    return digest.toString(); // Devuelve el hash como cadena
  }

  Future<void> _registerUser() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Verificar si el correo electrónico ya está registrado
      final querySnapshot = await _db.collection('users').where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El correo ya está registrado')),
        );
        return;
      }

      // Cifra la contraseña
      final hashedPassword = _hashPassword(password);

      // Añadir el nuevo usuario a Firestore y esperar la respuesta
      final docRef = await _db.collection('users').add({
        'username': username,
        'email': email,
        'password': hashedPassword, // Guarda la contraseña cifrada
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Verifica si el documento fue creado correctamente
      if (docRef.id.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso')),
        );

        // Limpiar los campos del formulario
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } else {
        throw 'Error al registrar el usuario en Firestore';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar usuario: $e')),
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
              Image.asset(
                'assets/logo_marvel.png',
                height: 100,
              ),
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
                      const Text('Nombre de usuario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.name,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zñÑ]'))],
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu nombre de usuario',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(),
                        ),
                        validator: _validateUsername,
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      const Text('Repite la contraseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Repite tu contraseña',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: const OutlineInputBorder(),
                        ),
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _registerUser();
                            }
                          },
                          child: const Text('Registrarse'),
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
                  const Text('¿Ya tienes usuario? '),
                  GestureDetector(
                    onTap: () {
                      // Navegar a la pantalla de inicio de sesión
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
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
