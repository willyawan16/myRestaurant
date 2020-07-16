import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCode extends StatefulWidget {
  String restoId, restoDocId;

  QRCode({Key key, this.restoId, this.restoDocId}) : super(key: key);
  @override
  QRCodeState createState() => QRCodeState();
}

class QRCodeState extends State<QRCode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: QrImage(
            data: '${widget.restoDocId}${widget.restoId}_5',
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      ),
    );
  }
}