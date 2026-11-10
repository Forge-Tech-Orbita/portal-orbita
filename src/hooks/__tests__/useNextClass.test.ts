import { dayKeyForDate, schedule } from '../../data';
import { WeekSchedule } from '../../types';
import { resolveNextClass } from '../useNextClass';

// 21/09/2026 é uma segunda-feira; os demais dias derivam dela.
const SEGUNDA = 21;
const at = (dayOfMonth: number, hours: number, minutes: number) =>
  new Date(2026, 8, dayOfMonth, hours, minutes);

describe('dayKeyForDate', () => {
  it('mapeia cada dia letivo para sua chave', () => {
    expect(dayKeyForDate(at(SEGUNDA, 12, 0))).toBe('SEG');
    expect(dayKeyForDate(at(SEGUNDA + 1, 12, 0))).toBe('TER');
    expect(dayKeyForDate(at(SEGUNDA + 4, 12, 0))).toBe('SEX');
    expect(dayKeyForDate(at(SEGUNDA + 5, 12, 0))).toBe('SÁB');
  });

  // Regressão: o mapa antigo devolvia 'SÁB' no domingo, e a tela de Horário
  // abria num sábado vazio.
  it('devolve null no domingo, em vez de um sábado disfarçado', () => {
    expect(dayKeyForDate(at(SEGUNDA - 1, 12, 0))).toBeNull();
  });
});

describe('resolveNextClass', () => {
  it('conta os minutos até a próxima aula de hoje', () => {
    const next = resolveNextClass(schedule, at(SEGUNDA, 18, 13));
    expect(next?.startsIn).toBe('em 47 min');
    expect(next?.session.subject).toBe('Inteligência Artificial');
    expect(next?.session.time).toBe('19:00');
  });

  it('usa horas quando falta mais de uma', () => {
    expect(resolveNextClass(schedule, at(SEGUNDA, 18, 0))?.startsIn).toBe('em 1h');
    expect(resolveNextClass(schedule, at(SEGUNDA, 19, 30))?.startsIn).toBe('em 1h30');
    expect(resolveNextClass(schedule, at(SEGUNDA, 0, 30))?.startsIn).toBe('em 18h30');
  });

  it('pula para o próximo dia quando as aulas de hoje já começaram', () => {
    const next = resolveNextClass(schedule, at(SEGUNDA, 21, 30));
    expect(next?.startsIn).toBe('amanhã');
    expect(next?.session.subject).toBe('Arquitetura de Software');
  });

  it('atravessa o fim de semana, pulando sábado vazio e domingo', () => {
    // Sexta à noite: sábado não tem aula e domingo não existe na grade.
    expect(resolveNextClass(schedule, at(SEGUNDA + 4, 20, 0))?.startsIn).toBe('em 3 dias');
    expect(resolveNextClass(schedule, at(SEGUNDA + 5, 10, 0))?.startsIn).toBe('em 2 dias');
  });

  it('parte do domingo direto para segunda', () => {
    const next = resolveNextClass(schedule, at(SEGUNDA - 1, 10, 0));
    expect(next?.startsIn).toBe('amanhã');
    expect(next?.session.subject).toBe('Inteligência Artificial');
  });

  it('escolhe a aula mais cedo do dia, não a primeira da lista', () => {
    const desordenada: WeekSchedule = {
      ...schedule,
      SEG: [
        { time: '21:00', subject: 'Tarde', room: 'B', professor: 'P', accent: 'violet' },
        { time: '19:00', subject: 'Cedo', room: 'A', professor: 'P', accent: 'cyan' },
      ],
    };
    expect(resolveNextClass(desordenada, at(SEGUNDA, 8, 0))?.session.subject).toBe('Cedo');
  });

  it('devolve null quando não há nada na semana inteira', () => {
    const vazia: WeekSchedule = { SEG: [], TER: [], QUA: [], QUI: [], SEX: [], SÁB: [] };
    expect(resolveNextClass(vazia, at(SEGUNDA, 12, 0))).toBeNull();
  });
});
