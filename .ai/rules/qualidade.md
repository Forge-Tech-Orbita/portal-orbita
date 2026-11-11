---
paths: ["lib/**", "test/**", "pubspec.yaml", "pubspec.lock", "analysis_options.yaml", ".claude/hooks/**"]
---

# Qualidade e validação

## Configuração real

- `analysis_options.yaml` inclui `package:flutter_lints/flutter.yaml` e exclui `build/**`, `android/**`, `ios/**`, `web/**`. Isso não valida Kotlin, Swift, HTML nem build nativo.
- `pubspec.yaml` declara `flutter_lints: ^6.0.0` e `flutter_test`; `pubspec.lock` resolve `flutter_lints` 6.0.0. Não há linter customizado nem flags `strict-casts`, `strict-inference` ou `strict-raw-types` configuradas.
- Use indentação de 2 espaços e o resultado do `dart format`; não aplique um limite de linha inventado ou formatter adicional.
- Use null safety e tipos explícitos nos campos/contratos como em `lib/features/grades/data/grade.dart` e `lib/core/widgets/orbita_bottom_nav.dart`. Inferência local com `final`/`var` é legítima e existente. Evite `dynamic` e mapas sem contrato; não acrescente flags estritas ao analyzer sem aprovação.
- Preserve construtores `const` e use instâncias constantes quando possível, como `StudentIdCard` e `HomeScreen`. Não force `const` em valores de runtime.

## Gate de conclusão

Execute na raiz, um comando por vez. No primeiro erro, interrompa a sequência para diagnosticar/corrigir e depois reexecute a verificação que falhou e as restantes; não abandone a tarefa por uma tentativa falha:

```text
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
git diff --check
```

- Pré-requisito: Flutter/Dart disponíveis e dependências resolvidas. Use `flutter pub get` para preparar as dependências declaradas quando necessário e autorizado; não use `pub upgrade` como reparo automático.
- Se o formato falhar, formate somente os arquivos afetados: `dart format <caminho>`. `dart format .` existe, mas é amplo; não o use para alterar arquivos fora do escopo.
- No PowerShell 5.1 não use `&&`; execute cada linha e confira seu código de saída. Não existe script agregador de qualidade da aplicação.
- Baseline medido: análise sem problemas, 52 arquivos Dart formatados sem diferenças, 123 testes aprovados. Preserve zero novos erros/warnings. Não desligue diagnósticos nem atualize snapshots/expectativas para esconder regressões.
- Build Web passou com aviso de fontes `MaterialIcons`/`CupertinoIcons`. Não instale `cupertino_icons` apenas para remover esse aviso durante uma tarefa não relacionada.
- Se uma verificação global já falhar no início, registre comando e diagnóstico. Não declare gate verde nem absorva correções fora do escopo.

## Testes existentes

- Há 14 arquivos em `test/`, cobrindo modelos, fixtures, widgets, navegação e fluxos demonstrativos; não há apenas teste de contador.
- Exemplos canônicos: `test/grades_test.dart` (AV2 nula/zero e média), `test/login_test.dart` (validação, espera e descarte), `test/navigation_test.dart` (pilha/rotas) e `test/migration_audit_test.dart` (fluxos e viewports).
- Ao mudar lógica, deixe um teste pequeno de regressão usando `flutter_test`. Ao mudar contratos, atualize consumidores e fixtures envolvidos. Não introduza outro framework de testes.
- Para acelerar diagnóstico, execute o arquivo afetado, por exemplo `flutter test --no-pub test/grades_test.dart`; antes de concluir implementação, execute a suíte completa.
- Testes controlam o avanço dos 900 ms simulados; preserve determinismo. Redefina viewport/teclado em teardown como em `test/migration_audit_test.dart`.

## Build e validação manual

- Use `flutter build web --no-pub` como fumaça quando a alteração justificar. Não equivale a uma compilação Android/iOS.
- Build Android: `flutter build apk --debug --no-pub`, com SDK configurado. iOS: `flutter build ios --no-codesign --no-pub`, apenas em macOS/Xcode. Não execute nem alegue sucesso sem pré-requisitos.
- Para UI/fluxos, peça ao desenvolvedor para executar `flutter run -d <id>` em mobile e conferir login com teclado, rolagem, abas, secundárias, retorno e logout afetados. Confira texto ampliado; registre resultado/responsável.
- Ausência de exceção em widget test não comprova fidelidade visual nem acessibilidade completa.

## Documentação e hook

- Em mudanças apenas documentais, confira caminhos, links, referências dos adaptadores, frontmatter, JSON e `git diff --check`; confira também arquivos não rastreados, que não aparecem no diff normal. Valide a importação `@AGENTS.md` em `CLAUDE.md`, fora de crases/cercas, com alvo existente e sem cópia das regras. Uma frase curta como `Leia @AGENTS.md` é aceita; não exija igualdade literal entre as entradas.
- Ao alterar `.claude/hooks/check.sh`, execute `bash -n .claude/hooks/check.sh` e `bash .claude/hooks/check-self-test.sh` em Bash. Os testes do hook são isolados e não substituem a suíte Flutter.
- O hook executa formato/análise somente quando há Dart ativo ou configuração relevante no status. Não é CI, não executa testes nem build, não comprova proteções Git e não autoriza commit.
