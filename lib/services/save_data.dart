import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {

  Future<String> uploadImgToStorage(String child, Uint8List file) async {
    Reference ref = _storage.ref().child(child);
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    await snapshot.ref.getDownloadURL();
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<String> saveData({required Uint8List file}) async {
    String res = "Some error occured";
    try {
      String photoUrl = await uploadImgToStorage('profileImg', file);
      await _firestore.collection('userProfile').add({'photoUrl': photoUrl});
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
