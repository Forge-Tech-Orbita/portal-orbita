import { useMemo } from 'react';
import { dayKeyForDate } from '../data';
import { ClassSession, WeekSchedule } from '../types';

const MINUTES_PER_DAY = 24 * 60;

export interface NextClass {
  session: ClassSession;
  /** Rótulo relativo já formatado: "em 47 min", "em 2h15", "amanhã", "em 3 dias". */
  startsIn: string;
}

/** Converte 'HH:MM' em minutos desde a meia-noite. */
function minutesOfDay(time: string): number {
  const [hours, minutes] = time.split(':').map(Number);
  return hours * 60 + minutes;
}

function formatLeadTime(daysAhead: number, deltaMinutes: number): string {
  if (daysAhead === 1) return 'amanhã';
  if (daysAhead > 1) return `em ${daysAhead} dias`;
  if (deltaMinutes < 60) return `em ${deltaMinutes} min`;

  const hours = Math.floor(deltaMinutes / 60);
  const minutes = deltaMinutes % 60;
  return minutes === 0 ? `em ${hours}h` : `em ${hours}h${String(minutes).padStart(2, '0')}`;
}

/**
 * Primeira aula que ainda não começou, varrendo de hoje até uma semana à
 * frente e pulando os dias sem grade (domingo, e sábado quando vazio).
 *
 * Devolve `null` quando não há nada pela frente, para o card sumir em vez de
 * exibir um horário inventado.
 *
 * A distância é contada em dias de calendário vezes 1440 minutos: em país sem
 * horário de verão isso é exato, e serve de sobra para um rótulo arredondado.
 */
export function resolveNextClass(week: WeekSchedule, now: Date): NextClass | null {
  const nowMinutes = now.getHours() * 60 + now.getMinutes();

  for (let daysAhead = 0; daysAhead < 7; daysAhead += 1) {
    const date = new Date(now);
    date.setDate(date.getDate() + daysAhead);

    const dayKey = dayKeyForDate(date);
    if (!dayKey) continue;

    // Hoje só valem as aulas ainda por vir; nos dias seguintes, a primeira.
    const session = [...week[dayKey]]
      .sort((a, b) => minutesOfDay(a.time) - minutesOfDay(b.time))
      .find((candidate) => daysAhead > 0 || minutesOfDay(candidate.time) > nowMinutes);

    if (session) {
      const deltaMinutes = daysAhead * MINUTES_PER_DAY + minutesOfDay(session.time) - nowMinutes;
      return { session, startsIn: formatLeadTime(daysAhead, deltaMinutes) };
    }
  }

  return null;
}

/**
 * Versão reativa: recalcula a cada tique do relógio da Home. Aceita `null`
 * enquanto a grade ainda está vindo do servidor.
 */
export function useNextClass(week: WeekSchedule | null, now: Date): NextClass | null {
  return useMemo(() => (week ? resolveNextClass(week, now) : null), [week, now]);
}
