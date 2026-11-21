const institutions = {
  'inst-demo': (
    name: 'Sapiens — Demonstração',
    courses: {'si': 'Sistemas de Informação', 'adm': 'Administração'},
  ),
  'inst-horizonte': (
    name: 'Instituto Horizonte — Demonstração',
    courses: {'si': 'Sistemas de Informação'},
  ),
};

String technicalEmail(String institutionId, String registration) {
  if (!institutions.containsKey(institutionId) ||
      !RegExp(r'^[0-9]{1,20}$').hasMatch(registration)) {
    throw const FormatException('Instituição ou matrícula inválida.');
  }
  return '$institutionId.$registration@auth.orbita.example';
}
