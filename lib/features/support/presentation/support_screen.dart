import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central de suporte')),
      body: const SafeArea(
        child: Center(child: Text('Central de suporte — em migração')),
      ),
    );
  }
}
