import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 🔹 Firebase Core
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Necesario para usar código async antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Intentar inicializar Firebase (si no hay proyecto configurado,
  // simplemente seguirá la app igualmente).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error al inicializar Firebase (modo demo): $e');
  }

  runApp(const CatalogoPeliculasApp());
}

class CatalogoPeliculasApp extends StatelessWidget {
  const CatalogoPeliculasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151821),
        title: const Text(
          'Catálogo de Películas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const _HeroSection(),
          const SizedBox(height: 16),

          // LISTA DE PELÍCULAS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...movies.map((m) => MovieCard(movie: m)),

                const SizedBox(height: 20),

                // ---------------------------
                // SECCIÓN NUEVA: PETICIÓN HTTP
                // ---------------------------
                const _PokemonSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Movie {
  final String title;
  final String genre;
  final String year;
  final double rating;
  final String duration;

  Movie({
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.duration,
  });
}

final List<Movie> movies = [
  Movie(
    title: 'Inception',
    genre: 'Ciencia ficción',
    year: '2010',
    rating: 8.8,
    duration: '2h 28m',
  ),
  Movie(
    title: 'Interstellar',
    genre: 'Ciencia ficción / Drama',
    year: '2014',
    rating: 8.6,
    duration: '2h 49m',
  ),
  Movie(
    title: 'The Dark Knight',
    genre: 'Acción / Crimen',
    year: '2008',
    rating: 9.0,
    duration: '2h 32m',
  ),
  Movie(
    title: 'Whiplash',
    genre: 'Drama / Música',
    year: '2014',
    rating: 8.5,
    duration: '1h 47m',
  ),
];

// ---------------------------------------------------------------------
// HERO CON IMAGEN DE FONDO
// ---------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home_background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black54,
                BlendMode.darken,
              ),
            ),
          ),
        ),
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x802b2146),
                Color(0x80151821),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bienvenido a tu catálogo',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Catálogo de Películas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hello World',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Widgets: Text, Row, Column, Stack y Container.',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// NUEVA SECCIÓN – PETICIÓN HTTP A POKEAPI
// ---------------------------------------------------------------------

class _PokemonSection extends StatelessWidget {
  const _PokemonSection({super.key});

  Future<String> fetchPokemon() async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['name'];
    } else {
      return 'Error al obtener datos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchPokemon(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Text(
            'No se pudo cargar el Pokémon',
            style: TextStyle(color: Colors.white),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF181b24),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Pokémon desde API: ${snapshot.data!.toUpperCase()}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// CARD DE PELÍCULA
// ---------------------------------------------------------------------

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF181b24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genre,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.year,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.duration,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
