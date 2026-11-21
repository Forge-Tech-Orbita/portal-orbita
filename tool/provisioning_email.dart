import 'dart:io';

import 'package:portal_orbita/core/constants/institution_catalog.dart';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    stderr.writeln(
      'Uso: dart run tool/provisioning_email.dart <instituicaoId> <matricula>',
    );
    exitCode = 64;
    return;
  }
  try {
    stdout.writeln(technicalEmail(arguments[0], arguments[1]));
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  }
}
