import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';


class TakePicture extends StatefulWidget {
  TakePicture({Key key, this.title, this.firestore, this.camerasList});
  var firestore;
  List<CameraDescription> camerasList;
  final String title;

  @override
  TakePictureState createState() {
    return new TakePictureState(this.camerasList );
  }
}

class TakePictureState extends State<StatefulWidget> {
  TakePictureState(this.cameraDescriptionList);
  String loadingText = "Loading Cameras";

  CameraController controller;

  List<CameraDescription> cameraDescriptionList;

  @override
  void initState() {
    // Need to get all of the Future stuff started here
    super.initState();
    controller = new CameraController(cameraDescriptionList[0], ResolutionPreset.medium);
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Take a picture"),
      ),
      body: testWidget(),
      /*body: FutureBuilder(

        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.active:
              return new Text("Active");
            case ConnectionState.done:
              controller = new CameraController(widget.camerasList[0], ResolutionPreset.medium);
              controller.initialize().then((_) {
                if (!mounted) {
                  return;
                }
                setState(() {});
              });
              return new AspectRatio(aspectRatio: controller.value.aspectRatio, child: CameraPreview(controller));
            case ConnectionState.waiting:
              return new Text("Waiting");
            case ConnectionState.none:
              return new Text("None");
          }
          return ListTile(title: Text("test"));
        },
      ),*/
    );
  }

  Widget testWidget(){
    if(!controller.value.isInitialized){
      return new Container();
    }
    return new AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: new CameraPreview(controller),
    );
  }
}


