---
paths: ["**"]
---

# Commits

## Convenção e evidências

Use Conventional Commits com resumo em português e verbo no **infinitivo**, conforme decisão explícita da equipe nesta auditoria:

```text
<tipo>(<escopo opcional>): <resumo>
```

- Use `feat`, `fix`, `refactor`, `chore`, `docs`, `style` ou `test`. `test` já aparece no histórico e é pertinente à suíte existente.
- Omita os parênteses quando não houver escopo. Prefira escopo curto alinhado ao módulo ou finalidade: `auth`, `navigation`, `profile`, `tooling`, `agents`.
- Comece o resumo com `criar`, `adicionar`, `corrigir`, `atualizar`, `remover`, `ajustar`, `documentar` ou outro infinitivo adequado. Use minúscula inicial, sem ponto final; procure manter o assunto completo em até cerca de 72 caracteres sem truncar o sentido.
- Não use `att`, `update`, `cleanup` ou `remove` como tipos. `cleanup` apareceu como escopo de `chore`, não como tipo canônico. Não reescreva o histórico para normalizá-lo.
- Não confunda `feature` (prefixo de branch) com `feat` (tipo de commit).

Exemplos reais, preservados literalmente:

| Commit | Assunto |
| --- | --- |
| `b5749f8` | `feat(navigation): criar estrutura e rotas do portal` |
| `3f69189` | `feat(auth): portar login demonstrativo para flutter` |
| `03f8047` | `feat(profile): portar perfil e preferencias demonstrativas` |
| `78bd00d` | `chore(tooling): registrar skill e ignorar planos locais` |
| `9b6f976` | `test(migration): validar fluxos e documentar limites do prototipo` |

Os 30 commits auditados também incluem merges automáticos, mensagens antigas livres, ponto final e um tipo `remove` com erro de digitação. São inconsistências históricas, não modelos a copiar. Não imponha a terceira pessoa (`cria`, `adiciona`) do prompt inicial: a equipe escolheu preservar o infinitivo.

## Aprovação obrigatória

1. Revise `git diff`, `git diff --cached` e os arquivos não rastreados; confira alterações preexistentes.
2. Execute as validações aplicáveis e descreva resultados reais. Não omita falha, aviso de build ou validação manual pendente.
3. Mostre resumo e mensagem proposta, por exemplo: `docs(agents): documentar regras e fluxo de execucao do projeto`.
4. Pergunte exatamente: **“Aprova o commit?”** Não faça staging nem execute `git commit` antes da aprovação, salvo pedido específico de staging.
5. Após aprovação explícita, selecione somente caminhos da entrega; não use `git add .` ou `git add -A` indiscriminadamente. Não inclua planos locais ignorados.
6. Não faça amend, rebase ou reescrita de commits de outras pessoas sem autorização específica.
7. Aprovação de commit não autoriza `git push`, abertura de PR, merge, release ou deploy. Peça ou aguarde solicitação específica para cada operação.

Origem: histórico Git e decisão da equipe; não derive mensagens Git das regras de classes/arquivos Dart, exemplificadas separadamente em `lib/features/auth/presentation/login_screen.dart`.
