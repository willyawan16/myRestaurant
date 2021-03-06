//import 'dart:html';

// import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import './EditMenu.dart';
import 'GlobalState.dart';

class MenuListState extends State<MenuList> {
  int currentIndex;
  List wholeMenu = [];
  List sortedMenu = [];

  Widget onLoading() {
    return Center(
      child: SpinKitDualRing(
        size: 100,
        color: Colors.orange
      ),
    );
  }

  Widget menuCards() {
    return StreamBuilder(
      stream: Firestore.instance.collection('menuList').snapshots(),
      builder: (context, snapshot){
        List _sortedMenu = [];
        List _wholeMenu = [];
        Map _temp = {};
        if(!snapshot.hasData) return onLoading();
        for(int i = 0; i < snapshot.data.documents.length; i++){
          _temp.addAll({
            'name': snapshot.data.documents[i]['name'],
            'description': snapshot.data.documents[i]['description'],
            'price': snapshot.data.documents[i]['price'],
            'category': snapshot.data.documents[i]['category'],
            'picture': snapshot.data.documents[i]['picture'],
            'key': snapshot.data.documents[i].documentID,
          });
          _wholeMenu.add(_temp);
          _temp = {};
        }
        wholeMenu = _wholeMenu;
        //debugPrint(_wholeMenu[0].toString());
        for(int i = 0; i < _wholeMenu.length; i++){
          if(_wholeMenu[i]['category'] == widget.category){
            _sortedMenu.add(_wholeMenu[i]);
          }
        }
        _sortedMenu.sort((a, b) {
          return a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase());
        });
        sortedMenu = _sortedMenu;
        // debugPrint('>>>'+sortedMenu.length.toString());
        // debugPrint('>>>${widget.query}');
        return ListView.builder(
          itemCount: sortedMenu.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, i) => menuDetails(context, sortedMenu[i], i),
        );
      },
    );
  }

  Widget menuDetails(BuildContext context, document, int index){
    // var foodName = items[i][0];
    var totWidth = MediaQuery.of(context).size.width;
    var widthDetail = totWidth * 0.5;
    var widthIcon = totWidth / 12;
    var whPic = totWidth - ( widthDetail + widthIcon) - 48;
    return new Container(
      // height: 150,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 20,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(30),
              // ),
              height: whPic,
              width: whPic,
              child: (document['picture'] != null) 
              // ? Image.network(document['picture'])
              // : Container(),
              ?ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  document['picture'],
                  loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.orange,
                        value: loadingProgress.expectedTotalBytes != null 
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                        : null,
                      ),
                    );
                  },
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.black
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/img/no_image.jpg',
                    fit: BoxFit.fill,
                  ),
                )
              ),
            ),
            Container(
              // height: 150,
              //width: 210,
              width: widthDetail,
              //color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      // Food Name
                      // height: 30,
                      width: widthDetail,
                      // color: Colors.yellow[100],
                      child: Text(document['name'], style: TextStyle(fontSize: 18),),
                      //child: Text(whPic.toString()),
                    ),
                    Container(
                      // Description
                      height: 50,
                      width: widthDetail,
                      // color: Colors.yellow,
                      child: Text(document['description'], style: TextStyle(fontSize: 12)),
                    ),
                    Divider(),
                    Container(
                      // Price
                      height: 31,
                      width: widthDetail,
                      //decoration: BoxDecoration(borderRadius: BorderRadius.only(5)),
                      // color: Colors.yellow[400],
                      child: Text(
                        'Rp' + document['price'].toString() + ',00',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end
                      ), 
                    )
                  ],
                ),
              ),
            ),
            // Container(
            //   height: 150,
            //   width: 2,
            //   color: Colors.black87,
            // ),
            Container(
              height: 150,
              width: widthIcon,
              // color: Colors.pink,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (String choice){
                    choiceAction(choice, index);
                  },
                  tooltip: 'more',
                  itemBuilder: (BuildContext context) {
                    return Constants.choices.map((choice) {
                      return PopupMenuItem<String>(
                        value: choice[0],
                        child: new ListTile(
                          leading: Icon(choice[1]),
                          title: Text(choice[0], style: TextStyle(fontSize: 15)),
                        )
                      );
                    }).toList();
                  },
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  Future deleteImage(String imageFileName) async {
    final StorageReference firebaseStorageRef = 
      FirebaseStorage.instance.ref().child('${widget.restoId}/images/foodPic/$imageFileName');
    try {
      await firebaseStorageRef.delete();
      return true;
    } catch(e) {
      return e.toString();
    }
  }

  final db = Firestore.instance;
  deleteData(imageFileName, picture, doc) {
    //debugPrint('ini: '+ doc.DocumentID.toString());
    if(picture != null){
      deleteImage(doc);
    }
    
    db
      .collection('menuList')
      .document(doc)
      .delete();
  }

  void choiceAction(String choice, int index){
    currentIndex = index;
    var indexIni = wholeMenu.indexOf(sortedMenu[currentIndex]);
    var dataIni = wholeMenu[indexIni];
    if (choice == Constants.Edit[0]) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => EditMenu(
          name: dataIni['name'],
          desc: dataIni['description'],
          pric: dataIni['price'],
          cate: dataIni['category'],
          pict: dataIni['picture'],
          docID: dataIni['key'],
          restoId: widget.restoId,
        )),
      );
    }else if(choice == Constants.Delete[0]) {
      //debugPrint(currentIndex.toString());
      //debugPrint(sortedMenu[currentIndex]['name'].toString());  
      //debugPrint(indexIni.toString());
      debugPrint('deleting... ${sortedMenu[currentIndex]['name'].toString()} ${wholeMenu[indexIni]['key'].toString()}');
      debugPrint(wholeMenu[indexIni]['name']);
      deleteData(wholeMenu[indexIni]['name'], wholeMenu[indexIni]['picture'], wholeMenu[indexIni]['key']);
    }
    // else if(choice == Constants.Share[0]) {

    // }
  }

  Widget build(BuildContext context){
    // debugPrint('${store.get('val')}');
    return Scaffold(
      body: menuCards(),
      backgroundColor: Colors.orange[50]
    );
  }

}

class Constants {
  static const List Edit = ['Edit', Icons.edit];
  static const List Delete = ['Hapus', Icons.delete];
  // static const List Share = ['Share', Icons.share];

  static const List choices = [
    Edit,
    Delete,
    // Share,
  ];
}



class MenuList extends StatefulWidget{
  final String category;
  final String restoId;
  bool isSearching;
  String query;

  MenuList({Key key, this.category, this.restoId, this.isSearching, this.query}) : super(key: key);
  @override
  MenuListState createState() => MenuListState();
}