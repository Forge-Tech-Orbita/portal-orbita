---
paths: ["**"]
---

# Branches e Pull Requests

## Evidências e políticas

- **Observado:** remote `origin` aponta para `https://github.com/Forge-Tech-Orbita/portal-orbita.git`. A API pública confirmou `development` como branch padrão e `development`/`production` com `protected: true` em 10/11/2026.
- **Política informada pela equipe:** trabalhe a partir de `development` atualizada; PRs diários voltam para `development`, com ao menos uma aprovação e conversas resolvidas. `production` recebe somente versões estáveis por merge de `development`. Não faça push direto, force push ou deleção dessas duas branches.
- **Limite de verificação:** a API detalhada de proteção respondeu HTTP 401 sem autenticação. Aprovações, conversas, bypasses, bloqueio de push/force push/deleção e restrição da origem de merges não foram comprovados individualmente. Não trate orientação escrita como enforcement técnico.
- **Referências locais desatualizadas:** `origin/HEAD` ainda apontava para `origin/main`; a branch local `development` estava atrás de `origin/development`. Não use essa referência antiga para escolher a base e não a corrija sem necessidade/autorização.

## Nomenclatura

Use `<tipo>/<numero-issue>-<descricao-em-kebab-case>`, em português, minúsculo e sem acentos. Peça a issue quando não informada. Use verbo no **infinitivo**, conforme decisão explícita nesta auditoria, preservando o padrão predominante do histórico.

- `feature` é o prefixo observado para funcionalidades; use `chore`, `fix`, `refactor` ou `docs` conforme o escopo. Não misture tipos diferentes na mesma sessão.
- Exemplos observados: `feature/2-migracao-telas-flutter`, `chore/4-limpeza-react`, `chore/5-limpeza-codigo-legado`. As descrições históricas são nominais; não as renomeie retroativamente.
- Exemplos para novas branches: `feature/6-adicionar-filtro-de-notas`, `fix/7-corrigir-overflow-do-perfil`, `docs/8-documentar-validacao-mobile`. São exemplos, não branches existentes nem números de issues confirmados.
- A branch desta entrega, `feature/3-cria-documentacao-e-regras-execucao-projeto`, foi indicada pelo usuário e deve ser mantida, sem renomeação retroativa.

## Fluxo seguro

1. Execute `git status --short --branch`. Se houver alterações incompatíveis com troca/atualização, pare e combine a preservação; não faça stash, reset ou checkout destrutivo automaticamente.
2. Confirme remote, issue e base. Quando a tarefa autorizar criar uma branch e a árvore estiver apropriada, execute um comando por vez:

```text
git switch development
git pull --ff-only origin development
git switch -c <tipo>/<issue>-<descricao>
```

3. Pare se o fast-forward falhar; não faça rebase, merge de resolução, force push ou reset para contornar divergência. `git pull` altera referências/arquivos e exige contexto apropriado, não faz parte da auditoria somente de leitura.
4. Implemente apenas a sessão. Se já estiver na branch correta informada pelo usuário, não troque nem recrie a branch.
5. Somente após pedido específico faça push e abra PR para `development`. Informe escopo, verificações, baseline e pendências visuais. Não solicite merge com gate obrigatório falhando.
6. Promoção `development` → `production` é operação de entrega separada; não abra, aprove ou faça merge automaticamente.

Esta regra vem do Git, da API e da política da equipe, não de um arquivo Dart. A navegação da aplicação em `lib/app.dart` não configura branches ou proteção do GitHub.
