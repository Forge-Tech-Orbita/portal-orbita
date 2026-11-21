import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/models/student_profile.dart';
import '../../../core/constants/institution_catalog.dart';
import 'auth_repository.dart';

class AcademicSession extends ChangeNotifier {
  AcademicSession(this.repository) {
    _subscription = repository.authChanges.listen(
      _onAccount,
      onError: (Object _) => _fail('Não foi possível verificar a sessão.'),
    );
  }

  final AuthRepository repository;
  late final StreamSubscription<AuthAccount?> _subscription;
  AuthAccount? _account;
  StudentProfile? profile;
  Set<String> activeCourseIds = {};
  bool loading = true;
  String? error;
  int navigationEpoch = 0;
  int _generation = 0;
  bool _disposed = false;
  bool _acceptAccounts = true;
  String? _expectedEmail;
  bool get hasAccount => _account != null;

  void _fail(String message) {
    if (_disposed) return;
    _generation++;
    profile = null;
    activeCourseIds = {};
    loading = false;
    error = message;
    navigationEpoch++;
    notifyListeners();
  }

  Future<void> _onAccount(AuthAccount? account) async {
    if (_disposed) return;
    if (account != null &&
        (!_acceptAccounts ||
            (_expectedEmail != null && account.email != _expectedEmail))) {
      await signOut();
      return;
    }
    final generation = ++_generation;
    _account = account;
    profile = null;
    activeCourseIds = {};
    error = null;
    loading = account != null;
    navigationEpoch++;
    notifyListeners();
    if (account == null) return;
    try {
      final loaded = await repository.loadProfile(account);
      if (_disposed || generation != _generation) return;
      if (loaded.uid != account.uid) {
        throw const FormatException('UID inválido.');
      }
      final courses = loaded.courseId == null
          ? await repository.loadActiveCourseIds(loaded.institutionId)
          : <String>{};
      if (_disposed || generation != _generation) return;
      profile = loaded;
      activeCourseIds = courses;
      loading = false;
      navigationEpoch++;
      notifyListeners();
    } catch (_) {
      if (!_disposed && generation == _generation) {
        _fail(
          'Não foi possível carregar o perfil. Confira o provisionamento e tente novamente.',
        );
      }
    }
  }

  Future<void> signIn(
    String institution,
    String registration,
    String password,
  ) async {
    if (loading) return;
    _acceptAccounts = true;
    final generation = _generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      _expectedEmail = technicalEmail(institution, registration);
      await repository.signIn(institution, registration, password);
    } catch (_) {
      if (!_disposed && generation == _generation) {
        loading = false;
        error = 'Não foi possível entrar. Confira os dados ou a conexão.';
        notifyListeners();
      }
    }
  }

  Future<void> chooseCourse(String courseId) async {
    final account = _account;
    final current = profile;
    if (loading ||
        account == null ||
        current == null ||
        current.courseId != null ||
        !activeCourseIds.contains(courseId)) {
      return;
    }
    final generation = _generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await repository.chooseCourse(account.uid, courseId);
      if (!_disposed && generation == _generation) await _onAccount(account);
    } catch (_) {
      if (!_disposed && generation == _generation) {
        loading = false;
        error = 'Não foi possível vincular o curso. Tente novamente.';
        notifyListeners();
      }
    }
  }

  Future<void> signOut() async {
    if (_disposed) return;
    _generation++;
    _acceptAccounts = false;
    profile = null;
    activeCourseIds = {};
    _account = null;
    loading = true;
    error = null;
    navigationEpoch++;
    notifyListeners();
    try {
      await repository.signOut();
      if (!_disposed) {
        loading = false;
        notifyListeners();
      }
    } catch (_) {
      _fail('Não foi possível encerrar a sessão. Tente sair novamente.');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

class AcademicSessionScope extends InheritedNotifier<AcademicSession> {
  const AcademicSessionScope({
    super.key,
    required AcademicSession session,
    required super.child,
  }) : super(notifier: session);

  static AcademicSession? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AcademicSessionScope>()
      ?.notifier;
}
