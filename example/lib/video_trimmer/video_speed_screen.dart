import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';
import 'package:tapioca_example/video_player_screen.dart';
import 'package:video_player/video_player.dart';

class VideoSpeedScreen extends StatefulWidget {
  @override
  _VideoSpeedScreenState createState() => _VideoSpeedScreenState();
}

class _VideoSpeedScreenState extends State<VideoSpeedScreen> {
  PickedFile? _video;
  bool isLoading = false;
  bool isVideEditProcessing = false;
  VideoPlayerController? _controller;

  initState() {
    super.initState();
    pickAssetVideo();
  }

  pickAssetVideo() async {
    try {
      final byteData = await rootBundle.load('assets/test.mp4');

      final file = File('${(await getTemporaryDirectory()).path}/test.mp4');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      _video = PickedFile(file.path);
      initializeVideo();
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  initializeVideo() async {
    if (_video == null) return;
    _controller = VideoPlayerController.file(File(_video!.path));
    await _controller!.initialize();
    // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    _controller?.play();
    setState(() {});
    print("output video  ==== ${_controller!.value.duration.inSeconds}");
  }

  _onVideoSelectPressed() async {
    await _pickVideo();
    await initializeVideo();
  }

  _pickVideo() async {
    try {
      PickedFile? video =
          await ImagePicker().getVideo(source: ImageSource.gallery);
      if (video == null) return;
      print("videopath: ${video.path}");
      _video = video;
      isLoading = true;
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  onDonePressed() async {
    try {
      setState(() {
        isVideEditProcessing = true;
      });
      var tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/result.mp4';
      print("outputpath === $path === ${_video!.path}");
      // await VideoEditor.onTrimVideo(_video!.path, path, startPos, endPos);
      await VideoEditor.speed(_video!.path, path, 10);
      print("outputpath after === $path");
      setState(() {
        isVideEditProcessing = false;
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => VideoScreen(path)));
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        isVideEditProcessing = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: this._onVideoSelectPressed,
                icon: Icon(Icons.ondemand_video)),
            isVideEditProcessing
                ? Center(
                  child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                )
                : IconButton(
                    onPressed: this.onDonePressed, icon: Icon(Icons.done))
          ],
        ),
        body: Center(
          child: _controller != null && _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : _video == null
                  ? ElevatedButton(
                      onPressed: this._pickVideo, child: Text("pick a video"))
                  : CircularProgressIndicator(),
        ));
  }
}
