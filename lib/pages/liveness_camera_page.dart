import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fr_app/locator.dart';
import 'package:fr_app/services/camera.service.dart';

class LivenessCameraPage extends StatefulWidget {
  const LivenessCameraPage({super.key});

  @override
  State<LivenessCameraPage> createState() => _LivenessCameraPageState();
}

class _LivenessCameraPageState extends State<LivenessCameraPage> {
  CameraService cameraService = locator<CameraService>();
  bool isLoading = true;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liveness Page'),
        centerTitle: true,
      ),
      body: cameraService.cameraController == null
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
              child: CameraPreview(cameraService.cameraController!),
            ),
    );
  }
}
