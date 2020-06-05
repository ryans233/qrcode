# qrcode
A flutter plugin for scanning QR codes. Use AVCaptureSession in iOS and zxing in Android.

Added some permission related APIs to [SiriDx's qrcode library](https://github.com/SiriDx/qrcode).

## Usage
[Example](example/lib/main.dart)

### Use this package as a library

#### Add dependency

Add this to your package's pubspec.yaml file:

```dart
dependencies:
  qrcode: ^1.0.4
```

#### Install it

You can install packages from the command line:

with Flutter:

```
$ flutter pub get
```

#### Import it

Now in your Dart code, you can use:

```dart
import 'package:qrcode/qrcode.dart';
```

## Integration

### iOS
To use on iOS, you must add the following to your Info.plist


```
<key>NSCameraUsageDescription</key>
<string>Camera permission is required for qrcode scanning.</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
```
