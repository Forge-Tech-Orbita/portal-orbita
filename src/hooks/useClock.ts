import { useEffect, useState } from 'react';

function greetingFor(date: Date) {
  const hour = date.getHours();
  if (hour < 12) return 'Bom dia';
  if (hour < 18) return 'Boa tarde';
  return 'Boa noite';
}

/**
 * Relógio da Home, renovado a cada 30s. Devolve a saudação já formatada e o
 * `now` cru, para quem precisa derivar algo dele (a contagem da próxima aula)
 * sem abrir um segundo timer.
 */
export function useClock() {
  const [now, setNow] = useState(() => new Date());

  useEffect(() => {
    const id = setInterval(() => setNow(new Date()), 30000);
    return () => clearInterval(id);
  }, []);

  return { now, greeting: greetingFor(now) };
}
