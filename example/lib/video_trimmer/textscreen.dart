import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tapioca/tapioca.dart';
import 'package:tapioca_example/capture_video_screen.dart';
import 'package:tapioca_example/video_player_screen.dart';
import 'package:video_player/video_player.dart';

import 'dart:ui' as ui;

enum VideoPickType { CAMERA, GALLERY }

class TextScreen extends StatefulWidget {
  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  String? _video;
  bool isLoading = false;
  bool isVideEditProcessing = false;
  VideoPlayerController? _controller;
  VideoPlayerController? _pcontroller;
  var isEditing = true;

  Uint8List? bytes1;

  initState() {
    super.initState();
    pickAssetVideo();
  }

  pickAssetVideo() async {
    try {
      final byteData = await rootBundle.load('assets/teest1.mp4');

      final file = File('${(await getTemporaryDirectory()).path}/teest1.mp4');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      _video = file.path;
      initializeVideo();
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  initializeVideo() async {
    if (_video == null) return;
    _controller = VideoPlayerController.file(File(_video!));
    await _controller!.initialize();
    // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    _controller?.play();
    setState(() {});
    print(
        "output video  ==== ${_controller!.value.duration.inSeconds} == ${_controller!.value.size}");
  }

  _onVideoSelectPressed() async {
    var result = await showDialog(
        context: context,
        builder: (_) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                      onTap: () => Navigator.pop(context, VideoPickType.CAMERA),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("Pick from gallery"),
                      )),
                  InkWell(
                      onTap: () => Navigator.pop(context, VideoPickType.CAMERA),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("Capture from camera"),
                      ))
                ],
              ),
            ));
    if (result == VideoPickType.GALLERY) {
      await _pickVideo();
      await initializeVideo();
    } else if (result == VideoPickType.CAMERA) {
      var result = await Navigator.push(
          context, MaterialPageRoute(builder: (_) => VideoCaptureScreen()));
      if (result != null && result is String) {
        _video = result;
        await initializeVideo();
      }
    }
  }

  _pickVideo() async {
    try {
      PickedFile? video =
          await ImagePicker().getVideo(source: ImageSource.gallery);
      if (video == null) return;
      print("videopath: ${video.path}");
      _video = video.path;
      isLoading = true;
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  String processvideo = "";
  onDonePressed() async {
    print(_video);
    var ss = await _mixTextVideo(bytes1, _video!);
    print(ss);
    _pcontroller = VideoPlayerController.file(File(ss));
    await _pcontroller!.initialize();
    print(_pcontroller);
    print(_controller);
    setState(() {
      processvideo = ss;
    });
  }

  late GlobalKey key1;
  void onTextChange(String value) async {
    print(value);
    await Future.delayed(Duration(milliseconds: 300));
    var bytes1 = await capture(key1);
    setState(() {
      isEditing = false;
      this.bytes1 = bytes1;
    });
  }

  static Future capture(GlobalKey key) async {
    if (key == null) return null;
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.5);
    print("=======>${image.height}");
    print("=======>${image.width}");
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
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
        body: processvideo.isEmpty
            ? Stack(
                children: [
                  Center(
                    child:
                        _controller != null && _controller!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              )
                            : _video == null
                                ? ElevatedButton(
                                    onPressed: this._pickVideo,
                                    child: Text("pick a video"))
                                : CircularProgressIndicator(),
                  ),
                  isEditing
                      ? WidgetToImage(
                          builder: (GlobalKey<State<StatefulWidget>> key) {
                            this.key1 = key;
                            return Container(
                              color: Colors.blueGrey,
                              child: TextField(
                                style: TextStyle(fontSize: 30),
                                autocorrect: false,
                                maxLines: null,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration.collapsed(
                                  hintText: "inndsadas",
                                ),
                                onSubmitted: this.onTextChange,
                              ),
                            );
                          },
                        )
                      : buildImage(bytes1),
                ],
              )
            : AspectRatio(
                aspectRatio: _pcontroller!.value.aspectRatio,
                child: VideoPlayer(_pcontroller!),
              ));
  }

  static Future<String> createTempVideoPath() async {
    Directory temp = await getTemporaryDirectory();
    return "${temp.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";
  }

  Future<String> _mixTextVideo(var message, String videoPath) async {
    String outputPath = await createTempVideoPath();
    final tapiocaBalls = [
      TapiocaBall.imageOverlay(
        message!,
        0,
        0,
      ),
    ];
    final cup = Cup(Content(videoPath), tapiocaBalls);
    await cup.suckUp(outputPath);
    return outputPath;
  }

  Widget buildImage(Uint8List? bytes) =>
      bytes != null ? Image.memory(bytes, scale: 3) : Container();
}

class WidgetToImage extends StatefulWidget {
  final Function(GlobalKey key) builder;

  const WidgetToImage({
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _WidgetToImageState createState() => _WidgetToImageState();
}

class _WidgetToImageState extends State<WidgetToImage> {
  final globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: widget.builder(globalKey),
    );
  }
}
