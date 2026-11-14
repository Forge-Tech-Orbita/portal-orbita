---
paths: ["**"]
---

# Commits

## Convenção

Use Conventional Commits com resumo em português e verbo no **infinitivo**:

```text
<tipo>(<escopo opcional>): <resumo>
```

- Use `feat`, `fix`, `refactor`, `chore`, `docs`, `style` ou `test`.
- Omita os parênteses quando não houver escopo. Prefira escopo curto alinhado ao módulo ou finalidade: `auth`, `navigation`, `profile`, `tooling`, `agents`.
- Comece o resumo com `criar`, `adicionar`, `corrigir`, `atualizar`, `remover`, `ajustar`, `documentar` ou outro infinitivo adequado. Use minúscula inicial, sem ponto final; procure manter o assunto completo em até cerca de 72 caracteres sem truncar o sentido.
- Não confunda `feature` (prefixo de branch) com `feat` (tipo de commit).

Exemplos: `fix(grades): corrigir overflow do indicador de CRA` e `docs(agents): refinar regras de consulta dos agentes`.

## Aprovação obrigatória

1. Revise `git diff`, `git diff --cached` e os arquivos não rastreados; confira alterações preexistentes.
2. Execute as validações aplicáveis e descreva resultados reais. Não omita falha, aviso de build ou validação manual pendente.
3. Mostre resumo e mensagem proposta.
4. Pergunte exatamente: **“Aprova o commit?”** Não faça staging nem execute `git commit` antes da aprovação, salvo pedido específico de staging.
5. Após aprovação explícita, selecione somente caminhos da entrega; não use `git add .` ou `git add -A` indiscriminadamente. Não inclua planos locais ignorados.
6. Não reescreva o histórico para normalizar mensagens. Amend, rebase ou reescrita de commits de outras pessoas exigem autorização específica.
7. Aprovação de commit não autoriza `git push`, abertura de PR, merge, release ou deploy. Peça ou aguarde solicitação específica para cada operação.
