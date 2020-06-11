import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class HistoryList extends StatefulWidget {
  @override
  HistoryListState createState() => HistoryListState();
}

// class ExpansionItem {
//   ExpansionItem({
//     this.isExpanded: false, 
//     this.header, 
//     this.body
//   });

//   bool isExpanded;
//   final String header;
//   final List body;
// }

class HistoryListState extends State<HistoryList> {
  List yesterday = [];
  List twoDaysAgo = [];
  List oneWeekMore = [];
  List all = [];
  // List<ExpansionItem> _items = <ExpansionItem>[];
  List<String> expansionHeader = ['Yesterday', '2 days ago', 'One week ago'];

  @override
  void initState() {
    super.initState();
    // if(yesterday.isNotEmpty || twoDaysAgo.isNotEmpty || oneWeekMore.isNotEmpty) {
    //   _items = <ExpansionItem>[
    //     ExpansionItem(header: 'Yesterday', body: yesterday),
    //     ExpansionItem(header: '2 days ago', body: twoDaysAgo),
    //     ExpansionItem(header: 'One week ago', body: oneWeekMore),
    //   ];
    // }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance.collection('orderList').snapshots(),
        builder: (context, snapshot) {
          List orderList = [];
          List _yesterday = [];
          List _twoDaysAgo = [];
          List _oneWeekMore = [];
          Map _temp = {};
          var date, date2, time, timeago;
          if(!snapshot.hasData) return const Text('Loading');
          for(int i = 0; i < snapshot.data.documents.length; i++) {
            Timestamp t = snapshot.data.documents[i]['date'];
            DateTime d = t.toDate();
            date = DateFormat('EEE, MMM d, ''yy').format(d);
            date2 = DateFormat('yyyy-MM-dd').format(d);
            // debugPrint(date2.toString());
            // debugPrint(date2.toString());
            // debugPrint(Jiffy(date2).fromNow().toString());
            timeago = Jiffy(date2).fromNow().toString();
            time = DateFormat('h:mm a').format(d);
            _temp.addAll({
              'customer': snapshot.data.documents[i]['customer'],
              'date': date,
              'time': time,
              'timeago': timeago,
              'orders': snapshot.data.documents[i]['orders'],
              'progress': snapshot.data.documents[i]['progress'],
              'additionalOrder': snapshot.data.documents[i]['additionalOrder'],
              'additionalOrderProgress': snapshot.data.documents[i]['additionalOrderProgress'],
              'paid': snapshot.data.documents[i]['paid'],
              'status': snapshot.data.documents[i]['status'],
              'key': snapshot.data.documents[i].documentID,
            });
            orderList.add(_temp);
            if(_temp['timeago'] == 'a day ago') {
              _yesterday.add(_temp);
            } else if(_temp['timeago'] == 'two days ago') {
              _twoDaysAgo.add(_temp);
            } else {
              _oneWeekMore.add(_temp);
            }
            _temp = {};
          }
          orderList.sort((a, b) {
            return a['time'].compareTo(b['time']);
          });
          yesterday.sort((a, b) {
            return a['time'].compareTo(b['time']);
          });
          twoDaysAgo.sort((a, b) {
            return a['time'].compareTo(b['time']);
          });
          yesterday = _yesterday;
          twoDaysAgo = _twoDaysAgo;
          oneWeekMore = _oneWeekMore;
          // debugPrint(yesterday.length.toString());
          // debugPrint(twoDaysAgo.length.toString());
          // debugPrint(oneWeekMore.length.toString());

          // debugPrint('ini: ${Jiffy(orderList[0]['date']).fromNow()}');
          all = [yesterday, twoDaysAgo, oneWeekMore];
          return body();
        },
      ),
    );
  }

  Widget body(){
    // debugPrint(_items[2].body.toString());
    // return ListView.builder(
    //   itemCount: ,
    //   itemBuilder: (BuildContext context, int index) {
    //     // return buildExpansion(_items, index);
        // return _buildPanel(index);
    //   },
    // );
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: ListView.builder(
        itemCount: expansionHeader.length,
        itemBuilder: (context, i) => _buildExpansion(i),
      ),
    );
  }
  
  Widget _buildExpansion(index){
    return ExpansionTile(
      title: Text(expansionHeader[index]),
      children: <Widget>[
        Column(
          children: mapIndexed(
            all[index],
            (index, item) => orderDetails(context, index, item),
          ).toList(),
        ),
      ],
    );
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

  Widget orderDetails(BuildContext context, index, details) {
    var totWidth = MediaQuery.of(context).size.width - 20;
    var widthNum = totWidth * 0.3;
    var widthDetail = totWidth * 0.5;
    var widthLeft = totWidth - widthNum - widthDetail -10;
    var totHeight = 150.0;
    List progress = ['Waiting..', 'Serving..', 'Done!'];
    // debugPrint('[$index]: ${progress[progressCount]}');
    return GestureDetector(
      child: Container(
        height: totHeight,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Row(
            children: <Widget>[
              Container(
                // height: 100,
                width: widthNum,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                ),
                child: Center(
                  child: ListTile(
                    title: Text(
                      'Order',
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Text(
                      (index+1).toString(), 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: widthDetail,
                // color: Colors.indigo,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(details['customer'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        child: Text('Status: ${details['status'][0]}'),
                      ),
                      Container(
                        child: Text('Time: ${details['time']}'),
                      ),
                      Container(
                        child: RichText(
                          text: TextSpan(
                            text: 'Progress: ',
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${progress[details['progress']]}', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Text('Paid: -'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0,10,5,10),
                // color: Colors.yellow,
                width: widthLeft,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: totHeight * 0.6-10,
                      // color: Colors.amber,
                      child: (details['status'][1] != 0)
                      ? ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 70),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green,
                          ),
                          child: Center(
                            child: Text(
                              'Table ${details['status'][1]}', 
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,shadows: [
                                  Shadow( // bottomLeft
                                    offset: Offset(-0.5, -0.5),
                                    color: Colors.white
                                  ),
                                  Shadow( // bottomRight
                                    offset: Offset(0.5, -0.5),
                                    color: Colors.white
                                  ),
                                  Shadow( // topRight
                                    offset: Offset(0.5, 0.5),
                                    color: Colors.white
                                  ),
                                  Shadow( // topLeft
                                    offset: Offset(-0.5, 0.5),
                                    color: Colors.white
                                  ),
                                ]
                              ), 
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                      : Container(),
                    ),
                    // Container(
                    //   height: totHeight * 0.2-10,

                    //   // color: Colors.pink,
                    //   child: Text('Timer'),
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}