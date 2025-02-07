import 'package:flutter/material.dart';
import 'package:marvel_info/api/marvel_api_service.dart';
import 'package:marvel_info/screens/menuLateral.dart';
import 'package:marvel_info/screens/personajes_comics.dart';

class PersonajesMarvel extends StatefulWidget {
  const PersonajesMarvel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PersonajesMarvelState createState() => _PersonajesMarvelState();
}

class _PersonajesMarvelState extends State<PersonajesMarvel> {
  final MarvelApiService marvelApi = MarvelApiService(); // Servicio para obtener los personajes
  final ScrollController _scrollController = ScrollController(); // Controlador para la lista con scroll
  final TextEditingController _searchController = TextEditingController(); // Controlador para el campo de búsqueda

  List<Map<String, dynamic>> _characters = []; // Lista de personajes
  bool _isLoading = false; // Variable que indica si estamos cargando más personajes
  bool _hasMore = true; // Variable que indica si hay más personajes por cargar
  int _offset = 0; // Desplazamiento para la carga de personajes
  final int _limit = 30; // Límite de personajes por carga
  String _searchQuery = ""; // Término de búsqueda
  bool _isSearching = false; // Estado de la búsqueda
  bool _isDisposed = false; // Para evitar realizar operaciones después de que el widget haya sido eliminado

  @override
  void initState() {
    super.initState();
    _fetchCharacters(); // Cargar los personajes cuando la pantalla se inicializa

    _scrollController.addListener(() {
      // Detecta cuando llegamos al final de la lista
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchCharacters(); // Cargar más personajes
      }
    });

    _searchController.addListener(() {
      // Detecta cambios en el campo de búsqueda
      _onSearchChanged();
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // Marca el widget como eliminado
    _scrollController.dispose(); // Limpia el controlador de scroll
    _searchController.dispose(); // Limpia el controlador de búsqueda
    super.dispose();
  }

  // Función que obtiene los personajes desde el API de Marvel
  Future<void> _fetchCharacters() async {
    if (_isDisposed) return; // Si el widget ha sido destruido, no realizar nada

    setState(() {
      _isLoading = true; // Cambiar el estado a cargando
    });

    try {
      final newCharacters = await marvelApi.fetchCharacters(
        offset: _offset,
        limit: _limit,
        nameStartsWith: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (_isDisposed) return; // Si el widget ha sido destruido, no realizar nada

      setState(() {
        if (_offset == 0) {
          _characters = newCharacters; // Si es la primera carga, reemplazamos los personajes
        } else {
          _characters.addAll(newCharacters); // Si no es la primera carga, añadimos más personajes
        }

        _offset += _limit; // Aumentamos el offset para la siguiente carga

        if (newCharacters.length < _limit) {
          _hasMore = false; // Si los personajes obtenidos son menos que el límite, no hay más por cargar
        }
      });
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isLoading = false; // Cambiar el estado a no cargando
        });
      }
    }
  }

  // Función que se ejecuta cuando el texto de la búsqueda cambia
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase(); // Convertimos la búsqueda a minúsculas

    setState(() {
      _searchQuery = query; // Guardamos el término de búsqueda
      _offset = 0; // Restablecemos el offset al inicio
      _hasMore = true; // Permitimos seguir cargando personajes
      _characters.clear(); // Limpiamos la lista de personajes
    });

    _fetchCharacters(); // Realizamos la búsqueda
  }

  // Función para navegar a la página de cómics del personaje seleccionado
  void _navigateToComicsPage(int characterId, String characterName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicsPage(characterId: characterId, characterName: characterName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? const Text("Personajes de Marvel") // Título normal
            : TextField(
                controller: _searchController, // Campo de búsqueda
                decoration: const InputDecoration(
                  hintText: 'Buscar personaje',
                  border: InputBorder.none,
                ),
                autofocus: true, // Activar el autofocus para que el campo se seleccione automáticamente
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search), // Icono de búsqueda o cerrar búsqueda
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false; // Si estamos buscando, cerramos la búsqueda
                  _searchController.clear(); // Limpiamos el campo de búsqueda
                } else {
                  _isSearching = true; // Si no estamos buscando, activamos la búsqueda
                }
              });
            },
          ),
        ],
      ),
      drawer: const MenuLateral(), // Menú lateral
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Margen a los lados
        child: GridView.builder(
          controller: _scrollController, // Controlador de scroll
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Número de columnas en la cuadrícula
            crossAxisSpacing: 8, // Espacio entre columnas
            mainAxisSpacing: 8, // Espacio entre filas
            childAspectRatio: 0.7, // Relación de aspecto de cada celda
          ),
          itemCount: _characters.length + (_hasMore ? 1 : 0), // Número de elementos a mostrar, incluyendo el indicador de carga
          itemBuilder: (context, index) {
            if (index == _characters.length) {
              return const Center(child: CircularProgressIndicator()); // Indicador de carga al final
            }

            final character = _characters[index]; // Obtener personaje de la lista
            return GestureDetector(
              onTap: () => _navigateToComicsPage(character['id'], character['name']), // Al tocar un personaje, navegar a su página de cómics
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                      child: SizedBox(
                        width: double.infinity,
                        height: 150, // Tamaño fijo para todas las imágenes
                        child: Image.network(
                          character['imageUrl'], // Imagen del personaje
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5), // Espacio para evitar overflow
                  SizedBox(
                    height: 35, // Espacio fijo para el texto
                    child: Text(
                      character['name'], // Nombre del personaje
                      textAlign: TextAlign.center, // Alineación centrada
                      maxLines: 2, // Permite que el texto use hasta dos líneas
                      overflow: TextOverflow.ellipsis, // Si el texto es largo, se corta con "..."
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), // Estilo del texto
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}