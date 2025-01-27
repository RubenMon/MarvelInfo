import 'package:flutter/material.dart';
import 'package:marvel_info/api/marvel_api_service.dart';

class PersonajesMarvel extends StatefulWidget {
  const PersonajesMarvel({super.key});

  @override
  _PersonajesMarvelState createState() => _PersonajesMarvelState();
}

class _PersonajesMarvelState extends State<PersonajesMarvel> {
  final MarvelApiService marvelApi = MarvelApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _characters = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 30;
  String _searchQuery = ""; // Texto actual del buscador
  bool _isSearching = false; // Estado para mostrar/ocultar el buscador

  @override
  void initState() {
    super.initState();
    _fetchCharacters();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchCharacters();
      }
    });

    _searchController.addListener(() {
      _onSearchChanged();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCharacters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newCharacters = await marvelApi.fetchCharacters(
        offset: _offset,
        limit: _limit,
        nameStartsWith: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        if (_offset == 0) {
          // Si estamos en la primera página, reemplazamos los personajes
          _characters = newCharacters;
        } else {
          // Si no, añadimos más personajes
          _characters.addAll(newCharacters);
        }

        _offset += _limit;

        if (newCharacters.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      // Manejar el error aquí si es necesario
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      // Si el buscador está vacío, reiniciamos la lista y mostramos todos los personajes
      setState(() {
        _searchQuery = "";
        _offset = 0; // Reiniciar la paginación
        _hasMore = true; // Permitir más personajes
        _characters.clear(); // Limpiar la lista
      });

      _fetchCharacters(); // Realizar nueva llamada para obtener todos los personajes
    } else {
      // Si hay texto en el buscador, buscar personajes por nombre
      setState(() {
        _searchQuery = query;
        _offset = 0; // Reiniciar la paginación
        _hasMore = true; // Permitir más personajes
        _characters.clear(); // Limpiar la lista
      });

      _fetchCharacters(); // Realizar llamada filtrada
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_isSearching
            ? const Text("Personajes de Marvel")
            : TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar personaje',
                  hintStyle: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                cursorColor: Colors.white,
                autofocus: true,
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear(); // Limpiar el campo de búsqueda
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7,
          ),
          itemCount: _characters.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _characters.length) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final character = _characters[index];
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      character['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset("assets/images/placeholder.png"),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  character['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}