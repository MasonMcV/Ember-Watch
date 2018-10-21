import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:location/location.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'license.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fire_list.dart';

class CameraExampleHome extends StatefulWidget {
  CameraExampleHome(this.firestore);
  Firestore firestore;
  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome> {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  Location location;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Ember Watch'),
      ),
      drawer: new Drawer(
        child: new ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            new DrawerHeader(
              child: null,
              decoration: new BoxDecoration(
                //color: Colors.red),
                image:
                    DecorationImage(image: new AssetImage('assets/Icon.png')),
              ),
            ),
            new ListTile(
                title: new Text('View Data', style: new TextStyle(fontSize: 30.0),),
                isThreeLine: true,
                subtitle: new Text(" "),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new FireList(firestore: widget.firestore,)));
                  //update state of app
                }),
            new ListTile(
                title: new Text('License', style: new TextStyle(fontSize: 30.0),),
                isThreeLine: true,
                subtitle: new Text(" "),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new LicensePg()));
                }),
          ],
        ),
      ),
      body: new Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _cameraTogglesRowWidget(),
                _thumbnailWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, double>> getLocation() async {
    var currentLocation = <String, double>{};

    var location = new Location();
    return await location.getLocation();
    currentLocation = null;
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: videoController == null && imagePath == null
            ? null
            : SizedBox(
                child: (videoController == null)
                    ? Image.file(File(imagePath))
                    : Container(
                        child: Center(
                          child: AspectRatio(
                              aspectRatio: videoController.value.size != null
                                  ? videoController.value.aspectRatio
                                  : 1.0,
                              child: VideoPlayer(videoController)),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink)),
                      ),
                width: 64.0,
                height: 64.0,
              ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isRecordingVideo
              ? onTakePictureButtonPressed
              : null,
        ),
        /*IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        )*/
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      //onNewCameraSelected(cameras[0]);
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              selected: (cameraDescription == cameras[0]) ? true : false,
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    var locationData;
    var awsKeys;
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) {
          showInSnackBar('Picture saved to $filePath');
          //http://www.google.com/searchbyimage/upload
          //testDio();
        }
      }
    }).then((dynamic IDKWhy) {
      locationData = getLocation();
    }).then((dynamic IDKWhy) {
      testDio(locationData, awsKeys);
    });
  }

  /*Future<List<String>> readFile() async {
    String path = "assets/keys.key";
    debugPrint("in readFile");
    try {
      List<String> verseLinesList;
      String wholeFile = await rootBundle.loadString(path);
      wholeFile.substring(2, wholeFile.length - 2);
      verseLinesList = wholeFile.split("\n");
      return verseLinesList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }*/

  void testDio(var locationDataMap, var awsKeys) async {
    Dio dio = new Dio();

    String awsSecretKey = "2KPh0X08rwdtVQMC1OOnKw21AUeHhvzhXSVu/D+s";
    String awsKey = "AKIAJPUHR4QFCAJAHU5A";

    var canonicalizedResource = "/ember-watch";

    /*var string = "POST" + "\n" + "\n" +
        "image/jpeg" + "\n" +
        */ /*DateTime.now().toString() + */ /*"\n" +
        canonicalizedResource;*/

    var base64 = Base64Codec.urlSafe();
    var secretAccessKey = utf8.encode(awsKey);
    var stringToSign = utf8.encode("test");
    String signature =
        base64.encode(Hmac(sha1, secretAccessKey).convert(stringToSign).bytes);
    /*FormData formdata = new FormData();
    File file = new File(imagePath);
    formdata.add("photos", new UploadFileInfo(file, imagePath));

    var response = await dio.post("http://ptsv2.com/t/ei8l8-1540111603/post", data: formdata, options: Options(

        method: 'POST',

        responseType: ResponseType.PLAIN // or ResponseType.JSON

    ));*/

    File file = new File(imagePath);
    var fileInfo = new UploadFileInfo(file, imagePath);
    var multipart = {'encoded_image': 'null', 'image_content': ''};
    FormData formData = new FormData.from({
      "name": "wendux",
      "file1": new UploadFileInfo(new File(imagePath), "upload1.jpg")
    });
    //response = await dio.post("/info", data: formData)
    var response;
    try {
      debugPrint("THIS");
      //response = await
      dio
          .post(
        "https://ember-watch.s3.amazonaws.com/",
        options: new Options(
            //method: "POST",
            //headers: {"Authorization": "AWS" + " " + awsKey + ":" + signature},
            ),
        data: formData,
      )
          .then((var test) {
        response = test;
        debugPrint("Printed, so this ran");
        debugPrint(response.data);
        debugPrint("test");
      });
    } on DioError catch (e) {
      debugPrint(e.toString());
      debugPrint("stuff hit the fan");
    }
  }

  /*void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) showInSnackBar('Saving video to $filePath');
    });
  }*/

  /*void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }*/

  /*Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }*/

  /*Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }*/

  /*Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
    VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }*/

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class CameraApp extends StatelessWidget {
  CameraApp(this.firestore);

  Firestore firestore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraExampleHome(firestore),
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
    );
  }
}

List<CameraDescription> cameras;

Future<Null> main() async {
  // Fetch the available cameras before initializing the app.
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'test',
    options: const FirebaseOptions(
      googleAppID: '1:107553084724:android:f5a141036d59379a',
      gcmSenderID: '107553084724',
      apiKey: 'AIzaSyDP7SobuX5USQHv0TCKZtuuGd8S7pHd4zQ',
      projectID: 'ember-watch-cb6ea',
    ),
  );
  final Firestore firestore = new Firestore(app: app);

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(CameraApp(firestore));
}
