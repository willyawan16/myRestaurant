import 'package:flutter/material.dart';

class MenuList extends StatefulWidget {
  final String category;
  final List wholeMenu;

  final Function(List) onAddMenu;

  MenuList({Key key, @required this.category, @required this.wholeMenu, this.onAddMenu}) : super(key: key);
  @override
  MenuListState createState() => MenuListState();
}

class MenuListState extends State<MenuList> { 
  TextEditingController quantityFood, descOrder;
  List sortedMenu;
  int indexSorted, indexWhole;

  FocusNode quantityFoodNode;

  @override
  void initState() {
    super.initState();
    quantityFood = TextEditingController(text: '1');
    descOrder = TextEditingController(text: '');

    quantityFoodNode = new FocusNode();
  }

  @override
  void dispose(){
    quantityFood.dispose();
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
      body: viewMenu(),
    );
  }

  void resetDetails() {
    setState(() {
      descOrder = TextEditingController(text: '');
      quantityFood = TextEditingController(text: '1');
    });
  }

  Future<void> _showAddDialog(BuildContext context, TextEditingController quantityFood, index) {
    // debugPrint(quantityFood.text);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add ${sortedMenu[index]['name']}'),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: 170,
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
                      //     addFunction();
                      //     debugPrint('oke');
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
                      Container(
                        height: 30,
                        width: 50,
                        child: TextFormField(
                          focusNode: quantityFoodNode,
                          controller: quantityFood,
                          keyboardType: TextInputType.number,
                        ),
                      ),
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
                  Navigator.of(context).pop();
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
                  if(quantityFood.text.length != 0) 
                  {
                    widget.onAddMenu([sortedMenu[index]['key'], descOrder.text, int.parse(quantityFood.text), sortedMenu[index]['name'], sortedMenu[index]['price']]);
                    debugPrint('added ${sortedMenu[index]['name']}');
                    Navigator.of(context).pop();
                    resetDetails();
                  }
                  else
                  {
                    FocusScope.of(context).requestFocus(quantityFoodNode);
                  }
                }, 
                child: Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
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

    return ListView.builder(
      itemCount: _sortedMenu.length,
      itemBuilder: (context, i) => menuDetails(context, _sortedMenu[i], i),
    );
  }

  Widget menuDetails(BuildContext context, document, int index) {
    var totWidth = MediaQuery.of(context).size.width;
    var widthDetail = totWidth * 0.5;
    var widthIcon = totWidth / 12;
    var whPic = totWidth - ( widthDetail + widthIcon) - 48;
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              _showAddDialog(context, quantityFood, index);
            },
            child: Container(
              color: Colors.white,
              height: 150,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 10)),
                    Container(
                      height: whPic,
                      width: whPic,
                      color: Colors.red,
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
                              height: 30,
                              width: widthDetail,
                              //color: Colors.yellow[100],
                              child: Text(document['name'], style: TextStyle(fontSize: 20),),
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
          Divider(thickness: 5,)
        ],
      ),
    );
  }
}