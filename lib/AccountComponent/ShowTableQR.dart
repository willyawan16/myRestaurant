import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowTableQR extends StatefulWidget {
  String restoDocId, restoId, tableNum;

  ShowTableQR({Key key, this.restoDocId, this.restoId, this.tableNum}) : super(key: key);
  @override
  ShowTableQRState createState() => ShowTableQRState();
}

class ShowTableQRState extends State<ShowTableQR> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new QrImage(
              data: '${widget.restoDocId}${widget.restoId}_${widget.tableNum}',
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(
              height: 20,
            ),
            Text('Meja', style: TextStyle(fontSize: 20),),
            Text('${widget.tableNum}', style: TextStyle(fontSize: 70),),
          ],
        ),
      ),
    );
  }
}