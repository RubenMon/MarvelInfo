import 'package:flutter/material.dart';
import 'package:marvel_info/api/marvel_api_service.dart';
import 'package:marvel_info/screens/menuLateral.dart';
import 'package:marvel_info/screens/personajes_comics.dart';

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
  String _searchQuery = "";
  bool _isSearching = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _fetchCharacters();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
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
    _isDisposed = true;
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCharacters() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newCharacters = await marvelApi.fetchCharacters(
        offset: _offset,
        limit: _limit,
        nameStartsWith: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (_isDisposed) return;

      setState(() {
        if (_offset == 0) {
          _characters = newCharacters;
        } else {
          _characters.addAll(newCharacters);
        }

        _offset += _limit;

        if (newCharacters.length < _limit) {
          _hasMore = false;
        }
      });
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _searchQuery = query;
      _offset = 0;
      _hasMore = true;
      _characters.clear();
    });

    _fetchCharacters();
  }

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
            ? const Text("Personajes de Marvel")
            : TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar personaje',
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      drawer: const MenuLateral(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Margen a los lados
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
              return const Center(child: CircularProgressIndicator());
            }

            final character = _characters[index];
            return GestureDetector(
              onTap: () => _navigateToComicsPage(character['id'], character['name']),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 150, // Tamaño fijo para todas las imágenes
                        child: Image.network(
                          character['imageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5), // Espacio para evitar overflow
                  SizedBox(
                    height: 35, // Espacio fijo para el texto
                    child: Text(
                      character['name'],
                      textAlign: TextAlign.center,
                      maxLines: 2, // Permite que el texto use hasta dos líneas
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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