import 'package:flutter/material.dart';
import 'package:marvel_info/api/marvel_api_service.dart';
import 'package:marvel_info/screens/menuLateral.dart';

class ComicsPage extends StatefulWidget {
  final int characterId;
  final String characterName;

  const ComicsPage({super.key, required this.characterId, required this.characterName});

  @override
  _ComicsPageState createState() => _ComicsPageState();
}

class _ComicsPageState extends State<ComicsPage> {
  final MarvelApiService marvelApi = MarvelApiService();
  List<Map<String, dynamic>> _comics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComics();
  }

  Future<void> _fetchComics() async {
    try {
      final comics = await marvelApi.fetchComicsByCharacter(widget.characterId);
      setState(() {
        _comics = comics;
      });
    } catch (e) {
      // Manejar el error si es necesario
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cómics de ${widget.characterName}")),
      drawer: const MenuLateral(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _comics.isEmpty
              ? const Center(child: Text("No se encontraron cómics."))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _comics.length,
                  itemBuilder: (context, index) {
                    final comic = _comics[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          comic['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset("assets/images/placeholder.png"),
                        ),
                        title: Text(comic['title']),
                      ),
                    );
                  },
                ),
    );
  }
}