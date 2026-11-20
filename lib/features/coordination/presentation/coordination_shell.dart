import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/models/learning_material.dart';
import '../../../core/widgets/materials_board.dart';
import '../../../core/widgets/orbita_bottom_nav.dart';
import '../data/coordination.dart';
import '../data/coordination_mock.dart';
import 'coordination_classes_screen.dart';
import 'coordination_panel_screen.dart';
import 'coordination_publish_screen.dart';

const coordinationNavItems = <OrbitaNavItem>[
  (icon: Icons.home_outlined, label: 'Painel'),
  (icon: Icons.group_outlined, label: 'Turmas'),
  (icon: Icons.menu_book_outlined, label: 'Materiais'),
  (icon: Icons.campaign_outlined, label: 'Publicar'),
];

abstract final class CoordinationTab {
  static const panel = 0;
  static const classes = 1;
  static const materials = 2;
  static const publish = 3;
}

class CoordinationShell extends StatefulWidget {
  const CoordinationShell({super.key});

  @override
  State<CoordinationShell> createState() => _CoordinationShellState();
}

class _CoordinationShellState extends State<CoordinationShell> {
  int _index = CoordinationTab.panel;
  var _classFilter = ClassFilter.all;
  // shortcut: publicações ficam só nesta sessão, sem persistência.
  final _materials = [...coordinationMaterials];
  final _posts = [...coursePosts];

  Future<void> _newMaterial() async {
    final result = await Navigator.of(context)
        .pushNamed(AppRoutes.coordinationNewMaterial);
    if (!mounted || result is! PublishedMaterial) return;

    setState(() {
      _materials.insert(0, result.material);
      _index = CoordinationTab.materials;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Material publicado.')));
  }

  void _publish(CoursePost post) => setState(() => _posts.insert(0, post));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            CoordinationPanelScreen(
              onPublishEvent: () =>
                  setState(() => _index = CoordinationTab.publish),
              onPostMaterial: _newMaterial,
              onOpenRiskClasses: () => setState(() {
                _classFilter = ClassFilter.atRisk;
                _index = CoordinationTab.classes;
              }),
            ),
            CoordinationClassesScreen(
              filter: _classFilter,
              onFilterChanged: (filter) =>
                  setState(() => _classFilter = filter),
            ),
            MaterialsBoard(
              subtitle: 'Para todo o curso ou para períodos específicos',
              filters: const ['Curso inteiro', '6º período', 'Calouros'],
              materials: _materials,
              onNewMaterial: _newMaterial,
            ),
            CoordinationPublishScreen(posts: _posts, onPublished: _publish),
          ],
        ),
      ),
      bottomNavigationBar: OrbitaBottomNav(
        currentIndex: _index,
        items: coordinationNavItems,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}
