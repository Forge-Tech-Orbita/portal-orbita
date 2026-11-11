---
trigger: always_on
description: "Entrada das regras canônicas do Portal Órbita para Antigravity"
---

# Portal Órbita

- Leia `AGENTS.md`, `.ai/rules/index.md` e todas as regras aplicáveis aos caminhos antes de editar. Os caminhos são relativos à raiz do repositório; abra explicitamente esses arquivos.
- A aplicação é Flutter/Dart, organizada em `lib/core/` e `lib/features/`, com fixtures locais e sem Firebase/backend/persistência. Reutilize `OrbitaTheme`, `AppRoutes` e widgets existentes; não restaure legado nem introduza pacotes/camadas sem aprovação.
- Confira o estado do Git, preserve alterações existentes e use `.plan/TEMPLATE.md` para escopo, decisões e acompanhamento.
- Se uma tentativa não resolver o pedido, continue investigando, corrigindo e validando conforme `.ai/rules/geral.md`. Não declare conclusão parcial como sucesso; pare somente a etapa com bloqueio real ou por orientação do usuário, sem ultrapassar o escopo autorizado.
- Para Dart/configuração, execute separadamente `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze --no-pub`, `flutter test --no-pub` e `git diff --check`. Há testes reais. Interrompa a sequência na falha, investigue/corrija e reexecute; registre bloqueios reais e não instale SDKs nem altere versões para contornar erros.
- Base e destino de PR diário: `development`; preserve a branch correta já informada. Conventional Commits em português com verbo no infinitivo, conforme as regras Git.
- Não faça staging, commit ou push automaticamente. PR, merge, release e deploy também exigem pedido separado. Apresente resumo, validações, pendências e commit proposto; pergunte **“Aprova o commit?”**.
- As skills locais estão em `.agents/skills/`; se não forem descobertas pela versão utilizada, leia o `SKILL.md` pertinente pelo caminho. O hook de `.claude/` não configura automação do Antigravity.
