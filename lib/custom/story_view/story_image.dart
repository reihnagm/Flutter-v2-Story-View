import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:story_view_app/custom/story_view/controller/story_controller.dart';
import 'package:story_view_app/custom/story_view/utils.dart';

class ImageLoader {
  ui.Codec? frames;

  String url;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading; 

  ImageLoader(this.url, {this.requestHeaders});

  void loadImage(VoidCallback onComplete) {
    if (frames != null) {
      state = LoadState.success;
      onComplete();
    }
    final fileStream = DefaultCacheManager().getFileStream(url, headers: requestHeaders as Map<String, String>?);

    fileStream.listen(
      (fileResponse) {
        if (fileResponse is! FileInfo) return;
        if (frames != null) {
          return;
        }
        final imageBytes = fileResponse.file.readAsBytesSync();
        state = LoadState.success;
        PaintingBinding.instance!.instantiateImageCodec(imageBytes).then((codec) {
          frames = codec;
          onComplete();
        }, onError: (error) {
          state = LoadState.failure;
          onComplete();
        });
      },
      onError: (error) {
        state = LoadState.failure;
        onComplete();
      },
    );
  }
}

class StoryImage extends StatefulWidget {
  final ImageLoader imageLoader;

  final BoxFit? fit;

  final StoryController? controller;

  StoryImage(
    this.imageLoader, {
    Key? key,
    this.controller,
    this.fit,
  }) : super(key: key ?? UniqueKey());

  factory StoryImage.url(
    String url, {
    StoryController? controller,
    Map<String, dynamic>? requestHeaders,
    BoxFit fit = BoxFit.fitWidth,
    Key? key,
  }) {
    return StoryImage(
      ImageLoader(
        url,
        requestHeaders: requestHeaders,
      ),
      controller: controller,
      fit: fit,
      key: key
    );
  }

  @override
  State<StatefulWidget> createState() => StoryImageState();
}

class StoryImageState extends State<StoryImage> {
  ui.Image? currentFrame;

  Timer? _timer;

  StreamSubscription<PlaybackState>? _streamSubscription;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _streamSubscription = widget.controller!.playbackNotifier.listen((playbackState) {
        if (widget.imageLoader.frames == null) {
          return;
        }
        if (playbackState == PlaybackState.pause) {
          _timer?.cancel();
        } else {
          forward();
        }
      });
    }
    widget.controller?.pause();
    widget.imageLoader.loadImage(() async {
      if (mounted) {
        if (widget.imageLoader.state == LoadState.success) {
          widget.controller?.play();
          forward();
        } else {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void forward() async {
    _timer?.cancel();

    if (widget.controller != null && widget.controller!.playbackNotifier.valueWrapper!.value == PlaybackState.pause) {
      return;
    }

    final nextFrame = await widget.imageLoader.frames!.getNextFrame();

    currentFrame = nextFrame.image;

    if (nextFrame.duration > const Duration(milliseconds: 0)) {
      _timer = Timer(nextFrame.duration, forward);
    }

    setState(() {});
  }

  Widget getContentView() {
    switch (widget.imageLoader.state) {
      case LoadState.success:
        return RawImage(
          image: currentFrame,
          fit: widget.fit,
        );
      case LoadState.failure:
        return const Center(
          child: Text("Image failed to load.",
          style: TextStyle(
            color: Colors.white,
          ),
        )
      );
      default:
        return const Center(
          child: SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: getContentView(),
    );
  }
}