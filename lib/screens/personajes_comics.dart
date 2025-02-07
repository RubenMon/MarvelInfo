import 'package:flutter/material.dart';
import 'package:marvel_info/api/marvel_api_service.dart';
import 'package:marvel_info/screens/menuLateral.dart';

class ComicsPage extends StatefulWidget {
  // Recibe el ID y nombre del personaje como parámetros
  final int characterId;
  final String characterName;

  // Constructor de la clase ComicsPage
  const ComicsPage({super.key, required this.characterId, required this.characterName});

  @override
  // ignore: library_private_types_in_public_api
  _ComicsPageState createState() => _ComicsPageState();
}

class _ComicsPageState extends State<ComicsPage> {
  // Instancia del servicio MarvelApiService para obtener datos de la API
  final MarvelApiService marvelApi = MarvelApiService();
  
  // Lista de cómics que se obtendrán desde la API
  List<Map<String, dynamic>> _comics = [];
  
  // Variable para controlar el estado de carga de los datos
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Llamada a la función para obtener los cómics cuando se inicializa la página
    _fetchComics();
  }

  // Función asincrónica para obtener los cómics del personaje
  Future<void> _fetchComics() async {
    try {
      // Obtiene los cómics del personaje mediante el ID
      final comics = await marvelApi.fetchComicsByCharacter(widget.characterId);
      setState(() {
        // Almacena los cómics obtenidos en la variable _comics
        _comics = comics;
      });
    } catch (e) {
      // Manejar el error si ocurre durante la obtención de datos
    } finally {
      setState(() {
        // Indica que la carga de datos ha finalizado
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el nombre del personaje
      appBar: AppBar(title: Text("Cómics de ${widget.characterName}")),
      
      // Menú lateral con la navegación
      drawer: const MenuLateral(),
      
      // Cuerpo de la página, que muestra un indicador de carga o los cómics
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Indicador de carga
          : _comics.isEmpty
              ? const Center(child: Text("No se encontraron cómics.")) // Si no hay cómics
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _comics.length, // Número de cómics a mostrar
                  itemBuilder: (context, index) {
                    final comic = _comics[index]; // Obtiene el cómic actual de la lista
                    return Card(
                      child: ListTile(
                        // Imagen del cómic, con manejo de error
                        leading: Image.network(
                          comic['imageUrl'], // URL de la imagen del cómic
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover, // Ajuste de la imagen
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset("assets/images/placeholder.png"), // Imagen de reemplazo si falla
                        ),
                        // Título del cómic
                        title: Text(comic['title']),
                      ),
                    );
                  },
                ),
    );
  }
}