import '../../../core/theme/orbita_theme.dart';
import 'schedule.dart';

const _artificialIntelligence = ScheduledClass(
  time: '19:00',
  subject: 'Inteligência Artificial',
  room: 'Sala 304 · Bloco C',
  professor: 'Prof. R. Nakamura',
  color: OrbitaTheme.primary,
);
const _databases = ScheduledClass(
  time: '21:00',
  subject: 'Banco de Dados II',
  room: 'Lab 05 · Bloco B',
  professor: 'Prof.ª L. Andrade',
  color: OrbitaTheme.terracotta,
);
const _architecture = ScheduledClass(
  time: '19:00',
  subject: 'Arquitetura de Software',
  room: 'Sala 210 · Bloco A',
  professor: 'Prof. F. Ramalho',
  color: OrbitaTheme.green,
);
const _numericalCalculus = ScheduledClass(
  time: '21:00',
  subject: 'Cálculo Numérico',
  room: 'Sala 108 · Bloco A',
  professor: 'Prof. E. Villas',
  color: OrbitaTheme.amber,
);
const _requirements = ScheduledClass(
  time: '19:00',
  subject: 'Engenharia de Requisitos',
  room: 'Sala 212 · Bloco A',
  professor: 'Prof.ª C. Bezerra',
  color: OrbitaTheme.alert,
);

const demoSchedule = <ScheduleDay, List<ScheduledClass>>{
  ScheduleDay.monday: [_artificialIntelligence, _databases],
  ScheduleDay.tuesday: [_architecture],
  ScheduleDay.wednesday: [_artificialIntelligence, _numericalCalculus],
  ScheduleDay.thursday: [_requirements, _databases],
  ScheduleDay.friday: [_architecture],
  ScheduleDay.saturday: [],
};
