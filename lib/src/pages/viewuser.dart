import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/auth.dart';
import 'package:food/src/screens/comments.dart';
import 'package:food/src/varibles.dart';

class ViewUser extends StatefulWidget {
  final String uid;
  ViewUser(this.uid);
  @override
  _ViewUserState createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  String uid;
  Stream userstream;
  String username;

  bool dataishere = false;
  initState() {
    super.initState();
    getcurrentuseruid();
    getstream();
    getcurrentuserinfo();
  }

  getcurrentuserinfo() async {
    DocumentSnapshot userdoc =
        await usercollection.doc(widget.uid.trim()).get();
    setState(() {
      username = userdoc.data()['username'];
      dataishere = true;
    });
  }

  getstream() async {
    setState(() {
      userstream = tweetcollection
          .where('uid', isEqualTo: widget.uid.trim())
          .snapshots();
    });
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
      body: dataishere == true
          ? SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.lightBlue,
                      Colors.purple,
                    ])),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 6,
                        left: MediaQuery.of(context).size.width / 2 - 55),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 2.7),
                    child: Column(
                      children: [
                        Text(
                          username,
                          style: mystyle(25, Colors.black, FontWeight.w500),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Following",
                              style: mystyle(18, Colors.black),
                            ),
                            Text(
                              "Follower",
                              style: mystyle(18, Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "50",
                              style: mystyle(18, Colors.black),
                            ),
                            Text(
                              "250",
                              style: mystyle(18, Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.lightBlue]),
                            ),
                            child: Center(
                              child: Text(
                                "Follow",
                                style:
                                    mystyle(22, Colors.white, FontWeight.bold),
                              ),
                            ),
                          ),
                        ),

// user tweet

                        SizedBox(height: 10),
                        Text(
                          "User Tweets",
                          style: mystyle(20, Colors.black),
                        ),

                        StreamBuilder(
                            stream: userstream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot tweetdoc =
                                      snapshot.data.documents[index];
                                  return Card(
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.lightBlue,
                                        radius: 23,
                                      ),
                                      title: Text(
                                        tweetdoc.data()['username'],
                                        style: mystyle(
                                            18, Colors.black, FontWeight.w600),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (tweetdoc.data()['type'] == 1)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                tweetdoc.data()['tweet'],
                                                style:
                                                    mystyle(17, Colors.black),
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
                                                  style:
                                                      mystyle(17, Colors.black),
                                                ),
                                                SizedBox(height: 5),
                                                Image(
                                                  image: NetworkImage(
                                                      tweetdoc.data()['image']),
                                                  height: 250,
                                                  width: 400,
                                                ),
                                              ],
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    Comments(tweetdoc
                                                                            .data()[
                                                                        'id'])));
                                                      },
                                                      child: Icon(
                                                        Icons.comment,
                                                        color: Colors.black45,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      tweetdoc
                                                          .data()[
                                                              'commentcount']
                                                          .toString(),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                        onTap: () => likepost(
                                                            tweetdoc
                                                                .data()['id']),
                                                        child: tweetdoc
                                                                .data()['likes']
                                                                .contains(uid)
                                                            ? Icon(
                                                                Icons.favorite,
                                                                color:
                                                                    Colors.red,
                                                              )
                                                            : Icon(Icons
                                                                .favorite_border)),
                                                    Text(
                                                      tweetdoc
                                                          .data()['likes']
                                                          .length
                                                          .toString(),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => sharepost(
                                                          tweetdoc.data()['id'],
                                                          tweetdoc
                                                              .data()['tweet']),
                                                      child: Icon(
                                                        Icons.share,
                                                        color: Colors.lightBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      tweetdoc
                                                          .data()['share']
                                                          .toString(),
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
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
