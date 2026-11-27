import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/app.dart';
import 'package:portal_orbita/core/constants/institution_catalog.dart';
import 'package:portal_orbita/core/models/student_profile.dart';
import 'package:portal_orbita/core/theme/orbita_colors.dart';
import 'package:portal_orbita/features/navigation/presentation/main_navigation_screen.dart';
import 'package:portal_orbita/features/profile/presentation/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';
import 'fake_grades_repository.dart';
import 'helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // Abre o app com uma sessão já ativa, como após reabrir o aplicativo.
  Future<void> startApp(WidgetTester tester, String uid) async {
    final auth = FakeAuthRepository();
    addTearDown(auth.dispose);
    auth.profile = StudentProfile(
      uid: uid,
      name: auth.profile.name,
      registration: auth.profile.registration,
      institutionId: auth.profile.institutionId,
      courseId: auth.profile.courseId,
      semester: auth.profile.semester,
      period: auth.profile.period,
    );
    auth.account = (
      uid: uid,
      email: technicalEmail(
        auth.profile.institutionId,
        auth.profile.registration,
      ),
    );
    await tester.pumpWidget(
      MainApp(
        key: UniqueKey(),
        authRepository: auth,
        gradesRepository: FakeGradesRepository(),
        preferences: prefs,
      ),
    );
    await tester.pumpAndSettle();
  }

  Brightness mainBrightness(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(MainNavigationScreen))).brightness;

  testWidgets('tema escolhido volta ao reabrir o app e não vaza entre alunos', (
    tester,
  ) async {
    // 1. Aluno A troca o tema no Perfil.
    await startApp(tester, 'student-a');
    expect(mainBrightness(tester), Brightness.light);
    await openFromMore(tester, 'Meu perfil');
    await tapVisible(tester, find.widgetWithText(ListTile, 'Forge Tech'));
    expect(
      Theme.of(tester.element(find.byType(ProfileScreen)))
          .scaffoldBackgroundColor,
      OrbitaColors.forgeTech.background,
    );

    // 2. Reabrir o app com o aluno A restaura o tema.
    await startApp(tester, 'student-a');
    expect(mainBrightness(tester), Brightness.dark);

    // 3. O aluno B começa no vintage.
    await startApp(tester, 'student-b');
    expect(mainBrightness(tester), Brightness.light);

    // 4. Voltando ao aluno A, o tema continua.
    await startApp(tester, 'student-a');
    expect(mainBrightness(tester), Brightness.dark);
  });
}
