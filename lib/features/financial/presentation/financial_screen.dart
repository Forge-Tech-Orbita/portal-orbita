import 'package:flutter/material.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financeiro')),
      body: const SafeArea(
        child: Center(child: Text('Financeiro — em migração')),
      ),
    );
  }
}
