import { AccentToken } from '../theme';

export type DayKey = 'SEG' | 'TER' | 'QUA' | 'QUI' | 'SEX' | 'SÁB';

export interface ClassSession {
  time: string;
  subject: string;
  room: string;
  professor: string;
  /** Token de destaque — a cor concreta vem da paleta ativa. */
  accent: AccentToken;
}

export type WeekSchedule = Record<DayKey, ClassSession[]>;

export type GradeStatus = 'cursando' | 'concluidas';

export interface Grade {
  subject: string;
  code: string;
  av1: number;
  av2: number | null;
  frequency: number;
  status: GradeStatus;
}

export interface Course {
  subject: string;
  professor: string;
  credits: number;
  progress: number;
  room: string;
}

export type NoticeCategory = 'acad' | 'event' | 'fin';

export interface Notice {
  id: string;
  title: string;
  text: string;
  category: NoticeCategory;
  date: string;
}

export type DueStatus = 'ok' | 'warn';

export interface Book {
  id: string;
  title: string;
  author: string;
  dueLabel: string;
  dueStatus: DueStatus;
}

export interface PaymentHistoryEntry {
  month: string;
  amount: string;
}

export interface FaqEntry {
  question: string;
  answer: string;
}

export interface StudentProfile {
  fullName: string;
  displayName: string;
  initials: string;
  course: string;
  period: string;
  registration: string;
  validUntil: string;
  cra: number;
  attendance: number;
  credits: number;
  cpfMasked: string;
  institutionalEmail: string;
  phoneMasked: string;
}
