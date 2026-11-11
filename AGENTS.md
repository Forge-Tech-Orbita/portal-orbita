# Portal Órbita — instruções para agentes

## Leia antes de editar

- Leia este arquivo, [.ai/rules/index.md](.ai/rules/index.md) e as regras correspondentes aos caminhos afetados. Os caminhos escritos nas instruções são relativos à raiz do repositório, salvo indicação contrária.
- Confira `git status --short --branch` e leia os arquivos envolvidos e seus consumidores. Preserve alterações existentes; não descarte, faça staging ou inclua trabalho alheio por conveniência.
- Consulte [.ai/auditoria.md](.ai/auditoria.md) para evidências e baseline de 10/11/2026. Confira novamente fatos que possam ter mudado.
- Separe fato observado, política solicitada e recomendação pendente. Se houver conflito com instruções de maior prioridade ou decisão de negócio ausente, pare a etapa afetada e pergunte.
- **Concluir de verdade:** se uma tentativa não resolver o problema solicitado, não encerre como concluído: confira o resultado, investigue a causa e continue corrigindo e validando dentro do escopo autorizado. Siga o ciclo e as exceções de bloqueio em `.ai/rules/geral.md`; não confunda um comando bem-sucedido com a resolução do pedido.

## Projeto atual e limites

- Aplicação Flutter/Dart: `lib/main.dart` inicia `MainApp` em `lib/app.dart`. Há plataformas Android, iOS e Web; `web/` é o bootstrap Flutter, não o protótipo antigo.
- O app demonstra um portal acadêmico com 11 telas. Os dados são fixtures locais, sem backend, Firebase/Firestore, autenticação real ou persistência. Veja `.ai/rules/arquitetura.md`.
- Use `lib/core/` para recursos compartilhados e `lib/features/<feature>/` conforme os arquivos irmãos. Estado é local, com `StatefulWidget`/`setState`; navegação usa `AppRoutes`, `Navigator` e `IndexedStack`.
- `portal-orbita-antigo/` já foi removido. Não restaure, edite, importe nem use esse legado para inferir padrões novos. Os antigos arquivos React Native/Expo também não integram a aplicação atual.
- Não edite `build/`, `.dart_tool/`, registradores gerados ou `.metadata` manualmente. Não exponha credenciais, valores de ambiente ou dados pessoais.

## Execução de comandos

Execute na raiz, junto de `pubspec.yaml`, usando o CLI nativo. Não há wrapper Flutter, FVM ou script agregador versionado. Ambiente auditado: Flutter **3.47.7**, Dart **3.13.5**, Windows/PowerShell **5.1**. `pubspec.yaml` exige Dart `^3.13.5`; não fixa uma versão exata do Flutter.

| Ação | Comando literal | Pré-requisito / situação na auditoria |
| --- | --- | --- |
| Conferir SDKs | `flutter --version` | Executado; versões acima |
| Diagnosticar ambiente | `flutter doctor --verbose` | Executado; faltam Android SDK e Visual Studio |
| Baixar dependências declaradas | `flutter pub get` | Rede/cache; não é autorização para adicionar pacotes ou executar upgrade |
| Listar alvos | `flutter devices` | Escolha um dispositivo disponível; não presuma emulador Android |
| Rodar app | `flutter run -d <id>` | Substitua `<id>` por um ID listado; execução visual não realizada nesta auditoria |
| Rodar demonstração Web | `flutter run -d chrome` | Chrome detectado; não substitui validação mobile |
| Analisar código | `flutter analyze --no-pub` | Dependências resolvidas; executado sem problemas |
| Conferir formatação | `dart format --output=none --set-exit-if-changed lib test` | Executado: 52 arquivos, nenhum diferente |
| Formatar arquivos da tarefa | `dart format <arquivo-ou-diretorio>` | Substitua pelo caminho editado; não reformate trabalho alheio |
| Formatar toda a aplicação | `dart format lib test` | Somente se o escopo justificar; `dart format .` tem alcance maior |
| Executar suíte | `flutter test --no-pub` | Stack existente; 123 testes aprovados na auditoria |
| Executar teste específico | `flutter test --no-pub test/login_test.dart` | Exemplo real; escolha o teste relacionado à tarefa |
| Compilar fumaça Web | `flutter build web --no-pub` | Executado com sucesso e aviso de fontes preexistente |
| Compilar Android debug | `flutter build apk --debug --no-pub` | Não executado: Android SDK ausente |
| Compilar iOS sem assinatura | `flutter build ios --no-codesign --no-pub` | Não executado: requer macOS/Xcode |
| Conferir espaços do diff | `git diff --check` | Não cobre arquivos não rastreados; confira-os separadamente |

`flutter analyze`, `flutter test` e `flutter build web` são comandos documentados no README; `--no-pub` evita resolução implícita de dependências durante as checagens. Não execute dois comandos Flutter simultaneamente: o SDK compartilha locks.

### Regras de parada

- Se faltar SDK, pacote, dispositivo, acesso à rede ou credencial, registre o comando e o erro. Pare só a etapa bloqueada; não declare sucesso.
- Se faltar `.dart_tool/package_config.json`, prepare as dependências declaradas com autorização adequada usando `flutter pub get`. Não instale ferramentas, atualize versões ou altere o lockfile para contornar falhas silenciosamente.
- Não execute `flutter clean` como primeira tentativa. Leia `.agents/skills/diagnostico-mobile/SKILL.md`; limpeza é medida justificada e remove artefatos locais.
- Pare antes de operações destrutivas, migrações, deploy, uso de produção ou mudanças de regra de negócio não aprovadas.

## Qualidade, testes e validação

- Siga `analysis_options.yaml`: `flutter_lints`, exclusões de `build/**`, `android/**`, `ios/**` e `web/**`. Não desligue regras para fazer a entrega passar.
- Use indentação de 2 espaços definida pelo formatador, null safety, campos/callbacks tipados e `const` quando possível. Inferência com `final`/`var` é usada no código; não confunda isso com `dynamic`.
- Há testes reais em `test/`, não um contador de template. Preserve e atualize os testes afetados; acrescente uma regressão pequena quando alterar lógica não trivial. Não introduza outra stack.
- Antes de concluir mudanças Dart/configuração, execute separadamente, interrompendo a sequência no primeiro erro para diagnosticar, corrigir e reexecutar:

```text
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
git diff --check
```

- Não existe comando agregador. No PowerShell 5.1, não cole essa sequência ligada por `&&`. No Bash/PowerShell 7, encadeamento condicional é possível, mas não é necessário.
- Baseline: zero problemas na análise, zero diferenças de formatação, 123 testes aprovados. Não introduza novos erros/warnings. Se o baseline mudar, relate o problema preexistente sem corrigi-lo fora do escopo.
- Para alterações visuais/fluxos, peça ao desenvolvedor para rodar `flutter run -d <id>` no emulador/dispositivo mobile, conferir telas afetadas, teclado, rolagem, retorno e logout. Use 360×640, 360×800 e 390×844 como referências dos testes; confira também texto ampliado. Registre quem validou e o resultado.
- Build Web e testes de widgets não comprovam build Android/iOS nem fidelidade visual. Não exija `flutter clean` para chamar uma compilação de bem-sucedida.
- Para documentação apenas, confira caminhos, links, sincronização, sintaxe dos arquivos de configuração/scripts e diff. Não reformate nem altere o app sem necessidade.

## Lazy Senior Dev — Ponytail

Use `.agents/skills/ponytail/SKILL.md` em implementação, correção, refatoração e revisão de código, ou quando o usuário pedir simplicidade. Se o cliente não descobrir a skill, leia o arquivo explicitamente; os princípios abaixo continuam aplicáveis.

- **YAGNI:** implemente somente o pedido; não crie camadas, serviços, pastas raiz em `lib/` ou dependências sem aprovação.
- **Reutilize:** consulte `OrbitaTheme`, `AppRoutes`, widgets em `lib/core/widgets/` e arquivos irmãos antes de criar alternativas.
- **Causa raiz:** investigue consumidores e constraints antes de corrigir bug/overflow; não esconda texto ou desative erros para disfarçar o defeito.
- **Deleção sobre adição:** prefira o menor diff completo, preservando validações, acessibilidade, tratamento de erros e contratos existentes.
- **Escopo fechado:** anote melhorias alheias no plano, sem implementá-las. Registre limites conhecidos com `shortcut: <limite>, <quando revisar>`, como em `lib/features/auth/presentation/login_screen.dart`.

## Git e fechamento obrigatório

- GitHub: `Forge-Tech-Orbita/portal-orbita`. Base e destino diário: `development`; `production` recebe apenas entregas estáveis de `development`, conforme política da equipe.
- Siga `.ai/rules/branches.md`: uma sessão de implementação = uma branch = um PR de escopo fechado. Preserve a branch já indicada pelo usuário; não crie/troque branches automaticamente nesta situação.
- Use Conventional Commits em português com verbo no **infinitivo**, conforme decisão da equipe nesta auditoria; veja `.ai/rules/commits.md`.
- **Zero auto-commit:** não execute `git commit` nem `git push` sem autorização explícita para a operação. Aprovação de commit não autoriza push, PR, merge, release ou deploy. Não faça staging antes da aprovação do commit, salvo pedido específico.
- Ao terminar, apresente resumo, verificações realmente realizadas, pendências/riscos e mensagem de commit proposta. Pergunte exatamente: **“Aprova o commit?”**

## Guia rápido da equipe

1. Use `.plan/TEMPLATE.md` para criar os planos maiores e compartilhados em `.plan/geral/<nome>/index.md`, com contexto, referência da base, decisões, tarefas e responsáveis para toda a equipe.
2. Cada integrante pode destrinchar suas tarefas designadas em `.plan/local/<integrante>/<nome>/index.md`, referenciando o plano geral. Esses roteiros individuais continuam ignorados pelo Git; não force sua inclusão. Registre decisões e andamento relevantes para a equipe no plano geral, sem depender dos arquivos locais.
3. Peça: `Execute a sessão S01 do plano .plan/geral/<nome>/index.md. Leia AGENTS.md e .ai/rules/index.md. Não commite automaticamente.`
4. Responda decisões bloqueantes antes da implementação. Revise o diff e a validação; aprove commit e operações remotas separadamente.
5. O plano de migração `.plan/geral/plano-migracao-index-html.md` é histórico concluído. Suas referências a arquivos removidos e commits por etapa não substituem estas regras atuais.

## Ferramentas e skills

Consulte [.ai/compatibilidade.md](.ai/compatibilidade.md) para adaptadores e carregamento manual. Não presuma que `.ai/rules/` ou seu campo `paths` sejam carregados nativamente por todos os agentes.

- Descobrir/atualizar convenções: `.agents/skills/infer-conventions/SKILL.md`.
- Resolver com o menor diff completo (Ponytail): `.agents/skills/ponytail/SKILL.md`.
- Alterar Flutter/Dart: `.agents/skills/flutter-best-practices/SKILL.md`.
- Diagnosticar ambiente/build/layout: `.agents/skills/diagnostico-mobile/SKILL.md`.
- Leia a skill pelo caminho quando não estiver disponível no catálogo da ferramenta. Não instale skills nem dispare subagentes sem necessidade/autorização.
