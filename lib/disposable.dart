import 'package:flutter/foundation.dart';

class Disposable {

  bool isDisposed = false;
  bool isInitialized = false;

  @mustCallSuper
  void initState() {
    isInitialized = true;
  }

  @mustCallSuper
  void dispose() {
    onDispose();
  }

  @mustCallSuper
  void onDispose() {
    isDisposed = true;
  }

  Disposable() {
    initState();
  }
}