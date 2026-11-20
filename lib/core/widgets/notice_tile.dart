import 'package:flutter/material.dart';

import '../models/notice.dart';
import 'status_tag.dart';

TagTone noticeTone(NoticeCategory category) => switch (category) {
  NoticeCategory.academic => TagTone.info,
  NoticeCategory.events => TagTone.danger,
  NoticeCategory.financial => TagTone.warning,
};

class NoticeTile extends StatelessWidget {
  const NoticeTile({super.key, required this.notice, this.compact = false});

  final Notice notice;

  /// Versão em card com título curto e resumo, usada no Início.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tag = StatusTag(
      label: notice.category.label,
      tone: noticeTone(notice.category),
    );

    if (compact) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice.shortTitle ?? notice.title,
                      style: textTheme.bodyLarge,
                    ),
                    Text(
                      notice.summary ?? notice.body,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              tag,
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notice.title, style: textTheme.titleSmall),
          const SizedBox(height: 4),
          tag,
          const SizedBox(height: 6),
          Text(notice.body),
          const SizedBox(height: 4),
          Text(notice.dateText, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
