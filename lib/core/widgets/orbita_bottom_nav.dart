import 'package:flutter/material.dart';

import '../theme/orbita_theme.dart';

typedef OrbitaNavItem = ({IconData icon, String label});

const studentNavItems = <OrbitaNavItem>[
  (icon: Icons.home_outlined, label: 'Início'),
  (icon: Icons.calendar_today_outlined, label: 'Horário'),
  (icon: Icons.bar_chart_outlined, label: 'Notas'),
  (icon: Icons.menu_book_outlined, label: 'Cursos'),
  (icon: Icons.more_horiz, label: 'Mais'),
];

class OrbitaBottomNav extends StatelessWidget {
  const OrbitaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = studentNavItems,
    this.dark = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<OrbitaNavItem> items;

  /// Variante escura usada pelo Portal Administrativo.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: dark ? OrbitaTheme.text : OrbitaTheme.border),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: dark ? OrbitaTheme.text : null,
        selectedItemColor: dark ? OrbitaTheme.surface : null,
        unselectedItemColor: dark
            ? OrbitaTheme.surface.withValues(alpha: 0.6)
            : null,
        items: [
          for (final item in items)
            BottomNavigationBarItem(icon: Icon(item.icon), label: item.label),
        ],
      ),
    );
  }
}
