import 'dart:ui' as UI;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class Joint {
  double x;
  double y;
  String name;

  Offset toOffset() {
    return Offset(x, y);
  }
}

class DetectionPainter extends CustomPainter {
  List<Face> faces;
  DetectionPainter({this.faces});

  var eyePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

  var nosePaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

  var earPaint = Paint()
    ..color = Colors.yellow
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

  var posturePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round;

  var jointPaint = Paint()
    ..color = Colors.purple
    ..strokeWidth = 15
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) async {
    List<Offset> landmarks = [];
    for (Face face in faces) {
      FaceContour contour = face.getContour(FaceContourType.allPoints);
      canvas.drawPoints(UI.PointMode.points, contour.positionsList, nosePaint);

      landmarks.addAll([
        // face.getLandmark(FaceLandmarkType.bottomMouth).position,
        face.getLandmark(FaceLandmarkType.leftMouth).position,
        face.getLandmark(FaceLandmarkType.rightMouth).position,
      ]);

      landmarks.removeWhere((element) => element == null);
      landmarks = landmarks.map((e) => Offset(e.dy/2, e.dx-200)).toList();
      print(landmarks);
    }

    landmarks.addAll([
      Offset(0, 0),
      Offset(size.width, size.height),
    ]);
    canvas.drawPoints(UI.PointMode.points, landmarks, jointPaint);
  }

  // void paintPoseNet(Canvas canvas, Size size) async {
  //   canvas.drawRect(
  //       Rect.fromLTWH(0, 0, 10, 10),
  //       Paint()
  //         ..color = Colors.blue
  //         ..strokeWidth = 10
  //         ..strokeCap = StrokeCap.round);

  //   canvas.drawRect(
  //       Rect.fromLTWH(size.width - 10, size.height - 10, 10, 10),
  //       Paint()
  //         ..color = Colors.blue
  //         ..strokeWidth = 10
  //         ..strokeCap = StrokeCap.round);

  //   if (features == null || features.length == 0) return;

  //   void drawPosture(dynamic posture) {
  //     List<Offset> eyes = [];
  //     List<Offset> nose = [];
  //     List<Offset> ears = [];
  //     List<Joint> posture = [];

  //     Joint _findJoint(String name) {
  //       return posture.singleWhere((element) => element.name == name,
  //           orElse: () => null);
  //     }

  //     void _tryToConnect(Joint a, Joint b) {
  //       if (b != null) {
  //         canvas.drawLine(a.toOffset(), b.toOffset(), posturePaint);
  //       }
  //     }

  //     int numOfFeatures = features[0]['keypoints'].length;

  //     for (var i = 0; i < numOfFeatures; i++) {
  //       dynamic feature = features[0]['keypoints'][i];
  //       String part = feature['part'];
  //       double score = feature['score'];
  //       double scoreLimit = 0.5;
  //       if (score > scoreLimit) {
  //         double x = feature['x'];
  //         double y = feature['y'];
  //         Offset off = Offset(x * size.width, y * size.height);
  //         switch (part) {
  //           case 'leftEye':
  //             eyes.add(off);
  //             break;

  //           case 'rightEye':
  //             eyes.add(off);
  //             break;

  //           case 'nose':
  //             nose.add(off);
  //             break;

  //           case 'leftEar':
  //             ears.add(off);
  //             break;

  //           case 'rightEar':
  //             ears.add(off);
  //             break;
  //           default:
  //             posture.add(Joint()
  //               ..x = off.dx
  //               ..y = off.dy
  //               ..name = part);
  //         }
  //       }
  //     }

  //     posture.forEach((joint) {
  //       if (joint.name == 'leftShoulder') {
  //         _tryToConnect(joint, _findJoint('leftElbow'));
  //         _tryToConnect(joint, _findJoint('leftHip'));
  //         _tryToConnect(joint, _findJoint('rightShoulder'));
  //       } else if (joint.name == 'rightShoulder') {
  //         _tryToConnect(joint, _findJoint('rightElbow'));
  //         _tryToConnect(joint, _findJoint('rightHip'));
  //         _tryToConnect(joint, _findJoint('leftShoulder'));
  //       } else if (joint.name == 'leftWrist') {
  //         _tryToConnect(joint, _findJoint('leftElbow'));
  //       } else if (joint.name == 'rightWrist') {
  //         _tryToConnect(joint, _findJoint('rightElbow'));
  //       } else if (joint.name == 'leftHip') {
  //         _tryToConnect(joint, _findJoint('rightHip'));
  //         _tryToConnect(joint, _findJoint('leftKnee'));
  //       } else if (joint.name == 'rightHip') {
  //         _tryToConnect(joint, _findJoint('leftHip'));
  //         _tryToConnect(joint, _findJoint('rightKnee'));
  //       } else if (joint.name == 'leftAnkle') {
  //         _tryToConnect(joint, _findJoint('leftKnee'));
  //       } else if (joint.name == 'rightAnkle') {
  //         _tryToConnect(joint, _findJoint('rightKnee'));
  //       }
  //     });

  //     posture.forEach((joint) {
  //       canvas.drawPoints(UI.PointMode.points, [joint.toOffset()], jointPaint);
  //     });

  //     canvas.drawPoints(UI.PointMode.points, eyes, eyePaint);
  //     canvas.drawPoints(UI.PointMode.points, nose, nosePaint);
  //     canvas.drawPoints(UI.PointMode.points, ears, earPaint);
  //   }

  //   features.forEach((person) {
  //     drawPosture(person);
  //   });
  // }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
