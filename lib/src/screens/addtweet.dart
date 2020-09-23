import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food/auth.dart';
import 'package:food/src/varibles.dart';
import 'package:image_picker/image_picker.dart';

class AddTweets extends StatefulWidget {
  @override
  _AddTweetsState createState() => _AddTweetsState();
}

class _AddTweetsState extends State<AddTweets> {
  File imagepath;
  bool uploading = false;
// post image section start from here..
  pickImage(ImageSource imgsource) async {
    final image = await ImagePicker().getImage(source: imgsource);
    setState(() {
      imagepath = File(image.path);
    });
    Navigator.pop(context);
  }

  final TextEditingController tweetController = new TextEditingController();
  optiondialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () => pickImage(ImageSource.gallery),
                child: Text("Image from gallery"),
              ),
              SimpleDialogOption(
                onPressed: () => pickImage(ImageSource.camera),
                child: Text("Image from camera"),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
            ],
          );
        });
  }

  //upload image to firebase..

  uploadimage(String id) async {
    StorageUploadTask storageUploadTask =
        tweetpictures.child(id).putFile(imagepath);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    String downloadurl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadurl;
  }

  // and end here...

  posttweet() async {
    setState(() {
      uploading = true;
    });
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userdoc = await usercollection.doc(firebaseuser.uid).get();

    var alldocuments = await tweetcollection.get();
    int length = alldocuments.docs.length;
    //  there are 3 conditions

    // only tweet

    if (tweetController.text != '' && imagepath == null) {
      tweetcollection.doc('Tweet $length').set({
        'username': userdoc.data()['username'],
        'uid': firebaseuser.uid,
        'id': 'Tweet $length',
        'tweet': tweetController.text,
        'likes': [],
        'commentcount': 0,
        'share': 0,
        'type': 1,
      });
      Navigator.pop(context);
    }

    // only image
    if (tweetController.text == '' && imagepath != null) {
      String imageurl = await uploadimage('Tweet $length');
      tweetcollection.doc('Tweet $length').set({
        'username': userdoc.data()['username'],
        'uid': firebaseuser.uid,
        'id': 'Tweet $length',
        'image': imageurl,
        'likes': [],
        'commentcount': 0,
        'share': 0,
        'type': 2,
      });
      Navigator.pop(context);
    }
    // both image and tweet

    if (tweetController.text != '' && imagepath != null) {
      String imageurl = await uploadimage('Tweet $length');
      tweetcollection.doc('Tweet $length').set({
        'username': userdoc.data()['username'],
        'uid': firebaseuser.uid,
        'id': 'Tweet $length',
        'image': imageurl,
        'tweet': tweetController.text,
        'likes': [],
        'commentcount': 0,
        'share': 0,
        'type': 3,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Tweet"),
        centerTitle: true,
      ),
      body: uploading == false
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.bottomRight,
                  child: imagepath == null
                      ? Container()
                      : Image(
                          width: 200,
                          height: 200,
                          image: FileImage(imagepath),
                        ),
                ),
                Flexible(
                    child: Container(
                  child: buildComposer(),
                )),
              ],
            )
          : Center(
              child: Text(
                'Uploading...',
                style: mystyle(23, Colors.black, FontWeight.normal),
              ),
            ),
    );
  }

  Widget buildComposer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        new Flexible(
            child: Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 15, bottom: 15.0),
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Enter your tweet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
            controller: tweetController,
            onChanged: (String txt) {
              setState(() {});
            },
          ),
        )),
        Container(
          child: Row(
            children: [
              IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    optiondialog();
                  }),
              IconButton(icon: Icon(Icons.send), onPressed: () => posttweet()),
            ],
          ),
        )
      ],
    );
  }
}
