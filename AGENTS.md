# Portal Órbita — instruções para agentes

## Antes de trabalhar

- Leia [.ai/rules/index.md](.ai/rules/index.md) e as regras aplicáveis antes de editar. Caminhos nas instruções são relativos à raiz do repositório.
- Confira `git status --short --branch`, arquivos envolvidos e consumidores. Preserve alterações existentes; não descarte nem inclua trabalho alheio.
- Confirme fatos no código e configuração atuais.
- Resolva decisões bloqueantes antes de implementar. Não exponha segredos ou dados pessoais; pare antes de operações destrutivas, migrações ou uso de produção não aprovados.
- Se uma tentativa não resolver o pedido, continue investigando, corrigindo e validando dentro do escopo. Siga o ciclo e os bloqueios de `.ai/rules/geral.md`; não declare sucesso sem verificar os critérios de aceite.

## Projeto e fontes principais

Aplicação Flutter/Dart para Android, iOS e Web, com fixtures locais, sem backend, autenticação real ou persistência. `lib/main.dart` inicia `MainApp` em `lib/app.dart`.

| Assunto | Fonte |
| --- | --- |
| Escopo, segurança, planejamento e conclusão | [.ai/rules/geral.md](.ai/rules/geral.md) |
| Estrutura, dados, navegação e plataformas | [.ai/rules/arquitetura.md](.ai/rules/arquitetura.md) |
| Tema, widgets, acessibilidade e ciclo de vida | [.ai/rules/ui-widgets.md](.ai/rules/ui-widgets.md) |
| Comandos, testes, gates e validação documental | [.ai/rules/qualidade.md](.ai/rules/qualidade.md) |
| Branches e PRs | [.ai/rules/branches.md](.ai/rules/branches.md) |
| Mensagens e aprovação de commit | [.ai/rules/commits.md](.ai/rules/commits.md) |

Reutilize `lib/core/` e `lib/features/<feature>/`, `OrbitaTheme`, `AppRoutes` e widgets existentes. Preserve estado local, navegação e limites demonstrativos; não adicione pacotes, camadas ou pastas raiz em `lib/` sem aprovação. Não edite artefatos gerados manualmente.

## Execução e validação

- Execute na raiz com CLI Flutter/Dart nativo e dependências resolvidas; confirme constraints no `pubspec.yaml`. Não execute comandos Flutter simultaneamente.
- Para Dart/configuração da aplicação, execute separadamente:

```text
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
git diff --check
```

- No primeiro erro, corrija e reexecute antes de continuar a sequência; não esconda diagnósticos. Falta de SDK, dependência, dispositivo ou acesso bloqueia apenas a etapa afetada.
- Preserve testes e adicione regressão para lógica não trivial. Para UI, solicite conferência mobile; Web e widget tests não a substituem.
- Para documentação apenas, valide caminhos, links, referências, sintaxe aplicável e diff, sem alterar o app. Pré-requisitos e comandos de diagnóstico/build estão em `.ai/rules/qualidade.md`.

## Planejamento e Git

- Use `.plan/TEMPLATE.md` em planos compartilhados `.plan/geral/<nome>/index.md`. Detalhamentos individuais ficam em `.plan/local/<integrante>/<nome>/index.md`, ignorados pelo Git; registre decisões e resultados da equipe no plano geral.
- Repositório: `Forge-Tech-Orbita/portal-orbita`. Base e destino diário: `development`; `production` recebe entregas estáveis de `development`. Uma sessão de implementação = uma branch = um PR de escopo fechado; preserve a branch já indicada pelo usuário.
- Use Conventional Commits em português com verbo no infinitivo.
- **Sem auto-commit:** não faça staging nem commit antes de aprovação explícita, salvo pedido específico de staging. Aprovação de commit não autoriza push, PR, merge, release ou deploy.
- Ao terminar, apresente resumo, verificações reais, pendências/riscos e commit proposto. Pergunte exatamente: **“Aprova o commit?”**

## Skills e clientes

Use a skill pertinente:

- Menor diff completo em implementação, correção, refatoração e revisão: `.agents/skills/ponytail/SKILL.md`.
- Investigar ou atualizar convenções: `.agents/skills/infer-conventions/SKILL.md`.
- Alterar Flutter/Dart: `.agents/skills/flutter-best-practices/SKILL.md`.
- Diagnosticar ambiente, build ou layout, antes de limpar caches/alterar SDKs: `.agents/skills/diagnostico-mobile/SKILL.md`.

Não instale skills nem dispare subagentes sem necessidade/autorização. Para alterar integrações dos agentes ou o hook, consulte [.ai/compatibilidade.md](.ai/compatibilidade.md).
