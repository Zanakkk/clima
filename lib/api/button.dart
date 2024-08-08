import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

IconData getSocialMediaIcon(String name) {
  switch (name.toLowerCase()) {
    case 'whatsapp':
      return LineIcons.whatSApp;
    case 'instagram':
      return LineIcons.instagram;
    case 'tiktok':
      return Icons.tiktok;
    case 'linkedin':
      return LineIcons.linkedin;
    case 'twitter':
      return LineIcons.twitter;
    case 'email':
      return LineIcons.mailBulk;
    case 'github':
      return LineIcons.github;
    case 'dribble':
      return LineIcons.dribbble;
    case 'facebook':
      return LineIcons.facebook;
    default:
      return Icons.link; // Default icon if name does not match predefined icons
  }
}
