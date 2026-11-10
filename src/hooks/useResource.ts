import { useCallback, useEffect, useRef, useState } from 'react';

export interface Resource<T> {
  /** `null` enquanto a primeira carga não terminou, ou se ela falhou. */
  data: T | null;
  /** Primeira carga, ou recarga após erro — a tela ainda não tem o que mostrar. */
  loading: boolean;
  /** Recarga com dados já na tela (puxar-para-atualizar). */
  refreshing: boolean;
  error: Error | null;
  /** `silent` mantém o conteúdo visível durante a recarga. */
  reload: (options?: { silent?: boolean }) => void;
}

/**
 * Estado de uma busca no servidor: carregando, erro, dado e recarga.
 *
 * `load` precisa ser estável entre renders — na prática, uma função exportada
 * de `src/services/`. Uma função recriada a cada render refaz a busca a cada
 * render, então passe a referência do serviço, não uma seta inline.
 */
export function useResource<T>(load: () => Promise<T>): Resource<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const active = useRef(true);

  /**
   * Dispara a busca e grava o resultado. Deliberadamente não é `async`: todo
   * `setState` fica dentro dos callbacks da promessa, nunca no corpo síncrono
   * — é o que separa "efeito que assina uma fonte externa" de "efeito que
   * dispara render em cascata".
   */
  const fetchInto = useCallback(
    () =>
      load()
        .then((result) => {
          if (!active.current) return;
          setData(result);
          setError(null);
        })
        .catch((cause: unknown) => {
          if (!active.current) return;
          setError(cause instanceof Error ? cause : new Error(String(cause)));
        })
        .finally(() => {
          if (!active.current) return;
          setLoading(false);
          setRefreshing(false);
        }),
    [load],
  );

  useEffect(() => {
    active.current = true;
    // `loading` já nasce `true`, então a carga inicial não precisa anunciar
    // nada antes de sair — nenhum estado muda no corpo deste efeito.
    fetchInto();
    // Evita gravar estado depois que a tela saiu: a resposta ainda chega, mas
    // não tem mais ninguém para recebê-la.
    return () => {
      active.current = false;
    };
  }, [fetchInto]);

  const reload = useCallback(
    (options?: { silent?: boolean }) => {
      if (options?.silent) {
        setRefreshing(true);
      } else {
        setLoading(true);
        setError(null);
      }
      fetchInto();
    },
    [fetchInto],
  );

  return { data, loading, refreshing, error, reload };
}
