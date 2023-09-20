import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageCompressor {

  // COMPUTE
  /// [compress] can used in compute function
  /// PASS DATA AS LIST
  /// First parameter always the input of [Uint8List]
  /// Second parameter is size in bytes (MaxSizeInBytes)[int]
  /// If anyone value is missing then compress will emit null
  static Future<Uint8List?> compress(dynamic data) async {
    Uint8List? inputUin8List;
    int? maxSizeInBytes;
    if (data is List) {
      inputUin8List = data[0];
      maxSizeInBytes = data[1];
    }

    if (inputUin8List == null || inputUin8List.isEmpty || maxSizeInBytes == null || (maxSizeInBytes) == 0) {
      return null;
    }
    final inputImage = img.decodeImage(inputUin8List);
    if (inputImage != null) {
      final compressedImageBytes = ImageCompressor()._compressImage(inputImage, maxSizeInBytes);
      return compressedImageBytes;
    } else {
      return null;
    }
  }

  Future<Uint8List> compressImagesInParallel(Uint8List inputData, int maxSizeInBytes) async {
    final receivePort = ReceivePort();
    final completer = Completer<Uint8List>();
    await Isolate.spawn(_compressorIsolate, receivePort.sendPort);
    receivePort.listen((message) {
      if (message is SendPort) {
       message.send([inputData, maxSizeInBytes]);
      } else if (message is Uint8List) {
        completer.complete(message);
      }
    });
    final compressedImageBytes = await completer.future;
    receivePort.close();
    return compressedImageBytes;
  }

  void _compressorIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      final inputImageBytes = message[0] as Uint8List;
      final maxSize = message[1] as int;

      final inputImage = img.decodeImage(inputImageBytes);
      if (inputImage != null) {
        final compressedImageBytes = _compressImage(inputImage, maxSize);
        sendPort.send(compressedImageBytes);
      }
    });
  }

  Uint8List _compressImage(img.Image inputImage, int maxSizeInBytes) {
    int width = inputImage.width;
    int height = inputImage.height;
    int compressionQuality = 90;

    img.Image resizedImage = img.copyResize(inputImage, width: width, height: height);

    Uint8List compressedImageInBytes = Uint8List.fromList([]);

    while (compressedImageInBytes.isEmpty || compressedImageInBytes.length > maxSizeInBytes) {
      if (compressionQuality <= 0) {
        break;
      }
      compressedImageInBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: compressionQuality));
      compressionQuality -= 10;
    }
    return compressedImageInBytes;
  }
}