import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class CameraPreviewScreen extends StatefulWidget {
  String imgPath;
  CameraPreviewScreen({this.imgPath});
  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Image.file(File(widget.imgPath), fit: BoxFit.cover,)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 60,
                color: Colors.black,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.share, color: Colors.white10),
                    onPressed: (){
                      getBytes().then((bytes){
                        Share.file("Share via", basename(widget.imgPath), bytes.buffer.asUint8List(), "image/path");
                      });

                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<ByteData> getBytes()async{
    Uint8List bytes = File(widget.imgPath).readAsLinesSync() as Uint8List;
    return ByteData.view(bytes.buffer);
  }
}
