import 'package:flutter/material.dart';

import '../../../core/models/learning_material.dart';
import '../../../core/widgets/material_tile.dart';
import '../../../core/widgets/page_heading.dart';
import '../data/student_materials_mock.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  String? _discipline;
  MaterialKind? _kind;

  @override
  Widget build(BuildContext context) {
    final materials = demoStudentMaterials.where(
      (material) =>
          (_discipline == null || material.audiences.contains(_discipline)) &&
          (_kind == null || material.kind == _kind),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Materiais')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                overline: 'Livros em PDF e links recomendados',
                title: 'Materiais',
                subtitle: 'Postados pelos professores das suas disciplinas e pela coordenação',
              ),
              const SizedBox(height: 10),
              const Text('Disciplina'),
              Wrap(
                key: const ValueKey('material-discipline-filter'),
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _discipline == null,
                    onSelected: (_) => setState(() => _discipline = null),
                  ),
                  for (final filter in studentMaterialFilters)
                    ChoiceChip(
                      label: Text(filter),
                      selected: _discipline == filter,
                      onSelected: (_) => setState(() => _discipline = filter),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Tipo de material'),
              Wrap(
                key: const ValueKey('material-kind-filter'),
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _kind == null,
                    onSelected: (_) => setState(() => _kind = null),
                  ),
                  for (final kind in MaterialKind.values)
                    ChoiceChip(
                      label: Text(kind.label),
                      selected: _kind == kind,
                      onSelected: (_) => setState(() => _kind = kind),
                    ),
                ],
              ),
              const SizedBox(height: 10),
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
        ),
      ),
    );
  }
}
