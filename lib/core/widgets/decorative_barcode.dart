import 'package:flutter/material.dart';

import '../theme/orbita_theme.dart';

class DecorativeBarcode extends StatelessWidget {
  const DecorativeBarcode({super.key, this.count = 14}) : assert(count > 0);

  final int count;

  @override
  Widget build(BuildContext context) {
    // shortcut: barras apenas decorativas, substituir se houver identificação escaneável real.
    const heights = [
      8.0,
      18.0,
      12.0,
      20.0,
      10.0,
      16.0,
      9.0,
      19.0,
      14.0,
      8.0,
      17.0,
      11.0,
      20.0,
      13.0,
    ];

    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < count; index++)
            SizedBox(
              width: 2,
              height: heights[index % heights.length],
              child: const ColoredBox(color: OrbitaTheme.text),
            ),
        ],
      ),
    );
  }
}
