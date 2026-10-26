/**
 * Espera artificial para que os estados de carregamento sejam exercitados
 * durante o desenvolvimento, em vez de aparecerem por um frame e sumirem.
 */
const SIMULATED_LATENCY_MS = 350;

/** Erro de transporte. Mantém a mensagem que a tela vai mostrar ao usuário. */
export class RequestError extends Error {
  constructor(message = 'Não foi possível falar com o portal.') {
    super(message);
    this.name = 'RequestError';
  }
}

/**
 * Fronteira única entre o app e o servidor. Hoje devolve os dados mockados de
 * `src/data/` depois de uma espera; quando existir API de verdade, é esta
 * função que vira `fetch` — as telas e os hooks não mudam.
 */
export function request<T>(load: () => T): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    setTimeout(() => {
      try {
        resolve(load());
      } catch (cause) {
        reject(new RequestError(cause instanceof Error ? cause.message : undefined));
      }
    }, SIMULATED_LATENCY_MS);
  });
}
