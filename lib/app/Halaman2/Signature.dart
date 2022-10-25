// ignore_for_file: file_names, depend_on_referenced_packages, use_build_context_synchronously, avoid_print

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:signature/signature.dart';

class SignatureDosen extends StatefulWidget {
  const SignatureDosen({Key? key}) : super(key: key);

  @override
  State<SignatureDosen> createState() => _SignatureDosenState();
}

class _SignatureDosenState extends State<SignatureDosen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    exportPenColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  Future<void> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No content')));
      return;
    }

    final Uint8List? data = await _controller.toPngBytes();
    if (data == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(
                color: Colors.yellow,
                child: Image.memory(data),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> exportSVG(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No content')));
      return;
    }

    final SvgPicture data = _controller.toSVG()!;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(color: Colors.grey[300], child: data),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double swidth = MediaQuery.of(context).size.width;
    double sheight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: ListView(
            children: <Widget>[
              const SizedBox(
                height: 120,
              ),

              Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  width: swidth / 2,
                  height: (sheight / 2) - 100,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Signature(
                      controller: _controller,
                      height: 300,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              //OK AND CLEAR BUTTONS
              Container(
                decoration: const BoxDecoration(color: Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //SHOW EXPORTED IMAGE IN NEW ROUTE
                    IconButton(
                      icon: const Icon(Icons.image),
                      color: Colors.blue,
                      onPressed: () => exportImage(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.polyline),
                      color: Colors.blue,
                      onPressed: () => exportSVG(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _controller.undo());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _controller.redo());
                      },
                    ),
                    //CLEAR CANVAS
                    IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _controller.clear());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
