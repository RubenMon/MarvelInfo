import 'package:flutter/material.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text(
              "Rubén Montero Martín",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),  // Color de texto cambiado a negro
            ),
            accountEmail: Text(
              "rmonmar0810@g.educaand.es",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),  // Color de texto cambiado a negro
            ),
            decoration: BoxDecoration(
              color: Colors.red,
            ),
          ),
          ListTile(
              title: const Text(
                "Personajes de Marvel",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/personajes');
              },
            ),
          ListTile(
            title: const Text(
              "Juego",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/juego');
            },
          ),
          ListTile(
            title: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}