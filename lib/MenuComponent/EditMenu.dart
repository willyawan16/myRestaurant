import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditMenuState extends State<EditMenu> {
  List<String> _initCate = [];
  String menuName, oldFileName, menuDesc, menuPric, menuCate, selectedVal, docID;
  File imageFile;
  Image currentImage;
  bool reset = false;
  int cek = 1;
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  // bool enableText;
  FocusNode myFocusNode;

  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    //if(_initCate.isNotEmpty){
      //selectedVal = 'Select Category';
    //}
    menuName = widget.name;
    oldFileName = menuName;
    menuDesc = widget.desc;
    menuPric = widget.pric;
    selectedVal = widget.cate;
    docID = widget.docID;
    if(widget.pict != null)
      currentImage = Image.network(widget.pict);
    else
      currentImage = null;
    // enableText = false;
    // menuName = TextEditingController(text:"name");
  }
  
  @override
  void dispose(){
    myFocusNode.dispose();
    super.dispose();
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
        _accDialog(docID, menuName);
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  Future deleteImage(String fileName, folder) async {
    final StorageReference firebaseStorageRef = 
      FirebaseStorage.instance.ref().child('images/$folder/$fileName');
    try {
      await firebaseStorageRef.delete();
      return true;
    } catch(e) {
      return e.toString();
    }
  }

  // String imageUrl;
  // Future<void> uploadImage (String fileName) async {
  //   if(imageFile != null) {
  //     final StorageReference firebaseStorageRef =
  //       FirebaseStorage.instance.ref().child('images/$fileName');
  //     final StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile); 
  //     final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
  //       // You can use this to notify yourself or your user in any kind of way.
  //       // For example: you could use the uploadTask.events stream in a StreamBuilder instead
  //       // to show your user what the current status is. In that case, you would not need to cancel any
  //       // subscription as StreamBuilder handles this automatically.

  //       // Here, every StorageTaskEvent concerning the upload is printed to the logs.
  //       print('EVENT ${event.type}');
  //     });

  //     // Cancel your subscription when done.
  //     await uploadTask.onComplete;
  //     streamSubscription.cancel();

  //     imageUrl = await firebaseStorageRef.getDownloadURL();
  //     debugPrint('get imageUrl.. $imageFile');
  //   }
  // }

  final db = Firestore.instance;
  void updateData(oldFileName, fileName, doc) async{  
    String imageUrl;
    if(reset == true && widget.pict != null) {
      deleteImage(doc, widget.restoId);
      debugPrint('deleted previous image');
    }  
    // debugPrint(fileName.toString());
    if(imageFile != null){
      if(imageFile != null) {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('${widget.restoId}/images/foodPic/$doc');
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
        debugPrint('get imageUrl.. $imageFile');
      }
      debugPrint('image uploaded...');
    }
    debugPrint(imageUrl.toString());
    Firestore.instance.runTransaction((Transaction transaction) async{
      CollectionReference reference = db.collection('menuList');
      await reference
      .document(doc)
      .updateData({
        'name': menuName,
        'description': menuDesc,
        'price': menuPric,
        'category': menuCate,
        'picture': imageUrl,
      });
    });
  }

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
    if(reset == false) {
      if(currentImage == null){
        return Text('No image selected');
      } else {
        return currentImage;
      }
    } else {
      if(imageFile == null){
        return Text('No image selected');
      }else{
        return Image.file(imageFile, width: 150, height: 150);
      }
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

  Future<void> _accDialog(key, String name) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Menu updated!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(menuName, style: TextStyle(fontWeight: FontWeight.bold),),
                Text('is updated'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay', style: TextStyle(fontSize: 15),),
              onPressed: () {
                updateData(oldFileName, menuName, key);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _body (){
    debugPrint('imageFile....' + imageFile.toString());
    double widthImport = (MediaQuery.of(context).size.width-28)/2;
    double spacingHeight = 25;
    if(selectedVal != '+')
    {
      menuCate = selectedVal;
      //enableText = false;
    }
    // else
    // {
    //   enableText = true;
    // }
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
                    initialValue: menuName,
                    validator: (value) => value.isEmpty ? 'Menu name can\'t be empty' : null,
                    onSaved: (value) => menuName = value,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.restaurant),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'New Menu',
                      //hintText: 'Name of New Menu',
                      labelStyle: TextStyle(fontSize: 17),
                    ),
                  ),
                  SizedBox(
                    height: spacingHeight,
                  ),
                  TextFormField(
                    initialValue: menuDesc,
                    validator: (value) => value.isEmpty ? null : null,
                    onSaved: (value) => menuDesc = value,
                    maxLength: 60,
                    maxLines: 3,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'Description',
                      //hintText: 'Name of New Menu',
                      labelStyle: TextStyle(fontSize: 17),
                    ),
                  ),
                  TextFormField(
                    initialValue: menuPric,
                    validator: (value) => value.isEmpty ? 'Price name can\'t be empty' : null,
                    onSaved: (value) => menuPric = value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.label),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: 'Price',
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
                              validator: (value) => value.isEmpty ? 'Category can\'t be empty' : null,
                              onSaved: (value) => menuCate = value,
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
                  new Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            // color: Colors.red,
                            child: Text('Menu Image', style: TextStyle(fontSize: 17),),
                          ),  
                          Container(
                            child: ((cek > 1) ? imageFile == null : imageFile != null) 
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
                                  cek++;
                                  reset = true;
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
                      child: Text('Update', style: TextStyle(fontSize: 20)),
                      onPressed: (){
                        validating();
                      }
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return StreamBuilder(
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
        // _initCate.insert(0, 'Select Category');
        _initCate.add('+');
        // debugPrint(selectedVal);
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.orange[50],
          appBar: AppBar(
            backgroundColor: Colors.orange,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              tooltip: 'back',
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            title: Text('Edit Menu'),
          ),
          body: _body(),
        );
      }
    );
  }
}

class EditMenu extends StatefulWidget {
  final String name;
  final String desc;
  final String cate;
  final String pric;
  final String pict;
  final String docID;
  final String restoId;

  EditMenu({Key key, @required this.name, this.desc, this.cate, this.pric, this.pict, this.docID, this.restoId });

  @override
  EditMenuState createState() => new EditMenuState();
}