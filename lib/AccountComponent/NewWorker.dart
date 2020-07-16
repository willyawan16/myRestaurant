import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_group_sliver/flutter_group_sliver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';

class NewWorker extends StatefulWidget {
  String restoId;
  String restoDocId;

  NewWorker({Key key, this.restoId, this.restoDocId}) : super(key: key);
  @override
  NewWorkerState createState() => NewWorkerState();
}

class NewWorkerState extends State<NewWorker> {

  final formKey = new GlobalKey<FormState>();
  DateTime _dateTime;
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  String name, phoneNum, gender;
  List<String> workAs = ['Select Role', 'Cashier', 'Waiter'];
  String selectedStatus = 'Select Role'; 
  Map finalObj = {};

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      debugPrint('Form is valid. Name: $name, DOB: ${_dateTime.toString().substring(0, 10)}, phoneNum: $phoneNum, role: $selectedStatus');
      return true;
    } else {
      debugPrint('Form is invalid. Name: $name, DOB: ${_dateTime.toString().substring(0, 10)}, phoneNum: $phoneNum, role: $selectedStatus');
      return false;
    }
  }

  void validateAndSubmit() async {
    // final FirebaseAuth _auth = FirebaseAuth.instance;
    if(validateAndSave()) {
      try {
        _addWorker();
        // widget.workerListCallback(finalObj);
        Navigator.of(context).pop();
      } catch (e) {
        debugPrint('Error: $e');
      }
    } else {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('${widget.restoId}');
    // debugPrint('${widget.restoDocId}');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Balsamiq_Sans',
      ),
      home: Scaffold(
        backgroundColor: Colors.orange[50],
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: false,
                leading: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    color: Colors.transparent,
                  ),
                  child: IconButton(
                    color: Colors.black,
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
                expandedHeight: 150,
                flexibleSpace: const FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text('New Worker', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                backgroundColor: Colors.orange[50],
              ),
              SliverGroupBuilder(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.grey,
                  //       blurRadius: 5.0,
                  //       spreadRadius: 5.0,
                  //       offset: Offset(0, 0),
                  //   )
                  // ],
                  color: Colors.orange[200],
                  borderRadius: BorderRadius.only(
                    // topLeft: Radius.circular(150), 
                    topRight: Radius.circular(70)
                  ),
                ),
                child: SliverList(
                  delegate: SliverChildListDelegate([
                    new Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.center,
                            // color: Colors.red,
                            width: 150,
                            height: 150,
                            child: _decideImage(),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                            child: TextFormField(            
                              validator: (value) => (value.isEmpty) ? 'Name can\'t be empty' : null,
                              onSaved: (value) => name = value,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                labelText: 'Name',
                                hintText: 'Worker\'s name',
                                labelStyle: TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20,0,20,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new Row(
                                  children: <Widget>[
                                    Radio(
                                      activeColor: Colors.orange,
                                      value: 'M',
                                      groupValue: gender,
                                      onChanged: (val){
                                        setState(() {
                                          gender = val;
                                        });
                                      },
                                    ),
                                    Text('Male'),
                                  ],
                                ),
                                new Row(
                                  children: <Widget>[
                                    Radio(
                                      activeColor: Colors.orange,
                                      value: 'F',
                                      groupValue: gender,
                                      onChanged: (val){
                                        setState(() {
                                          gender = val;
                                        });
                                      },
                                    ),
                                    Text('Female'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 20, 0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Date of Birth', style: TextStyle(fontSize: 15)),
                                OutlineButton(
                                  highlightedBorderColor: Colors.orange,
                                  onPressed: (){
                                    showDatePicker(
                                      
                                      context: context,
                                      initialDate: _dateTime == null ? DateTime.now() : _dateTime,
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime.now(),
                                    ).then((date) {
                                      setState(() {
                                        _dateTime = date;
                                      });
                                    });
                                  },
                                  child: Text('Select'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 20, 20),
                            child: Text(
                              (_dateTime == null)
                              ? 'Select your DOB'
                              : _dateTime.toString().substring(0,10),
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: TextFormField(            
                              validator: (value) => (value.isEmpty) ? 'Phone number can\'t be empty' : null,
                              onSaved: (value) => phoneNum = value,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.call),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                labelText: 'Phone number',
                                hintText: 'Ex: 08123478545',
                                labelStyle: TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: DropdownButton<String>(
                              value: selectedStatus,
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
                              items: workAs.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                              }).toList(),
                              onChanged: (String str) {
                                setState(() {
                                  selectedStatus = str;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Builder(
                        builder: (context) =>
                          RaisedButton(
                            color: Colors.orange[50],
                            child: Text('Submit', style: TextStyle(fontSize: 20)),
                            onPressed: (){
                              var birthYear = int.parse(_dateTime.toString().substring(0, 4));
                              var thisYear = int.parse(DateFormat('yyyy').format(DateTime.now()));
                              var yearDiff = thisYear - birthYear;
                              FocusScope.of(context).requestFocus(new FocusNode());
                              if(imageFile == null) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 5,
                                    content: Text('Dont\'t forget worker\'s picture!')
                                  )
                                );
                              } else if(gender == null) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 5,
                                    content: Text('Please select your gender!'),
                                  )
                                );
                              } else if(_dateTime == null) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 5,
                                    content: Text('Don\'t you remember your Birth date?'),
                                  )
                                );
                              } else if(_dateTime != null && yearDiff <= 15) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 5,
                                    content: Text('Too young! Re-check your DOB'),
                                  )
                                );
                              } else if(selectedStatus == 'Select Role') {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 5,
                                    content: Text('Haven\'t decided a role yet? Select "Waiter" as default!'),
                                  )
                                );
                              } else {
                                validateAndSubmit();
                              }
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                            elevation: 7,
                          ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                  ]),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                // fillOverscroll: false,
                child: Container(
                  // height: 400,
                  color: Colors.orange[200],
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addWorker() async{
    String imageUrl;

    CollectionReference reference = Firestore.instance.collection('restaurant');

    // String docID = docRef.documentID;
    if(imageFile != null) {
      final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('${widget.restoId}/images/workerPic/${name}_${_dateTime.toString().substring(0, 10)}');
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

    var obj = {
      'name': name,
      'dob': _dateTime.toString().substring(0, 10), 
      'phoneNum': phoneNum,
      'role': selectedStatus,
      'gender': gender,
      'picture': imageUrl,
    };
    finalObj = obj;
    await reference
      .document(widget.restoDocId)
      .updateData({
        'worker': FieldValue.arrayUnion([obj]),
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
    // Navigator.of(context).pop();
  }

  Widget _decideImage() {
    if(imageFile == null)
    {
      return GestureDetector(
        onTap: (){
          _getImage(context, ImageSource.camera);
        },
        child: Container(
          alignment: Alignment.center,
            height: 150,
            width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.withOpacity(0.7),
          ),
          child: Text('Tap to photo', textAlign: TextAlign.center),
        )
      );
    }
    else
    {
      return Container(
        child: GestureDetector(
          onTap: (){
            _getImage(context, ImageSource.camera);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: Image.file(imageFile, width: 150, height: 150, fit: BoxFit.fill),
          ),
        ),
      );
    }
  }
}