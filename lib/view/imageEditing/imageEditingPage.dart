import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:screenshot/screenshot.dart';
import 'package:flutter/services.dart' show rootBundle;

class ImageEditingPage extends StatefulWidget {
  final File image;
  ImageEditingPage({this.image});
  @override
  _ImageEditingPageState createState() => _ImageEditingPageState();
}

class DrawingArea{
  Offset point;
  Paint areaPaint;
  DrawingArea({this.point, this.areaPaint});
}

class _ImageEditingPageState extends State<ImageEditingPage> {
  final ScreenshotController screenshotController = ScreenshotController();
  Uint8List _imageFile;
  GlobalKey canvasKey = new GlobalKey();
  bool isImageLoaded = false;
  ui.Image image;
  List<DrawingArea> _points = [];
  Color selectedColor;
  double strokeWidth;
  BlendMode _blendMode;
  File imgFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imgFile = widget.image;
    init();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
    _blendMode = BlendMode.multiply;
  }

  Future<Null> init() async {
    final bytes = await imgFile.readAsBytes();
    final ByteData data = bytes.buffer.asByteData();
    image = await loadImage(Uint8List.view(data.buffer));
  }
  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  void selectColor(){
    showDialog(context: context, builder: (context) =>  AlertDialog(
      title: Text("Select Color"),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color){
            this.setState(() {
              selectedColor = color;
            });
          },
        ),
      ),actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: Text("Close"))
    ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    ImageDrawer imageDrawer = ImageDrawer(image: image);

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit your post"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Column(
                children: [
                  FittedBox(
                    child: GestureDetector(
                      onPanDown: (detailData) {
                        //imageDrawer.update(detailData.localPosition);
                        //_points.add(detailData.localPosition);
                        _points.add(DrawingArea(
                          point: detailData.localPosition,
                          areaPaint:  Paint()
                          ..color = selectedColor
                          ..isAntiAlias = true
                          ..strokeWidth = strokeWidth
                            ..blendMode = _blendMode

                        ));
                        imageDrawer.update(_points);
                        canvasKey.currentContext
                            .findRenderObject()
                            .markNeedsPaint();
                      },
                      onPanUpdate: (detailData) {
                        //imageDrawer.update(detailData.localPosition);
                        _points.add(DrawingArea(
                            point: detailData.localPosition,
                            areaPaint:  Paint()
                              ..color = selectedColor
                              ..isAntiAlias = true
                              ..strokeWidth = strokeWidth
                            ..blendMode = _blendMode

                        ));
                        imageDrawer.update(_points);
                        canvasKey.currentContext
                            .findRenderObject()
                            .markNeedsPaint();
                      },
                      onPanEnd: (detailData){
                        _points.add(null);
                      },
                      child: isImageLoaded == false
                          ? Container(
                              child: Text("loading"),
                            )
                          : FittedBox(
                              child: SizedBox(
                                width: image.width.toDouble(),
                                height: image.height.toDouble(),
                                child: CustomPaint(
                                    key: canvasKey,
                                    size: MediaQuery.of(context).size,
                                    painter: imageDrawer,
                                    ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              TextButton(
                  onPressed: () {
                    screenshotController.capture().then((Uint8List image) async {
                      setState(() {
                        _imageFile = image;
                      });
                      showDialog(
                          context: context,
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text("Captured"),
                            ),
                            body: Center(
                              child: Column(
                                children: [Image.memory(_imageFile)],
                              ),
                            ),
                          ));
                    }).catchError((onError) {
                      print(onError);
                    });
                  },
                  child: Icon(Icons.camera)),
                TextButton(onPressed: (){
                  setState(() {
                    _points.clear();
                  });
                  }, child: Icon(Icons.delete)),
                TextButton(onPressed: (){
                  _cropImage();
                }, child: Icon(Icons.crop))
              ]
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.9,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(20.0))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(icon: Icon(Icons.color_lens), onPressed: (){
                    selectColor();
                  }),
                  Expanded(child: Slider(
                    min: 1.0,
                    max: 7.0,
                    activeColor: selectedColor,
                    value: strokeWidth ,
                      onChanged:(val){
                      setState(() {
                        strokeWidth = val;
                      });
                  })),
                  IconButton(icon: Icon(Icons.layers_clear), onPressed: (){

                  })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imgFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() {
        imgFile = croppedFile;
      });
      init();
    }
  }
}



class ImageDrawer extends CustomPainter {
  ui.Image image;
  ImageDrawer({this.image});
  List<DrawingArea> points = [];

  void update(List<DrawingArea> offset) {
    points = offset;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());
    for(int i = 0; i< points.length - 1 ; i++)
      {
        if(points[i] != null && points[i+1] != null)
          {
            Paint paint = points[i].areaPaint;
            canvas.drawCircle(points[i].point, 10, paint);
          }
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
// Screenshot(
// controller: screenshotController,
// child: Column(
// children: [
// FittedBox(
// child: SizedBox(
// width: MediaQuery.of(context).size.width,
// height: MediaQuery.of(context).size.width,
// child: Image.asset(
// "assets/dog.jpg",
// fit: BoxFit.cover,
// ),
// ),
// )
// ],
// ),
// ),
