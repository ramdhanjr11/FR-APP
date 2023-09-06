import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fr_app/locator.dart';
import 'package:fr_app/models/ml_user_model.dart';
import 'package:fr_app/services/camera.service.dart';
import 'package:fr_app/services/face_detector_service.dart';
import 'package:fr_app/services/ml_service.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'widgets/faces_painter.dart';

class LivenessCameraPage extends StatefulWidget {
  const LivenessCameraPage({super.key});

  @override
  State<LivenessCameraPage> createState() => _LivenessCameraPageState();
}

class _LivenessCameraPageState extends State<LivenessCameraPage> {
  CameraService cameraService = locator<CameraService>();
  FaceDetectorService faceDetectorService = locator<FaceDetectorService>();
  MLService mlService = locator<MLService>();

  bool isLoading = true;
  bool isProcessing = false;
  bool isRecognizing = false;
  List<Face>? facesDetected;
  Size? imageSize;
  List<MlUserModel>? mlUserModels;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    cameraService.dispose();
    faceDetectorService.dispose();
    mlService.dispose();
    super.dispose();
  }

  initialize() async {
    setState(() => isLoading = true);
    await cameraService.initialize();
    setState(() => isLoading = false);

    _startImageStream();
  }

  _startImageStream() async {
    imageSize = cameraService.getImageSize();

    cameraService.cameraController?.startImageStream((image) async {
      if (!mounted) return;
      if (isProcessing) return;

      isProcessing = true;

      try {
        await faceDetectorService.detectFacesFromImage(image);

        if (faceDetectorService.faces.isNotEmpty) {
          setState(() {
            facesDetected = faceDetectorService.faces;
          });

          isRecognizing = true;

          await faceDetectorService.detectFacesFromImage(image);
          await _recognizingFaces(image);
          setState(() {});
        } else {
          log(name: 'CAMERA DEBUG', 'Face is null or empty');
          setState(() {
            facesDetected = null;
          });
        }
        isProcessing = false;
      } catch (e) {
        facesDetected = null;
        isProcessing = false;
        log(name: 'CAMERA ERROR', e.toString());
      }
    });
  }

  _recognizingFaces(CameraImage image) async {
    if (!faceDetectorService.isFaceNotEmpty) return;

    List<MlUserModel> mlUserModels = [];

    for (var face in facesDetected!) {
      mlService.setCurrentPrediction(image, face);
      final predictedResult = await mlService.predict();
      log(name: 'face', predictedResult!.user);

      final mlUserModel = MlUserModel(face: face, user: predictedResult);
      mlUserModels.add(mlUserModel);
    }

    this.mlUserModels = mlUserModels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liveness Page'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Stack(
              children: [
                LinearProgressIndicator(),
                Align(
                  alignment: Alignment.center,
                  child: Text('Wait a momment, we are preparing the tools..'),
                )
              ],
            )
          : SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: CameraPreview(
                cameraService.cameraController!,
                child: CustomPaint(
                  painter: FacesPainter(
                    imageSize: imageSize,
                    mlUserModels: mlUserModels,
                  ),
                ),
              ),
            ),
    );
  }
}
