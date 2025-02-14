import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  bool _isEditing = false;
  File? _image;
  String? _userProfilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar los datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          // 🔥 Agregamos setState para actualizar la UI
          _fullNameController.text = userData['fullName'] ?? '';
          _professionController.text = userData['profession'] ?? '';
          _birthDateController.text = userData['birthDate'] ?? '';
          _userProfilePicUrl = userData['profilePicUrl'];
        });
      }
    }
  }

  // Seleccionar imagen desde la galería
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Subir imagen a Firebase Storage
  Future<String?> _uploadProfilePic(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pics/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(image);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir la image: $e");
      return null;
    }
  }

  Future<void> _saveUserData() async {
    print("HOLAAAA2222");
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? profilePicUrl = _image != null
          ? await _uploadProfilePic(_image!)
          : _userProfilePicUrl;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': _fullNameController.text,
        'profession': _professionController.text,
        'birthDate': _birthDateController.text,
        'profilePicUrl': profilePicUrl ?? _userProfilePicUrl,
      }, SetOptions(merge: true));

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Perfil de Usuario",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700, // Tonalidad de verde más oscura
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null
                      ? FileImage(_image!) as ImageProvider
                      : (_userProfilePicUrl != null &&
                              _userProfilePicUrl!.isNotEmpty
                          ? NetworkImage(
                              _userProfilePicUrl!) // Carga desde Firebase Storage
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider),
                  child: _image == null &&
                          (_userProfilePicUrl == null ||
                              _userProfilePicUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    'Cambiar foto de perfil',
                    style: TextStyle(color: Colors.green),
                  ),
                ),

                // Nombre completo
                TextFormField(
                  controller: _fullNameController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: "Nombre Completo",
                    labelStyle: TextStyle(color: Colors.green),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade700),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade300),
                    ),
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
                const SizedBox(
                  height: 20.0,
                ),
                // Profesión
                TextFormField(
                  controller: _professionController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: "Profesión",
                    labelStyle: TextStyle(color: Colors.green),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade700),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade300),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Profesion no puede estar vacía.";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                // Fecha de nacimiento
                TextFormField(
                  controller: _birthDateController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: "Fecha de Nacimiento",
                    labelStyle: TextStyle(color: Colors.green),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade700),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade300),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "La Fecha no puede estar vacía.";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Botón para editar o guardar
                _isEditing
                    ? ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveUserData();
                            print("HOLAAAA");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade700,
                        ),
                        child: const Text('Guardar Cambios'),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green.shade500,
                        ),
                        child: const Text('Editar Perfil'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
