import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_widgets/animated_widgets.dart';

import 'ShowTableQR.dart';

class TableManage extends StatefulWidget {
  Map tableData;
  String restoDocId, restoId;

  TableManage({Key key, this.tableData, this.restoDocId, this.restoId}) : super(key: key);
  @override
  TableManageState createState() => TableManageState();
}

class TableManageState extends State<TableManage> {

  List tableNum = [], previousTableNum;
  bool switchOrder;
  String newNumber;
  int selectedTable1, selectedTable2;
  int currentGridScale = 3;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FocusNode newNumberNode;

  void initState() {
    newNumber = '';
    switchOrder = false;
    newNumberNode = FocusNode();
    if(widget.tableData['tableList'].isNotEmpty) {
      for(int i = 0; i < widget.tableData['tableList'].length; i++) {
        tableNum.add(widget.tableData['tableList'][i]);
      }
    } else {
      tableNum = [];
    }
    currentGridScale = widget.tableData['gridScale'];
    super.initState();
  }

  void dispose() {
    newNumberNode.dispose();
    super.dispose();
  }

  Future<void> _newTableDialog(context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: new AlertDialog(
                title: Text('No meja baru'),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  height: 100,
                  // color: Colors.grey,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Number:'),
                            Container(
                              width: MediaQuery.of(dialogContext).size.width/3,
                              child: TextField(
                                autofocus: true,
                                focusNode: newNumberNode,
                                onChanged: (val) {
                                  newNumber = val;
                                },
                                style: TextStyle(fontFamily: 'Balsamiq_Sans'),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  labelText: 'No.',
                                  // hintText: 'Name of New Menu',
                                  labelStyle: TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('batal', style: TextStyle(color: Colors.grey),),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ), 
                  OutlineButton(
                    child: Text('Tambah', style: TextStyle(color: Colors.orange)),
                    onPressed: () {
                      if(newNumber.length != 0) {
                        debugPrint('${tableNum.indexOf(newNumber)}');
                        if(tableNum.indexOf(newNumber) == -1) {
                          tableNum.add(newNumber);
                          newNumber = '';
                          Navigator.of(dialogContext).pop();
                        } else {
                          final snackbar = SnackBar(
                            content: Text(
                              'No meja sudah ada',
                              style: TextStyle(color: Colors.yellow),
                            ), 
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          );
                          _scaffoldKey.currentState.showSnackBar(snackbar);
                        }
                      } else {
                        FocusScope.of(context).requestFocus(newNumberNode);
                        final snackbar = SnackBar(
                          content: Text(
                            'Kosong', 
                            style: TextStyle(color: Colors.yellow),
                          ), 
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 1),
                        );
                        _scaffoldKey.currentState.showSnackBar(snackbar);
                      }
                    },
                  ),
                ],
              ),
            );
          }
        );
      }
    ).then((value) => setState(() {}));
  }

  Future<void> _onDeleteTable(index) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          title: Text('Delete Table ${tableNum[index]}'),
          actions: <Widget>[
            FlatButton(
              child: Text('cancel', style: TextStyle(color: Colors.grey),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ), 
            OutlineButton(
              child: Text('Yes', style: TextStyle(color: Colors.orange),),
              onPressed: () {
                previousTableNum = tableNum;
                tableNum.removeAt(index);
                Navigator.of(dialogContext).pop();
              },
            ), 
          ],
        );
      }
    ).then((value) => setState(() {}));
  }

  Future<void> _onVerifyDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Save changes?'),
          actions: <Widget>[
            FlatButton(
              splashColor: Colors.grey[50],
              child: Text('cancel', style: TextStyle(color: Colors.grey),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ), 
            FlatButton(
              splashColor: Colors.red[50],
              child: Text('Discard', style: TextStyle(color: Colors.red),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ), 
            OutlineButton(
              highlightedBorderColor: Colors.orange,
              splashColor: Colors.orange[50],
              child: Text('Save', style: TextStyle(color: Colors.orange),),
              onPressed: () {
                _updateTable(widget.restoDocId);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ), 
          ],
        );
      }
    );
  }

  Future<void> _helpDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Bantuan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Selamat datang di pengaturan meja'),
              SizedBox(
                height: 10,
              ),
              new Row(
                children: <Widget>[
                  Icon(Icons.add),
                  Text('-> Tambah no meja baru')
                ],
              ),
              new Row(
                children: <Widget>[
                  Icon(Icons.grid_on),
                  Text('-> Ganti tampilan grid')
                ],
              ),
              new Row(
                children: <Widget>[
                  Icon(Icons.help_outline),
                  Text('-> Bantuan')
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text('P: Bagaimana mengganti urutan meja?'),
              Text('J: Tahan meja yang hendak diganti, tekan destinasiny'),
              SizedBox(
                height: 20,
              ),
              Text('P: Bagaimana hapus meja?'),
              Text('J: Tekan dua kali'),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay!', style: TextStyle(color: Colors.orange),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ), 
          ],
        );
      }
    );
  }

  Future<void> _updateTable(docId) async {
    var obj = {
      'gridScale': currentGridScale,
      'tableList':tableNum,
    };
    Firestore.instance.runTransaction((Transaction transaction) async{
      CollectionReference reference = Firestore.instance.collection('restaurant');
      await reference
      .document(docId)
      .updateData({
        'table': obj,
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Manage Table'),
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: Icon(Icons.arrow_back), 
            onPressed: () {
              _onVerifyDialog();
            }
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'change grid scale',
              icon: Icon(Icons.grid_on),
              onPressed: () {
                setState(() {
                  if(currentGridScale == 2) {
                    currentGridScale = 3;
                  } else if(currentGridScale == 3) {
                    currentGridScale = 4;
                  } else if(currentGridScale == 4) {
                    currentGridScale = 5;
                  } else if(currentGridScale == 5) {
                    currentGridScale = 2;
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.add), 
              onPressed: () {
                _newTableDialog(context);
              }
            ),
            IconButton(
              tooltip: 'help',
              icon: Icon(Icons.help_outline),
              onPressed: () {
                _helpDialog();
              },
            ),
          ],
        ),
        backgroundColor: Colors.orange[50],
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                height: 100,
                child: Text(
                  'Print QR code setiap meja agar karyawan dapat membuat order!',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                height: 80,
                child: Text(
                  'NB: Untuk menunjukkan QR code meja, tekanlah no meja',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20),)
                ),
              ),
              (tableNum.isNotEmpty)
              ? GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: currentGridScale,
                // children: tableNum.map<Widget>((item) => table(item)).toList(),
                children: mapIndexed(
                  tableNum,
                  (index, item) => table(item, index),
                ).toList(),
              )
              : Container(
                height: 500,
                child: Center(
                  child: Text('Tidak ada no meja', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)
                ),
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: (tableNum.isNotEmpty) ? Colors.orange[400] : Colors.orange[50],
                  // borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20),)
                ),
              ),
            ],
          ),
        ),
      ), 
      onWillPop: _onWillPop,
    );
  }
  
  Future<bool> _onWillPop() async{
    return false;
  }

  Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, 
    E Function(int index, T item) f
  ) sync* {
    var index = 0;

    for (final item in items) {
      yield f(index, item);
      index = index + 1;
    }
  }

  Widget table(content, index) {
    // bool shakeEnabled = false;
    return Container(
      child: new Material(
        child: InkWell(
          splashColor: Colors.grey,
          onLongPress: () {
            debugPrint(index.toString());
            setState(() {
              switchOrder = true;
              selectedTable1 = index;
            });
          },
          onDoubleTap: () {
            _onDeleteTable(index);
            
          },
          onTap: (switchOrder)
          ? (index != selectedTable1)
            ? () {
              debugPrint(index.toString());
              setState(() {
                selectedTable2 = index;
                switchingTable();
                switchOrder = false;
              });
            }
            : () { 
              final snackbar = SnackBar(content: Text('This table is selected! Choose another one.'),);
              _scaffoldKey.currentState.showSnackBar(snackbar);
            }
          : () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ShowTableQR(
                  restoDocId: widget.restoDocId, 
                  restoId: widget.restoId,
                  tableNum: content,
                )),
            );
          },
          child: Container(
            height: double.infinity,
            child: Center(
              child: ShakeAnimatedWidget(
                enabled: switchOrder,
                duration: Duration(milliseconds: 250),
                shakeAngle: Rotation.deg(z: 10),
                curve: Curves.linear,
                child: Text(content.toString(), style: TextStyle(fontSize: 24.0),),
              ),
            ),
          )
        ),
        color: Colors.transparent,
      ),
      decoration: BoxDecoration(
        color: (switchOrder && selectedTable1 == index) 
        ? Colors.grey
        : Colors.orange[200],
        border: Border.all(color: Colors.black, width: 0.1),
      ),
    );
  } 

  switchingTable() {
    setState(() {
      var _temp = tableNum[selectedTable1];
      tableNum[selectedTable1] = tableNum[selectedTable2];
      tableNum[selectedTable2] = _temp;
    });
  }
}