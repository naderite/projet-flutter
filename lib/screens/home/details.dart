import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Details extends StatefulWidget {
  final String title;
  final String movieimg;
  final double movieyear;
  final String moviecategory;
  final String id;

  const Details({
    super.key,
    required this.title,
    required this.movieimg,
    required this.movieyear,
    required this.moviecategory,
    required this.id,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  IconData icon = Icons.bookmark_border;
  bool isFavorite = false;
  Future<void> checkIfFavorite() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(widget.id)
        .get();

    setState(() {
      isFavorite = doc.exists;
      icon = doc.exists ? Icons.bookmark : Icons.bookmark_border;
    });
  }

  Future<void> addToFavorites() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("favorites")
          .doc(widget.id)
          .set({
            "title": widget.title,
            "image": widget.movieimg,
            "year": widget.movieyear,
            "category": widget.moviecategory,
            "addedAt": FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print("Error adding favorite: $e");
    }
  }

  Future<void> removeFromFavorites() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(widget.id)
        .delete();
  }

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121011),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Detail",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () async {
                if (isFavorite) {
                  await removeFromFavorites();
                  setState(() {
                    isFavorite = false;
                    icon = Icons.bookmark_border;
                  });
                } else {
                  await addToFavorites();
                  setState(() {
                    isFavorite = true;
                    icon = Icons.bookmark;
                  });
                }
              },
              icon: Icon(icon, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              child: Image.network(
                widget.movieimg,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "Release year: ${widget.movieyear}",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
