import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flexicapture/flexicapture.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flexicapturePlugin = Flexicapture();
  int maxMin = 5;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    _flexicapturePlugin.maxMinute = 5;
    _flexicapturePlugin.enableCompress = true;
    _flexicapturePlugin.pauseCapture = true;
    _flexicapturePlugin.maxSize = 400 * 1024;
    _flexicapturePlugin.start();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flexicapturePlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FloatingActionButton.small(onPressed: (){
                _flexicapturePlugin.maxMinute = maxMin + 1;
              }, child: Icon(Icons.add), elevation: 5,),
              SizedBox(width: 10),
              FloatingActionButton.small(onPressed: (){
                _flexicapturePlugin.pauseCapture = !_flexicapturePlugin.pauseCapture;
              }, child: Icon(_flexicapturePlugin.pauseCapture ? Icons.play_arrow : Icons.pause)),
              SizedBox(width: 10),
              FloatingActionButton.small(onPressed: (){
                _flexicapturePlugin.enableCompress = !_flexicapturePlugin.enableCompress;
              }, child: Icon(Icons.compress))
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Flex(direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Running on: $_platformVersion\n'),
            StreamBuilder(stream: _flexicapturePlugin.randomMinController, builder: (context, snapshot) => Text('TICK: ${snapshot.data} @${TimeOfDay.now().toString()}'),),
            StreamBuilder(stream: _flexicapturePlugin.screenShotListen, builder: (context, snapshot) => (snapshot.data?.isNotEmpty ?? false) ? Text('CAPTURED: ${(snapshot.data?.lengthInBytes ?? 0) / 1000} kb @${TimeOfDay.now().toString()}') : Text(""),),
            ])),
        ),
      );
  }
}
