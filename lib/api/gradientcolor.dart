// gradientcolor.dart

// ignore_for_file: non_constant_identifier_names


import 'package:flutter/material.dart';

Color FaceBookColor1 = const Color(0xFF538FEB);
Color FaceBookColor2 = const Color(0xFFABDCFD);

Color Tiktok1 = const Color(0xFF7F7AB8);
Color Tiktok2 = const Color(0xFFEEADE1);

Color Instagram1 = const Color(0xFFDD6598);
Color Instagram2 = const Color(0xFF894DA2);

Color WhatsApp1 = const Color(0xFFD9DBBE);
Color WhatsApp2 = const Color(0xFF7EA27B);

Color Email1 = const Color(0xFFED8F55);
Color Email2 = const Color(0xFFFF7F31);

Color Dribble1 = const Color(0xFFED8F55);
Color Dribble2 = const Color(0xFFFF7F31);

LinearGradient getSocialMediaGradient(String name) {
  switch (name.toLowerCase()) {
    case 'facebook':
      return LinearGradient(colors: [FaceBookColor1, FaceBookColor2]);
    case 'instagram':
      return LinearGradient(colors: [Instagram1, Instagram2]);
    case 'tiktok':
      return LinearGradient(colors: [Tiktok1, Tiktok2]);
    case 'dribble':
      return LinearGradient(colors: [Dribble1, Dribble2]);
    case 'whatsapp':
      return LinearGradient(colors: [WhatsApp1, WhatsApp2]);
    case 'email':
      return LinearGradient(colors: [Email1, Email2]);
    case 'github':
      return const LinearGradient(colors: [
        Colors.black,
        Colors.grey,
      ]);
    default:
      return const LinearGradient(colors: [
        Colors.black,
        Colors.grey,
      ]); // Default gradient if name does not match predefined gradients
  }
}
