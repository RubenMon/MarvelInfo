import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Verificar si el correo ya está registrado en Firestore
      final existingUser = await _db.collection('users').where('email', isEqualTo: email).get();
      if (existingUser.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El correo ya está registrado')),
        );
        return;
      }

      // Registrar usuario en Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar información adicional en Firestore
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );

      // Limpiar los campos del formulario
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Redirigir al usuario a la pantalla de inicio de sesión
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al registrar usuario';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo ya está en uso';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El correo electrónico no es válido';
      }

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
                      _buildTextField('Nombre de usuario', _usernameController, TextInputType.name, _validateUsername),
                      _buildTextField('Correo electrónico', _emailController, TextInputType.emailAddress, _validateEmail),
                      _buildTextField('Contraseña', _passwordController, TextInputType.visiblePassword, _validatePassword, obscureText: true),
                      _buildTextField('Repite la contraseña', _confirmPasswordController, TextInputType.visiblePassword, _validateConfirmPassword, obscureText: true),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: _registerUser,
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
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/login');
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

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType, String? Function(String?)? validator, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: 'Ingresa tu $label',
            filled: true,
            fillColor: Colors.grey[200],
            border: const OutlineInputBorder(),
          ),
          validator: validator,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}