import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:screenshot/screenshot.dart';
import 'package:text_editor/text_editor.dart';


class ImageEditingPage extends StatefulWidget {
  final File image;

  ImageEditingPage({this.image});

  @override
  _ImageEditingPageState createState() => _ImageEditingPageState();
}

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({this.point, this.areaPaint});
}

class _ImageEditingPageState extends State<ImageEditingPage> with TickerProviderStateMixin {
  final ScreenshotController screenshotController = ScreenshotController();
  Uint8List _imageFileUInt8;
  GlobalKey canvasKey = new GlobalKey();
  bool isImageLoaded = false;
  ui.Image image;
  List<DrawingArea> _points = [];
  Color selectedColor;
  double strokeWidth;
  BlendMode _blendMode;
  File imgFile;
  Image img;

  //values for text annotation
  Alignment focalPoint = Alignment.center;
  ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imgFile = widget.image;
    init();
    selectedColor = Colors.black;
    strokeWidth = 2.0;

    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _blendMode = BlendMode.multiply;
  }

  Future<Null> init() async {
    final bytes = await imgFile.readAsBytes();
    final ByteData data = bytes.buffer.asByteData();
    img = Image.file(imgFile);
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

  void selectColor() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select Color"),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) {
                    this.setState(() {
                      selectedColor = color;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    ImageDrawer imageDrawer = ImageDrawer(image: image);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit your post"),
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                child: Screenshot(
                  controller: screenshotController,
                  child: Column(
                    children: [
                      postArea(imageDrawer)
                    ],
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                //takes picture of the post in the area
                //users should be able to upload it to firebase
                TextButton(
                    onPressed: () {
                      screenshotController
                          .capture()
                          .then((Uint8List image) async {
                        setState(() {
                          _imageFileUInt8 = image;
                        });
                        showDialog(
                            context: context,
                            builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: Text("Captured"),
                                  ),
                                  body: Center(
                                    child: Column(
                                      children: [Image.memory(_imageFileUInt8)],
                                    ),
                                  ),
                                ));
                      }).catchError((onError) {
                        print(onError);
                      });
                    },
                    child: Icon(Icons.camera)),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _points.clear();
                      });
                    },
                    child: Icon(Icons.delete)),
                TextButton(
                    onPressed: () {
                      _cropImage();
                    },
                    child: Icon(Icons.crop))
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      icon: Icon(Icons.color_lens),
                      onPressed: () {
                        selectColor();
                      }),
                  Expanded(
                      child: Slider(
                          min: 1.0,
                          max: 30.0,
                          activeColor: selectedColor,
                          value: strokeWidth,
                          onChanged: (val) {
                            setState(() {
                              strokeWidth = val;
                            });
                          })),
                  IconButton(icon: Icon(Icons.layers_clear), onPressed: () {})
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  //post with picture
  //this is where you can draw lines
  Widget postArea(imageDrawer)
  {
    return Container(
      height: Image.file(imgFile).height,
      child: Stack(
        children: [
          FittedBox(
          child: GestureDetector(
            onPanDown: (detailData) {
              //imageDrawer.update(detailData.localPosition);
              //_points.add(detailData.localPosition);
              _points.add(DrawingArea(
                  point: detailData.localPosition,
                  areaPaint: Paint()
                    ..color = selectedColor
                    ..isAntiAlias = true
                    ..strokeWidth = strokeWidth
                    ..blendMode = _blendMode));
              imageDrawer.update(_points);
              canvasKey.currentContext
                  .findRenderObject()
                  .markNeedsPaint();
            },
            onPanUpdate: (detailData) {
              //imageDrawer.update(detailData.localPosition);
              _points.add(DrawingArea(
                  point: detailData.localPosition,
                  areaPaint: Paint()
                    ..color = selectedColor
                    ..isAntiAlias = true
                    ..strokeWidth = strokeWidth
                    ..blendMode = _blendMode));
              imageDrawer.update(_points);
              canvasKey.currentContext
                  .findRenderObject()
                  .markNeedsPaint();
            },
            onPanEnd: (detailData) {
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
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: postTextArea(),
          ),
        ]
      ),
    );
  }


  final fonts = [
    'OpenSans',
    'Billabong',
    'GrandHotel',
    'Oswald',
    'Quicksand',
    'BeautifulPeople',
    'BeautyMountains',
    'BiteChocolate',
    'BlackberryJam',
    'BunchBlossoms',
    'CinderelaRegular',
    'Countryside',
    'Halimun',
    'LemonJelly',
    'QuiteMagicalRegular',
    'Tomatoes',
    'TropicalAsianDemoRegular',
    'VeganStyle',
  ];
  TextStyle _textStyle = TextStyle(
    fontSize: 50,
    color: Colors.white,
    fontFamily: 'Billabong',
  );
  String _text = 'Sample Text';
  TextAlign _textAlign = TextAlign.center;

  Widget postTextArea()
  {
    return MatrixGestureDetector(onMatrixUpdate: (m, tm, sm, rm) {
      notifier.value = m;
    }, shouldRotate: true,
        shouldScale: true,
        shouldTranslate: true,
        focalPointAlignment: focalPoint,
        child: AnimatedBuilder(
      animation: notifier,
      builder: (ctx, child){
        return Transform(
          transform: notifier.value,
          child: Container(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              transitionBuilder: (child, animation ) {
                return ScaleTransition(scale: animation, child: child, alignment: focalPoint);
              },
              switchInCurve: Curves.ease,
              switchOutCurve: Curves.ease,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: TextEditor(
                      fonts: fonts,
                      paletteColors: [
                        Colors.black,
                        Colors.white,
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.yellow,
                        Colors.pink,
                        Colors.cyanAccent,
                      ],
                      text: "Hello",
                      textStyle: _textStyle,
                      textAlingment: _textAlign,
                      onEditCompleted: (style, align, text) {
                        setState(() {
                          _text = text;
                          _textStyle = style;
                          _textAlign = align;
                        });
                      },
                    )
                  )
                ],
              ),
            ),
          ),
        );
      },
    ));
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
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        Paint paint = points[i].areaPaint;
        canvas.drawLine(points[i].point, points[1+i].point, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

