import 'package:camera/camera.dart';

ResolutionPreset parseResolutionPreset(String? resolutionPreset) {
    switch (resolutionPreset?.toLowerCase()) {
      case "low":
        return ResolutionPreset.low;
      case "medium":
        return ResolutionPreset.medium;
      case "high":
        return ResolutionPreset.high;
      case "veryhigh":
        return ResolutionPreset.veryHigh;
      case "ultrahigh":
        return ResolutionPreset.ultraHigh;
      case "max":
        return ResolutionPreset.max;
      default:
        return ResolutionPreset.medium;
    }
  }

ImageFormatGroup? parseImageFormatGroup(String? imageFormatGroup) {
    switch (imageFormatGroup?.toLowerCase()) {
      case "unknown":
        return ImageFormatGroup.unknown;
      case "yuv420":
        return ImageFormatGroup.yuv420;
      case "bgra8888":
        return ImageFormatGroup.bgra8888;
      case "jpeg":
        return ImageFormatGroup.jpeg;
      case "nv21":
        return ImageFormatGroup.nv21;
      default:
        return null;
    }
  }

  ExposureMode parseExposureMode(String? resolutionPreset) {
    switch (resolutionPreset?.toLowerCase()) {
      case "auto":
        return ExposureMode.auto;
      case "locked":
        return ExposureMode.locked;
      default:
        return ExposureMode.auto;
    }
  }