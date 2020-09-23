import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/auth.dart';
import 'package:food/src/screens/addtweet.dart';
import 'package:food/src/screens/comments.dart';
import 'package:food/src/varibles.dart';

class TweetPage extends StatefulWidget {
  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  String uid;
  initState() {
    super.initState();
    getcurrentuseruid();
  }

  getcurrentuseruid() async {
    var firebsaeuser = FirebaseAuth.instance.currentUser;
    setState(() {
      uid = firebsaeuser.uid;
    });
  }

  likepost(String documentid) async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot document = await tweetcollection.doc(documentid).get();

    if (document.data()['likes'].contains(firebaseuser.uid)) {
      tweetcollection.doc(documentid).update({
        'likes': FieldValue.arrayRemove([firebaseuser.uid]),
      });
    } else {
      tweetcollection.doc(documentid).update({
        'likes': FieldValue.arrayUnion([firebaseuser.uid]),
      });
    }
  }

  sharepost(String documentid, tweet) async {
    Share.text('Tweet', tweet, 'text/plain');
    DocumentSnapshot document = await tweetcollection.doc(documentid).get();
    tweetcollection.doc(documentid).update({
      'share': document.data()['share'] + 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTweets()));
        },
        child: Icon(Icons.add),
        tooltip: 'Add tweet',
      ),
      appBar: AppBar(
        title: Text(
          "Twitter",
          style: mystyle(20, Colors.white, FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: tweetcollection.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot tweetdoc = snapshot.data.documents[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.lightBlue,
                      radius: 23,
                    ),
                    title: Text(
                      tweetdoc.data()['username'],
                      style: mystyle(18, Colors.black, FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tweetdoc.data()['type'] == 1)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              tweetdoc.data()['tweet'],
                              style: mystyle(17, Colors.black),
                            ),
                          ),
                        if (tweetdoc.data()['type'] == 2)
                          Image(
                            image: NetworkImage(
                              tweetdoc.data()['image'],
                            ),
                            height: 250,
                            width: 400,
                          ),
                        if (tweetdoc.data()['type'] == 3)
                          Column(
                            children: [
                              Text(
                                tweetdoc.data()['tweet'],
                                style: mystyle(17, Colors.black),
                              ),
                              SizedBox(height: 5),
                              Image(
                                image: NetworkImage(tweetdoc.data()['image']),
                                height: 250,
                                width: 400,
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Comments(
                                                  tweetdoc.data()['id'])));
                                    },
                                    child: Icon(
                                      Icons.comment,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    tweetdoc.data()['commentcount'].toString(),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                      onTap: () =>
                                          likepost(tweetdoc.data()['id']),
                                      child:
                                          tweetdoc.data()['likes'].contains(uid)
                                              ? Icon(
                                                  Icons.favorite,
                                                  color: Colors.red,
                                                )
                                              : Icon(Icons.favorite_border)),
                                  Text(
                                    tweetdoc.data()['likes'].length.toString(),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => sharepost(
                                        tweetdoc.data()['id'],
                                        tweetdoc.data()['tweet']),
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  Text(
                                    tweetdoc.data()['share'].toString(),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
