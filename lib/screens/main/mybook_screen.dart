import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  Stream<QuerySnapshot> _getUserBooks() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('mislibros')
        .where('userId', isEqualTo: userId)
        //.orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mis Libros",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.greenAccent, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.go('/login');
            },
            tooltip: "Cerrar sesión",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUserBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // ⏳ Cargando...
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar los libros."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No has calificado ningún libro."));
          }

          var books = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: books.length,
            itemBuilder: (context, index) {
              var book = books[index];
              String title = book['title'];
              String author = book['author'];
              String imageUrl = book['imageUrl'];
              double rating = (book['rating'] as num).toDouble();
              String review = book['review'];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        imageUrl,
                        width: 70,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Autor: $author"),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Revie: $review",
                              style: const TextStyle(fontSize: 14),
                              softWrap: true,
                              overflow: TextOverflow
                                  .visible, // Permite que se expanda
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
