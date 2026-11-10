import {
  courses,
  faq,
  grades,
  gradesSummary,
  invoice,
  libraryCategories,
  loans,
  notices,
  paymentHistory,
  schedule,
  student,
} from '../data';
import {
  Book,
  Course,
  FaqEntry,
  Grade,
  Notice,
  PaymentHistoryEntry,
  StudentProfile,
  WeekSchedule,
} from '../types';
import { request } from './client';

/**
 * Um endpoint por tela, no formato que a tela consome. Evita que uma tela
 * precise orquestrar três chamadas e três estados de carregamento — e é o
 * recorte que um back-end for-frontend entregaria de qualquer forma.
 */

export interface HomePayload {
  student: StudentProfile;
  schedule: WeekSchedule;
  notices: Notice[];
}

export interface GradesPayload {
  grades: Grade[];
  summary: typeof gradesSummary;
}

export interface FinancialPayload {
  invoice: typeof invoice;
  history: PaymentHistoryEntry[];
}

export interface LibraryPayload {
  categories: string[];
  loans: Book[];
}

export const getHome = (): Promise<HomePayload> =>
  request(() => ({ student, schedule, notices }));

export const getSchedule = (): Promise<WeekSchedule> => request(() => schedule);

export const getGrades = (): Promise<GradesPayload> =>
  request(() => ({ grades, summary: gradesSummary }));

export const getCourses = (): Promise<Course[]> => request(() => courses);

export const getNotices = (): Promise<Notice[]> => request(() => notices);

export const getFinancial = (): Promise<FinancialPayload> =>
  request(() => ({ invoice, history: paymentHistory }));

export const getLibrary = (): Promise<LibraryPayload> =>
  request(() => ({ categories: libraryCategories, loans }));

export const getFaq = (): Promise<FaqEntry[]> => request(() => faq);

export const getProfile = (): Promise<StudentProfile> => request(() => student);
