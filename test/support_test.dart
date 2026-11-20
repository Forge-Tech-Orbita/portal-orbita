import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/support/data/support_ticket.dart';
import 'package:portal_orbita/features/support/data/support_tickets_mock.dart';
import 'package:portal_orbita/features/support/presentation/widgets/new_ticket_sheet.dart';

const expectedSupportFaqs = [
  ('Como emito a 2ª via do boleto?', 'Acesse Financeiro → Gerar 2ª via.'),
  (
    'Como solicito o histórico escolar?',
    'Abra um chamado na Central de Suporte.',
  ),
  ('Onde vejo minha frequência?', 'Acesse Notas → detalhes da disciplina.'),
];

Future<void> openSupport(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.ensureVisible(find.text('ENTRAR NO PORTAL'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ENTRAR NO PORTAL'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
  final shortcut = find.widgetWithText(OutlinedButton, 'Suporte');
  await tester.ensureVisible(shortcut);
  await tester.pumpAndSettle();
  await tester.tap(shortcut);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'central de suporte exibe card da secretaria e três FAQs na ordem original',
    (tester) async {
      await openSupport(tester);
      for (final text in [
        'Central de suporte',
        'Atendimento',
        'Equipe de suporte',
        'Atendimento demonstrativo · chamados simulados, sem integração',
        'FALE COM A SECRETARIA',
        'Abra um chamado para dúvidas sobre matrícula, documentos, aproveitamento de disciplinas ou requerimentos.',
        'Abrir novo chamado',
        'Perguntas frequentes',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      for (final (question, answer) in expectedSupportFaqs) {
        await tester.ensureVisible(find.text(answer));
        await tester.pumpAndSettle();
        expect(find.text(question), findsOneWidget);
        expect(find.text(answer), findsOneWidget);
      }
      final questions = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .where((text) => expectedSupportFaqs.any((faq) => faq.$1 == text));
      expect(questions, expectedSupportFaqs.map((faq) => faq.$1));
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.textContaining('em migração'), findsNothing);
    },
  );

  testWidgets(
    'Abrir novo chamado valida formulário, cria chamado e lista na equipe',
    (tester) async {
      await openSupport(tester);
      final button = find.widgetWithText(FilledButton, 'Abrir novo chamado');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(NewTicketSheet), findsOneWidget);
      expect(find.text('Novo chamado'), findsOneWidget);

      final send = find.widgetWithText(FilledButton, 'Enviar chamado');
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pumpAndSettle();
      for (final error in [
        'Selecione a categoria.',
        'Descreva o assunto com ao menos 5 caracteres.',
        'Detalhe a solicitação com ao menos 10 caracteres.',
      ]) {
        expect(find.text(error), findsOneWidget);
      }

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Documentos').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Assunto'),
        'Histórico escolar atualizado',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Descrição'),
        'Preciso do histórico para processo de transferência.',
      );
      await tester.ensureVisible(send);
      await tester.pumpAndSettle();
      await tester.tap(send);
      await tester.pump();
      expect(find.text('ENVIANDO...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.byType(NewTicketSheet), findsNothing);
      expect(find.text('Chamado ORB-1003 criado.'), findsOneWidget);
      await tester.tap(find.text('Ver chamados'));
      await tester.pumpAndSettle();

      expect(find.text('3 chamados · 2 pendentes'), findsOneWidget);
      expect(find.text('ORB-1003'), findsOneWidget);
      expect(find.text('Histórico escolar atualizado'), findsOneWidget);
      expect(find.text('Aberto'), findsOneWidget);

      final start = find.text('Iniciar atendimento');
      await tester.ensureVisible(start);
      await tester.pumpAndSettle();
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(find.text('Aberto'), findsNothing);
      expect(find.text('Em atendimento'), findsNWidgets(2));

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  testWidgets(
    'aba da equipe lista fixtures e permite concluir chamado em atendimento',
    (tester) async {
      await openSupport(tester);
      await tester.tap(find.text('Equipe de suporte'));
      await tester.pumpAndSettle();

      expect(find.text('2 chamados · 1 pendentes'), findsOneWidget);
      for (final ticket in demoSupportTickets) {
        await tester.ensureVisible(find.text(ticket.subject));
        await tester.pumpAndSettle();
        expect(find.text(ticket.protocol), findsOneWidget);
        expect(find.text(ticket.status.label), findsOneWidget);
      }
      expect(find.text('Iniciar atendimento'), findsNothing);

      final resolve = find.text('Marcar como resolvido');
      await tester.ensureVisible(resolve);
      await tester.pumpAndSettle();
      await tester.tap(resolve);
      await tester.pumpAndSettle();

      expect(find.text('Marcar como resolvido'), findsNothing);
      expect(find.text('Resolvido'), findsNWidgets(2));
      expect(find.text('2 chamados · 0 pendentes'), findsOneWidget);
    },
  );

  test('status do chamado avança até resolvido', () {
    expect(SupportTicketStatus.open.next, SupportTicketStatus.inProgress);
    expect(SupportTicketStatus.inProgress.next, SupportTicketStatus.resolved);
    expect(SupportTicketStatus.resolved.next, isNull);
  });

  for (final size in [
    const Size(360, 800),
    const Size(390, 844),
    const Size(360, 640),
  ]) {
    testWidgets(
      'secretaria e perguntas frequentes alcançáveis sem overflow em $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await openSupport(tester);

        await tester.ensureVisible(find.text('Abrir novo chamado'));
        await tester.pumpAndSettle();
        expect(find.text('Abrir novo chamado').hitTestable(), findsOneWidget);
        for (final (question, answer) in expectedSupportFaqs) {
          await tester.ensureVisible(find.text(answer));
          await tester.pumpAndSettle();
          expect(find.text(question).hitTestable(), findsOneWidget);
          expect(find.text(answer).hitTestable(), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'texto ampliado mantém chamado e três FAQs legíveis por rolagem',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openSupport(tester);

      for (final target in [
        find.text('FALE COM A SECRETARIA'),
        find.text('Abrir novo chamado'),
        for (final (question, answer) in expectedSupportFaqs) ...[
          find.text(question),
          find.text(answer),
        ],
      ]) {
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
