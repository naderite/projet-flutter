import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test/screens/home/details.dart';
import 'package:test/screens/home/user_home.dart';
import 'package:test/services/favorite_movie.dart';
import '../../services/user_service.dart';
import '../../services/movie_service.dart';
import '../../models/movie.dart';
import 'package:test/screens/home/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String imgurl =
      "https://www.shutterstock.com/image-vector/male-avatar-profile-picture-vector-260nw-203739001.jpg";
  String name = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final data = await UserService().getCurrentUserData();
    if (data != null) {
      setState(() {
        name = data["displayName"] ?? "";
        imgurl = data["photoURL"] ?? imgurl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundImage: NetworkImage(imgurl)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $name",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      "Let’s stream your favorite movie",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92929D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add to your collections",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final moviesAppState = context
                            .findAncestorStateOfType<UserHomeState>();
                        if (moviesAppState != null) {
                          moviesAppState.setState(() {
                            moviesAppState.index = 1;
                          });
                        }
                      },

                      child: const Text(
                        "See All",
                        style: TextStyle(color: Color(0xFFEB2F3D)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 260,
                  child: StreamBuilder<List<Movie>>(
                    stream: MovieService().getMovies(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final movies = snapshot.data!;

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) =>
                            _movieCard(context, movies[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "your favorite movies",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final moviesAppState = context
                            .findAncestorStateOfType<UserHomeState>();
                        if (moviesAppState != null) {
                          moviesAppState.setState(() {
                            moviesAppState.index = 2;
                          });
                        }
                      },

                      child: const Text(
                        "See All",
                        style: TextStyle(color: Color(0xFFEB2F3D)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 260,
                  child: StreamBuilder<List<Movie>>(
                    stream: FavoriteMovie().getFavoriteMovies(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final movies = snapshot.data!;

                      if (movies.isEmpty) {
                        return const Center(
                          child: Text(
                            "No favorites yet",
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) =>
                            _movieCard(context, movies[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "matching users",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},

                      child: const Text(
                        "See All",
                        style: TextStyle(color: Color(0xFFEB2F3D)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 120,
                  child: StreamBuilder<Map<String, List<String>>>(
                    stream: FavoriteMovie().getAllUsersFavorites(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allUsers = snapshot.data!;
                      final currentUserId = UserService().currentUserUid();
                      final currentFavorites = allUsers[currentUserId] ?? [];

                      if (currentFavorites.isEmpty) {
                        return const Center(
                          child: Text(
                            "Add favorites to get matches",
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final matches = <String>[];

                      allUsers.forEach((userId, favs) {
                        if (userId.toString().trim() ==
                            currentUserId.toString().trim()) {
                          print("Comparing: $userId with $currentUserId");

                          return;
                        }

                        int same = favs
                            .where((id) => currentFavorites.contains(id))
                            .length;

                        double percent = same / currentFavorites.length;

                        if (percent >= 0.75) {
                          matches.add(userId);
                        }
                      });

                      if (matches.isEmpty) {
                        return const Center(
                          child: Text(
                            "No matching users yet",
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final userId = matches[index];
                          return _matchingUserCard(userId);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _matchingUserCard(String userId) {
  return FutureBuilder(
    future: UserService().getUserDataById(userId), 
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox();

      final user = snapshot.data!;

      return Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                user["photoURL"] ??
                    "https://www.shutterstock.com/image-vector/male-avatar-profile-picture-vector-260nw-203739001.jpg",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user["displayName"] ?? "Unknown",
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    },
  );
}

Widget _movieCard(BuildContext context, Movie movie) {
  return Container(
    width: 150,
    margin: const EdgeInsets.only(right: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Details(
                      movieyear: movie.year,
                      title: movie.title,
                      movieimg: movie.imageUrl,
                      moviecategory: movie.category,
                      id: movie.id,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  movie.imageUrl,
                  height: 200,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(movie.category, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}
