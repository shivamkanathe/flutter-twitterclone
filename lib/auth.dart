import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

CollectionReference usercollection =
    FirebaseFirestore.instance.collection('users');
CollectionReference tweetcollection =
    FirebaseFirestore.instance.collection('tweets');
StorageReference tweetpictures =
    FirebaseStorage.instance.ref().child('tweetpictures');
