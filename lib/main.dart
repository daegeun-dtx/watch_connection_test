import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watch_connection_test/my_android_page.dart';
import 'package:watch_connection_test/my_ios_page.dart';

const String packageA = "watch_connectivity";
const String packageB = "flutter_*_connectivity";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return MaterialApp(
        title: '워치 다중 패키지 데모',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AndroidHomePage(title: 'Android Test'),
      );
    } else {
      return MaterialApp(
        title: '워치 다중 패키지 데모',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const IosHomePage(title: 'iOS Test'),
      );
    }
  }
}
