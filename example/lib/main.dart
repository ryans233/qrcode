import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrcode/qrcode.dart';
import 'package:wakelock/wakelock.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final title = 'QRCode Scanner';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: title),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 250,
                height: 250,
                child: QRCaptureView(
                  controller: _captureController,
                ),
              ),
              Container(
                child: Text('$_captureText'),
              ),
              !isGranted ? RaisedButton(child: Text("PERMISSION"), onPressed: ()=>_captureController.requestCameraPermission(),) : Container(),
            ],
          ),
          _buildToolBar(),
        ],
      ),
    );
  }

  QRCaptureController _captureController = QRCaptureController();

  bool _isTorchOn = false;

  String _captureText = '';

  Future<bool> showDeleteConfirmDialog1() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Camera"),
          content: Text("Require?"),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
          ],
        );
      },
    );
  }

  bool isGranted;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();

    _captureController.onCapture((data) {
      print('onCapture----$data');
      setState(() {
        _captureController.pause();
        _captureText = data;
      });
    });
    _captureController.onRequestPermission((granted) async {
      setState(() {
        isGranted = granted;
        print("onRequestPermission=$granted");
        if (!granted) showDeleteConfirmDialog1();
      });

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildToolBar() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            _captureController.pause();
          },
          child: Text('pause'),
        ),
        FlatButton(
          onPressed: () {
            if (_isTorchOn) {
              _captureController.torchMode = CaptureTorchMode.off;
            } else {
              _captureController.torchMode = CaptureTorchMode.on;
            }
            _isTorchOn = !_isTorchOn;
          },
          child: Text('torch'),
        ),
        FlatButton(
          onPressed: () {
            _captureController.resume();
          },
          child: Text('resume'),
        ),
      ],
    );
  }
}
