import 'package:flexicapture/app_helper_screen_capture.dart';
import 'package:flexicapture/flexicapture.dart';
import 'package:flexicapture_example/capturing_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final _flexiCapturePlugin = FlexiCapture();
  // int maxMin = 5;
  StreamController<List<Map<String, dynamic>>> capturedController =
      StreamController.broadcast();

  late CapturingProvider provider;

  @override
  void initState() {
    super.initState();

    provider = CapturingProvider();
    // _flexiCapturePlugin.maxMinute = 2;
    // _flexiCapturePlugin.enableCompress = true;
    // _flexiCapturePlugin.pauseCapture = false;
    // _flexiCapturePlugin.convertBase64 = false;
    // _flexiCapturePlugin.maxSize = 400 * 1024;
    // _flexiCapturePlugin.start();
    // _flexiCapturePlugin.exceptAppName = "flexitrac";
    // _flexiCapturePlugin.onCaptured = (val) => print("IMAGE-SIZE:\t[${(val?.imageByte?.lengthInBytes ?? 0)}] WINDOW-DETAILS:\t[${val?.windowInfo?.toMap()}] BASE64:[${val?.base64Image}]");
    // _flexiCapturePlugin.onCaptureError = (val) => print("Error:\t[$val]");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListenableBuilder(listenable: provider, builder: (context, child) => Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FloatingActionButton.small(
                tooltip: "Increase duration",
                onPressed: provider.onIncrease,
                elevation: 5,
                child: const Icon(Icons.add),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                tooltip: "Convert Base64",
                onPressed: provider.onConvert,
                elevation: 5,
                child: const Icon(Icons.conveyor_belt),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                  tooltip: "Pause",
                  onPressed: provider.onPause,
                  child: Icon(provider.pauseCapture
                      ? Icons.play_arrow
                      : Icons.pause)),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                  tooltip: "Compress",
                  onPressed: provider.onCompress,
                  child: const Icon(Icons.photo_size_select_small_rounded)),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                  tooltip: "Screenshot",
                  onPressed: provider.onCapture,
                  child: const Icon(Icons.screenshot_monitor_rounded)),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                  tooltip: "Dispose ${provider.captureDisposed}",
                  onPressed: (provider.captureDisposed) ? provider.onRestart : provider.onDispose,
                  child: Icon((provider.captureDisposed) ? Icons.not_started_outlined : Icons.stop_screen_share_outlined)),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Flex(
                direction: Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (provider.capturedModel != null)
                      ? Text(
                      textAlign: TextAlign.center,
                      'CAPTURED: ${(provider.capturedModel?.imageByte?.lengthInBytes ?? 0) / 1000} kb @${provider.capturedModel?.windowInfo?.toJson()}')
                      : const Text("Not yet captured"),
                ])),
      ),),
    );
  }
}
