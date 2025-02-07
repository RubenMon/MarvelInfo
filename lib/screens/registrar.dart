import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Controladores para los campos de texto
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Clave global para el formulario
  final _formKey = GlobalKey<FormState>();
  // Instancia de FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Validación del nombre de usuario
  String? _validateUsername(String? value) {
    final usernameRegex = RegExp(r'^[A-ZÑ][a-zñ]+$');
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario no puede estar vacío';
    } else if (!usernameRegex.hasMatch(value)) {
      return 'Debe comenzar con mayúscula y solo contener letras';
    }
    return null;
  }

  // Validación del correo electrónico
  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (value == null || value.isEmpty) {
      return 'El correo no puede estar vacío';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Introduce un correo electrónico válido';
    }
    return null;
  }

  // Validación de la contraseña
  String? _validatePassword(String? value) {
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (value == null || value.isEmpty) {
      return 'La contraseña no puede estar vacía';
    } else if (!passwordRegex.hasMatch(value)) {
      return 'Debe tener al menos 8 caracteres, una mayúscula, una minúscula y un número';
    }
    return null;
  }

  // Validación de la confirmación de la contraseña
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Repite la contraseña';
    } else if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Función para registrar al usuario
  Future<void> _registerUser() async {
    // Verificar si el formulario es válido
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Registrar usuario en Firebase Authentication
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Mostrar mensaje de éxito
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );

      // Limpiar los campos del formulario
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Redirigir al usuario a la pantalla de inicio de sesión
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al registrar usuario';
      // Manejar posibles errores de Firebase
      if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo ya está en uso';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El correo electrónico no es válido';
      }

      // Mostrar mensaje de error
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
              // Imagen de logo
              Image.asset('assets/logo_marvel.png', height: 100),
              const SizedBox(height: 20),
              // Contenedor del formulario
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
                      // Campo de nombre de usuario
                      _buildTextField('Nombre de usuario', _usernameController, TextInputType.name, _validateUsername),
                      // Campo de correo electrónico
                      _buildTextField('Correo electrónico', _emailController, TextInputType.emailAddress, _validateEmail),
                      // Campo de contraseña
                      _buildTextField('Contraseña', _passwordController, TextInputType.visiblePassword, _validatePassword, obscureText: true),
                      // Campo de confirmación de la contraseña
                      _buildTextField('Repite la contraseña', _confirmPasswordController, TextInputType.visiblePassword, _validateConfirmPassword, obscureText: true),
                      const SizedBox(height: 20),
                      // Botón de registro
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
              // Enlace para iniciar sesión si ya tienes cuenta
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

  // Función para construir un campo de texto con su validación
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