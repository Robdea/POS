import 'package:flutter/material.dart';

class AppShapes {
  AppShapes._();

  static const double radius = 10;

  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(radius));

  static const RoundedRectangleBorder cardShape =
      RoundedRectangleBorder(borderRadius: borderRadius);
}