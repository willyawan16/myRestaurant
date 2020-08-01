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
                title: Text('New Table Number'),
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
                    child: Text('cancel', style: TextStyle(color: Colors.grey),),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ), 
                  OutlineButton(
                    child: Text('Add', style: TextStyle(color: Colors.orange)),
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
                              'Table is existed!',
                              style: TextStyle(color: Colors.yellow),
                            ), 
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          );
                          _scaffoldKey.currentState.showSnackBar(snackbar);
                        }
                      } else {
                        FocusScope.of(context).requestFocus(newNumberNode);
                        final snackbar = SnackBar(
                          content: Text(
                            'Empty input!', 
                            style: TextStyle(color: Colors.yellow),
                          ), 
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
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
          title: Text('Help', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Welcome to Table Management'),
              SizedBox(
                height: 10,
              ),
              new Row(
                children: <Widget>[
                  Icon(Icons.add),
                  Text('-> add new Table Number')
                ],
              ),
              new Row(
                children: <Widget>[
                  Icon(Icons.grid_on),
                  Text('-> change grid display')
                ],
              ),
              new Row(
                children: <Widget>[
                  Icon(Icons.help_outline),
                  Text('-> help')
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text('Q: How to change table order?'),
              Text('A: Hold chosen table, then select destination'),
              SizedBox(
                height: 20,
              ),
              Text('Q: How to delete table?'),
              Text('A: Double tap chosen table'),
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
                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                height: 100,
                child: Text(
                  'NB: To show table\'s QR code, just press on the table grid below',
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
                  child: Text('Table Number is Empty!', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)
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