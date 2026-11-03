import 'package:flutter/material.dart';

void main() {
  runApp(const ApexProApp());
}

class ApexProApp extends StatelessWidget {
  const ApexProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex Pro Auto Downloader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Apex Pro Auto Downloader'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            '⚡ Apex Pro Engine Active\nAutonomous Downloader Ready',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
