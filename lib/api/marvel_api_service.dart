import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class MarvelApiService {
  // Claves de la API de Marvel
  final String publicKey = "f5615ebf7a9698a9fc6cc907ace261bc";
  final String privateKey = "ee13a061765a7dbe08fcd3b48768d057320f79b9";
  final String baseUrl = "https://gateway.marvel.com/v1/public";

  // Método para generar el hash necesario para autenticarse en la API
  String _generateHash(String timestamp) {
    final input = timestamp + privateKey + publicKey;
    return md5.convert(utf8.encode(input)).toString();
  }

  // Método para obtener una lista de personajes de Marvel
  Future<List<Map<String, dynamic>>> fetchCharacters(
      {int offset = 0, int limit = 30, String? nameStartsWith}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(timestamp);

    // Construcción de la URL con los parámetros de consulta
    final url = Uri.parse(
      "$baseUrl/characters?ts=$timestamp&apikey=$publicKey&hash=$hash&offset=$offset&limit=$limit"
      "${nameStartsWith != null ? '&nameStartsWith=$nameStartsWith' : ''}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data']['results'] as List;

        return results.map((character) {
          final thumbnail = character['thumbnail'];
          final imageUrl = "${thumbnail['path']}.${thumbnail['extension']}";
          return {
            'id': character['id'],  // Identificador único del personaje
            'name': character['name'],  // Nombre del personaje
            'imageUrl': imageUrl.contains("image_not_available")
                ? "https://imgs.search.brave.com/B7-gbgoCYR2WLCefSZE4gZAztX8yJNp-Uxr624Br-RQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvcmVk/LW1hcnZlbC1pcGhv/bmUtdGl0bGUtbG9n/by1weXA1ZWl0NW80/OWpuenJyLmpwZw"
                : imageUrl,  // Imagen del personaje
          };
        }).toList();
      } else {
        throw Exception('Error al obtener personajes: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  // Método para obtener los cómics de un personaje específico
  Future<List<Map<String, dynamic>>> fetchComicsByCharacter(int characterId,
      {int offset = 0, int limit = 30}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(timestamp);

    final url = Uri.parse(
      "$baseUrl/characters/$characterId/comics?ts=$timestamp&apikey=$publicKey&hash=$hash&offset=$offset&limit=$limit",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data']['results'] as List;

        return results.map((comic) {
          final thumbnail = comic['thumbnail'];
          final imageUrl = "${thumbnail['path']}.${thumbnail['extension']}";
          return {
            'title': comic['title'],  // Título del cómic
            'imageUrl': imageUrl.contains("image_not_available")
                ? "https://imgs.search.brave.com/B7-gbgoCYR2WLCefSZE4gZAztX8yJNp-Uxr624Br-RQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvcmVk/LW1hcnZlbC1pcGhv/bmUtdGl0bGUtbG9n/by1weXA1ZWl0NW80/OWpuenJyLmpwZw"
                : imageUrl,  // Imagen del cómic
          };
        }).toList();
      } else {
        throw Exception('Error al obtener cómics: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  // Método para obtener un juego de adivinanza de personajes
  Future<Map<String, dynamic>> fetchGame({int limit = 4}) async {
    final characters = await fetchCharacters(limit: 100);

    // Filtrar personajes con imágenes válidas
    final validCharacters = characters.where((character) {
      return character['imageUrl'].isNotEmpty &&
             !character['imageUrl'].contains("image_not_available") &&
             !character['imageUrl'].contains("B7-gbgoCYR2WLCefSZE4gZAztX8yJNp-Uxr624Br-RQ");
    }).toList();

    if (validCharacters.isEmpty) {
      throw Exception('No se encontraron personajes con imágenes válidas.');
    }

    // Seleccionar un personaje correcto al azar
    final correctCharacter = validCharacters[DateTime.now().millisecond % validCharacters.length];
    
    // Obtener nombres de personajes para opciones del juego
    final options = validCharacters.map((character) => character['name']).toList();
    options.shuffle();  // Mezclar las opciones
    final selectedOptions = options.take(limit).toList();

    // Asegurar que la respuesta correcta esté entre las opciones
    if (!selectedOptions.contains(correctCharacter['name'])) {
      selectedOptions[0] = correctCharacter['name'];
    }

    return {
      'correctCharacter': correctCharacter,  // Personaje correcto
      'options': selectedOptions,  // Opciones del juego
    };
  }
}