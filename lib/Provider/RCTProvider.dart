// ignore_for_file: file_names

import 'package:flutter/material.dart';

class RCTProvider with ChangeNotifier {
  final Map<String, bool> _rctStatus = {};

  bool getRCT(String label) {
    return _rctStatus[label] ?? false;
  }

  void setRCT(String label, bool value) {
    _rctStatus[label] = value;
    notifyListeners();
  }
}
