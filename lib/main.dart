import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marvel_info/screens/login.dart';

void main() async {
  // Asegúrate de inicializar Firebase antes de ejecutar la app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro Marvel',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Login(), // Usa el widget de registro
    );
  }
}
