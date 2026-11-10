import { student } from '../data';
import { StudentProfile } from '../types';
import { request } from './client';

const MIN_PASSWORD_LENGTH = 6;
const REGISTRATION_PATTERN = /^\d{6,}$/;

export interface Credentials {
  registration: string;
  password: string;
}

/**
 * Regras de entrada do login. Devolve a mensagem do primeiro problema, ou
 * `null` quando as credenciais podem seguir para o servidor.
 *
 * Fica separada de `signIn` para a tela poder avisar na hora, sem esperar a
 * ida ao servidor só para ouvir que o campo está vazio.
 */
export function validateCredentials({ registration, password }: Credentials): string | null {
  const trimmed = registration.trim();

  if (!trimmed) return 'Informe sua matrícula.';
  if (!REGISTRATION_PATTERN.test(trimmed)) return 'A matrícula deve ter ao menos 6 dígitos, só números.';
  if (!password) return 'Informe sua senha de acesso.';
  if (password.length < MIN_PASSWORD_LENGTH) {
    return `A senha precisa de ao menos ${MIN_PASSWORD_LENGTH} caracteres.`;
  }

  return null;
}

/**
 * Autenticação simulada: valida de novo no "servidor" e devolve o estudante
 * da sessão. Qualquer credencial bem formada é aceita enquanto não houver
 * back-end — o que muda aqui, e só aqui, quando houver.
 */
export function signIn(credentials: Credentials): Promise<StudentProfile> {
  return request(() => {
    const problem = validateCredentials(credentials);
    if (problem) throw new Error(problem);
    return student;
  });
}
