import 'package:book_review_final/widgets/card_book_presentation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../service/book_service.dart';
import 'Rating_book.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<List<dynamic>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = BookService.getBooks(); // Llamada a la API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Libros",
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
              context.go('/login'); // Redirigir al login
            },
            tooltip: "Cerrar sesión",
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay libros disponibles"));
          }

          final books = snapshot.data!;
          return GridView.builder(
            itemCount: books.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1 / 1.7),
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCardInfo(
                itmName: book['title'],
                itmAutor: book['authors']?.join(', ') ?? 'Autor desconocido',
                itmDescrip: book['description'],
                itmGenero: book['title'],
                itmImg: book['imageLinks']?['thumbnail'],
                //      'https://marketplace.canva.com/EAFutLMZJKs/1/0/1003w/canva-portada-libro-novela-suspenso-elegante-negro-wxuYB_sJtMw.jpg',
                onPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(book['title'] ?? 'Sin título'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              book['imageLinks']?['thumbnail'] ??
                                  'https://marketplace.canva.com/EAFutLMZJKs/1/0/1003w/canva-portada-libro-novela-suspenso-elegante-negro-wxuYB_sJtMw.jpg',
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              book['description'] ??
                                  'No hay descripción disponible.',
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Lógica para calificar el libro
                            print('Calificar libro');
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RateBook(
                                  title: book['title'] ?? 'Sin título',
                                  author: book['authors']?.join(', ') ??
                                      'Autor desconocido',
                                  imageUrl: book['imageLinks']?['thumbnail'] ??
                                      'https://marketplace.canva.com/EAFutLMZJKs/1/0/1003w/canva-portada-libro-novela-suspenso-elegante-negro-wxuYB_sJtMw.jpg',
                                ),
                              ),
                            );
                          },
                          child: const Text('Calificar'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
