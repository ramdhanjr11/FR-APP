import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fr_app/locator.dart';
import 'package:fr_app/services/camera.service.dart';
import 'package:lottie/lottie.dart';

class RegisterFacePage extends StatefulWidget {
  const RegisterFacePage({super.key});

  @override
  State<RegisterFacePage> createState() => _RegisterFacePageState();
}

class _RegisterFacePageState extends State<RegisterFacePage> {
  CameraService cameraService = locator<CameraService>();
  bool isLoading = true;
  static const String lottieUrl =
      'https://lottie.host/670ac850-85a0-4c23-986d-4bb35cb0a476/DoIIY2rpCH.json';

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    cameraService.dispose();
    super.dispose();
  }

  initialize() async {
    setState(() => isLoading = true);
    await cameraService.initialize();
    setState(() => isLoading = false);

    if (!mounted) return;
    cameraService.cameraController?.startImageStream((image) {
      log(image.format.group.name);
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
                    child: Center(
                      child: Lottie.network(lottieUrl),
                    ),
                  ),
                ),
                Positioned(
                  left: 64,
                  right: 64,
                  bottom: 16,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return _buildModalBottomSheet(context);
                        },
                      );
                    },
                    child: const Text('Take picture'),
                  ),
                ),
              ],
            ),
    );
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Name',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Save user'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
