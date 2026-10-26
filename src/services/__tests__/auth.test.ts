import { signIn, validateCredentials } from '../auth';

const valid = { registration: '2023104567', password: 'senha-forte' };

describe('validateCredentials', () => {
  it('aceita credenciais bem formadas', () => {
    expect(validateCredentials(valid)).toBeNull();
  });

  it('cobra a matrícula antes da senha', () => {
    expect(validateCredentials({ registration: '  ', password: '' })).toBe('Informe sua matrícula.');
  });

  it('recusa matrícula com letras ou curta demais', () => {
    expect(validateCredentials({ ...valid, registration: '2023abc' })).toMatch(/só números/);
    expect(validateCredentials({ ...valid, registration: '123' })).toMatch(/6 dígitos/);
  });

  it('cobra senha vazia e senha curta com mensagens diferentes', () => {
    expect(validateCredentials({ ...valid, password: '' })).toBe('Informe sua senha de acesso.');
    expect(validateCredentials({ ...valid, password: '123' })).toMatch(/ao menos 6 caracteres/);
  });

  it('ignora espaços em volta da matrícula', () => {
    expect(validateCredentials({ ...valid, registration: '  2023104567  ' })).toBeNull();
  });
});

describe('signIn', () => {
  it('devolve o estudante da sessão quando as credenciais servem', async () => {
    await expect(signIn(valid)).resolves.toHaveProperty('registration');
  });

  // O servidor revalida: a tela não é a única barreira.
  it('rejeita credenciais inválidas com a mensagem da regra', async () => {
    await expect(signIn({ ...valid, password: '123' })).rejects.toThrow(/ao menos 6 caracteres/);
  });
});
