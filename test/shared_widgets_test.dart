import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/mock/notices_mock.dart';
import 'package:portal_orbita/core/mock/student_mock.dart';
import 'package:portal_orbita/core/models/notice.dart';
import 'package:portal_orbita/core/models/student.dart';
import 'package:portal_orbita/core/theme/orbita_theme.dart';
import 'package:portal_orbita/core/widgets/notice_tile.dart';
import 'package:portal_orbita/core/widgets/student_id_card.dart';

Future<void> pumpComponent(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: OrbitaTheme.data,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  test('estudante mantém os dados e máscaras do legado', () {
    expect(
      [
        demoStudent.name,
        demoStudent.shortName,
        demoStudent.initials,
        demoStudent.course,
        demoStudent.period,
        demoStudent.registration,
        demoStudent.validUntil,
        demoStudent.maskedCpf,
        demoStudent.email,
        demoStudent.maskedPhone,
      ],
      [
        'Marina Duarte Costa',
        'Marina Duarte',
        'MD',
        'Engenharia de Software',
        '6º período',
        '2023104567',
        '12/2027',
        '•••.•••.•••-45',
        'marina.costa@orbita.edu',
        '(11) 9•••-4521',
      ],
    );
  });

  test(
    'avisos preservam ordem, categorias, datas e três resumos distintos',
    () {
      expect(demoNotices, hasLength(4));
      expect(demoNotices.map((notice) => notice.id).toSet(), hasLength(4));
      expect(demoNotices.map((notice) => notice.title), [
        'Matrícula do próximo período',
        'Semana de Tecnologia Órbita',
        'Boleto de setembro disponível',
        'Manutenção no laboratório 2',
      ]);
      expect(demoNotices.map((notice) => notice.category), [
        NoticeCategory.academic,
        NoticeCategory.events,
        NoticeCategory.financial,
        NoticeCategory.academic,
      ]);
      expect(demoNotices.map((notice) => notice.dateText), [
        'Hoje · 08:12',
        'Ontem · 17:40',
        '2 dias atrás',
        '4 dias atrás',
      ]);
      expect(demoNotices.map((notice) => notice.summary), [
        'Matrícula do próximo período abre dia 15/09 pelo portal.',
        'Semana de Tecnologia com palestras e feira de projetos.',
        'Boleto de setembro disponível para emissão.',
        null,
      ]);
      expect(demoNotices.map((notice) => notice.body), [
        'As inscrições para o período 2026.2 abrem no portal a partir das 8h.',
        'Palestras, workshops e feira de projetos dos alunos no Bloco C.',
        'A fatura já pode ser emitida na área Financeiro do portal.',
        'Aulas remanejadas para o laboratório 5 durante esta semana.',
      ]);
    },
  );

  testWidgets('carteirinha normal mostra metadados e barras determinísticas', (
    tester,
  ) async {
    await pumpComponent(tester, const StudentIdCard(student: demoStudent));

    expect(find.text('INSTITUTO ÓRBITA'), findsOneWidget);
    expect(find.text('ATIVO'), findsOneWidget);
    expect(find.text('MD'), findsOneWidget);
    expect(find.text(demoStudent.name), findsOneWidget);
    expect(find.text('Engenharia de Software · 6º período'), findsOneWidget);
    expect(find.text('Matrícula'), findsOneWidget);
    expect(find.text(demoStudent.registration), findsOneWidget);
    expect(find.text('Validade'), findsOneWidget);
    expect(find.text(demoStudent.validUntil), findsOneWidget);

    final bars = find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.width == 2,
    );
    expect(bars, findsNWidgets(14));
    final heights = tester
        .widgetList<SizedBox>(bars)
        .map((bar) => bar.height)
        .toList();
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpComponent(tester, const StudentIdCard(student: demoStudent));
    expect(tester.widgetList<SizedBox>(bars).map((bar) => bar.height), heights);
  });

  testWidgets(
    'carteirinha compacta usa o mesmo estudante sem período ou metadados',
    (tester) async {
      await pumpComponent(
        tester,
        const StudentIdCard(student: demoStudent, compact: true),
      );

      expect(
        tester.widget<StudentIdCard>(find.byType(StudentIdCard)).student,
        same(demoStudent),
      );
      expect(find.text(demoStudent.name), findsOneWidget);
      expect(find.text(demoStudent.course), findsOneWidget);
      expect(find.textContaining(demoStudent.period), findsNothing);
      expect(find.text('Matrícula'), findsNothing);
      expect(find.text(demoStudent.registration), findsNothing);
      expect(find.text('Validade'), findsNothing);
      expect(find.text(demoStudent.validUntil), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 2,
        ),
        findsNothing,
      );
    },
  );

  for (final notice in demoNotices) {
    testWidgets('aviso completo ${notice.id} exibe corpo, categoria e data', (
      tester,
    ) async {
      await pumpComponent(tester, NoticeTile(notice: notice));

      expect(find.text(notice.title), findsOneWidget);
      expect(find.text(notice.category.label), findsOneWidget);
      expect(find.text(notice.body), findsOneWidget);
      expect(find.text(notice.dateText), findsOneWidget);
      if (notice.summary != null) {
        expect(find.text(notice.summary!), findsNothing);
      }
    });

    testWidgets(
      'aviso compacto ${notice.id} usa resumo ou corpo sem inventar conteúdo',
      (tester) async {
        await pumpComponent(tester, NoticeTile(notice: notice, compact: true));

        expect(find.text(notice.category.label), findsOneWidget);
        expect(find.text(notice.summary ?? notice.body), findsOneWidget);
        expect(find.text(notice.dateText), findsNothing);
        if (notice.summary != null) {
          expect(find.text(notice.body), findsNothing);
        }
      },
    );
  }

  for (final compact in [false, true]) {
    testWidgets(
      'widgets com compact=$compact acomodam textos longos em 360 px',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        const student = Student(
          name: 'Nome demonstrativo extenso para verificar a quebra de linha da carteirinha estudantil',
          shortName: 'Nome demonstrativo',
          initials: 'ND',
          course: 'Nome demonstrativo extenso de uma disciplina acadêmica para verificar a quebra de linha',
          period: '6º período',
          registration: '2023104567',
          validUntil: '12/2027',
          maskedCpf: '•••.•••.•••-45',
          email: 'demonstracao@example.com',
          maskedPhone: '(11) 9•••-4521',
        );
        const notice = Notice(
          id: 'long-text',
          title: 'Título demonstrativo extenso para verificar a quebra de linha do comunicado acadêmico',
          category: NoticeCategory.academic,
          summary: 'Resumo demonstrativo extenso que precisa quebrar em várias linhas sem perder o conteúdo.',
          body: 'Texto completo demonstrativo extenso que precisa quebrar em várias linhas sem perder o conteúdo.',
          dateText: 'Hoje · 08:12',
        );

        await pumpComponent(
          tester,
          Column(
            children: [
              StudentIdCard(student: student, compact: compact),
              NoticeTile(notice: notice, compact: compact),
            ],
          ),
        );

        expect(find.text(student.name), findsOneWidget);
        expect(
          find.text(compact ? notice.summary! : notice.body),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
