import 'package:flutter/material.dart';

import '../models/notice.dart';
import '../theme/orbita_theme.dart';

class NoticeTile extends StatelessWidget {
  const NoticeTile({super.key, required this.notice, this.compact = false});

  final Notice notice;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = switch (notice.category) {
      NoticeCategory.academic => OrbitaTheme.primary,
      NoticeCategory.events => OrbitaTheme.terracotta,
      NoticeCategory.financial => OrbitaTheme.amber,
    };
    final tag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        notice.category.label,
        style: textTheme.labelSmall?.copyWith(color: OrbitaTheme.text),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: compact
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tag,
                const SizedBox(width: 10),
                Expanded(child: Text(notice.summary ?? notice.body)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notice.title, style: textTheme.titleSmall),
                const SizedBox(height: 4),
                tag,
                const SizedBox(height: 8),
                Text(notice.body),
                const SizedBox(height: 4),
                Text(notice.dateText, style: textTheme.bodySmall),
              ],
            ),
    );
  }
}
