import 'package:flutter/material.dart';

import 'package:flutter_counter/flutter_counter.dart';

class MenuList extends StatefulWidget {
  final String category, whoCall;
  final List wholeMenu, orderList;

  final Function(Map) onAddMenu, onUpdateMenu;
  final Function(int) getIndex, updateSubtotal;
  final Function(bool) changed;

  MenuList({Key key, @required this.category, @required this.wholeMenu, this.onAddMenu, this.orderList, this.onUpdateMenu, this.getIndex, this.updateSubtotal, @required this.whoCall, this.changed}) : super(key: key);
  @override
  MenuListState createState() => MenuListState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class MenuListState extends State<MenuList> { 
  TextEditingController descOrder;
  List sortedMenu;
  int indexSorted, indexWhole, quantityFood;
  bool addStatus;

  FocusNode quantityFoodNode;

  @override
  void initState() {
    super.initState();
    descOrder = TextEditingController(text: '');
    quantityFood = 1;
    quantityFoodNode = new FocusNode();
  }

  @override
  void dispose(){
    descOrder.dispose();
    super.dispose();
  }

  void getIndex(int index){
    int _indexSorted = index;
    int _wholeSorted = widget.wholeMenu.indexOf(sortedMenu[_indexSorted]);
    setState(() {
      indexSorted = _indexSorted;
      indexWhole = _wholeSorted;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.orange[200],
      body: viewMenu(),
    );
  }

  void resetDetails() {
    setState(() {
      descOrder = TextEditingController(text: '');
      quantityFood = 1;
    });
  }

  Future<void> _showAddDialog(BuildContext context, int quantityFood, TextEditingController descOrder, index, addStatus) {
    // debugPrint(quantityFood.text);
    int before = quantityFood;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext addcontext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: new AlertDialog(
                title: Text('Add ${sortedMenu[index]['name']}'),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Container(
                  height: 200,
                  // color: Colors.grey,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: TextField(
                            controller: descOrder,
                            maxLength: 60,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Additional Details',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            // GestureDetector(
                            //   onTap: () {
                            //     quantityFood++;
                            //     debugPrint(quantityFood.toString());
                            //   },
                            //   child: Container(
                            //     height: 30,
                            //     width: 30,
                            //     decoration: BoxDecoration(
                            //       border: Border.all(),
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //     child: Icon(Icons.add),
                            //   ),
                            // ),
                            // SizedBox(
                            //   width: 5,
                            // ),
                            Counter(
                              initialValue: quantityFood,
                              minValue: 1,
                              maxValue: 10,
                              step: 1,
                              decimalPlaces: 0,
                              buttonSize: 30,
                              color: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  quantityFood = value;
                                });
                              },
                            ),
                            // Container(
                            //   height: 30,
                            //   width: 50,
                            //   child: TextFormField(
                            //     focusNode: quantityFoodNode,
                            //     controller: quantityFood,
                            //     keyboardType: TextInputType.number,
                            //   ),
                            // ),
                            // SizedBox(
                            //   width: 5,
                            // ),
                            // GestureDetector(
                            //   onTap: () {
                            //     debugPrint('tes');
                            //   },
                            //   child: Container(
                            //     height: 30,
                            //     width: 30,
                            //     decoration: BoxDecoration(
                            //       border: Border.all(),
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //     child: Icon(Icons.remove),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(addcontext).pop();
                        resetDetails();
                      }, 
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10),
                    child: OutlineButton(
                      onPressed: () {
                        var check = false;
                        var indexRes;
                        for(int i = 0; i < widget.orderList.length; i++) {
                          if(widget.orderList[i]['key'] == sortedMenu[index]['key']) {
                            check = true;
                            indexRes = i;
                            break;
                          }
                        }
                        if(check) {
                          // update existing
                          widget.getIndex(indexRes);
                          widget.onUpdateMenu({'key': sortedMenu[index]['key'], 'description': descOrder.text, 'quantity': quantityFood, 'menuname': sortedMenu[index]['name'], 'menuprice': sortedMenu[index]['price']});
                          debugPrint('-------------------------------------------------------');
                          debugPrint('updated ${sortedMenu[index]['name']} in orderList');
                          if(widget.whoCall == 'AdditionalOrder')
                            quantityFood -= before; 
                        } else {
                          // new
                          widget.onAddMenu({'key': sortedMenu[index]['key'], 'description': descOrder.text, 'quantity': quantityFood, 'menuname': sortedMenu[index]['name'], 'menuprice': sortedMenu[index]['price']});
                          debugPrint('-------------------------------------------------------');
                          debugPrint('added ${sortedMenu[index]['name']} to orderList');
                        }
                        if(widget.whoCall == 'AdditionalOrder'){
                          widget.updateSubtotal(int.parse(sortedMenu[index]['price'])*quantityFood);
                          widget.changed(true);
                        }
                        Navigator.of(addcontext).pop();
                        resetDetails();
                      }, 
                      child: Text(
                        (addStatus)
                        ? 'Add'
                        : 'Update',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  } 

  Widget viewMenu() {
    List _sortedMenu = [];
    for(int i = 0; i < widget.wholeMenu.length; i++){
      if(widget.wholeMenu[i]['category'] == widget.category){
        _sortedMenu.add(widget.wholeMenu[i]);
      }
    }
    _sortedMenu.sort((a, b) {
      return a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase());
    });
    
    sortedMenu = _sortedMenu;

    return ScrollConfiguration(
      behavior: BounceScrollBehavior(),
      child: ListView.builder(
        itemCount: _sortedMenu.length,
        itemBuilder: (context, i) => menuDetails(context, _sortedMenu[i], i, _sortedMenu),
      ),
    );
  }

  Widget menuDetails(BuildContext context, document, int index, wholeDoc) {
    var totWidth = MediaQuery.of(context).size.width;
    var widthDetail = totWidth * 0.5;
    var widthIcon = totWidth / 12;
    var whPic = totWidth - ( widthDetail + widthIcon) - 48;
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              // var check = false;
              addStatus = true;
              for(int i = 0; i < widget.orderList.length; i++) {
                if(widget.orderList[i]['key'] == sortedMenu[index]['key']) {
                  setState(() {
                    addStatus = false;
                    quantityFood = widget.orderList[i]['quantity'];
                    descOrder = TextEditingController(text: widget.orderList[i]['description']);
                  });
                  break;
                }
              }
              _showAddDialog(context, quantityFood, descOrder, index, addStatus);
            },
            child: Container(
              color: Colors.orange[50],
              height: 150,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 10)),
                    Container(
                      height: whPic,
                      width: whPic,
                      color: Colors.white,
                      child: (document['picture'] != null) 
                      ? Image.network(document['picture'])
                      : Container(),
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
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 1,
          ),
          (index == wholeDoc.length-1)
          ? SizedBox(height: 100)
          : Container(),
        ],
      ),
    );
  }
}