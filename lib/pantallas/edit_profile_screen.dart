import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/imgur.dart';
import '../services/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  Uint8List? _image;
  bool isPasswordUser = false;
  String? photoURL;

  @override
  void initState() {
    super.initState();
    nameController.text = user.displayName ?? '';
    emailController.text = user.email ?? '';
    photoURL = user.photoURL;
    isPasswordUser = user.providerData.any((p) => p.providerId == 'password');
  }

  void updateProfile() async {
    try {
      String? uploadedUrl;

      if (_image != null) {
        uploadedUrl = await ImgurUploader.uploadImage(_image!);
      }

      await user.updateDisplayName(nameController.text);

      if (uploadedUrl != null) {
        await user.updatePhotoURL(uploadedUrl);
        photoURL = uploadedUrl;
        await FirebaseFirestore.instance
            .collection('userProfile')
            .doc(user.uid)
            .set({'photoUrl': uploadedUrl}, SetOptions(merge: true));
      }

      await user.reload();

      setState(() {
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado exitosamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar perfil')),
      );
    }
  }

  void logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 64,
                            backgroundImage: _image != null
                                ? MemoryImage(_image!)
                                : NetworkImage(photoURL ??
                                'https://www.gravatar.com/avatar/placeholder.png?d=mp')
                            as ImageProvider,
                          ),
                          if (isPasswordUser)
                            Positioned(
                              child: GestureDetector(
                                onTap: selectImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre de usuario',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: emailController,
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (isPasswordUser)
                              ElevatedButton.icon(
                                onPressed: () {
                                  FirebaseAuth.instance.sendPasswordResetEmail(
                                    email: user.email!,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Correo de recuperación enviado'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.lock_reset, size: 22),
                                label: const Text(
                                  'Solicitar cambio de contraseña',
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade50,
                                  minimumSize: const Size.fromHeight(50),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: updateProfile,
                      icon: const Icon(Icons.save, size: 25),
                      label: const Text('Guardar cambios', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen.shade100,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: logOut,
              icon: const Icon(Icons.logout, size: 25),
              label: const Text('Cerrar sesión', style: TextStyle(fontSize: 18)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
