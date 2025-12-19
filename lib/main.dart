import 'package:flutter/material.dart';
export 'core/app.dart';
import 'core/app.dart';
import 'core/di.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}
