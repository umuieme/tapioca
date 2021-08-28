import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_compress/video_compress.dart';

class VideoCaptureScreen extends StatefulWidget {
  @override
  _VideoCaptureScreenState createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool isInitialized = false;
  bool isRecording = false;
  bool isCompressing = false;
  bool _shouldCompress = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();

      controller = CameraController(
        cameras.firstWhere(
            (element) => element.lensDirection == CameraLensDirection.back),
        ResolutionPreset.high,
        enableAudio: true,
      );
      await controller?.initialize();
      if (Platform.isAndroid)
        await controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);

      isInitialized = true;
      setState(() {});
    } on CameraException catch (e) {
      print(e);
    }
  }

  Future<String?> compressVideo(String path) async {
    setState(() {
      isCompressing = true;
    });
    try {
      var mediaInfo = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.HighestQuality,
        deleteOrigin: false, // It's false by default
      );
      print("compress video ==== ${mediaInfo?.toJson()}");
      setState(() {
        isCompressing = false;
      });
      return mediaInfo?.path;
    } catch (error) {
      setState(() {
        isCompressing = false;
      });
    }
  }

  startRecordingPressed() async {
    try {
      if (controller == null) return;
      if (controller!.value.isRecordingVideo) {
        var file = await controller?.stopVideoRecording();
        setState(() {
          isRecording = false;
        });
        print("recoreded video === ${file?.path}");
        if (file != null) {
          if (_shouldCompress) {
            var compressed = await compressVideo(file.path);
            Navigator.pop(context, compressed);
          } else {
            Navigator.pop(context, file.path);
          }
        }
      } else {
        await controller?.prepareForVideoRecording();
        await controller?.startVideoRecording();
        setState(() {
          isRecording = true;
        });
      }
    } catch (error, stack) {
      print(stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.done))],
      ),
      body: _buildCameraPreview(),
    );
  }

  Widget _buildCameraPreview() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              controller != null && (controller?.value.isInitialized ?? false)
                  ? CameraPreview(
                      controller!,
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: IconButton(
                    onPressed: this.startRecordingPressed,
                    icon: Icon(
                      Icons.circle,
                      color: this.isRecording ? Colors.red : Colors.blue,
                      size: 48,
                    )),
              ),
              if (isCompressing)
                Positioned.fill(
                    child: Center(child: CircularProgressIndicator()))
            ],
          ),
        ),
        InkWell(
          onTap: () => this.setState(() {
            _shouldCompress = !_shouldCompress;
          }),
          child: Row(
            children: [
              Checkbox(
                  value: _shouldCompress,
                  onChanged: (value) => this.setState(() {
                        _shouldCompress = value ?? false;
                      })),
              Text("Should Compress")
            ],
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}
