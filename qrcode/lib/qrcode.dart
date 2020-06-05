import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef CaptureCallback(String data);
typedef RequestPermissionCallback(bool granted);

enum CaptureTorchMode { on, off }

class QRCaptureController {
  MethodChannel _methodChannel;
  CaptureCallback _capture;
  RequestPermissionCallback _requestPermission;

  void _onPlatformViewCreated(int id) {
    print("void _onPlatformViewCreated");
    _methodChannel = MethodChannel('plugins/qr_capture/method_$id');
    _methodChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onCaptured':
          if (_capture != null && call.arguments != null)
            _capture(call.arguments.toString());
          break;
        case 'onPermissionRequested':
          if (_requestPermission != null && call.arguments != null)
            _requestPermission(call.arguments as bool);
          break;
      }
    });
  }

  void pause() {
    _methodChannel?.invokeMethod('pause');
  }

  void resume() {
    _methodChannel?.invokeMethod('resume');
  }

  void requestCameraPermission() {
    _methodChannel?.invokeMethod('requestCameraPermission');
  }

  void onCapture(CaptureCallback capture) {
    _capture = capture;
  }

  void onRequestPermission(RequestPermissionCallback requestPermission) {
    _requestPermission = requestPermission;
  }

  set torchMode(CaptureTorchMode mode) {
    var isOn = mode == CaptureTorchMode.on;
    _methodChannel?.invokeMethod('setTorchMode', isOn);
  }
}

class QRCaptureView extends StatefulWidget {
  final QRCaptureController controller;

  QRCaptureView({Key key, this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return QRCaptureViewState();
  }
}

class QRCaptureViewState extends State<QRCaptureView> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: 'plugins/qr_capture_view',
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          widget.controller._onPlatformViewCreated(id);
        },
      );
    } else {
      return AndroidView(
        viewType: 'plugins/qr_capture_view',
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: (id) {
          widget.controller._onPlatformViewCreated(id);
        },
      );
    }
  }
}
