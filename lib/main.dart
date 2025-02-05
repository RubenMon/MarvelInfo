import 'package:firebase_core/firebase_core.dart';
import 'package:marvel_info/rutas/rutas.dart';
import 'package:marvel_info/screens/screens.dart';

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
      title: 'Marvel Info',
      initialRoute: '/login',
      routes: appRoutes,
    );
  }
}
