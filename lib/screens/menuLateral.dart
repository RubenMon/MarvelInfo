import 'package:flutter/material.dart';

// Clase que define un menú lateral en la aplicación
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          // Encabezado del menú lateral con información del usuario
          const UserAccountsDrawerHeader(
            accountName: Text(
              "Rubén Montero Martín",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),  // Color del texto en blanco
            ),
            accountEmail: Text(
              "rmonmar0810@g.educaand.es",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),  // Color del texto en blanco
            ),
            decoration: BoxDecoration(
              color: Colors.red,  // Color de fondo del encabezado
            ),
          ),
          // Opción para navegar a la sección "Personajes de Marvel"
          ListTile(
              title: const Text(
                "Personajes de Marvel",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.of(context).pop();  // Cierra el menú lateral
                Navigator.pushNamed(context, '/personajes');  // Navega a la pantalla de personajes
              },
            ),
          // Opción para navegar a la sección "Juego"
          ListTile(
            title: const Text(
              "Juego",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.of(context).pop();  // Cierra el menú lateral
              Navigator.pushNamed(context, '/juego');  // Navega a la pantalla del juego
            },
          ),
          // Opción para cerrar sesión y redirigir a la pantalla de inicio de sesión
          ListTile(
            title: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.of(context).pop();  // Cierra el menú lateral
              Navigator.pushReplacementNamed(context, '/login');  // Redirige a la pantalla de inicio de sesión
            },
          ),
        ],
      ),
    );
  }
}