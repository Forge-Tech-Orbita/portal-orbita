import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/features/home/presentation/home_screen.dart';
import 'package:portal_orbita/features/support/data/support_tickets_mock.dart';
import 'package:portal_orbita/features/support/presentation/new_ticket_screen.dart';
import 'package:portal_orbita/features/support/presentation/support_screen.dart';
import 'package:portal_orbita/features/support/presentation/ticket_sent_screen.dart';

import 'helpers.dart';

Future<void> openNewTicket(WidgetTester tester) async {
  await loginAs(tester);
  await openFromMore(tester, 'Suporte');
  await tapVisible(tester, find.text('Abrir novo chamado'));
}

Future<void> fillTicket(WidgetTester tester) async {
  await tapVisible(tester, find.text('Selecione o assunto'));
  await tester.tap(find.text('Documentos e declarações').last);
  await tester.pumpAndSettle();
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Declaração de matrícula para estágio');
  await tester.enterText(
    fields.at(1),
    'Preciso de uma declaração de matrícula do semestre 2026.2.',
  );
}

Future<void> send(WidgetTester tester) async {
  await tapVisible(tester, find.text('Enviar chamado'));
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

void main() {
  test('protocolos seguem o formato #2026-NNNN', () {
    expect(ticketProtocol(firstNewTicketNumber), '#2026-0418');
    expect(ticketProtocol(5), '#2026-0005');
    expect(demoSupportTickets.single.protocol, '#2026-0412');
  });

  testWidgets('central mostra secretaria, chamado aberto e perguntas', (
    tester,
  ) async {
    await pumpScreen(tester, const SupportScreen());

    expect(find.text('FALE COM A SECRETARIA'), findsOneWidget);
    expect(find.text('Chamado #2026-0412 · Histórico escolar'), findsOne);
    expect(find.text('Em análise'), findsOneWidget);
    for (final (question, answer) in supportFaqs) {
      expect(find.text(question), findsOneWidget);
      expect(find.text(answer), findsOneWidget);
    }
  });

  testWidgets('formulário valida assunto, título e descrição', (tester) async {
    await pumpScreen(tester, const NewTicketScreen());
    await tapVisible(tester, find.text('Enviar chamado'));

    expect(find.text('Selecione o assunto.'), findsOneWidget);
    expect(
      find.text('Descreva o título com ao menos 5 caracteres.'),
      findsOneWidget,
    );
    expect(
      find.text('Detalhe a solicitação com ao menos 10 caracteres.'),
      findsOneWidget,
    );
  });

  testWidgets('anexar informa que depende de integração', (tester) async {
    await pumpScreen(tester, const NewTicketScreen());
    await tapVisible(tester, find.text('Anexar arquivo'));
    expect(
      find.text('Anexos ficam disponíveis após a integração.'),
      findsOneWidget,
    );
  });

  testWidgets('enviar mostra protocolo e volta ao suporte com o chamado', (
    tester,
  ) async {
    await openNewTicket(tester);
    await fillTicket(tester);
    await tapVisible(tester, find.text('Enviar chamado'));
    expect(find.text('ENVIANDO...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(TicketSentScreen), findsOneWidget);
    expect(find.text('Chamado enviado'), findsOneWidget);
    expect(find.text('#2026-0418'), findsOneWidget);
    expect(find.text('Aberto'), findsOneWidget);

    await tapVisible(tester, find.text('Voltar ao suporte'));
    expect(find.byType(SupportScreen), findsOneWidget);
    expect(
      find.text('Chamado #2026-0418 · Declaração de matrícula para estágio'),
      findsOneWidget,
    );
  });

  testWidgets('ir para o início limpa a pilha do suporte', (tester) async {
    await openNewTicket(tester);
    await fillTicket(tester);
    await send(tester);
    await tapVisible(tester, find.text('Ir para o início'));

    expect(find.byType(HomeScreen), findsOneWidget);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('cancelar volta sem criar chamado', (tester) async {
    await openNewTicket(tester);
    await tapVisible(tester, find.text('Cancelar'));
    expect(find.byType(SupportScreen), findsOneWidget);
    expect(find.textContaining('#2026-0418'), findsNothing);
  });

  for (final size in testViewports) {
    testWidgets('suporte e formulário sem overflow em $size', (tester) async {
      useViewport(tester, size, textScale: 2);
      await pumpScreen(tester, const SupportScreen());
      await tester.ensureVisible(find.text(supportFaqs.last.$2));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await pumpScreen(tester, const NewTicketScreen());
      await tester.ensureVisible(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
