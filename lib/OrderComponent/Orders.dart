import 'package:flutter/material.dart';
import './OrderList.dart';
import './HistoryList.dart';
import './NewOrder.dart';
import '../MenuComponent/NewMenu.dart';

class Orders extends StatefulWidget {
  String restoId, restoDocId;

  Orders({Key key, this.restoId, this.restoDocId}) : super(key: key);
  @override
  OrdersState createState() => OrdersState();
}

class BounceScrollBehavior extends ScrollBehavior {
  @override
  getScrollPhysics(_) => const BouncingScrollPhysics();
}

class OrdersState extends State<Orders> {
  int count;
  List inUseTable = [];

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
              Text('Selamat Datang di Order'),
              SizedBox(
                height: 10,
              ),
              // Text('- Every orders must be printed in invoice to be verified'),
              Text('- Setiap order harus di-print terlebih dahulu untuk diverifikasi'),
              SizedBox(
                height: 10,
              ),
              // Text('- If the order is verified, the status of order will be changed to "On going.."'),
              Text('- Jika sudah diverifikasi, status order akan berubah menjadi "On going.."'),
              SizedBox(
                height: 20,
              ),
              Text(
                'Gerakan:', 
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline
                ),
              ),
              // Text('- On tap order -> Overview order summary / add order'),
              Text('- Tekan sekali -> Untuk melihat / tambah order'),
              SizedBox(
                height: 5,
              ),
              // Text('- On double tap order -> Change status to Done!'),
              Text('- Tekan dua kali -> Untuk ganti status jadi "Done!"'),
              SizedBox(
                height: 5,
              ),
              Text('- Tekan dan Tahan -> Hapus order'),
              SizedBox(
                height: 20,
              ),
              Text(
                'Pertanyaan:',
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline
                ),
              ),
              // Text('P: Can I change customer\'s table number'),
              // Text('J: No, you can\'t'),
              Text('P: Apakah no meja customer dapat diubah?'),
              Text('J: Tidak'),
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

  @override
  Widget build(BuildContext context) {
    // debugPrint('${widget.restoDocId}');
    return ScrollConfiguration(
      behavior: BounceScrollBehavior(),
      child: DefaultTabController(
        length: 2, 
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Text('Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),),
            backgroundColor: Colors.orange[100],
            actions: <Widget>[
              IconButton(
                color: Colors.black,
                icon: Icon(Icons.help_outline),
                onPressed: () {
                  _helpDialog();
                },
              ),    
            ],
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: Colors.white,
              labelColor: Colors.orange,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)),
                  color: Colors.orange[50]
              ),
              tabs: <Widget>[
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Orders', style: TextStyle(fontFamily: 'Balsamiq_Sans'),),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('History', style: TextStyle(fontFamily: 'Balsamiq_Sans')),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OrderList(
                restoId: widget.restoId, 
                count: (val){
                  count = val;
                },
                inUseTable: (val) {
                  inUseTable = val;
                },
              ),
              HistoryList(restoId: widget.restoId),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewOrder(restoId: widget.restoId, count: count, restoDocId: widget.restoDocId, inUseTable: inUseTable)),
              );
            },
            label: Text('Order Baru'),
            icon: Icon(Icons.assignment),
            backgroundColor: Colors.orangeAccent[400],
          ),
        ),
      ),
    );
  }
}