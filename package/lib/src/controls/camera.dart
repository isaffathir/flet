import 'package:camera/camera.dart';
import 'package:flet/src/utils/camera.dart';
import 'package:flutter/material.dart';

import '../flet_app_services.dart';
import '../flet_server.dart';
import '../models/control.dart';
import 'create_control.dart';
import 'error.dart';

class CameraControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final List<Control> children;
  final bool parentDisabled;
  final List<CameraDescription?>? cameras;

  const CameraControl(
      {super.key,
      required this.parent,
      required this.control,
      required this.children,
      required this.parentDisabled,
      required this.cameras});

  @override
  State<CameraControl> createState() => _CameraControlState();
}

class _CameraControlState extends State<CameraControl> {
  late CameraController _controller;
  FletServer? _server;

  @override
  void initState() {
    super.initState();
    debugPrint("Camera.initState($hashCode)");
    if (widget.cameras!.isEmpty) {
      return;
    }

    var resolutionPreset =
        parseResolutionPreset(widget.control.attrString("resolutionPreset"));
    var imageFormatGroup =
        parseImageFormatGroup(widget.control.attrString("imageFormatGroup"));
    var enableAudio = widget.control.attrBool("enableAudio", true)!;

    debugPrint("CAMERA initState: ${widget.cameras}");
    _controller = CameraController(widget.cameras![0]!, resolutionPreset,
        enableAudio: enableAudio, imageFormatGroup: imageFormatGroup);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      // https://github.com/flutter/flutter/issues/69298
      if (e is CameraException) {
        debugPrint("CAMERA ERROR: ${e.code} = ${e.description}");
        /*switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }*/
      }
    });
    _controller.addListener(() {
      debugPrint("CAMERA  NOTIFIER: ${_controller.value}");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<XFile?> captureImage() async {
    if (_controller.value.isInitialized) {
      try {
        final XFile imageFile = await _controller.takePicture();
        debugPrint("CAMERA IMAGE imageFile.path: ${imageFile.path}");
        return imageFile;
      } catch (e) {
        debugPrint("CAMERA ERROR: $e");
      }
    }
    return null;
  }

  void startRecording() async {
    if (_controller.value.isInitialized) {
      try {
        await _controller.startVideoRecording();
      } catch (e) {
        debugPrint("VIDEO ERROR starting video recording: $e");
      }
    }
  }

  Future<XFile?> stopRecording() async {
    if (_controller.value.isRecordingVideo) {
      try {
        final XFile videoFile = await _controller.stopVideoRecording();
        debugPrint("VIDEO recording stopped. File: ${videoFile.path}");
        return videoFile;
      } catch (e) {
        debugPrint("VIDEO ERROR stopping video recording: $e");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool disabled = widget.control.isDisabled || widget.parentDisabled;
    var exposureMode = widget.control.attrString("exposureMode");
    var exposureOffset = widget.control.attrDouble("exposureOffset");
    var zoomLevel = widget.control.attrDouble("zoomLevel");

    var server = FletAppServices.of(context).server;

    () async {
      if (exposureMode != null) {
        await _controller.setExposureMode(parseExposureMode(exposureMode));
      }

      if (exposureOffset != null) {
        await _controller.setExposureOffset(exposureOffset);
      }

      if (zoomLevel != null) {
        //  && 1.0 <= zoomLevel && zoomLevel <= _controller.getMaxZoomLevel()
        await _controller.setZoomLevel(zoomLevel ?? 1.0);
      }

      _server = server;
      _server?.controlInvokeMethods[widget.control.id] =
          (methodName, args) async {
        switch (methodName) {
          case "capture_image":
            debugPrint("CAMERA.captureImage()");
            await captureImage();
            break;
          case "start_video_recording":
            debugPrint("CAMERA.startRecording()");
            startRecording();
            break;
          case "stop_video_recording":
            debugPrint("CAMERA.stopRecording()");
            await stopRecording();
            break;
          default:
            debugPrint("CAMERA unknown method: $methodName");
            break;
        }
        return null;
      };
    }();

    var errorContentCtrls =
        widget.children.where((c) => c.name == "error_content" && c.isVisible);

    var camera = _controller.value.isInitialized
        ? CameraPreview(_controller)
        : errorContentCtrls.isNotEmpty
            ? createControl(
                widget.control, errorContentCtrls.first.id, disabled)
            : const ErrorControl("Camera not initialized.");

    debugPrint("Camera build: ${widget.control.id}");

    return constrainedControl(context, camera, widget.parent, widget.control);
  }
}
