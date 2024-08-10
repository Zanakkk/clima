// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class LihatFoto extends StatelessWidget {
  const LihatFoto({
    super.key,
    required this.foto,
  });
  final String? foto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: PinchZoom(
            maxScale: 2.5,
            onZoomStart: () {},
            onZoomEnd: () {},
            child: (MediaQuery.of(context).size.width >
                    MediaQuery.of(context).size.height)
                ? ImageNetwork(
                    image: foto!,
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    fitWeb: BoxFitWeb.scaleDown,
                  )
                : ImageNetwork(
                    image: foto!,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.height,
                    fitAndroidIos: BoxFit.fitWidth,
                  )),
      ),
    );
  }
}
