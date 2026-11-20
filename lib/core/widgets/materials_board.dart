import 'package:flutter/material.dart';

import '../models/learning_material.dart';
import 'material_tile.dart';
import 'page_heading.dart';

/// Lista de materiais com filtros por público e botão de novo material.
class MaterialsBoard extends StatefulWidget {
  const MaterialsBoard({
    super.key,
    required this.subtitle,
    required this.filters,
    required this.materials,
    required this.onNewMaterial,
    this.allLabel = 'Todos',
  });

  final String subtitle;
  final List<String> filters;
  final String allLabel;
  final List<LearningMaterial> materials;
  final VoidCallback onNewMaterial;

  @override
  State<MaterialsBoard> createState() => _MaterialsBoardState();
}

class _MaterialsBoardState extends State<MaterialsBoard> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final materials = widget.materials.where(
      (material) => _filter == null || material.audiences.contains(_filter),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeading(
            overline: 'Livros em PDF e links recomendados',
            title: 'Materiais',
            subtitle: widget.subtitle,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: Text(widget.allLabel),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              for (final filter in widget.filters)
                ChoiceChip(
                  label: Text(filter),
                  selected: _filter == filter,
                  onSelected: (_) => setState(() => _filter = filter),
                ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: widget.onNewMaterial,
            icon: const Icon(Icons.add),
            label: const Text('Novo material'),
          ),
          const SizedBox(height: 12),
          if (materials.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhum material para este filtro.',
                textAlign: TextAlign.center,
              ),
            ),
          for (final material in materials)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MaterialTile(
                material: material,
                onOpen: () => showMaterialUnavailable(context, material),
              ),
            ),
        ],
      ),
    );
  }
}
