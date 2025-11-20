
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class StorageServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instanceFor( //instance
    app:  FirebaseDatabase.instance.app, 
    databaseURL: 'https://attendance-app-4fe20-default-rtdb.asia-southeast1.firebasedatabase.app/', // database url yg di ambil dari realtime database
  ).ref(); // ref() untuk mengakses root database


  // upload photo to firebase realtime database as Base64(string) =>namanya
  Future <String> uploadAttendancePhoto(String localPath, String photoType) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not Authenticated');

      final file = File(localPath);
      // compress image to mengurangi size file (important for realtime database)
      final compressBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 600,
        quality: 70
      );

      if (compressBytes == null) {
        throw Exception('Failed to compress image');
      }

      // convert to base64
      final base64Image = base64Encode(compressBytes);

      // create a unique key for the photo
      final photoKey = '${DateTime.now().millisecondsSinceEpoch}_$photoType';

      // save to realtime database
      await _database
        .child('attendance_photos')
        .child(user.uid)
        .child(photoKey)
        .set(
        {
           'data': base64Image,
          'timestamp': ServerValue.timestamp,
          'type': photoType
        }
        );

  // return the key as reference
      return photoKey;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  //  get photo from firebase realtime database
  Future<String?> getPhotoBase64(String photokey) async{
    try {
      final user = _auth.currentUser; //current user adalah user yg sedang login
      if (user == null) return null;

      final snapshot = await _database
        .child('attendance_photos')
        .child(user.uid)  //uid adalah user id dari firebase auth
        .child(photokey) 
        .child('data')
        .get();

        if (snapshot.exists) {
          return snapshot.value as String; // untuk mengembalikan data dalam bentuk string
         }

         return null; // tidak menampilkan apapun
    } catch (e) {
      return null;
    }
  }

// delete photo from firebase realtime database
  Future<void> deletePhoto(String photokey) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      await _database
          .child('attendance photos')
          .child(user.uid)
          .child(photokey)
          .remove();

    } catch (e) {
      // ignore id doesn't exist
    }
  }
}
