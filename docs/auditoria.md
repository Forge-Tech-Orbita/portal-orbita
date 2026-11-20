# Auditoria do Portal Órbita

- **Auditor:** Eduardo Barros da Silva (GitHub: Eduardo-Barros08)
- **Data de início:** 20/11/2026
- **Repositório:** Forge-Tech-Orbita/portal-orbita
- **Branch auditado:** `development`, commit `45631ab` (após o merge do PR #20)
- **Ambiente:** MacBook Air (macOS) · Flutter 3.50.1 (canal stable, revisão `ae9b586f34`) · Dart 3.14.0

## 1. Objetivo

Verificar se o código integrado ao `development` compila, passa nos testes automatizados e funciona como descrito no README e no protótipo de interface, registrando problemas e recomendações.

## 2. Escopo

- PR #16: implementação das telas do protótipo (aluno, professor, coordenação e portal administrativo).
- PR #17 (notas) e PR #18 (temas do aplicativo), integrados ao PR #16.
- PR #19 (Firebase no Android) e PR #20 (regras de commits e PRs).

## 3. Registro das verificações

| # | Verificação | Comando ou ação | Resultado | Situação |
| --- | --- | --- | --- | --- |
| 1 | Atualizar o branch local | `git pull` / `git merge origin/development` | Fast-forward `b581c3b..45631ab`, sem conflitos | OK |
| 2 | Conferir integração do PR #16 | Histórico do `development` | Conflitos resolvidos em `0cc3a83` e PR mergeado em `19c146d` | OK |
| 3 | Ferramenta Flutter disponível | `flutter test` | `command not found: flutter`; Flutter instalado no Mac | Corrigido no ambiente |
| 4 | Instalar dependências | `flutter pub get` | Alterou o `pubspec.lock` (`test_api` 0.7.12 → 0.7.14, `listen` 1.0.1 adicionado); 14 pacotes com versões mais novas incompatíveis com as restrições | Achado A1 |
| 5 | Testes automatizados | `flutter test` | `+198: All tests passed!` em 15 s; avisos de toque fora do alvo (`warnIfMissed`) durante a execução | OK, com achado A2 |
| 6 | Versão do Flutter | `flutter --version` | Flutter 3.50.1 · Dart 3.14.0 · DevTools 2.61.0 | Registrado |
| 7 | Análise estática | `flutter analyze` | `87 issues found`; as exibidas são `info` do tipo `deprecated_member_use` (`package:flutter/material.dart` obsoleto desde a v3.47); contagem por tipo: **0 error, 0 warning, 87 info** (0 + 0 + 87 = 87, confere com o total) | OK com ressalva, achado A3 |
| 8 | Execução na Web | `flutter run -d chrome` | _[preencher]_ | _[pendente]_ |

## 4. Verificação manual das telas

| Perfil | Conta | O que foi verificado | Resultado | Diferença do protótipo |
| --- | --- | --- | --- | --- |
| Aluno | `2023104567` | _[preencher]_ | | |
| Professor | `P2019042` | _[preencher]_ | | |
| Coordenação | `C2015007` | _[preencher]_ | | |
| Administrador | rota `/admin` | _[preencher]_ | | |

## 5. Achados

### A1 — `pubspec.lock` divergente da versão do Flutter

- **Evidência:** após `flutter pub get` no `development` atualizado, com Flutter 3.50.1, o `pubspec.lock` foi alterado (`test_api` 0.7.12 → 0.7.14 e inclusão de `listen` 1.0.1). O `git status` confirma `modified: pubspec.lock`; a mudança **não** foi commitada.
- **Impacto:** _[sua análise: o que isso pode causar na equipe?]_
- **Recomendação:** _[sua recomendação]_

### A2 — Avisos de toque fora do alvo nos testes

- **Evidência:** durante o `flutter test`, o framework exibiu o aviso de que um `tap()` não atingiu o widget esperado e sugeriu `warnIfMissed: false` ou `WidgetController.hitTestWarningShouldBeFatal = true`. Mesmo assim, os 198 testes passaram.
- **Impacto:** _[sua análise: um teste que toca fora do botão está realmente testando o que diz testar?]_
- **Recomendação:** _[sua recomendação]_

### A3 — Importação do Material marcada como obsoleta

- **Evidência:** `flutter analyze` com Flutter 3.50.1 aponta 87 ocorrências, todas `info` (contagem com `grep -cE`: 0 error, 0 warning, 87 info). As exibidas são `info • 'package:flutter/material.dart' is deprecated [...] Use package:material_ui/material_ui.dart instead` (`deprecated_member_use`), na linha 1 de arquivos de `lib/` e `test/`.
- **Impacto:** _[sua análise: é erro ou aviso? Impede o app de compilar hoje? E no futuro?]_
- **Recomendação:** _[sua recomendação]_

## 6. Conclusão do auditor

_[Escreva aqui o seu parecer final: o código está apto, apto com ressalvas ou não apto? Por quê?]_
