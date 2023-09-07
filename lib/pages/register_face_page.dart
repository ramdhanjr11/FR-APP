import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fr_app/db/databse_helper.dart';
import 'package:fr_app/models/user_model.dart';
import 'package:fr_app/pages/widgets/face_painter.dart';
import 'package:fr_app/services/camera.service.dart';
import 'package:fr_app/services/face_detector_service.dart';
import 'package:fr_app/services/ml_service.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../cubit/register_user/register_user_cubit.dart';

class RegisterFacePage extends StatefulWidget {
  const RegisterFacePage({super.key});

  @override
  State<RegisterFacePage> createState() => _RegisterFacePageState();
}

class _RegisterFacePageState extends State<RegisterFacePage> {
  late CameraService cameraService;
  late FaceDetectorService faceDetectorService;
  late DatabaseHelper databaseHelper;
  late MLService mlService;

  late TextEditingController txtEditingControllerName;
  late TextEditingController txtEditingControllerPassword;

  late RegisterUserCubit registerUserCubit;

  final formKey = GlobalKey<FormState>();

  bool isProcessing = false;
  bool isPredicted = false;
  bool isSaving = false;
  Face? faceDetected;
  Size? imageSize;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () async => await context.read<RegisterUserCubit>().initializeServices(),
    );
    txtEditingControllerName = TextEditingController();
    txtEditingControllerPassword = TextEditingController();
  }

  @override
  void dispose() {
    registerUserCubit.disposeServices();
    super.dispose();
  }

  _startImageStream() {
    cameraService = registerUserCubit.cameraService;
    faceDetectorService = registerUserCubit.faceDetectorService;
    mlService = registerUserCubit.mlService;
    databaseHelper = registerUserCubit.databaseHelper;

    imageSize = cameraService.getImageSize();

    cameraService.cameraController?.startImageStream(
      (image) async {
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    registerUserCubit = BlocProvider.of<RegisterUserCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Please register your face'),
        centerTitle: true,
      ),
      body: BlocConsumer<RegisterUserCubit, RegisterUserState>(
        listener: (context, state) async {
          if (state is RegisterUserHasInitialized) {
            log(name: 'STATE STATUS', state.runtimeType.toString());
            _startImageStream();
          }
        },
        builder: (context, state) {
          if (state is RegisterUserInitial) {
            log(name: 'STATE STATUS', state.runtimeType.toString());
            return _buildLoading();
          }

          if (state is RegisterUserLoading) {
            log(name: 'STATE STATUS', state.runtimeType.toString());
            return _buildLoading();
          }

          if (state is RegisterUserError) {
            log(name: 'STATE STATUS', state.runtimeType.toString());
            return _buildLoading();
          }

          if (state is RegisterUserLoaded) {
            log(name: 'STATE STATUS', state.runtimeType.toString());
            return Stack(
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
            );
          }

          return const LinearProgressIndicator();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Stack(
      children: [
        LinearProgressIndicator(),
        Align(
          alignment: Alignment.center,
          child: Text('Wait a momment, we are preparing the tools..'),
        )
      ],
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
    await cameraService.cameraController?.stopImageStream();
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
                  onPressed: () {
                    final isSaved = _saveUser();
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

  bool _saveUser() {
    final name = txtEditingControllerName.value.text;
    final password = txtEditingControllerPassword.value.text;
    final modelData = mlService.predictedData;
    if (formKey.currentState!.validate()) {
      if (name.isNotEmpty && password.isNotEmpty) {
        final user = User(user: name, password: password, modelData: modelData);
        registerUserCubit.insertUser(user);

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
