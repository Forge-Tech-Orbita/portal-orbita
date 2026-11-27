import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_orbita/firebase_options.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('usa as opções do app iOS do projeto existente', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final options = DefaultFirebaseOptions.currentPlatform;

    expect(options.projectId, 'portal-orbita');
    expect(options.iosBundleId, 'com.forgetech.plataformaorbita');
    expect(options.appId, contains(':ios:'));
  });

  test('mantém o app Android com o mesmo projeto', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final options = DefaultFirebaseOptions.currentPlatform;

    expect(options.projectId, 'portal-orbita');
    expect(options.appId, contains(':android:'));
  });
}
