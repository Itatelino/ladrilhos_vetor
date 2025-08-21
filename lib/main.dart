import 'package:flutter/material.dart';
import 'package:ladrilhos_app/screens/tile_selection_screen.dart';
// ignore: unused_import
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ladrilhos Cores da Roça',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const TileSelectionScreen(),
    );
  }
}
