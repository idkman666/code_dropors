import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


class CameraPreviewPage extends StatefulWidget {
  @override
  _CameraPreviewPageState createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {

  CameraController cameraController;
  List cameras;
  int selectedCameraIndex;
  String imgPath;



  Future _initCameraController(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.medium);
    cameraController.addListener(() {
      if (mounted) {
        setState(() {

        });
      }
    });

    if (cameraController.value.hasError) {
      print("camera error ${cameraController.value.errorDescription}");
    }

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }
    if (mounted) {
      setState(() {

      });
    }
  }

  //camera preview
  Widget _cameraPreviewWidget() {
    if (cameraController == null ||
        cameraController.value.isInitialized == false) {
      return loadingPage();
    }

    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }

  //row for toggle to select the camera
  Widget _cameraToggleRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(child: Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(onPressed: _onSwitchCamera,
          icon: Icon(
            _getCameraLensIcon(lensDirection),
            color: Colors.white10,
            size: 24,
          ),
          label: Text("${lensDirection.toString().substring(
              lensDirection.toString().indexOf('.') + 1).toUpperCase()}",
            style: TextStyle(
                color: Colors.white10,
                fontWeight: FontWeight.w300
            ),
          )),

    ));
  }


  //camera control bar with camera controls
  Widget _cameraControlWidget(context) {
    return Expanded(
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              FloatingActionButton(
                  child: Icon(Icons.camera, color: Colors.black,),
                  backgroundColor: Colors.white10,
                  onPressed: () {
                    _onCapturePressed(context);
                  })
            ],
          ),
        )
    );
  }

  Widget loadingPage() {
    return Center(
      child: SpinKitCircle(
        color: Colors.black,
        size: 50.0,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    availableCameras().then((value) {
      cameras = value;
      if(cameras.length> 0){
        setState(() {
          selectedCameraIndex = 0;
        });
        _initCameraController(cameras[selectedCameraIndex]).then((void v){});
      }else{
        print("no camera available");
      }
    }).catchError((onError){
      print("error: ${onError.hashCode}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  flex: 1,
                  child: _cameraPreviewWidget()
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _cameraToggleRowWidget(),
                      _cameraControlWidget(context),
                      Spacer(),
                    ],
                  ),
                ) ,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
    selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    _initCameraController(selectedCamera);
  }

  void _onCapturePressed(context) async{
    try {
      final path = join((await getTemporaryDirectory()).path,'${DateTime.now()}.jpeg');
      await cameraController.takePicture(path);
    }catch(e){
      _showCameraException(e);
    }
  }

}

IconData _getCameraLensIcon(CameraLensDirection lensDirection) {
  switch (lensDirection) {
    case CameraLensDirection.back:
      return CupertinoIcons.switch_camera;
    case CameraLensDirection.front:
      return CupertinoIcons.switch_camera_solid;
    case CameraLensDirection.external:
      return CupertinoIcons.photo_camera;
    default:
      return Icons.device_unknown;
  }
}

void _showCameraException(CameraException e) {
  String errorLText = 'Error : ${e.code}\n Error message :${e.description}';
}
