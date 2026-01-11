import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
      ),
      home: const PokemonListScreen(),
    );
  }
}

//
// 1st Screen: Pokemon List Screen
//
class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemons = [];
  bool isLoading = false;
  bool isGridView = false;
  int offset = 0;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    GetData();
  }

  Future<void> GetData() async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
    });

    final response = Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset');
    try {
      final data = await http.get(response);
      final jsonData = jsonDecode(data.body);
      setState(() {
        pokemons.addAll(jsonData['results']);
        offset += limit;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int getPokemonNumber(String url) {
    final parts = url.split('/');
    return int.parse(parts[parts.length - 2]);
  }

  String getPokemonImageUrl(int number) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$number.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: pokemons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: isGridView ? _buildGridView() : _buildListView(),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                if (!isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: GetData,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Load More Pokémon'),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: pokemons.length,
      itemBuilder: (context, index) {
        final pokemonNumber = getPokemonNumber(pokemons[index]['url']);
        final imageUrl = getPokemonImageUrl(pokemonNumber);
        
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonDetailScreen(
                name: pokemons[index]['name'],
                url: pokemons[index]['url'],
                number: pokemonNumber,
              ),
            ),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            child: ListTile(
              leading: Hero(
                tag: 'pokemon-$pokemonNumber',
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images.png',
                      width: 60,
                      height: 60,
                    );
                  },
                ),
              ),
              title: Text(
                pokemons[index]['name'].toString().toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('#${pokemonNumber.toString().padLeft(3, '0')}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: pokemons.length,
      itemBuilder: (context, index) {
        final pokemonNumber = getPokemonNumber(pokemons[index]['url']);
        final imageUrl = getPokemonImageUrl(pokemonNumber);
        
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonDetailScreen(
                name: pokemons[index]['name'],
                url: pokemons[index]['url'],
                number: pokemonNumber,
              ),
            ),
          ),
          child: Card(
            elevation: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'pokemon-$pokemonNumber',
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images.png',
                        width: 100,
                        height: 100,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '#${pokemonNumber.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  pokemons[index]['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//
// 2nd Screen: Pokemon Detail Screen
//
class PokemonDetailScreen extends StatefulWidget {
  final String name;
  final String url;
  final int number;

  const PokemonDetailScreen({
    super.key,
    required this.name,
    required this.url,
    required this.number,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic>? pokemonDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemonDetail();
  }

  Future<void> fetchPokemonDetail() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final data = jsonDecode(response.body);
      setState(() {
        pokemonDetail = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching detail: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.pink;
      case 'fighting':
        return Colors.red;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.lightBlue;
      case 'bug':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade400,
                          Colors.red.shade200,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '#${widget.number.toString().padLeft(3, '0')}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Hero(
                          tag: 'pokemon-${widget.number}',
                          child: Image.network(
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${widget.number}.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images.png',
                                width: 200,
                                height: 200,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Types
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pokemonDetail!['types'].map<Widget>((type) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: getTypeColor(type['type']['name']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type['type']['name'].toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Base Stats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...pokemonDetail!['stats'].map<Widget>((stat) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stat['stat']['name']
                                          .toString()
                                          .toUpperCase()
                                          .replaceAll('-', ' '),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${stat['base_stat']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: stat['base_stat'] / 255,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red.shade400,
                                  ),
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  // Physical Stats
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                          'Height',
                          '${(pokemonDetail!['height'] / 10).toStringAsFixed(1)} m',
                          Icons.height,
                        ),
                        _buildInfoCard(
                          'Weight',
                          '${(pokemonDetail!['weight'] / 10).toStringAsFixed(1)} kg',
                          Icons.monitor_weight,
                        ),
                      ],
                    ),
                  ),
                  
                  // Abilities
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Abilities',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: pokemonDetail!['abilities'].map<Widget>((ability) {
                            return Chip(
                              label: Text(
                                ability['ability']['name']
                                    .toString()
                                    .toUpperCase()
                                    .replaceAll('-', ' '),
                              ),
                              backgroundColor: Colors.grey.shade200,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.red.shade400),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}