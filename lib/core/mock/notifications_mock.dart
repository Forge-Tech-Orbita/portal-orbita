import 'package:flutter/material.dart';

import '../models/app_notification.dart';

const demoNotifications = [
  AppNotification(
    id: 'material-ai',
    icon: Icons.description_outlined,
    title: 'Novo material em Inteligência Artificial',
    subtitle: 'PDF postado pelo Prof. R. Nakamura · há 12 min',
  ),
  AppNotification(
    id: 'invoice-november',
    icon: Icons.credit_card_outlined,
    title: 'Fatura de novembro disponível',
    subtitle: 'Vence em 10/12/2026 · há 2 h',
  ),
  AppNotification(
    id: 'ticket-0412',
    icon: Icons.help_outline,
    title: 'Chamado #2026-0412 atualizado',
    subtitle: 'Status: em análise · ontem',
  ),
  AppNotification(
    id: 'loan-due',
    icon: Icons.menu_book_outlined,
    title: 'Empréstimo vence em 2 dias',
    subtitle: 'Estruturas de Dados e Algoritmos · ontem',
    read: true,
  ),
  AppNotification(
    id: 'grades-architecture',
    icon: Icons.bar_chart_outlined,
    title: 'Notas atualizadas: Arquitetura de Software',
    subtitle: 'Importadas do sistema acadêmico · ontem',
    read: true,
  ),
];
