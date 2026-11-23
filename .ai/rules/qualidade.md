---
paths: ["lib/**", "test/**", "pubspec.yaml", "pubspec.lock", "analysis_options.yaml", ".claude/hooks/**"]
---

# Qualidade e validação

## Padrão Dart

- Siga `analysis_options.yaml` e `flutter_lints`; não desative diagnósticos nem adicione regras estritas sem aprovação. Exclusões do analyzer não validam arquivos nativos/Web.
- Use `dart format`, indentação de 2 espaços e null safety. Arquivos: `snake_case.dart`; classes: `PascalCase`; membros: `lowerCamelCase`; privados: `_`.
- Tipe campos, callbacks e contratos. Inferência local com `final`/`var` é aceita; evite `dynamic` e mapas sem contrato. Use `const` quando possível.

## Execução e pré-requisitos

- Execute comandos na raiz, junto de `pubspec.yaml`, com CLI Flutter/Dart nativo. Confira SDKs com `flutter --version` e o ambiente com `flutter doctor --verbose`; constraints vigentes estão no manifest.
- Liste alvos com `flutter devices` antes de usar `flutter run -d <id>`. Não presuma emulador ou SDK disponível.
- Dependências devem estar resolvidas. Se faltar `.dart_tool/package_config.json`, execute `flutter pub get` quando autorizado e confira alterações no manifest/lockfile. Não instale ferramentas, atualize versões ou execute `pub upgrade` silenciosamente.
- Execute cada comando e confira seu código de saída. Não execute comandos Flutter simultaneamente.
- Não use `flutter clean` como tentativa inicial; siga `.agents/skills/diagnostico-mobile/SKILL.md` antes de limpar caches ou alterar SDKs/pacotes.
- Em falta de SDK, pacote, acesso, credencial ou dispositivo, registre comando/erro e pare só a etapa bloqueada. Não declare sucesso.

## Gate para Dart e configuração da aplicação

Execute separadamente:

```text
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
git diff --check
```

- No primeiro erro, investigue/corrija, reexecute a verificação que falhou e complete as restantes, conforme `.ai/rules/geral.md`.
- Formate somente arquivos afetados com `dart format <caminho>`; não use formatação ampla para modificar trabalho fora do escopo.
- Não introduza novos erros/warnings. Registre falhas e avisos preexistentes sem escondê-los ou corrigi-los fora do pedido; não altere expectativas para mascarar regressões.

## Testes

- Preserve a stack `flutter_test`. Mudança de lógica não trivial exige regressão pequena; contratos alterados exigem atualização de consumidores, testes e fixtures.
- Use testes relacionados para diagnóstico, como `flutter test --no-pub test/grades_test.dart`; execute a suíte completa antes de concluir implementação.
- Referências: `test/grades_test.dart` para média/AV2, `test/login_test.dart` para validação/espera/descarte, `test/navigation_test.dart` para rotas e `test/migration_audit_test.dart` para fluxos/viewports.
- Controle o avanço do tempo simulado e restaure viewport, teclado e escala de texto em teardown para manter determinismo.

## Build e validação manual

| Alvo | Comando | Pré-requisito |
| --- | --- | --- |
| Web | `flutter build web --no-pub` | Toolchain Web |
| Android debug | `flutter build apk --debug --no-pub` | Android SDK configurado |
| iOS sem assinatura | `flutter build ios --no-codesign --no-pub` | macOS/Xcode |

- Compile quando o impacto da alteração justificar. Web e widget tests não comprovam build nativo, fidelidade visual ou acessibilidade completa. Não exija limpeza de cache para considerar build bem-sucedido.
- Para UI/fluxos, peça ao desenvolvedor `flutter run -d <id>` em mobile, conferindo telas afetadas, teclado, rolagem, abas, retorno, logout e texto ampliado. Registre responsável e resultado.

## Documentação e hook

- Para documentação apenas, confira caminhos, links, referências dos consumidores, frontmatter/JSON aplicáveis e `git diff --check`. Confira arquivos não rastreados separadamente; não rode gates Flutter nem reformate o app sem necessidade.
- Preserve `@AGENTS.md` em `CLAUDE.md`, fora de crases/cercas, com alvo existente e sem cópia das regras. Uma frase curta junto da importação é aceita.
- Ao alterar `.claude/hooks/check.sh`, execute `bash -n .claude/hooks/check.sh` e `bash .claude/hooks/check-self-test.sh` em Bash. Os testes isolados não substituem a suíte Flutter.
- O hook cobre formato/análise de alterações relevantes no status; não substitui testes, build ou validação funcional nem autoriza operações Git.
