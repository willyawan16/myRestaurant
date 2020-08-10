import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginPageForWorker extends StatefulWidget {
  final VoidCallback onSignedIn;
  Function(String) restoDocId, restoId, tableNum, name;

  LoginPageForWorker({this.onSignedIn, this.restoDocId, this.restoId, this.tableNum, this.name});
  @override
  LoginPageForWorkerState createState() => LoginPageForWorkerState();
}

class LoginPageForWorkerState extends State<LoginPageForWorker> {
  String _username, _password, tableNum;
  bool hidePassword;
  bool isLoading, failedSignIn;
  String finalQrResult = 'Belum di-scan', restoId, restoDocId, errMsg;
  List restoList = [];
  Map finalRestoData = {};

  final formKey = new GlobalKey<FormState>();

  void initState() {
    super.initState();
    hidePassword = true;
    isLoading = false;
    failedSignIn = false;
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      debugPrint('Form is valid. Username: $_username, Password: $_password');
      return true;
    } else {
      debugPrint('Form is invalid. Username: $_username, Password: $_password');
      return false;
    }
  }

  void validateAndSubmit() async {
    // final FirebaseAuth _auth = FirebaseAuth.instance;
    if(validateAndSave()) {
      try {
        
        List workerList = restoList[0]['workerList'];
        debugPrint('$tableNum');
        for(int i = 0; i < workerList.length; i++) {
          if(_username.toUpperCase() == workerList[i]['name'].toUpperCase()) {
              widget.onSignedIn();
              widget.restoDocId(restoDocId);
              widget.tableNum(tableNum);
              widget.restoId(restoId);
              widget.name(_username);
          } else if(tableNum == null) {
            failedSignIn = true;
            errMsg = 'Belum di-scan';
          } else if(_username.toUpperCase() != workerList[i]['name'].toUpperCase()) {
            failedSignIn = true;
            errMsg = 'Username tidak ditemukan';
          } 
        }

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        debugPrint('Error: $e');
        setState(() {
          isLoading = false;
          errMsg = 'Username tidak ditemukan atau meja belum di-scan';
          failedSignIn = true;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void generateTableNum(qrResult) {
    if(qrResult.length <= 40) {
      setState(() {
        finalQrResult = 'Restaurant tidak ditemukan!';
      });
    } else {
      bool found = false, tableFound = false;
      String _tableNum = '';
      int tableNumDigit = 0; 
      setState(() {
        restoDocId = qrResult.substring(0,20);
        restoId = qrResult.substring(20,40);
      });
      debugPrint('------$restoDocId');
      debugPrint('------$restoId');
      // for(int i = 0; i < restoList.length; i++) {
      //   if(restoDocId == restoList[i]['restoDocId']) {
      //     if(restoId == restoList[i]['restoId']) {
      //       finalRestoData = restoList[i]; 
      //       setState(() {
      //         finalQrResult = '${finalRestoData['restoName']}\'s Restaurant';
      //         // tableNum = _tableNum;
      //         found = true;
      //       });
      //     }
      //     break;
      //   }
      // } 
      // if(!found) {
      //   setState(() {
      //     finalQrResult = 'Restaurant Not Found!';
      //   });
      // }
      for(int i = qrResult.length-1; i >= 40; i--) {
        // debugPrint('--> $tableNumDigit');
        if(qrResult[i] != '_') {
          setState(() {
            tableNumDigit++;
          });
        } else {
          setState(() {
            _tableNum = qrResult.substring(qrResult.length - tableNumDigit);
            tableFound = true;
          });
          break;
        }
      }
      debugPrint('$_tableNum $tableFound');
      if(tableFound) {
        debugPrint('--------------masuk---------------');
        for(int i = 0; i < restoList.length; i++) {
          if(restoDocId == restoList[i]['restoDocId']) {
            if(restoId == restoList[i]['restoId']) {
              finalRestoData = restoList[i]; 
              setState(() {
                finalQrResult = 'Restoran ${finalRestoData['restoName']} (Table $_tableNum)';
                tableNum = _tableNum;
                found = true;
              });
            }
            break;
          }
        } 
        if(!found) {
          setState(() {
            finalQrResult = 'Restaurant tidak ditemukan!';
          });
        }
      } else {
        setState(() {
          finalQrResult = 'Meja tidak ditemukan';
        });
      }
    }
  }

  Widget onLoading() {
    return Center(
      child: Container(
        height: 50,
        width: 50,
        child: Card(
          elevation: 10,
          child: SpinKitCubeGrid(
            size: 30,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Future<void> _helpDialog() {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Bantuan'),
          content: Text('Tanyakan admin kamu mengenai QR meja'),
          actions: <Widget>[
            OutlineButton(
              child: Text('Okay!'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('restaurant').snapshots(),
      builder: (context, snapshot) {
        Map _temp = {};
        List _restoList = [];
        if(!snapshot.hasData) return onLoading();
        for(int i = 0; i < snapshot.data.documents.length; i++) {
          _temp.addAll({
            'restoDocId': snapshot.data.documents[i].documentID,
            'restoId': snapshot.data.documents[i]['restaurantId'],
            'restoName': snapshot.data.documents[i]['restaurantName'],
            'workerList': snapshot.data.documents[i]['worker'],
          });
          _restoList.add(_temp);
          _temp = {};
        }
        restoList = _restoList;
        _restoList = [];

        return GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            backgroundColor: Colors.orange[50],
            resizeToAvoidBottomPadding: false,
            body: Container(
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   // end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
                //   end: Alignment.bottomRight,
                //   colors: [Colors.yellow[400], Colors.orange[600]], // whitish to gray
                //   tileMode: TileMode.repeated, // repeats the gradient over the canvas
                // ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Container(
                  //   height: totHeight * 0.4,
                  //   width: totWidth,
                  //   decoration: new BoxDecoration(
                  //     color: Colors.orange,
                  //     borderRadius: new BorderRadius.only(
                  //       bottomLeft: const Radius.circular(100.0),
                  //     )
                  //   ),
                  // ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        
                        Container(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(40,10,40,0),
                            child: new Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text('Buat Order?', style: TextStyle(fontFamily: 'Balsamiq_Sans', fontSize: 30, fontWeight: FontWeight.bold),),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Cari meja'),
                                      new Row(
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.help_outline),
                                            onPressed: () {
                                              _helpDialog();
                                            },
                                          ),
                                          OutlineButton(
                                            highlightedBorderColor: Colors.orange,
                                            onPressed: _scanQR,
                                            child: Text('Scan')
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(finalQrResult, style: TextStyle(color: (finalQrResult == 'Belum di-scan') ? Colors.red : Colors.black)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    // onChanged: (String str){
                                    //   setState(() {
                                    //     email = str;
                                    //   });
                                    // },
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) => value.isEmpty ? 'Username tidak boleh kosong': null,
                                    onSaved: (value) => _username = value,
                                    decoration: InputDecoration(
                                      // prefixIcon: Icon(Icons.person),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      labelText: 'Username',
                                      labelStyle: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // TextFormField(
                                  //   // onChanged: (String str){
                                  //   //   setState(() {
                                  //   //     password = str;
                                  //   //   });
                                  //   // },
                                  //   validator: (value) => value.isEmpty ? 'Password can\'t be empty': null,
                                  //   onSaved: (value) => _password = value,
                                  //   obscureText: hidePassword,
                                  //   keyboardType: TextInputType.number,
                                  //   decoration: InputDecoration(
                                  //     suffixIcon: IconButton(
                                  //       color: Colors.grey,
                                  //       icon: (hidePassword != true)
                                  //       ? Icon(Icons.visibility)
                                  //       : Icon(Icons.visibility_off),
                                  //       onPressed: (){
                                  //         setState(() {
                                  //           hidePassword = !hidePassword;
                                  //         });
                                  //       },
                                  //     ),
                                  //     // prefixIcon: Icon(Icons.),
                                  //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  //     labelText: 'Password',
                                  //     hintText: 'YYYY-MM-DD',
                                  //     labelStyle: TextStyle(fontSize: 17),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    // width: totWidth-80,                          
                                    child: RaisedButton(
                                      color: Colors.orange,
                                      elevation: 7,
                                      child: Text('Masuk', style: TextStyle(fontSize: 17,)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(40)),
                                      ),
                                      onPressed: (){
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        setState(() {
                                          isLoading = true;
                                        });
                                        validateAndSubmit();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  (isLoading)
                                  ? SpinKitWave(
                                    size: 50.0,
                                    // duration: Duration(seconds: 1),
                                    itemBuilder: (BuildContext context, int index){
                                      return DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                      );
                                    },
                                    // controller: AnimationController(vsync: this,duration: const Duration(milliseconds: 1200)),
                                  )
                                  : (failedSignIn)
                                    ? Text('$errMsg', style: TextStyle(color: Colors.red), textAlign: TextAlign.start,)
                                    : Container(),
                                ],
                              ),
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Future _scanQR() async {
    try{
      String result = await BarcodeScanner.scan();
      generateTableNum(result);
    } on PlatformException catch (ex) {
      if(ex.code == BarcodeScanner.CameraAccessDenied) {
        debugPrint('Camera permission denied');
        // setState((){
        //   qrResult = 'Camera permission was denied';
        // });
      } else {
        debugPrint('Unknown err $ex');
        // setState((){
        //   qrResult = 'Unknown Error $ex';
        // });
      } 
    } on FormatException {
      debugPrint('Pressed backButton');
      // setState((){
      //   qrResult = 'You pressed back button';
      // });
    } catch (ex) {
      debugPrint('Unknown err $ex');
      // setState((){
      //   qrResult = 'Unknown Error $ex';
      // });
    }
  }
}