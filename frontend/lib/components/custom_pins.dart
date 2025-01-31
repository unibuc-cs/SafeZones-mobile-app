//import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarkers {
  static Future<BitmapDescriptor> yellowPin() async {
    final Uint8List markerIcon = await _getBytesFromAsset('assets/images/yellow_pin.png', width: 100);
    return BitmapDescriptor.fromBytes(markerIcon);
  }

  static Future<BitmapDescriptor> redPin() async {
    final Uint8List markerIcon = await _getBytesFromAsset('assets/images/red_pin.png', width: 100);
    return BitmapDescriptor.fromBytes(markerIcon);
  }

  static Future<Uint8List> _getBytesFromAsset(String path, {int width = 200}) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }
}
