import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marvel_info/screens/menuLateral.dart';
import 'package:marvel_info/api/marvel_api_service.dart';

class CharacterGame extends StatefulWidget {
  const CharacterGame({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CharacterGameState createState() => _CharacterGameState();
}

class _CharacterGameState extends State<CharacterGame> {
  final MarvelApiService _marvelApiService = MarvelApiService();
  Map<String, dynamic>? _currentCharacter;
  List<String> _options = [];
  bool _isChecking = false;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchNewGame();
  }

  Future<void> _fetchNewGame() async {
    setState(() {
      _isLoading = true;
      _currentCharacter = null;
    });

    try {
      final gameData = await _marvelApiService.fetchGame();
      if (gameData['correctCharacter'] != null) {
        setState(() {
          _currentCharacter = gameData['correctCharacter'];
          _options = List<String>.from(gameData['options']);
          _isChecking = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron personajes válidos.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los datos del juego. Intenta de nuevo más tarde.')),
      );
    }
  }

  void _checkAnswer(String userGuess) {
    setState(() {
      _isChecking = true;
    });

    if (userGuess.toLowerCase().trim() == _currentCharacter?['name'].toLowerCase().trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Correcto! Era ${_currentCharacter?['name']} 🎉')),
      );
      _fetchNewGame();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adivina el Personaje Marvel')),
      drawer: const MenuLateral(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentCharacter == null
              ? const Center(child: Text("Error al cargar los datos del juego."))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 400,
                          height: 350,
                          child: _currentCharacter!['imageUrl'] != null && _currentCharacter!['imageUrl'].isNotEmpty
                              ? Image.network(
                                  _currentCharacter!['imageUrl'],
                                  fit: BoxFit.cover, // Ajusta la imagen correctamente
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 100, color: Colors.grey);
                                  },
                                )
                              : const Icon(Icons.person, size: 100, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20), // Espaciado inferior
                      const Text('¿Quién es este personaje?', style: TextStyle(fontSize: 18)),
                      ..._options.map(
                        (option) => ElevatedButton(
                          onPressed: () => _checkAnswer(option),
                          child: Text(option),
                        ),
                      ),
                      if (_isChecking)
                        Column(
                          children: [
                            Text('Incorrecto: Era ${_currentCharacter?['name']} 😢'),
                            ElevatedButton(
                              onPressed: _fetchNewGame,
                              child: const Text('Siguiente'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}