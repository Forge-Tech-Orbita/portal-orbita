import 'dart:async';

import 'package:portal_orbita/core/constants/institution_catalog.dart';
import 'package:portal_orbita/core/models/student_profile.dart';
import 'package:portal_orbita/features/auth/data/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final events = StreamController<AuthAccount?>.broadcast();
  AuthAccount? account;
  StudentProfile profile = const StudentProfile(
    uid: 'student-a',
    name: 'Aluno Demonstração',
    registration: '202600001',
    institutionId: 'inst-demo',
    courseId: 'si',
    semester: '2026-2',
    period: 4,
  );
  Future<StudentProfile>? pendingProfile;
  Future<Set<String>>? pendingCourses;
  final inactiveCourseIds = <String>{};
  bool failCourses = false;
  Completer<void>? pendingSignIn;
  bool failProfile = false;
  bool failSignOut = false;
  bool failSaveContact = false;
  int saveContactCalls = 0;
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Stream<AuthAccount?> get authChanges async* {
    yield account;
    yield* events.stream;
  }

  @override
  Future<void> signIn(
    String institutionId,
    String registration,
    String password,
  ) async {
    signInCalls++;
    if (pendingSignIn != null) await pendingSignIn!.future;
    if (registration != profile.registration ||
        institutionId != profile.institutionId ||
        password.isEmpty) {
      throw StateError('Credenciais inválidas');
    }
    account = (
      uid: profile.uid,
      email: technicalEmail(institutionId, registration),
    );
    events.add(account);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (failSignOut) throw StateError('Offline');
    account = null;
    events.add(null);
  }

  @override
  Future<StudentProfile> loadProfile(AuthAccount account) async {
    if (failProfile) throw const FormatException('Perfil inválido');
    return pendingProfile ?? Future.value(profile);
  }

  @override
  Future<Set<String>> loadActiveCourseIds(String institutionId) async {
    if (failCourses) throw StateError('Catálogo indisponível');
    return pendingCourses ??
        Future.value(
          institutions[institutionId]!.courses.keys
              .where((id) => !inactiveCourseIds.contains(id))
              .toSet(),
        );
  }

  @override
  Future<void> chooseCourse(String uid, String courseId) async {
    if (uid != profile.uid ||
        profile.courseId != null ||
        inactiveCourseIds.contains(courseId) ||
        !institutions[profile.institutionId]!.courses.containsKey(courseId)) {
      throw StateError('Curso inválido ou já escolhido');
    }
    profile = StudentProfile(
      uid: profile.uid,
      name: profile.name,
      registration: profile.registration,
      institutionId: profile.institutionId,
      courseId: courseId,
      semester: profile.semester,
      period: profile.period,
    );
  }

  @override
  Future<void> saveContact(
    String uid, {
    required String phone,
    required String personalEmail,
    required String postalCode,
    required String address,
  }) async {
    saveContactCalls++;
    if (failSaveContact || uid != profile.uid) throw StateError('Offline');
    profile = profile.withContact(
      phone: phone,
      personalEmail: personalEmail,
      postalCode: postalCode,
      address: address,
    );
  }

  Future<void> dispose() => events.close();
}
