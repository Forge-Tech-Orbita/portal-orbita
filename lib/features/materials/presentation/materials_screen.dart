import 'package:flutter/material.dart';

import '../../../core/widgets/material_tile.dart';
import '../../../core/widgets/page_heading.dart';
import '../data/student_materials_mock.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final materials = demoStudentMaterials.where(
      (material) => _filter == null || material.audiences.contains(_filter),
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
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final filter in studentMaterialFilters)
                    ChoiceChip(
                      label: Text(filter),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
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
