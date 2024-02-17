import 'dart:convert';
import 'dart:typed_data';

import 'package:flet/flet.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class LottieControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final Widget? nextChild;
  final FletControlBackend backend;

  const LottieControl(
      {super.key,
      required this.parent,
      required this.control,
      required this.nextChild,
      required this.backend});

  @override
  State<LottieControl> createState() => _LottieControlState();
}

class _LottieControlState extends State<LottieControl> with FletStoreMixin {
  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Lottie build: ${widget.control.id} (${widget.control.hashCode})");

    var src = widget.control.attrString("src", "")!;
    var srcBase64 = widget.control.attrString("srcBase64", "")!;
    if (src == "" && srcBase64 == "") {
      return const ErrorControl("Lottie must have either \"src\" or \"src_base64\" specified.");
    }

    return withPageArgs((context, pageArgs) {
      Widget? lottie;

      var assetSrc = getAssetSrc(src, pageArgs.pageUri!, pageArgs.assetsDir);
      var x = const Lottie(composition: null,);
      try {
        if (srcBase64 != "") {
          Uint8List bytes = base64Decode(srcBase64);
          lottie = Lottie.memory(
            bytes,
          );
        }
        else if (assetSrc.isFile) {
          lottie = Lottie.asset(
            assetSrc.path,
          );
        } else {
          // URL
          lottie = Lottie.network(
            assetSrc.path,
          );
        }
      } catch (e) {
        return ErrorControl("Lottie error: ${e.toString()}");
      }

      return constrainedControl(context, lottie, widget.parent, widget.control);
    });
  }
}
