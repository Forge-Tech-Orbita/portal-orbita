import '../../../core/mock/academic_demo.dart';
import '../../../core/theme/orbita_theme.dart';
import 'schedule.dart';

const scheduleGroup = 'ESW-6N';
typedef DemoSchedule = ({
  String group,
  Map<ScheduleDay, List<ScheduledClass>> lessons,
});

DemoSchedule? scheduleFor(AcademicDemo? demo) => switch (demo) {
  AcademicDemo.informationSystems => (
    group: scheduleGroup,
    lessons: demoSchedule,
  ),
  AcademicDemo.administration => (
    group: 'ADM-4N',
    lessons: _administrationSchedule,
  ),
  null => null,
};

const _administrationSchedule = <ScheduleDay, List<ScheduledClass>>{
  ScheduleDay.monday: [
    ScheduledClass(
      time: '19:00',
      subject: peopleManagementSubject,
      room: peopleManagementRoom,
      professor: peopleManagementProfessor,
      color: OrbitaTheme.primary,
    ),
  ],
  ScheduleDay.tuesday: [
    ScheduledClass(
      time: '19:00',
      subject: managementAccountingSubject,
      room: managementAccountingRoom,
      professor: managementAccountingProfessor,
      color: OrbitaTheme.amber,
    ),
  ],
  ScheduleDay.wednesday: [],
  ScheduleDay.thursday: [
    ScheduledClass(
      time: '19:00',
      subject: marketingSubject,
      room: marketingRoom,
      professor: marketingProfessor,
      color: OrbitaTheme.terracotta,
    ),
  ],
  ScheduleDay.friday: [],
  ScheduleDay.saturday: [],
};

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
  color: OrbitaTheme.amber,
);
const _architecture = ScheduledClass(
  time: '19:00',
  subject: 'Arquitetura de Software',
  room: 'Sala 210 · Bloco A',
  professor: 'Prof. F. Ramalho',
  color: OrbitaTheme.primary,
);
const _requirements = ScheduledClass(
  time: '21:00',
  subject: 'Engenharia de Requisitos',
  room: 'Sala 212 · Bloco A',
  professor: 'Prof.ª C. Bezerra',
  color: OrbitaTheme.terracotta,
);
const _requirementsEarly = ScheduledClass(
  time: '19:00',
  subject: 'Engenharia de Requisitos',
  room: 'Sala 212 · Bloco A',
  professor: 'Prof.ª C. Bezerra',
  color: OrbitaTheme.terracotta,
);

const demoSchedule = <ScheduleDay, List<ScheduledClass>>{
  ScheduleDay.monday: [_artificialIntelligence, _databases],
  ScheduleDay.tuesday: [_architecture],
  ScheduleDay.wednesday: [_artificialIntelligence, _databases],
  ScheduleDay.thursday: [_architecture, _requirements],
  ScheduleDay.friday: [_requirementsEarly],
  ScheduleDay.saturday: [],
};
