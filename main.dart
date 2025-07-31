// lib/main.dart

import 'package:flutter/material.dart';
import 'package:kouchuhyo_app/screens/home_screen.dart'; // 読み込む画面をhome_screen.dartに変更

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '工注票アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // 最初に表示する画面をHomeScreenに変更
    );
  }
}