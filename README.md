# flexicapture

A Screen capturing library
I've created this library with the help of `ScreenCapturer & Image`.
So kindly add these necessary lines with respective places.

#### Windows requirements

Be sure to modify your Visual Studio installation and ensure that **"C++ ATL for latest v142 build tools (x86 & x64)"** is installed!


### macOS

Change the file `macos/Runner/DebugProfile.entitlements` or `macos/Runner/Release.entitlements` as follows:

> Required only for sandbox mode.

```diff
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
+	<key>com.apple.security.temporary-exception.mach-register.global-name</key>
+	<string>com.apple.screencapture.interactive</string>
</dict>
</plist>
```

## Dart
To use the `Flexicapture` follow the necessary steps

```dart
final _flexicapturePlugin = Flexicapture();
_flexicapturePlugin.maxMinute = 5;
_flexicapturePlugin.start();
```
If compress required along with screen-capture

```dart
_flexicapturePlugin.enableCompress = true;
```

If compression need under the `maxSize`. Always multiply the value with `1024` to get the `bytes` value. Here we've mentioned `400kb (400 * 1024)`

```dart
_flexicapturePlugin.maxSize = 400 * 1024;
```

To pause and resume screen-capture `true` pause the capture `false` enable the capture

```dart
_flexicapturePlugin.pauseCapture = true;
```
