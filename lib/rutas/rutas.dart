import 'package:marvel_info/screens/screens.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const Login(),
  '/register': (context) => const Register(),
  '/personajes': (context) => const PersonajesMarvel(),  
  '/juego': (context) => const CharacterGame(),
};