import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class FireList extends StatelessWidget {
  FireList({this.firestore, this.context, this.title});

  BuildContext context;

  final Firestore firestore;
  final String reference = "Ember-Watch";
  final String title;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: firestore.collection("Ember-Watch").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('No Menu Avaliable...'); // If there isn't any data, say no Menu

        // Removes the Meta Data document.
        //var metaIndex = snapshot.data.documents.indexWhere((document) => document.documentID == "meta");
        //var meta = snapshot.data.documents.removeAt(metaIndex);

        //var send = {"lat":meta["lat"],"long":meta["long"]};
        return new ListView(
          children: expandedWidgetList(snapshot.data.documents,),
        );
      },
    );
  }

  Widget imageCard(String imageString) {
    return new Card(
        child: new Stack(
          children: <Widget>[
            new Center(
              child: new Image.network(imageString,),
            ),
            /*new Container(
              child: new Icon(
                Icons.add_location,
                size: 40.0,
                color: Colors.red,
              ),
              alignment: Alignment(0.0, 0.0),
            ),*/
          ],
          alignment: Alignment(0.0, 0.0),
        )
    );
  }


  List<Widget> expandedWidgetList(List<DocumentSnapshot> snapshotList,){
    List<Widget> expansionList = [];

    if(snapshotList != null &&  snapshotList.isNotEmpty) {
      for (var snapshotDocument in snapshotList) {
        expansionList.add(imageCard(snapshotDocument.data["image"]));
        debugPrint(snapshotDocument.data["Image"].toString());
        /*expansionList.add(new ExpansionTile(title: new Text(snapshotDocument.documentID),
          children: tileWidgetList(snapshotDocument.data["items"]),
        ));*/
      }
    }
    return expansionList;
  }
  List<Widget> tileWidgetList(List<dynamic> list){
    List<Widget> expansionList = [];
    for(Map map in list) {
      expansionList.add(new ListTile(
        title: new Text(map["name"]),
        //isThreeLine: true,
        subtitle: map.containsKey("description") ? new Text(map["description"]) : null,
        trailing: map.containsKey("price") ? new Text('\$'+map["price"].toString()) : " ",
      ),);
    }
    return expansionList;
  }
}

class MenuPage extends StatelessWidget {
  MenuPage({this.firestore, this.reference, this.title});
  final Firestore firestore;
  final String reference;
  final String title;

  CollectionReference get messages => firestore.collection('Ember-Watch');

  /*Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }*/

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: Text(title),
      ),
      body: new FireList(firestore: firestore, title: title),
    );
  }
}