import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  final String userId;

  NewsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Financial News')),
      body: Center(child: Text('Financial news will be displayed here')),
    );
  }
}
