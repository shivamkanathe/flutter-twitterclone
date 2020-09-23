import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food/auth.dart';
import 'package:food/src/pages/viewuser.dart';
import 'package:food/src/varibles.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<QuerySnapshot> searchuserresult;
  searchuser(String s) {
    var users =
        usercollection.where('username', isGreaterThanOrEqualTo: s).get();
    setState(() {
      searchuserresult = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffECE5DA),
        appBar: AppBar(
            title: TextFormField(
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
          ],
          decoration: InputDecoration(
            filled: true,
            hintText: 'Search for users...',
            hintStyle: mystyle(17),
          ),
          onFieldSubmitted: searchuser,
        )),
        body: searchuserresult == null
            ? Center(
                child: Text(
                  "Search for users.....",
                  style: mystyle(
                    18,
                  ),
                ),
              )
            : FutureBuilder(
                future: searchuserresult,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData == null) {
                    Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot user = snapshot.data.documents[index];
                        return Card(
                          elevation: 8.0,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.lightBlue,
                            ),
                            title: Text(user.data()['username']),
                            trailing: Container(
                              width: 90,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.lightBlue,
                              ),
                              child: Center(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewUser(
                                                  user.data()['uid'])));
                                    },
                                    child: Text(
                                      "View",
                                      style: mystyle(16, Colors.white),
                                    )),
                              ),
                            ),
                          ),
                        );
                      });
                }));
  }
}
