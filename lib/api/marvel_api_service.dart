import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class MarvelApiService {
  final String publicKey = "f5615ebf7a9698a9fc6cc907ace261bc";
  final String privateKey = "ee13a061765a7dbe08fcd3b48768d057320f79b9";
  final String baseUrl = "https://gateway.marvel.com/v1/public";

  /// Genera el hash necesario para autenticar las solicitudes
  String _generateHash(String timestamp) {
    final input = timestamp + privateKey + publicKey;
    return md5.convert(utf8.encode(input)).toString();
  }

  /// Obtiene la lista de personajes desde la API de Marvel
  Future<List<Map<String, dynamic>>> fetchCharacters() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(timestamp);

    final url = Uri.parse(
      "$baseUrl/characters?ts=$timestamp&apikey=$publicKey&hash=$hash",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data']['results'] as List;

        // Mapeamos los resultados para obtener solo la información necesaria
        return results.map((character) {
          final thumbnail = character['thumbnail'];
          final imageUrl = "${thumbnail['path']}.${thumbnail['extension']}";
          return {
            'name': character['name'],
            'imageUrl': imageUrl,
          };
        }).toList();
      } else {
        throw Exception('Error al obtener personajes: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }
}

/// Prueba la función fetchCharacters y muestra los resultados en consola
void main() async {
  final marvelApi = MarvelApiService();

  try {
    // Llama a la función fetchCharacters
    final characters = await marvelApi.fetchCharacters();

    // Imprime los datos obtenidos
    print("Personajes obtenidos:");
    for (var character in characters) {
      print("Nombre: ${character['name']}, Imagen: ${character['imageUrl']}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
