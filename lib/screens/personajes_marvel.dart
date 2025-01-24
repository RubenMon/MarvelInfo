import 'package:flutter/material.dart';
import 'package:marvel_info/api/marvel_api_service.dart';

class PersonajesMarvel extends StatefulWidget {
  const PersonajesMarvel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PersonajesMarvelState createState() => _PersonajesMarvelState();
}

class _PersonajesMarvelState extends State<PersonajesMarvel> {
  late Future<List<Map<String, dynamic>>> _characters;

  @override
  void initState() {
    super.initState();
    final marvelApi = MarvelApiService();
    _characters = marvelApi.fetchCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personajes Marvel"),
        actions: [
          IconButton(
            onPressed: () {
              // Funcionalidad de búsqueda en el futuro
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _characters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No se encontraron personajes."));
          }

          final characters = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Tres columnas como en tu diseño
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7, // Ajusta el tamaño de las imágenes
              ),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          character['imageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      character['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
