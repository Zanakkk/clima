// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveClock extends StatefulWidget {
  final bool isDesktop;
  const LiveClock({super.key, this.isDesktop = false});

  @override
  _LiveClockState createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late String _currentTime;
  late Timer _timer;
  final DateFormat formatter =
      DateFormat('EEEE d MMMM yyyy, HH:mm:ss', 'id_ID');

  @override
  void initState() {
    super.initState();
    _currentTime = formatter.format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = formatter.format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: TextStyle(
        fontSize: widget.isDesktop ? 13 : 11,
        color: Colors.grey[500],
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
