import 'dart:developer';

import 'package:fr_app/models/ml_user_model.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';

class FacesPainter extends CustomPainter {
  FacesPainter({required this.imageSize, required this.mlUserModels});

  final Size? imageSize;
  double? scaleX, scaleY;
  List<MlUserModel>? mlUserModels;
  // List<Face>? faces;

  @override
  void paint(Canvas canvas, Size size) {
    if (mlUserModels == null) return;

    if (mlUserModels!.isNotEmpty) {
      for (var user in mlUserModels!) {
        _paintFace(
          canvas,
          size,
          user.face,
          user,
        );
        log(name: 'PAINT DEBUG', user.user.user);
      }
    }
  }

  @override
  bool shouldRepaint(FacesPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.mlUserModels != mlUserModels;
  }

  _paintFace(Canvas canvas, Size size, Face face, MlUserModel user) {
    Paint paint;

    if (face.headEulerAngleY! > 10 || face.headEulerAngleY! < -10) {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.red;
    } else {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.green;
    }

    scaleX = size.width / imageSize!.width;
    scaleY = size.height / imageSize!.height;

    TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 20),
        text:
            "${user.user.user}  ${user.user.currentDistance?.toStringAsFixed(2)}");
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        face.boundingBox.left * scaleX!,
        face.boundingBox.bottom * scaleY!,
      ),
    );

    canvas.drawRRect(
        _scaleRect(
            rect: face.boundingBox,
            imageSize: imageSize!,
            widgetSize: size,
            scaleX: scaleX ?? 1,
            scaleY: scaleY ?? 1),
        paint);
  }
}

RRect _scaleRect(
    {required Rect rect,
    required Size imageSize,
    required Size widgetSize,
    double scaleX = 1,
    double scaleY = 1}) {
  return RRect.fromLTRBR(
      (widgetSize.width - rect.left.toDouble() * scaleX),
      rect.top.toDouble() * scaleY,
      widgetSize.width - rect.right.toDouble() * scaleX,
      rect.bottom.toDouble() * scaleY,
      const Radius.circular(10));
}
