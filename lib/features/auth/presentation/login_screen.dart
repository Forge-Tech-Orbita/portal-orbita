import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Login — em migração'),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(AppRoutes.main, (_) => false),
                child: const Text('Entrar no portal demonstrativo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
