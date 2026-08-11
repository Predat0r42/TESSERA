// TESSERA · © susi.su, All Rights Reserved
import 'package:flutter/material.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(const TesseraApp());
}

class TesseraApp extends StatelessWidget {
  const TesseraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TESSERA',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}
