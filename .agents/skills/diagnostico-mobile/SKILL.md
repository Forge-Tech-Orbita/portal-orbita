---
name: diagnostico-mobile
description: "Diagnostique falhas de Flutter/Dart, versões, dependências, build e constraints de widgets do Portal Órbita. Use antes de limpar caches ou alterar SDKs/pacotes."
---

# Diagnóstico Flutter e ambiente mobile

## Pré-condições e leitura

Leia `AGENTS.md`, `.ai/rules/qualidade.md`, `.ai/rules/arquitetura.md`, `pubspec.yaml` e `analysis_options.yaml`. Execute os comandos abaixo separadamente na raiz. Os caminhos são relativos ao repositório.

## Procedimento

1. Execute `git status --short --branch`. Registre a falha original: comando exato, diretório, código de saída e trecho útil do erro. Não copie segredos de logs.
2. Confira `flutter --version` e `flutter doctor --verbose`. O baseline é Flutter 3.47.7/Dart 3.13.5, mas somente Dart `^3.13.5` é exigido no manifest. Não atualize SDK para “tentar resolver”.
3. Para alvo de execução, use `flutter devices`; selecione o ID explicitamente. Android exige SDK; iOS exige macOS/Xcode. Em 10/11/2026 não havia Android SDK neste ambiente. Não instale ferramentas nem aceite licenças automaticamente.
4. Para erro de resolução, compare SDK constraints e dependências de `pubspec.yaml` com `pubspec.lock`. Use `flutter pub deps` para inspecionar o grafo disponível. Não apague lockfile, não rode `pub upgrade` e não acrescente pacote para silenciar um aviso.
5. Se a configuração de pacotes estiver ausente/desatualizada e a preparação estiver autorizada, rode `flutter pub get` e confira `git diff -- pubspec.yaml pubspec.lock`. Pare se houver mudança de versão inesperada ou necessidade de credencial/rede.
6. Rode `flutter analyze --no-pub`. Diferencie diagnóstico Dart de falha de infraestrutura. Não altere `analysis_options.yaml` para esconder o erro.
7. Para comportamento, rode o teste relacionado, por exemplo `flutter test --no-pub test/login_test.dart`; depois use a suíte completa para a entrega. Não use `flutter test` como prova de funcionamento em dispositivo.
8. Para overflow, leia a stack, widget e constraints envolvidos. Reproduza nos viewports de `test/migration_audit_test.dart`, com teclado quando pertinente. Inspecione a árvore com Flutter Inspector/DevTools quando uma sessão de app estiver disponível. Não alegue inspeção visual se só leu código.
9. Para build, confira a configuração pertinente: `android/app/build.gradle.kts`/`android/settings.gradle.kts`, `ios/Runner/` ou `web/index.html`. Web usa `flutter build web --no-pub`; Android debug usa `flutter build apk --debug --no-pub`; iOS sem assinatura usa `flutter build ios --no-codesign --no-pub` no ambiente apropriado.
10. **Só com evidência de cache obsoleto e autorização**, pare processos pertinentes e execute `flutter clean`, seguido de `flutter pub get`, um comando por vez. A limpeza remove artefatos locais e exige recompilação. Não limpe caches globais, SDKs ou pastas amplas.
11. Reexecute o comando original e os gates pertinentes. Compare com o baseline e registre causa, ação, resultado e bloqueios restantes.

## Pare quando

- Faltar SDK, acesso, credencial ou dispositivo indispensável.
- A solução exigir mudar versões, permissões, assinatura, application ID ou infraestrutura fora do escopo.
- O erro envolver dados reais/produção ou uma operação destrutiva.

## Resultado esperado

Informe reprodução mínima, diagnóstico comprovado (ou hipóteses explicitamente marcadas), validações e próxima ação. Não aplique mudanças especulativas, não faça staging/commit/push automaticamente e pergunte **“Aprova o commit?”** quando houver uma entrega com commit proposto.
