import 'dart:async';
import 'dart:io';
// import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    // myFocusNode.addListener(() {debugPrint('this is new');});
    //if(_initCate.isNotEmpty){
      selectedVal = 'Pilih Kategori';
    //}
    // enableText = false;
    // menuName = TextEditingController(text:"name");
  }

  @override
  void dispose(){
    myFocusNode.dispose();
    super.dispose();
  }

  Widget onLoading() {
    return Center(
      child: SpinKitDualRing(
        size: 100,
        color: Colors.orange
      ),
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      debugPrint('Form is valid. Menu Name: $menuName, Description: $menuDesc, menuPric: $menuPric, category: $menuCate' );
      return true;
    } else {
      debugPrint('Form is invalid. Menu Name: $menuName, Description: $menuDesc, menuPric: $menuPric, category: $menuCate');
      return false;
    }
  }

  void validating() {
    if(validateAndSave()) {
      try {
        _accDialog();
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  Future<void> _addData(String fileName) async{
    String imageUrl;

    CollectionReference reference = Firestore.instance.collection('menuList');
    final docRef = await reference.add({
      'name': menuName,
      'description': menuDesc,
      'price': menuPric,
      'category': menuCate,
      'restaurantId': widget.restoId,
    });

    String docID = docRef.documentID;
      if(imageFile != null) {
        final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('${widget.restoId}/images/foodPic/$docID');
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
    try {
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
    } catch(e) {
      print(e);
    }
    
    Navigator.of(context).pop();
  }

  Widget _decideImage() {
    if(imageFile == null){
      return Text('Tidak ada gambar');
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
          title: Text('Pilih dari..'),
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

  Future<void> _accDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Ingin tambah menu ini?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('NB: Menu bisa di-edit'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('kembali', style: TextStyle(fontSize: 15),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Ya', style: TextStyle(fontSize: 15),),
              onPressed: () {
                _addData(menuName.toString());
                Navigator.of(dialogContext).pop();
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
    double spacingHeight = 30;
    if(selectedVal != '+')
    {
      menuCate = selectedVal;
    }
    return new GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SingleChildScrollView(
        child: new Form(
          key: formKey,
          child: Container(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height-100,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    validator: (value) => value.isEmpty ? 'Nama Menu tidak boleh kosong' : null,
                    onSaved: (value) => menuName = value,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.restaurant),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'Nama Menu',
                      //hintText: 'Name of New Menu',
                      labelStyle: TextStyle(fontSize: 17),
                    ),
                  ),
                  SizedBox(
                    height: spacingHeight,
                  ),
                  TextFormField(
                    validator: (value) => value.isEmpty ? null : null,
                    onSaved: (value) => menuDesc = value,
                    maxLength: 60,
                    maxLines: 3,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'Deskripsi Menu',
                      //hintText: 'Name of New Menu',
                      labelStyle: TextStyle(fontSize: 17),
                    ),
                  ),
                  TextFormField(
                    validator: (value) => value.isEmpty ? 'Harga tidak boleh kosong' : null,
                    onSaved: (value) => menuPric = value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'Harga',
                      //hintText: 'Name of New Menu',
                      labelStyle: TextStyle(fontSize: 17),
                    ),
                  ),
                  SizedBox(
                    height: spacingHeight,
                  ),
                  DropdownButton<String>(
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
                  SizedBox(
                    height: spacingHeight,
                  ),
                  Container(
                    child: (selectedVal == '+') ? 
                      Column(
                        children: <Widget>[
                          Container(
                            child: TextFormField(
                              autofocus: true,
                              // controller: menuPric,
                              validator: (value) => value.isEmpty ? 'Kategori Baru tidak boleh kosong' : null,
                              onSaved: (value) => menuCate = capitalize(value),
                              //textAlign: TextAlign.end,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.category),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                // enabled: enableText,
                                labelText: 'Kategori Baru',
                                // hintText: 'Enter New Category',
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
                  new Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            // color: Colors.red,
                            child: Text('Gambar Menu', style: TextStyle(fontSize: 17),),
                          ),  
                          Container(
                            child: (imageFile == null) 
                            ? OutlineButton(
                              textColor: Colors.orange,
                              onPressed: (){
                                _showImportDialog(context);
                              },
                              child: Text('import',),
                            )
                            : FlatButton(
                              textColor: Colors.red,
                              onPressed: (){
                                this.setState((){
                                  imageFile = null;
                                });
                              },
                              child: Text('ulang',),
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
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 300,
                    child: RaisedButton(
                      elevation: 10,
                      color: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Text('Buat', style: TextStyle(fontSize: 20)),
                      onPressed: (){
                        validating();
                      }
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    debugPrint('Get Id: ${widget.restoId}');
    return Scaffold(
      backgroundColor: Colors.orange[50],
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'back',
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text('Menu Baru'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('menuList').where('restaurantId', isEqualTo: widget.restoId).snapshots(),
        builder: (context, snapshot){
          List<String> getCate = [];
          if(!snapshot.hasData) return onLoading();
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
          _initCate.insert(0, 'Pilih Kategori');
          _initCate.add('+');
          // debugPrint(selectedVal);
          return body();
        }
      )
    );
  }
} 

class NewMenu extends StatefulWidget{
  String restoId;

  NewMenu({Key key, this.restoId}) : super(key :key);
  @override
  NewMenuState createState() => NewMenuState();
}