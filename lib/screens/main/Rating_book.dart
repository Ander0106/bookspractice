import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

class RateBook extends StatefulWidget {
  final String title;
  final String author;
  final String imageUrl;
  const RateBook(
      {super.key,
      required this.title,
      required this.author,
      required this.imageUrl});

  @override
  State<RateBook> createState() => _RateBookState();
}

class _RateBookState extends State<RateBook> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  Future<void> _saveReview() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes iniciar sesión para calificar.")),
      );
      return;
    }

    Map<String, dynamic> reviewData = {
      'userId': user.uid,
      'title': widget.title,
      'author': widget.author,
      'imageUrl': widget.imageUrl,
      'rating': _rating,
      'review': _reviewController.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('mislibros').add(reviewData);

      _showMessage("Reseña guardada correctamente, verifique en mis libros. ");

      setState(() {
        _reviewController.clear();
        _rating = 0.0;
      });
      if (mounted) {
        Navigator.pop(context); // Cierra la pantalla de calificación RateBook
        context.go('/home'); // Navega al home, si estás usando GoRouter
      }
    } catch (e) {
      _showMessage("Error al guardar la reseña: $e", isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calificar Libro",
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  widget.imageUrl,
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  "Autor: ${widget.author}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // ⭐ Calificador de estrellas
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                if (_rating == 0) // Si no hay calificación, muestra advertencia
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Selecciona una calificación.",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _reviewController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Escribe tu reseña",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "La reseña no puede estar vacía.";
                    } else if (value.trim().length < 10) {
                      return "La reseña debe tener al menos 10 caracteres.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Fondo verde
                    foregroundColor: Colors.white, // Texto blanco
                  ),
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      if (_rating == 0) {
                        _showMessage("Debes seleccionar una calificación.",
                            isError: true);
                      } else {
                        _saveReview();
                        //   Navigator.of(context).pop();
                        //   context.go('/home');
                      }
                    }
                  },
                  child: const Text("Calificar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
