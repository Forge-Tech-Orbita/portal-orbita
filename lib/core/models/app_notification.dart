import 'package:flutter/widgets.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.read = false,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool read;

  AppNotification markRead() => AppNotification(
    id: id,
    icon: icon,
    title: title,
    subtitle: subtitle,
    read: true,
  );
}
