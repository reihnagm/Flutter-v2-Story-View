import 'dart:io';
import 'dart:typed_data';

import 'package:video_compress/video_compress.dart';

class VideoServices {

  static Future<MediaInfo?> compressVideo(File file) async {
    try {
      await VideoCompress.setLogLevel(0);
      return await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.HighestQuality,
        includeAudio: true, 
      );
    } catch(e) {
      VideoCompress.cancelCompression();
    }
    return null;
  }

  static Future<String?> getDuration(File file) async {
    MediaInfo? mediaInfo = await VideoCompress.getMediaInfo(file.path);
    return (Duration(microseconds: (mediaInfo.duration! * 1000).toInt())).toString();
  }
  
  static Future<Uint8List> generateByteThumbnail(File file) async {
    Uint8List? thumbnailBytes = await VideoCompress.getByteThumbnail(file.path);
    return thumbnailBytes!;
  }

  static Future<File> generateFileThumbnail(File f) async {
    File file = await VideoCompress.getFileThumbnail(f.path);
    return file;
  }

  static Future<int> getVideoSize(File file) async {
    int size = await file.length(); 
    return size;
  }
}