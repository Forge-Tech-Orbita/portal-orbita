import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/orbita_theme.dart';
import '../../../core/widgets/account_avatar.dart';
import '../../../core/widgets/orbita_bottom_nav.dart';
import '../data/admin.dart';
import '../data/admin_mock.dart';
import 'admin_audit_screen.dart';
import 'admin_panel_screen.dart';
import 'admin_permissions_screen.dart';
import 'admin_tickets_screen.dart';
import 'admin_users_screen.dart';

const adminNavItems = <OrbitaNavItem>[
  (icon: Icons.home_outlined, label: 'Painel'),
  (icon: Icons.group_outlined, label: 'Usuários'),
  (icon: Icons.help_outline, label: 'Chamados'),
  (icon: Icons.shield_outlined, label: 'Permissões'),
  (icon: Icons.description_outlined, label: 'Auditoria'),
];

abstract final class AdminTab {
  static const panel = 0;
  static const users = 1;
  static const tickets = 2;
  static const permissions = 3;
  static const audit = 4;
}

String _now() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}';
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = AdminTab.panel;
  var _auditFilter = AuditFilter.today;
  // shortcut: operações administrativas ficam só nesta sessão, sem backend.
  final _accounts = [...adminAccounts];
  final _tickets = [...adminTickets];
  final _audit = [...auditEntries];
  final _requests = <RoleRequest>[];

  void _log(String title, AuditResult result, {bool critical = false}) {
    _audit.insert(
      0,
      AuditEntry(
        title: title,
        actor: 'adm.ana',
        time: _now(),
        result: result,
        critical: critical,
      ),
    );
  }

  void _toggleBlock(AdminAccount account) {
    final blocked = account.status == AccountStatus.blocked;
    final index = _accounts.indexWhere((item) => item.id == account.id);
    setState(() {
      _accounts[index] = account.copyWith(
        status: blocked ? AccountStatus.active : AccountStatus.blocked,
      );
      _log(
        '${blocked ? 'Conta desbloqueada' : 'Conta bloqueada'} · ${account.name}',
        AuditResult.success,
      );
    });
    _message(blocked ? 'Conta desbloqueada.' : 'Conta bloqueada.');
  }

  void _invite(Invite invite) {
    setState(() {
      _accounts.add(
        AdminAccount(
          id: 'invite-${invite.email}',
          name: invite.email,
          detail: '${invite.role} (convite) · enviado hoje',
          group: AccountGroup.academic,
          status: AccountStatus.pending,
        ),
      );
      _log('Convite enviado · ${invite.role}', AuditResult.success);
    });
    _message('Convite enviado para ${invite.email}.');
  }

  void _advance(AdminTicket ticket) {
    final next = ticket.status.next;
    if (next == null) return;
    final index = _tickets.indexWhere((item) => item.id == ticket.id);
    setState(() {
      _tickets[index] = ticket.copyWith(status: next);
      _log('Chamado ${ticket.id} · ${next.label}', AuditResult.success);
    });
    _message('${ticket.id} agora está ${next.label.toLowerCase()}.');
  }

  void _forward(AdminTicket ticket, String team) {
    final index = _tickets.indexWhere((item) => item.id == ticket.id);
    setState(() => _tickets[index] = ticket.copyWith(team: team));
    _message('${ticket.id} encaminhado para $team.');
  }

  void _requestRole(RoleRequest request) {
    setState(() {
      _requests.insert(0, request);
      _log('Pedido de papel: ${request.role}', AuditResult.pending);
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final openTickets = _tickets
        .where((ticket) => ticket.status == TicketStatus.open)
        .toList();

    return Scaffold(
      body: Column(
        children: [
          _AdminHeader(title: adminNavItems[_index].label),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                AdminPanelScreen(
                  openTickets: openTickets.length,
                  urgentTickets: openTickets
                      .where((t) => t.priority == TicketPriority.urgent)
                      .length,
                  pendingRequests:
                      _accounts
                          .where((a) => a.status == AccountStatus.pending)
                          .length +
                      _audit
                          .where((e) => e.result == AuditResult.pending)
                          .length +
                      pendingProfessorAccounts,
                  criticalAlerts: _audit.where((e) => e.critical).toList(),
                  onOpenAudit: () => setState(() {
                    _auditFilter = AuditFilter.critical;
                    _index = AdminTab.audit;
                  }),
                  onOpenUsers: () => setState(() => _index = AdminTab.users),
                  onOpenTickets: () =>
                      setState(() => _index = AdminTab.tickets),
                ),
                AdminUsersScreen(
                  accounts: _accounts,
                  onToggleBlock: _toggleBlock,
                  onInvite: _invite,
                ),
                AdminTicketsScreen(
                  tickets: _tickets,
                  onAdvance: _advance,
                  onForward: _forward,
                ),
                AdminPermissionsScreen(
                  requests: _requests,
                  onRequest: _requestRole,
                ),
                AdminAuditScreen(
                  entries: _audit,
                  filter: _auditFilter,
                  onFilterChanged: (filter) =>
                      setState(() => _auditFilter = filter),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: OrbitaBottomNav(
          currentIndex: _index,
          items: adminNavItems,
          dark: true,
          onTap: (index) => setState(() => _index = index),
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: OrbitaTheme.text,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: OrbitaTheme.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ÓRBITA ADMIN · PORTAL SEPARADO',
                      style: textTheme.labelSmall?.copyWith(
                        color: OrbitaTheme.amber,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: OrbitaTheme.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Sair do portal administrativo',
                color: OrbitaTheme.surface,
                onPressed: () => signOut(context, route: AppRoutes.adminLogin),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
