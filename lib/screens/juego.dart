import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marvel_info/screens/menuLateral.dart';
import 'package:marvel_info/api/marvel_api_service.dart';

// Clase CharacterGame que representa el juego de adivinanza de personajes de Marvel
class CharacterGame extends StatefulWidget {
  const CharacterGame({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CharacterGameState createState() => _CharacterGameState();
}

// Estado del juego de adivinanza
class _CharacterGameState extends State<CharacterGame> {
  final MarvelApiService _marvelApiService = MarvelApiService(); // Instancia del servicio de la API de Marvel
  Map<String, dynamic>? _currentCharacter; // Personaje actual
  List<String> _options = []; // Opciones de respuesta
  bool _isChecking = false; // Indicador de verificación de respuesta
  bool _isLoading = true; // Indicador de carga de datos
  Timer? _timer; // Temporizador para futuras funcionalidades

  @override
  void initState() {
    super.initState();
    _fetchNewGame(); // Cargar un nuevo personaje al iniciar
  }

  // Método para obtener un nuevo personaje y opciones
  Future<void> _fetchNewGame() async {
    setState(() {
      _isLoading = true;
      _currentCharacter = null;
    });

    try {
      final gameData = await _marvelApiService.fetchGame();
      if (gameData['correctCharacter'] != null) {
        setState(() {
          _currentCharacter = gameData['correctCharacter']; // Asignar el personaje correcto
          _options = List<String>.from(gameData['options']); // Asignar opciones de respuesta
          _isChecking = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // Muestra un mensaje si no hay personajes válidos disponibles
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron personajes válidos.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Muestra un mensaje de error en caso de fallo al cargar los datos
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los datos del juego. Intenta de nuevo más tarde.')),
      );
    }
  }

  // Método para verificar si la respuesta seleccionada es correcta
  void _checkAnswer(String userGuess) {
    setState(() {
      _isChecking = true;
    });

    if (userGuess.toLowerCase().trim() == _currentCharacter?['name'].toLowerCase().trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Correcto! Era ${_currentCharacter?['name']} 🎉')),
      );
      _fetchNewGame(); // Cargar un nuevo personaje si la respuesta es correcta
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador al cerrar la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adivina el Personaje Marvel')),
      drawer: const MenuLateral(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar cargando
          : _currentCharacter == null
              ? const Center(child: Text("Error al cargar los datos del juego.")) // Mensaje de error si no hay datos
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
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 100, color: Colors.grey);
                                  },
                                )
                              : const Icon(Icons.person, size: 100, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
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