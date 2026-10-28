import 'package:flutter/material.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mural de avisos')),
      body: const SafeArea(
        child: Center(child: Text('Mural de avisos — em migração')),
      ),
    );
  }
}
