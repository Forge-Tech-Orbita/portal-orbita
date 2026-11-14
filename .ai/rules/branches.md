---
paths: ["**"]
---

# Branches e Pull Requests

## Política

- Repositório: `Forge-Tech-Orbita/portal-orbita`. Base de trabalho e destino dos PRs diários: `development`.
- `production` recebe somente entregas estáveis por merge de `development`. A promoção é uma operação separada.
- Exija ao menos uma aprovação e conversas resolvidas antes do merge. Não faça push direto, force push ou deleção de `development`/`production`.
- Essas são políticas da equipe; confira a configuração do provedor antes de afirmar que há enforcement técnico.
- Uma sessão de implementação corresponde a uma branch e um PR de escopo fechado. Não misture trabalhos independentes.

## Nomenclatura

Use `<tipo>/<numero-issue>-<descricao-em-kebab-case>`, em português, minúsculo, sem acentos e com verbo no infinitivo. Peça a issue quando faltar.

- Tipos: `feature`, `chore`, `fix`, `refactor` ou `docs`, conforme o escopo.
- Exemplo de formato: `fix/7-corrigir-overflow-do-perfil`; o número não indica uma issue confirmada.
- Preserve a branch já indicada pelo usuário; não renomeie branches existentes para adequá-las à convenção.

## Fluxo seguro

1. Execute `git status --short --branch`. Preserve alterações existentes; se impedirem troca/atualização, combine a preservação antes de prosseguir. Não faça stash, reset ou checkout destrutivo automaticamente.
2. Confirme remote, issue e base. Não presuma `main` nem use referências locais antigas como prova da base atual.
3. Se já estiver na branch correta indicada pelo usuário, continue nela. Caso a criação esteja autorizada, execute separadamente:

```text
git switch development
git pull --ff-only origin development
git switch -c <tipo>/<issue>-<descricao>
```

4. Pare se o fast-forward falhar; não contorne divergências com rebase, merge, force push ou reset sem autorização. Não atualize branches durante uma tarefa somente de leitura.
5. Faça push e abra PR somente com autorização específica, para `development`, informando escopo, verificações e pendências. Não solicite merge com gate obrigatório falhando.
6. Merge, promoção para `production`, release e deploy exigem autorizações próprias; aprovação de commit não as inclui.
