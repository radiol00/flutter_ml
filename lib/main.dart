import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:ml_flutter/detection_painter.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(Main());
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  List<Face> detectionResult = [];
  CameraController controller;
  bool isDetecting = false;
  bool shouldBeDetecting = false;
  FaceDetector detector = FirebaseVision.instance
      .faceDetector(FaceDetectorOptions(enableLandmarks: true));

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.veryHigh);
    handleCameraController();
  }

  Future<void> handleCameraController() async {
    await controller.initialize();
    if (!mounted) {
      return;
    }

    setState(() {});

    // controller
    controller.startImageStream((CameraImage img) async {
      if (!isDetecting && shouldBeDetecting) {
        isDetecting = true;
        WriteBuffer buf = WriteBuffer();
        img.planes.forEach((element) {
          buf.putUint8List(element.bytes);
        });

        FirebaseVisionImage fbVI = FirebaseVisionImage.fromBytes(
          buf.done().buffer.asUint8List(),
          FirebaseVisionImageMetadata(
            size: Size(img.width.toDouble(), img.height.toDouble()),
            rawFormat: img.format.raw,
            planeData: img.planes.map(
              (Plane plane) {
                return FirebaseVisionImagePlaneMetadata(
                  bytesPerRow: plane.bytesPerRow,
                  height: plane.height,
                  width: plane.width,
                );
              },
            ).toList(),
          ),
        );

        List<Face> faces = await detector.processImage(fbVI);
        print("${faces.length} ${DateTime.now().microsecondsSinceEpoch}");

        setState(() {
          detectionResult = faces;
          isDetecting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              shouldBeDetecting = !shouldBeDetecting;
            });
          },
          child: shouldBeDetecting ? Icon(Icons.stop) : Icon(Icons.play_arrow),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: CameraMlVision<List<Barcode>>(
          detector: FirebaseVision.instance.barcodeDetector().detectInImage,
          onResult: (List<Barcode> barcodes) {
            if (!mounted) {
              return;
            }
            // resultSent = true;
            // Navigator.of(context).pop<Barcode>(barcodes.first);
          },
        ),
        // body: Center(
        //   child: CameraPreview(
        //     controller,
        //     child: CustomPaint(
        //       painter: DetectionPainter(faces: detectionResult),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
