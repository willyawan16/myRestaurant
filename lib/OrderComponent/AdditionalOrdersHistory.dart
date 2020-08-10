import 'package:flutter/material.dart';

class AdditionalOrdersHistory extends StatefulWidget {
  List additionalOrders;
  int firstSubtotal;
  bool printAccess;

  AdditionalOrdersHistory({Key key, this.additionalOrders, this.firstSubtotal, this.printAccess}) : super(key: key);
  @override
  AdditionalOrdersHistoryState createState() => AdditionalOrdersHistoryState();
}

class AdditionalOrdersHistoryState extends State<AdditionalOrdersHistory> {
  
  @override
  Widget build(BuildContext context) {
    // debugPrint('${widget.additionalOrders}');

    // @override
    // void initState() {
      

    //   super.initState();
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text('Additional History'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.orange[50],
      body: (widget.additionalOrders.isNotEmpty)
      ? ListView.builder(
        shrinkWrap: true,
        itemCount: widget.additionalOrders.length,
        itemBuilder: (context, i) => orderCards(context, widget.additionalOrders[i], i+1),
        // orderCards(context, widget.additionalOrders[i]),
      )
      : Center(
        child: Text('No additional orders yet..', style: TextStyle(fontSize: 25),),
      ),
    );
  }

  Widget orderCards(BuildContext context, details, number) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 70,
          padding: EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                new Row(
                  // mainAxisAlignment: (widget.printAccess) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Order Tambahan $number ${(details['takeaway']) ? 'Take-Away' : ''}',style: TextStyle(fontSize: 20)),
                    (widget.printAccess)
                    ? IconButton(
                      disabledColor: (details['verified'] == 'yes') ? Colors.grey[400] : (details['verified'] == 'no') ? Colors.yellow[400] : Colors.red[400],
                      icon: Icon(Icons.print),
                      onPressed: (details['verified'] == 'yes')
                      ? () {

                      }
                      : null,
                    )
                    : IconButton(
                      disabledColor: (details['verified'] == 'yes') ? Colors.grey[400] : (details['verified'] == 'no') ? Colors.yellow[400] : Colors.red[400],
                      icon: Icon(Icons.print),
                      onPressed: null,
                    )
                  ],
                ),
                new Row(
                  children: <Widget>[
                    Text('Created by: ${details['createdBy']}'),
                    Text(' || '),
                    (details['verified'] == 'yes') 
                    ? Text('Terverifikasi')
                    : (details['verified'] == 'no') 
                      ? Text('Terverifikasi', style: TextStyle(fontWeight: FontWeight.bold)) 
                      : Text('Dibuang')
                  ],
                ),
              ],
            ),
          ),
          color: (details['verified'] == 'yes') ? Colors.grey[400] : (details['verified'] == 'no') ? Colors.yellow[400] : Colors.red[400],
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: details['orders'].length,
          itemBuilder: (context, i) => orderDetails(context, details['orders'][i], i),
        ),
        Container(
          color: (details['verified'] == 'yes') ? Colors.grey[300] : (details['verified'] == 'no') ? Colors.yellow[300] : Colors.red[300],
          height: 30,
          padding: EdgeInsets.only(right: 10),
          child: Text('${details['subtotal']}', style: TextStyle(fontSize: 20), textAlign: TextAlign.end,),
        ),
      ],
    );
  }

  Widget orderDetails(BuildContext context, details, index) {
    debugPrint('$details');
    double totWidth = MediaQuery.of(context).size.width;
    double iconWidth = 30.0;
    double priceWidth = 80.0;
    double detailsWidth = totWidth - iconWidth - priceWidth -15;
    return new StatefulBuilder(
      builder: (context, setState) {
        return Container(
          //height: 80,
          width: totWidth,
          padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
          // color: Colors.lightBlue[100],
          child: new Column(
            children: <Widget>[
              (index == 0)
              ? Padding(
                padding: EdgeInsets.only(right: 5),
                child: Divider(thickness: 1,),
              )
              : Padding(
                padding: EdgeInsets.only(right: 5),
                child: Divider(thickness: 0,),
              ),
              new Row(
                children: <Widget>[
                  // Icon
                  Container(
                    //padding: EdgeInsets.all(2),
                    height: 30,
                    width: iconWidth,
                    child: Center(
                      child: Text('x${details['quantity']}', style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    decoration: BoxDecoration(
                      // color: Colors.lightGreen,
                      border: Border.all(
                        color: Colors.orange,
                        width: 3
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                  ),
                  // Details
                  Container(
                    // color: Colors.lightBlueAccent,
                    width: detailsWidth,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 20,
                            //width: 290,
                            child: Text(details['menuname'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          ),
                          (details['description'] != '') 
                          ? Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(details['description']),
                          )
                          : Container(
                            padding: EdgeInsets.only(bottom: 10),
                          ),
                          Container(
                            height: 30,
                            child: Text('Edit', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                            // child: GestureDetector(
                            //   onTap: (){
                            //     _showEditDialog(context, details, index, orders);
                            //   },
                            //   child: Text('Edit', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            // ),
                          ),               
                        ],
                      ),
                    ),
                  ),
                  // Price
                  Container(
                    width: priceWidth,
                    child: Text((int.parse(details['menuprice'])*details['quantity']).toString(), style: TextStyle(fontSize: 18), textAlign: TextAlign.right,),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Divider(thickness: 1,),
              ),
            ],
          ),
        );
      }
    );
  }
}