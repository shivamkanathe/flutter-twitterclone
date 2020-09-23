import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food/auth.dart';
import 'package:food/src/varibles.dart';
import 'package:timeago/timeago.dart' as tAgo;

class Comments extends StatefulWidget {
  final String documentid;

  Comments(this.documentid);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  var commentcontroller = TextEditingController();

  addcomment() async {
    var firebaseuser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userdoc = await usercollection.doc(firebaseuser.uid).get();

    tweetcollection.doc(widget.documentid).collection('comments').doc().set({
      'comment': commentcontroller.text,
      'username': userdoc.data()['username'],
      'uid': userdoc.data()['uid'],
      'time': DateTime.now(),
    });
    DocumentSnapshot commentcount =
        await tweetcollection.doc(widget.documentid).get();
    tweetcollection
        .doc(widget.documentid)
        .update({'commentcount': commentcount.data()['commentcount'] + 1});
    commentcontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: tweetcollection
                        .doc(widget.documentid)
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot commentdoc =
                                snapshot.data.documents[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.lightBlue,
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    commentdoc.data()['username'] + " " + ":",
                                    style: mystyle(20, Colors.black),
                                  ),
                                  SizedBox(width: 15),
                                  Text(commentdoc.data()['comment']),
                                ],
                              ),
                              subtitle: Text(tAgo
                                  .format(commentdoc.data()['time'].toDate())
                                  .toString()),
                            );
                          });
                    }),
              ),
              Divider(),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: TextField(
                    controller: commentcontroller,
                    decoration: InputDecoration(
                      hintText: 'Comments',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                trailing: Container(
                  height: 40,
                  child: FlatButton(
                    onPressed: () => addcomment(),
                    color: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    child: Text(
                      "Publish",
                      style: mystyle(17, Colors.white, FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
