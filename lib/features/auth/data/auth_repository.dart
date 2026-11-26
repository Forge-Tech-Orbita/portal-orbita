import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/models/student_profile.dart';
import '../../../core/constants/institution_catalog.dart';

typedef AuthAccount = ({String uid, String email});

abstract class AuthRepository {
  Stream<AuthAccount?> get authChanges;
  Future<void> signIn(
    String institutionId,
    String registration,
    String password,
  );
  Future<void> signOut();
  Future<StudentProfile> loadProfile(AuthAccount account);
  Future<Set<String>> loadActiveCourseIds(String institutionId);
  Future<void> chooseCourse(String uid, String courseId);
  Future<void> saveContact(
    String uid, {
    required String phone,
    required String personalEmail,
    required String postalCode,
    required String address,
  });
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _store => FirebaseFirestore.instance;

  @override
  Stream<AuthAccount?> get authChanges async* {
    if (Firebase.apps.isEmpty) {
      yield null;
      return;
    }
    yield* _auth.authStateChanges().map(
      (user) => user == null ? null : (uid: user.uid, email: user.email ?? ''),
    );
  }

  @override
  Future<void> signIn(
    String institutionId,
    String registration,
    String password,
  ) => _auth.signInWithEmailAndPassword(
    email: technicalEmail(institutionId, registration),
    password: password,
  );

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<StudentProfile> loadProfile(AuthAccount account) async {
    final snapshot = await _store
        .doc('students/${account.uid}')
        .get(const GetOptions(source: Source.server));
    final data = snapshot.data();
    if (data == null) throw const FormatException('Perfil não provisionado.');
    final profile = StudentProfile.fromMap(account.uid, data);
    if (technicalEmail(profile.institutionId, profile.registration) !=
        account.email) {
      throw const FormatException('Perfil incompatível com a conta.');
    }
    return profile;
  }

  @override
  Future<Set<String>> loadActiveCourseIds(String institutionId) async {
    final snapshot = await _store
        .collection('institutions/$institutionId/courses')
        .where('ativo', isEqualTo: true)
        .get(const GetOptions(source: Source.server));
    final allowed = institutions[institutionId]!.courses;
    return snapshot.docs
        .map((document) => document.id)
        .where(allowed.containsKey)
        .toSet();
  }

  @override
  Future<void> chooseCourse(
    String uid,
    String courseId,
  ) => _store.runTransaction((transaction) async {
    final reference = _store.doc('students/$uid');
    final snapshot = await transaction.get(reference);
    final data = snapshot.data();
    if (data == null) throw const FormatException('Perfil não provisionado.');
    final profile = StudentProfile.fromMap(uid, data);
    if (profile.courseId != null ||
        !institutions[profile.institutionId]!.courses.containsKey(courseId)) {
      throw StateError('Curso já definido ou inválido.');
    }
    transaction.update(reference, {'cursoId': courseId});
  });

  @override
  Future<void> saveContact(
    String uid, {
    required String phone,
    required String personalEmail,
    required String postalCode,
    required String address,
  }) => _store.doc('students/$uid').update({
    'telefone': phone,
    'emailPessoal': personalEmail,
    'cep': postalCode,
    'endereco': address,
  });
}
