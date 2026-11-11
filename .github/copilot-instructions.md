# GitHub Copilot — Portal Órbita

**Política crítica:** não faça staging, commit nem push automaticamente. Commit exige aprovação explícita; push, PR, merge, release e deploy exigem autorização separada. Ao concluir, proponha a mensagem e pergunte **“Aprova o commit?”**. Se o modo do cliente exigir publicação automática, esclareça a incompatibilidade antes de iniciar.

Leia `AGENTS.md` e `.ai/rules/index.md` antes de editar; os caminhos são relativos à raiz. Leia também todas as regras correspondentes aos arquivos da tarefa. Não presuma inclusão automática do conteúdo referenciado.

**Conclusão verificável:** se uma tentativa não resolver o pedido, continue reproduzindo, investigando, corrigindo e validando dentro do escopo autorizado. Siga `.ai/rules/geral.md`; só interrompa a etapa por bloqueio real ou orientação do usuário, registrando a pendência sem declarar sucesso.

## Aplicação e padrões

- Flutter/Dart, com Android/iOS/Web. `lib/main.dart` inicia `MainApp` em `lib/app.dart`; não é React/Expo nem uma aplicação HTML.
- Dados locais demonstrativos, sem Firebase/Firestore, backend, autenticação real ou persistência. Não implemente essas integrações por antecipação.
- Reutilize `lib/core/theme/orbita_theme.dart`, `lib/core/constants/app_routes.dart` e `lib/core/widgets/`. Features ficam em `lib/features/<feature>/presentation/` e, quando já necessário, `data/` e widgets locais.
- Preserve `Navigator`/rotas nomeadas, `IndexedStack` das cinco abas e `setState` local. Não adicione pacote, camada, pasta raiz em `lib/` ou gerenciador de estado sem aprovação.
- Use arquivos `snake_case.dart`, classes `PascalCase`, membros `lowerCamelCase`, indentação de 2 espaços, null safety e `const` quando possível. Inferência local é aceita; evite `dynamic`.
- Reutilize paleta/tema, preserve acessibilidade, controllers/dispose e verificação de `mounted` após operações assíncronas. Resolva overflow pela causa nas constraints, não escondendo conteúdo.
- Não restaure/edite/importe `portal-orbita-antigo/`, já removido. `web/` é bootstrap Flutter ativo. Não edite gerados em `build/`, `.dart_tool/`, registradores ou `.metadata` manualmente.

## Comandos e validação

Execute na raiz com CLI nativo. Ambiente auditado: Flutter 3.47.7, Dart 3.13.5, PowerShell 5.1; o manifest exige Dart `^3.13.5`, sem pin exato do Flutter.

| Ação | Comando |
| --- | --- |
| Preparar dependências declaradas | `flutter pub get` |
| Diagnosticar SDKs | `flutter doctor --verbose` |
| Listar alvos | `flutter devices` |
| Rodar app em alvo escolhido | `flutter run -d <id>` |
| Formatar arquivo editado | `dart format <caminho>` |
| Conferir formato | `dart format --output=none --set-exit-if-changed lib test` |
| Analisar | `flutter analyze --no-pub` |
| Executar suíte existente | `flutter test --no-pub` |
| Build de fumaça Web | `flutter build web --no-pub` |
| Conferir espaços | `git diff --check` |

- Execute formato sem escrita, análise, suíte e verificação de espaços antes de concluir mudanças Dart/configuração, um comando por vez. No primeiro erro, interrompa a sequência para corrigir e reexecutar, não para abandonar a investigação. Não use `&&` no PowerShell 5.1 nem execute comandos Flutter simultaneamente.
- Há **14 arquivos de testes reais**, com **123 testes aprovados** no baseline. Preserve/atualize testes afetados com `flutter_test`, sem introduzir outra stack. Não escreva uma proibição de testes.
- Baseline: análise sem problemas e formato sem diferenças. Build Web passou com aviso preexistente de fontes. Não introduza novos erros/warnings nem esconda problemas anteriores.
- Falta de Android SDK bloqueia build/execução Android neste ambiente; iOS exige macOS/Xcode. Não instale ferramentas, rode upgrade ou limpe caches automaticamente. Pare a etapa afetada, registre o erro e peça decisão.
- Para UI/fluxos, peça ao desenvolvedor conferência no emulador/dispositivo mobile, incluindo teclado, rolagem, retorno/logout e texto ampliado. Testes de widgets e Web não substituem validação mobile.
- Em documentação apenas, valide caminhos, links, sincronização e sintaxe dos arquivos adicionados; não reformate o app sem motivo.

## Trabalho e Git

- Confira `git status --short --branch`; preserve trabalho existente. Faça o menor diff completo, reutilize código, evite abstrações especulativas e anote melhorias fora do escopo sem corrigi-las.
- Use `.plan/TEMPLATE.md` para planos maiores da equipe em `.plan/geral/<nome>/index.md`, com tarefas, responsáveis e acompanhamento compartilhado. Detalhe individualmente as tarefas designadas em `.plan/local/<integrante>/<nome>/index.md`, mantendo essa pasta ignorada pelo Git; registre decisões e resultados relevantes no plano geral. Resolva decisões bloqueantes antes de implementar.
- GitHub `Forge-Tech-Orbita/portal-orbita`; branches de trabalho saem de `development` atualizada, PRs diários voltam para `development`. `production` só recebe entregas estáveis de `development`, por política da equipe.
- Uma sessão = uma branch = um PR. Use `<tipo>/<issue>-<descricao>`; pergunte a issue quando faltar. Preserve branch já indicada pelo usuário. Siga `.ai/rules/branches.md` para atualização segura e limites das proteções verificadas.
- Use Conventional Commits em português, verbo no infinitivo, conforme `.ai/rules/commits.md` e decisão da equipe.
- Termine com resumo, verificações reais, bloqueios, mensagem de commit proposta e **“Aprova o commit?”**.

Skills canônicas: consulte a lista mantida em `AGENTS.md`, incluindo Ponytail em `.agents/skills/ponytail/SKILL.md`. Leia o arquivo pertinente pelo caminho se o cliente não o descobrir. Compatibilidade e limites: `.ai/compatibilidade.md`.
