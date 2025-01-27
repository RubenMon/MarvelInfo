import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class MarvelApiService {
  final String publicKey = "f5615ebf7a9698a9fc6cc907ace261bc";
  final String privateKey = "ee13a061765a7dbe08fcd3b48768d057320f79b9";
  final String baseUrl = "https://gateway.marvel.com/v1/public";

  String _generateHash(String timestamp) {
    final input = timestamp + privateKey + publicKey;
    return md5.convert(utf8.encode(input)).toString();
  }

  Future<List<Map<String, dynamic>>> fetchCharacters(
      {int offset = 0, int limit = 30, String? nameStartsWith}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _generateHash(timestamp);

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
            'name': character['name'],
            'imageUrl': imageUrl.contains("image_not_available")
                ? "https://imgs.search.brave.com/B7-gbgoCYR2WLCefSZE4gZAztX8yJNp-Uxr624Br-RQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93YWxs/cGFwZXJzLmNvbS9p/bWFnZXMvaGQvcmVk/LW1hcnZlbC1pcGhv/bmUtdGl0bGUtbG9n/by1weXA1ZWl0NW80/OWpuenJyLmpwZw"
                : imageUrl,
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
