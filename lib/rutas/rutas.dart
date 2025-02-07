import 'package:marvel_info/screens/screens.dart';

// Mapa que define las rutas de la aplicación y sus respectivas pantallas
final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const Login(),
  '/register': (context) => const Register(),
  '/personajes': (context) => const PersonajesMarvel(),  
  '/juego': (context) => const CharacterGame(),
};