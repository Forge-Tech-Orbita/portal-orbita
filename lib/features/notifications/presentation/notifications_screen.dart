import 'package:flutter/material.dart';

import '../../../core/mock/notifications_mock.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/info_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.notifications});

  /// Lista compartilhada com o Início; sem ela a tela usa dados próprios.
  final ValueNotifier<List<AppNotification>>? notifications;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ValueNotifier<List<AppNotification>> _items =
      widget.notifications ?? ValueNotifier(demoNotifications);
  var _unreadOnly = false;

  void _markRead(String id) {
    _items.value = [
      for (final item in _items.value) item.id == id ? item.markRead() : item,
    ];
  }

  void _markAllRead() {
    _items.value = [for (final item in _items.value) item.markRead()];
  }

  @override
  void dispose() {
    if (widget.notifications == null) _items.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _items,
          builder: (context, items, _) {
            final unread = items.where((item) => !item.read).length;
            final visible = _unreadOnly
                ? items.where((item) => !item.read)
                : items;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Avisos do portal nesta sessão · sem atualização automática',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: const Text('Todas'),
                        selected: !_unreadOnly,
                        onSelected: (_) => setState(() => _unreadOnly = false),
                      ),
                      ChoiceChip(
                        label: Text('Não lidas ($unread)'),
                        selected: _unreadOnly,
                        onSelected: (_) => setState(() => _unreadOnly = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (visible.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Nenhuma notificação não lida.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (final item in visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Semantics(
                        label: item.read ? null : 'Não lida',
                        child: InfoCard(
                          icon: item.icon,
                          title: item.title,
                          subtitle: item.subtitle,
                          onTap: item.read ? null : () => _markRead(item.id),
                          trailing: item.read
                              ? null
                              : const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: OrbitaTheme.primary,
                                ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: unread == 0 ? null : _markAllRead,
                    icon: const Icon(Icons.check),
                    label: const Text('Marcar todas como lidas'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
