import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CollectionReference news =
      FirebaseFirestore.instance.collection('news');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // READ :
  Stream<QuerySnapshot> getNewsStream(String category) {
    final newsStream = news
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots();
    return newsStream;
  }

  Stream<QuerySnapshot> getNewsStreamSearch(String search) {
    final newsStream = news
        .where('title', isEqualTo: search)
        .orderBy('date', descending: true)
        .snapshots();
    return newsStream;
  }

  Stream<DocumentSnapshot> getNewsStreamID(String id) {
    final newsStream =
        FirebaseFirestore.instance.collection('news').doc(id).snapshots();
    return newsStream;
  }

  Future<String?> getUserRoleByEmail(String email) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (snapshot.docs.isNotEmpty) {
        dynamic role = snapshot.docs[0]['role'];
        return role.toString();
      } else {
        return null;
      }
    } catch (error) {
      print('Error getting user name: $error');
      return null;
    }
  }

  // CREATE
  Future<void> addUserDetail(String name, String email, String password) {
    return users.add({
      "name": name,
      "email": email,
      "password": password,
      "role": 0,
    });
  }

  Future<String> uploadImage(String childName, Uint8List image) async {
    Reference ref = storage.ref().child(childName);
    UploadTask task = ref.putData(image);
    TaskSnapshot snapshot = await task;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> addNews(
      String title, String content, String category, Uint8List file) async {
    String res = "Error";
    try {
      String imageUrl = await uploadImage('newsImage-${Timestamp.now()}', file);
      await news.add({
        "title": title,
        "content": content,
        "category": category,
        "createdBy": "Admin",
        "image": imageUrl,
        "date": DateTime.now(),
      });
      res = "News Added";
    } catch (e) {
      print(e.toString());
      res = "Error" + e.toString();
    }
    return res;
  }

  // UPDATE
  Future<String> updateNews(String docId, String title, String content,
      String category, Uint8List file) async {
    String res = "Error";
    try {
      DocumentSnapshot oldData = await news.doc(docId).get();
      String oldImageUrl = oldData['image'];
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        Reference oldImageRef = storage.refFromURL(oldImageUrl);
        await oldImageRef.delete();
      }
      String imageUrl = await uploadImage('newsImage-${Timestamp.now()}', file);
      Map<String, dynamic> updatedData = {
        "title": title,
        "content": content,
        "category": category,
        "createdBy": "Admin",
        "image": imageUrl,
        "date": DateTime.now(),
      };
      await news.doc(docId).update(updatedData);

      res = "News Updated";
    } catch (e) {
      print(e.toString());
      res = "Error" + e.toString();
    }
    return res;
  }

  //DELETE
  Future<void> deleteNews(String docId) async {
    DocumentSnapshot oldData = await news.doc(docId).get();
    String oldImageUrl = oldData['image'];
    print(oldImageUrl);
    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      Reference oldImageRef = storage.refFromURL(oldImageUrl);
      await oldImageRef.delete();
    }
    return news.doc(docId).delete();
  }
}
