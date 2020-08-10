import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewWorker extends StatefulWidget {
  List workerList;
  int index;
  String restoDocId;

  ViewWorker({Key key, this.workerList, this.index, this.restoDocId}) : super(key: key);
  @override
  ViewWorkerState createState() => ViewWorkerState();
}

class ViewWorkerState extends State<ViewWorker> {
  Map details = {};
  List workerList = [];
  String newPhoneNum = '';

  @override
  void initState() {
    details = widget.workerList[widget.index];
    workerList = widget.workerList;
    super.initState();
  }

  void updateWorker() async {
    var reference = Firestore.instance.collection('restaurant').document('${widget.restoDocId}');
    await reference
    .updateData({
      'worker': workerList,
    });
  }

  Future<void> _changePhoneDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        String status = "";
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: AlertDialog(
                title: Text("No tlp. baru"),
                content: Container(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          newPhoneNum = val;
                        },
                      ),
                      Text(status, style: TextStyle(color: Colors.red))
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  RaisedButton(
                    color: Colors.green,
                    onPressed: () {
                      if(newPhoneNum.length > 9) 
                      {
                        details['phoneNum'] = newPhoneNum;
                        workerList[widget.index] = details;
                        updateWorker();
                        Navigator.of(context).pop();
                      }
                      else 
                      {
                        debugPrint(newPhoneNum);
                        setState(() {
                          status = "Mohon cek no tlp. kembali";
                        });
                      }
                    },
                    child: Text("Kirim"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('View Worker'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
          child: Builder(builder: (BuildContext dataContext) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Container(
                //   alignment: Alignment.centerRight,
                  // child: OutlineButton(
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: <Widget>[
                  //       Icon(Icons.edit),
                  //       SizedBox(
                  //         width: 10,
                  //       ),
                  //       Text('Edit')
                  //     ],
                  //   ),
                  //   onPressed: () {

                  //   },
                  // ),
                // ),
                Container(
                  // width: MediaQuery.of(context).size.width * 3 / 8,
                  // color: Colors.blueAccent,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    // color: Colors.orange,
                    height: (MediaQuery.of(context).size.width * 4 / 8)-30,
                    width: (MediaQuery.of(context).size.width * 4 / 8)-30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(100)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.network(
                          details['picture'],
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
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10 
                ),
                dataTemplate(dataContext, 'Nama', details['name']),
                SizedBox(
                  height: 15 
                ),
                dataTemplate(dataContext, 'DOB', details['dob']),
                SizedBox(
                  height: 15 
                ),
                dataTemplate(dataContext, 'Jenis Kelamin', (details['gender'] == 'M') ? 'L' : 'P'),
                SizedBox(
                  height: 15
                ),
                Row(
                  children: <Widget>[
                    dataTemplate(dataContext, 'No Tlp.', details['phoneNum']),
                    IconButton(
                      color: Colors.orange,
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _changePhoneDialog();
                      },
                    )
                  ],
                )
              ],
            );
          })
        ),
      ),
    );
  }

  Widget dataTemplate(context, dataName, dataContext) {
    return Container(
      child: new Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width/3-20,
            child: Text('$dataName', style: TextStyle(fontSize: 20),),
          ),
          // Text(':'),
          Container(
            // width: MediaQuery.of(context).size.width*2/3-20,
            child: Text(': $dataContext', style: TextStyle(fontSize: 20),),
          ),
        ],
      ),
    );
  }
}