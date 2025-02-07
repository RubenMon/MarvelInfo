import 'package:firebase_core/firebase_core.dart';
import 'package:marvel_info/rutas/rutas.dart';
import 'package:marvel_info/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Asegura que los widgets estén correctamente inicializados antes de ejecutar la app
  await Firebase.initializeApp();  // Inicializa Firebase
  runApp(const MyApp());  // Ejecuta la aplicación MyApp
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Desactiva el banner de modo de depuración
      title: 'Marvel Info',  // Título de la aplicación
      initialRoute: '/login',  // Ruta inicial de la aplicación (pantalla de login)
      routes: appRoutes,  // Define las rutas de navegación para la app
    );
  }
}
