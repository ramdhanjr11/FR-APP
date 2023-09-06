import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fr_app/db/databse_helper.dart';
import 'package:fr_app/locator.dart';
import 'package:fr_app/models/user_model.dart';
import 'package:fr_app/pages/widgets/face_painter.dart';
import 'package:fr_app/services/camera.service.dart';
import 'package:fr_app/services/face_detector_service.dart';
import 'package:fr_app/services/ml_service.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class RegisterFacePage extends StatefulWidget {
  const RegisterFacePage({super.key});

  @override
  State<RegisterFacePage> createState() => _RegisterFacePageState();
}

class _RegisterFacePageState extends State<RegisterFacePage> {
  CameraService cameraService = locator<CameraService>();
  FaceDetectorService faceDetectorService = locator<FaceDetectorService>();
  DatabaseHelper databaseHelper = locator<DatabaseHelper>();
  MLService mlService = locator<MLService>();

  late TextEditingController txtEditingControllerName;
  late TextEditingController txtEditingControllerPassword;

  final formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isProcessing = false;
  bool isPredicted = false;
  bool isSaving = false;
  Face? faceDetected;
  Size? imageSize;

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

    txtEditingControllerName = TextEditingController();
    txtEditingControllerPassword = TextEditingController();

    _startImageStream();
  }

  _startImageStream() {
    imageSize = cameraService.getImageSize();

    cameraService.cameraController?.startImageStream((image) async {
      if (!mounted) return;
      if (isProcessing) return;

      isProcessing = true;

      try {
        await faceDetectorService.detectFacesFromImage(image);

        if (faceDetectorService.faces.isNotEmpty) {
          setState(() {
            faceDetected = faceDetectorService.faces.first;
          });

          if (isSaving) mlService.setCurrentPrediction(image, faceDetected);
        } else {
          log(name: 'CAMERA DEBUG', 'Face is null or empty');
          setState(() {
            faceDetected = null;
          });
        }
        isProcessing = false;
      } catch (e) {
        faceDetected = null;
        isProcessing = false;
        log(name: 'CAMERA ERROR', e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Please register your face'),
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
          : Stack(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: CameraPreview(
                    cameraService.cameraController!,
                    child: CustomPaint(
                      painter: FacePainter(
                        imageSize: imageSize!,
                        face: faceDetected,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 64,
                  right: 64,
                  bottom: 16,
                  child: ElevatedButton(
                    onPressed: () => _processImage(context),
                    child: const Text('Take picture'),
                  ),
                ),
              ],
            ),
    );
  }

  _processImage(BuildContext context) async {
    log(
      name: 'NUMBER OF FACES DETECTED: ',
      faceDetectorService.faces.length.toString(),
    );

    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Information'),
            content: const Text(
                'Ooopss sorry we can\'t detect your face, please try again'),
            actions: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.replay_outlined),
                label: const Text('Try again'),
              ),
            ],
          );
        },
      );
      return;
    }

    isSaving = true;

    Future.delayed(const Duration(milliseconds: 500));

    await cameraService.cameraController?.stopImageStream();

    Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _buildModalBottomSheet(context);
      },
    ).whenComplete(() {
      setState(() {
        isSaving = false;
        _startImageStream();
      });
    });
  }

  Widget _buildModalBottomSheet(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 24,
            right: 16,
            left: 16,
            bottom: MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please input your identity..',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: txtEditingControllerName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You should fill this field..';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: txtEditingControllerPassword,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You should fill this field..';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final isSaved = await _saveUser();
                    if (!mounted) return;
                    if (isSaved) Navigator.pop(context);
                  },
                  child: const Text('Save user'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _clearData() {
    txtEditingControllerName.clear();
    txtEditingControllerPassword.clear();
    mlService.setPredictedData([]);
  }

  Future<bool> _saveUser() async {
    final name = txtEditingControllerName.value.text;
    final password = txtEditingControllerPassword.value.text;
    final modelData = mlService.predictedData;
    if (formKey.currentState!.validate()) {
      if (name.isNotEmpty && password.isNotEmpty) {
        final user = User(user: name, password: password, modelData: modelData);
        await databaseHelper.insert(user);

        log(
          'Save user success: ${user.modelData}, ${user.user}, ${user.password}',
          name: 'SAVE USER',
        );
        _clearData();
      }
    }
    return true;
  }
}
