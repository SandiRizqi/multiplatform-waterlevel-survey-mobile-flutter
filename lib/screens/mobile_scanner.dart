import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? qrText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: MobileScanner(
        onDetect: (barcode, args) {
          if (barcode.rawValue != null) {
            final String code = barcode.rawValue!;
            setState(() {
              qrText = code;
            });
            Navigator.pop(context, qrText);  // Return the scanned code
          }
        },
      ),
    );
  }
}
