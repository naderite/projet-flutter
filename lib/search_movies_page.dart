import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/movie_model.dart';
import 'services/movie_api_service.dart';

class SearchMoviesPage extends StatefulWidget {
  const SearchMoviesPage({super.key});

  @override
  State<SearchMoviesPage> createState() => _SearchMoviesPageState();
}

class _SearchMoviesPageState extends State<SearchMoviesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMovies() async {
    setState(() => _isLoading = true);

    // Ici on récupère des films "popular" ou "random" via ton service.
    final movies = await MovieApiService.getPopularMovies();

    setState(() {
      _movies = movies;
      _isLoading = false;
    });
  }

  Future<void> _onSearchSubmitted(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    final movies = await MovieApiService.searchMovies(query);

    setState(() {
      _movies = movies;
      _isLoading = false;
    });
  }

  Future<bool> _isMovieAlreadyAdded(String movieId) async {
    final doc = await FirebaseFirestore.instance
        .collection('movies')
        .doc(movieId)
        .get();
    return doc.exists;
  }

  Future<void> _addMovie(Movie movie) async {
    try {
      await FirebaseFirestore.instance
          .collection('movies')
          .doc(movie.id)
          .set(movie.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${movie.title} added to movies')),
      );

      setState(() {}); // pour rafraîchir les FutureBuilder (ADDED)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding movie: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101015),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C23),
        elevation: 0,
        title: const Text(
          'Search Movies',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchField(),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: _movies.isEmpty
                  ? const Center(
                child: Text(
                  'No movies found',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return FutureBuilder<bool>(
                    future: _isMovieAlreadyAdded(movie.id),
                    builder: (context, snapshot) {
                      final added = snapshot.data ?? false;
                      return _buildMovieRow(movie, added);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C23),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF0D6EFD),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: TextField(
          controller: _searchController,
          onSubmitted: _onSearchSubmitted,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search movie',
            hintStyle: TextStyle(color: Colors.grey),
            icon: Icon(Icons.search, color: Colors.grey),
          ),
        ),
      ),
    );
  }


  Widget _buildMovieRow(Movie movie, bool added) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C23),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Poster
          Container(
            width: 80,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[800],
              image: movie.posterUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(movie.posterUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Infos film
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // Ligne note (⭐ + note)
                Row(
                  children: [
                    const Icon(
                      Icons.star_border,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movie.vote == 0 ? 'N/A' : movie.vote.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Ligne date (📅 + année)
                if (movie.year != 0)
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.year.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Bouton ADD / ADDED
          added
              ? Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 1.2),
            ),
            child: const Text(
              'ADDED',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              : GestureDetector(
            onTap: () => _addMovie(movie),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red, width: 1.2),
              ),
              child: const Text(
                'ADD',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




}
