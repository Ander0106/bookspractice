import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookService {
  static const String baseUrl = "https://reactnd-books-api.udacity.com";
  static const Map<String, String> headers = {
    "Authorization": "whatever-you-want", // Requerido por la API
    "Content-Type": "application/json"
  };

  /// 🔹 Obtener la lista de libros
  static Future<List<dynamic>> getBooks() async {
    final response =
        await http.get(Uri.parse('$baseUrl/books'), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('----------------------DATA');
      debugPrint("📚 Respuesta de la API: ${jsonEncode(data)}",
          wrapWidth: 1024);

      return data['books']; // Retorna la lista de libros
    } else {
      throw Exception("Error al obtener los libros");
    }
  }

  /// 🔹 Obtener un libro por ID
  static Future<Map<String, dynamic>> getBookById(String id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/books/$id'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener el libro");
    }
  }

  /// 🔹 Buscar libros
  static Future<List<dynamic>> searchBooks(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/search'),
      headers: headers,
      body: jsonEncode({"query": query, "maxResults": 10}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['books'];
    } else {
      throw Exception("Error en la búsqueda");
    }
  }

  /// 🔹 Actualizar el estado de un libro
  static Future<void> updateBookStatus(String id, String shelf) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: headers,
      body: jsonEncode({"shelf": shelf}),
    );
    if (response.statusCode != 200) {
      throw Exception("Error al actualizar el estado del libro");
    }
  }
}
