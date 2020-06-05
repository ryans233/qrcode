# qrcode
A flutter plugin for scanning QR codes. Use AVCaptureSession in iOS and zxing in Android.

Added some permission related APIs to [SiriDx's qrcode library](https://github.com/SiriDx/qrcode).

## Usage
[Example](qrcode/example/lib/main.dart)

## Integration

### iOS
To use on iOS, you must add the following to your Info.plist

```
<key>NSCameraUsageDescription</key>
<string>Camera permission is required for qrcode scanning.</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
```
