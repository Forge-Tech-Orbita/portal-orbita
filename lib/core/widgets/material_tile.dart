import 'package:flutter/material.dart';

import '../models/learning_material.dart';
import '../theme/orbita_theme.dart';
import 'status_tag.dart';

class MaterialTile extends StatelessWidget {
  const MaterialTile({super.key, required this.material, this.onOpen});

  final LearningMaterial material;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPdf = material.kind == MaterialKind.pdf;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Icon(
              isPdf ? Icons.description_outlined : Icons.link,
              color: isPdf ? OrbitaTheme.terracotta : OrbitaTheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(material.title, style: textTheme.bodyLarge),
                  Text(material.details, style: textTheme.bodySmall),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusTag(
                    label: material.kind.label,
                    tone: isPdf ? TagTone.danger : TagTone.info,
                  ),
                  if (onOpen != null)
                    TextButton(
                      onPressed: onOpen,
                      child: Text(
                        material.kind.action,
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Feedback padrão enquanto não há armazenamento real de arquivos.
void showMaterialUnavailable(BuildContext context, LearningMaterial material) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '"${material.title}" é demonstrativo; o arquivo abre após a integração.',
        ),
      ),
    );
}
