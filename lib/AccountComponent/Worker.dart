import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './NewWorker.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';


class Worker extends StatefulWidget {
  Map restoData;

  Worker({Key key, this.restoData}) : super(key: key);
  @override
  WorkerState createState() => WorkerState();
}

class WorkerState extends State<Worker> {
  List workerList = [];

  void initState() {
    super.initState();
    // workerList = widget.restoData['worker'];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('restaurant').document(widget.restoData['restoDocId']).snapshots(),
      builder: (context, snapshot) {
        Map _temp = {};
        List _workerList = [];
        if(!snapshot.hasData) return const Text('Loading');
        for(int i = 0; i < snapshot.data['worker'].length; i++){
          _temp.addAll({
            'name': snapshot.data['worker'][i]['name'],
            'dob': snapshot.data['worker'][i]['dob'],
            'gender': snapshot.data['worker'][i]['gender'],
            'phoneNum': snapshot.data['worker'][i]['phoneNum'],
            'role': snapshot.data['worker'][i]['role'],
            'picture': snapshot.data['worker'][i]['picture'],
          });
          _workerList.add(_temp);
          _temp = {};
        }
        workerList = _workerList;
        return Scaffold(
          backgroundColor: Colors.orange[50],
          appBar: AppBar(
            title: Text('My Worker'),
            backgroundColor: Colors.orange,
            leading: IconButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                        NewWorker(
                          restoId: widget.restoData['restaurantId'], 
                          restoDocId: widget.restoData['restoDocId'],
                        ),
                    ),
                  );
                },
                icon: Icon(Icons.person_add),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              // mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(20, 50, 10, 10),
                  child: Text('Worker List', style: TextStyle(fontSize: 20)),
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                    color: Colors.orange[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40), 
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: workerList.length,
                  itemBuilder: (context, i) => workerCard(workerList[i], i),
                ),
                Container(
                  height: 50,
                  color: Colors.orange[200],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget workerCard(details, index) {
    var paddingCard = (MediaQuery.of(context).size.width * 3 / 8)-30;
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[100],
        border: Border(
          top: BorderSide(width: (index == 0) ? 1.0 : 0.0, color: Colors.grey),
          // left: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
          // right: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
          bottom: BorderSide(width: 1.0, color: Colors.grey),
        ),
      ),
      height: 150,
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 3 / 8,
            // color: Colors.blueAccent,
            alignment: Alignment.center,
            child: Container(
              // color: Colors.orange,
              height: paddingCard,
              width: paddingCard,
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
          Container(
            width: MediaQuery.of(context).size.width * 5 / 8,
            // padding: EdgeInsets.fromLTRB(0,0,0,0),
            alignment: Alignment.center,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(details['name'].toString()),
                Text(details['dob'].toString()),
                (details['gender'].toString() == 'M')
                ? Text('MALE')
                : Text('FEMALE'),
                Text(details['phoneNum'].toString()),
                Text(details['role'].toString(), style: TextStyle(color: Colors.red)),
              ],
            ),
            // color: Colors.blue,
          ),
        ],
      ),
    );    
  }
}