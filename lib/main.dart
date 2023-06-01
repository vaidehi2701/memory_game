import 'package:flutter/material.dart';
import 'package:memory_game/views/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //devDiariesWithVee on Instagram
 //devDiariesWithVee on Youtube
 //vaidehi2701 on Github/Linkedin

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Memory Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
