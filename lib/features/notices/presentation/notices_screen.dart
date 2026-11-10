import 'package:flutter/material.dart';

import '../../../core/mock/notices_mock.dart';
import '../../../core/widgets/notice_tile.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mural de avisos')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Comunicados e datas de demonstração',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              for (final notice in demoNotices) NoticeTile(notice: notice),
            ],
          ),
        ),
      ),
    );
  }
}
