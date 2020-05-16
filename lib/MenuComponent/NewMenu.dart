import 'dart:async';
import 'dart:io';
// import 'dart:math' show Random;

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
// import 'package:random_string/random_string.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// import './Menu.dart';

class NewMenuState extends State<NewMenu>{
  // TextEditingController menuName, menuDesc, menuPric, menuCate;
  List<String> _initCate = [];
  String menuName, menuDesc, menuPric, menuCate, selectedVal;
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  // bool enableText;
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    // myFocusNode.addListener(() {debugPrint('this is new');});
    //if(_initCate.isNotEmpty){
      selectedVal = 'Select Category';
    //}
    // enableText = false;
    // menuName = TextEditingController(text:"name");
  }

  @override
  void dispose(){
    myFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addData(String fileName) async{
    String imageUrl;

    CollectionReference reference = Firestore.instance.collection('menuList');
    final docRef = await reference.add({
      'name': menuName,
      'description': menuDesc,
      'price': menuPric,
      'category': menuCate,
    });

    String docID = docRef.documentID;
      if(imageFile != null) {
        final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('images/$docID');
        final StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile); 
        final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
          // You can use this to notify yourself or your user in any kind of way.
          // For example: you could use the uploadTask.events stream in a StreamBuilder instead
          // to show your user what the current status is. In that case, you would not need to cancel any
          // subscription as StreamBuilder handles this automatically.

          // Here, every StorageTaskEvent concerning the upload is printed to the logs.
          print('EVENT ${event.type}');
        });

        // Cancel your subscription when done.
        await uploadTask.onComplete;
        streamSubscription.cancel();

        imageUrl = await firebaseStorageRef.getDownloadURL();
      } else {
        imageFile = null;
      }

    Firestore.instance.runTransaction((Transaction transaction) async{
      CollectionReference reference = Firestore.instance.collection('menuList');
      await reference
      .document(docID)
      .updateData({
        'picture': imageUrl,
      });
    });
  }


  File imageFile;

  _getImage(BuildContext context, ImageSource source) async {
    File cropped;
    File picture = await ImagePicker.pickImage(source: source);
    if(picture != null){
      cropped = await ImageCropper.cropImage(
        sourcePath: picture.path,
        aspectRatio: CropAspectRatio(
          ratioX: 1, 
          ratioY: 1,
        ),
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.orange,
          toolbarTitle: 'Crop',
          statusBarColor: Colors.deepOrange,
          backgroundColor: Colors.white,
        ),
      );
    }
    this.setState((){
      imageFile = cropped;
    });
    Navigator.of(context).pop();
  }

  Widget _decideImage() {
    if(imageFile == null){
      return Text('No image selected');
    }else{
      return Image.file(imageFile, width: 150, height: 150);
    }
  }

  Future<void> _showImportDialog(BuildContext context){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Method'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: (){
                    _getImage(context, ImageSource.gallery);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0)
                ),
                GestureDetector(
                  child: Text('Camera'),
                  onTap: (){
                    _getImage(context, ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _currentLine = 0;
  Future<void> _nullDialog() async {
    int currentLine = _currentLine;
    String currentText;
    if(currentLine == 1){
      currentText = 'New Menu';
    }else if(currentLine == 3){
      currentText = 'Price';
    }else if(currentLine == 4){
      currentText = 'Category';
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops! Something is missing.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please fill in the missing box'),
                Text(currentText, style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay', style: TextStyle(fontSize: 15),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _accDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to add this Menu?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('NB: Menu is EDITABLE'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Back', style: TextStyle(fontSize: 15),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Sure', style: TextStyle(fontSize: 15),),
              onPressed: () {
                _addData(menuName.toString());
                Navigator.of(context).pop();
                debugPrint(menuCate.toString());
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget body () {
    double widthImport = (MediaQuery.of(context).size.width-28)/2;
    double spacingHeight = 25;
    if(selectedVal != '+')
    {
      menuCate = selectedVal;
    }
    else
    {

    }
    return new GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SingleChildScrollView(
        child: Container(
          color: Colors.orangeAccent[100],
          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: SizedBox(
            // height: MediaQuery.of(context).size.height * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 0,
              color: Colors.orange[100],
              child: new Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top:10),
                    child: Text(
                      'New Menu', 
                      style: TextStyle(
                        //fontFamily: 'Pacifico',
                        fontSize: 35, 
                        fontWeight: FontWeight.bold
                        ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextField(
                      // controller: menuName,
                      onChanged: (String str){
                        setState(() {
                          menuName = str;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.restaurant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        labelText: 'New Menu',
                        //hintText: 'Name of New Menu',
                        labelStyle: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: spacingHeight,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextField(
                      // controller: menuDesc,
                      onChanged: (String str){
                        setState(() {
                          menuDesc = str;
                        });
                      },
                      maxLength: 60,
                      maxLines: 3,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        labelText: 'Menu Description',
                        hintText: 'Enter Description',
                        labelStyle: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: spacingHeight,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextField(
                      // controller: menuPric,
                      onChanged: (String str){
                        setState(() {
                          menuPric = str;
                        });
                      },
                      keyboardType: TextInputType.number,
                      //textAlign: TextAlign.end,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.label),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        labelText: 'Price',
                        hintText: 'Enter Price',
                        labelStyle: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: spacingHeight,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: DropdownButton<String>(
                      value: selectedVal,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.grey,
                      ),
                      items: _initCate.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                      }).toList(),
                      onChanged: (String str) {
                        setState(() {
                          selectedVal = str;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: spacingHeight,
                  ),
                  Container(
                    child: (selectedVal == '+') ? 
                      Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: TextField(
                              autofocus: true,
                              // controller: menuPric,
                              onChanged: (String str){
                                setState(() {
                                  menuCate = capitalize(str);
                                });
                              },
                              //textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.category),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                // enabled: enableText,
                                labelText: 'New Category',
                                hintText: 'Enter New Category',
                                labelStyle: TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: spacingHeight,
                          ),
                                ],
                              )
                    :
                    Container(),
                  ),
                  Container(
                    width: widthImport*2,
                    // color: Colors.yellow,
                    child: new Column(
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            Container(
                              // color: Colors.red,
                              width: widthImport,
                              padding: EdgeInsets.only(left: 20),
                              child: Text('Menu Image', style: TextStyle(fontSize: 17),),
                            ),
                            SizedBox(
                              width: widthImport/2,
                            ),
                            Container(
                              child: (imageFile == null) ?
                                FlatButton(
                                  textColor: Colors.orange,
                                  onPressed: (){
                                    _showImportDialog(context);
                                  },
                                  child: Text('import',),
                                )
                                :
                                FlatButton(
                                  textColor: Colors.orange,
                                  onPressed: (){
                                    this.setState((){
                                      imageFile = null;
                                    });
                                  },
                                  child: Text('reset',),
                                )
                            ),
                          ],
                        ),
                        Container(
                          height: 150,
                          width: 150,
                          // color: Colors.red,
                          child: _decideImage(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.deepOrangeAccent,
                      label: Text('Submit'),
                      onPressed: (){
                        if(menuName == null || menuName.length == 0){
                          _currentLine = 1;
                          _nullDialog();
                        }else if(menuPric == null || menuPric.length == 0){
                          _currentLine = 3;
                          _nullDialog();
                        }else if(menuCate == null || menuCate.length == 0 || menuCate == 'Select Category'){
                          _currentLine = 4;
                          _nullDialog();
                        }else if(menuDesc != null || menuDesc == '' || menuDesc == null){
                          if(menuDesc == null)
                            menuDesc = '';
                          _accDialog();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'back',
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('New Menu'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('menuList').snapshots(),
        builder: (context, snapshot){
          List<String> getCate = [];
          if(!snapshot.hasData) return const Text('Loading');
          for(int i = 0; i < snapshot.data.documents.length; i++){
            if(getCate.isEmpty)
            {
              getCate.add(snapshot.data.documents[i]['category']);
            }
            else
            {
              bool needChange = true;
              for(int j = 0; j < getCate.length; j++){
                if(snapshot.data.documents[i]['category'] == getCate[j]){
                  needChange = false;
                }
              }
              if(needChange == true){
                  getCate.add(snapshot.data.documents[i]['category']);
              } 
              needChange = true;
            }
          }
          getCate.sort();
          _initCate = getCate;
          //debugPrint(_initCate.toString());
          _initCate.insert(0, 'Select Category');
          _initCate.add('+');
          // debugPrint(selectedVal);
          return body();
        }
      )
    );
  }
} 

class NewMenu extends StatefulWidget{
  @override
  NewMenuState createState() => NewMenuState();
}