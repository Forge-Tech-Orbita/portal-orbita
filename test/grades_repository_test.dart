import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/core/models/student_profile.dart';
import 'package:portal_orbita/features/grades/data/grade.dart';
import 'package:portal_orbita/features/grades/data/grades_repository.dart';

Map<String, dynamic> gradeData({String code = 'ESW-304'}) => {
  'semestreLetivo': '2026-2',
  'cursoId': 'si',
  'subject': 'Arquitetura de Software',
  'code': code,
  'firstStage': <String, Object?>{'exam': 6, 'ted': 2.6},
  'secondStage': <String, Object?>{
    'exam': 5.5,
    'ted': 2.5,
    'integratedAssessment': 1,
  },
  'frequency': 94,
  'status': 'inProgress',
};

Grade parse(Map<String, dynamic> data, {String id = '2026-2_si_ESW-304'}) =>
    Grade.fromMap(id, data, semester: '2026-2', courseId: 'si');

void main() {
  test('parser preserva modelos, totais, média e situação informada', () {
    final grade = parse(gradeData());
    expect(grade.firstStage.total, 8.6);
    expect(grade.secondStage.total, 9);
    expect(grade.average, 8.8);
    expect(grade.frequency, 94);
    expect(grade.status, GradeStatus.inProgress);
    for (final status in GradeStatus.values) {
      expect(parse(gradeData()..['status'] = status.name).status, status);
    }
  });

  test('parser aceita zero, limites e null explícito sem inventar notas', () {
    final data = gradeData();
    data['firstStage'] = {'exam': 7, 'ted': 3};
    data['secondStage'] = {'exam': 6, 'ted': 3, 'integratedAssessment': 1};
    expect(parse(data).average, 10);
    data['secondStage'] = {'exam': 0, 'ted': 0, 'integratedAssessment': 0};
    expect(parse(data).average, 5);
    data['secondStage'] = {'exam': null, 'ted': 0, 'integratedAssessment': 0};
    expect(parse(data).secondStage.total, isNull);
    expect(parse(data).average, isNull);
    data['firstStage'] = {'exam': null, 'ted': null};
    data['secondStage'] = {
      'exam': null,
      'ted': null,
      'integratedAssessment': null,
    };
    expect(parse(data).firstStage.total, isNull);
    for (final frequency in [0, 100]) {
      expect(parse(data..['frequency'] = frequency).frequency, frequency);
    }
  });

  for (final field in gradeData().keys) {
    test('parser rejeita campo obrigatório ausente: $field', () {
      expect(() => parse(gradeData()..remove(field)), throwsFormatException);
    });
  }
  for (final (field, values) in <(String, List<Object?>)>[
    ('semestreLetivo', ['2026-3', '2025-2', null, 2026]),
    ('cursoId', ['adm', '', null, 1]),
    ('subject', ['', '   ', 'x' * 121, null, 1]),
    ('code', ['', 'esw-304', 'ESW/304', 'X' * 31, null, 1]),
    ('frequency', [-1, 101, 94.5, '94', null]),
    ('status', ['unknown', 'Aprovado', 1, null]),
    ('firstStage', [null, [], '6']),
    ('secondStage', [null, [], 5]),
  ]) {
    test('parser rejeita campo inválido: $field', () {
      for (final value in values) {
        expect(
          () => parse(gradeData()..[field] = value),
          throwsFormatException,
          reason: '$field: $value',
        );
      }
    });
  }
  test('parser rejeita ID divergente, campos extras e mapas incompletos', () {
    expect(() => parse(gradeData(), id: 'outro'), throwsFormatException);
    expect(() => parse(gradeData()..['average'] = 10), throwsFormatException);
    for (final stage in ['firstStage', 'secondStage']) {
      for (final key in (gradeData()[stage] as Map).keys) {
        final data = gradeData();
        (data[stage] as Map).remove(key);
        expect(() => parse(data), throwsFormatException);
      }
      final data = gradeData();
      (data[stage] as Map)['extra'] = 0;
      expect(() => parse(data), throwsFormatException);
    }
  });
  for (final (stage, field, maximum) in [
    ('firstStage', 'exam', 7),
    ('firstStage', 'ted', 3),
    ('secondStage', 'exam', 6),
    ('secondStage', 'ted', 3),
    ('secondStage', 'integratedAssessment', 1),
  ]) {
    test('parser valida intervalo e finitude de $stage.$field em runtime', () {
      for (final value in [
        -1,
        maximum + 0.01,
        double.nan,
        double.infinity,
        double.negativeInfinity,
        '1',
        true,
      ]) {
        final data = gradeData();
        (data[stage] as Map)[field] = value;
        expect(() => parse(data), throwsFormatException);
      }
    });
  }

  test('repositório não consulta perfil sem curso', () async {
    const profile = StudentProfile(
      uid: 'student-a',
      name: 'Aluno',
      registration: '202600001',
      institutionId: 'inst-demo',
      courseId: null,
      semester: '2026-2',
      period: 4,
    );
    await expectLater(
      FirebaseGradesRepository().loadGrades(profile),
      throwsStateError,
    );
  });
}
