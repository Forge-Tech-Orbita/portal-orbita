---
paths: ["lib/**", "test/**"]
---

# UI e widgets Flutter

## Tema e composição

- Use `OrbitaTheme` de `lib/core/theme/orbita_theme.dart` e `Theme.of(context).textTheme`. Não duplique cores com literais; use `withValues(alpha: ...)` para transparência.
- Siga espaçamentos, raios e composição dos arquivos irmãos. Não crie um sistema de tokens ou wrappers Material sem necessidade concreta.
- Reutilize `StudentIdCard`, `NoticeTile`, `DecorativeBarcode` e `OrbitaBottomNav` em `lib/core/widgets/`.
- Mantenha widgets exclusivos na feature; widgets pequenos privados podem ficar no arquivo da tela.
- Passe dados e callbacks tipados por construtor. Use `StatelessWidget` sem estado próprio e `StatefulWidget` com estado mutável; preserve `const` quando possível.
- Preserve a composição de abas e secundárias definida em `.ai/rules/arquitetura.md`.

## Responsividade e acessibilidade

- Reproduza constraints, viewport, escala de texto e teclado antes de corrigir overflow. Não esconda conteúdo com clipping, remoção de texto ou redução arbitrária de fonte.
- Use rolagem e `SafeArea` para conteúdo vertical/teclado. Preserve o limite de largura do formulário de Login quando pertinente.
- Use `Expanded`/`Flexible` em `Row` com largura finita, `Wrap` para elementos quebráveis e `LayoutBuilder` quando depender de constraints locais.
- Não use `Expanded` no eixo ilimitado de uma rolagem nem simule dimensões fixas de tela, notch ou barra de status.
- Mantenha `Column`/`for` para fixtures curtas. Use construção sob demanda para listas realmente longas/dinâmicas, evitando rolagens aninhadas sem limites.
- Preserve labels, tooltips, controles Material e semântica. Informe AV2 ausente como não informada e exclua barras decorativas da leitura assistiva; não dependa só de cor para comunicar estado.
- Teste viewports 360×640 com teclado, 360×800 e 390×844, além de texto ampliado de pelo menos 2× nos cenários pertinentes. Referência: `test/migration_audit_test.dart`. Solicite conferência visual mobile conforme `.ai/rules/qualidade.md`.

## Ciclo de vida

- Libere controllers e outros recursos pertencentes ao estado em `dispose()`.
- Depois de `await`, confira `mounted`/`context.mounted` antes de acessar estado/contexto.
- Preserve validação de formulários e bloqueio de submissão duplicada, como no Login.
- Integrações assíncronas novas exigem escopo e contrato aprovados, incluindo loading, erros, permissões e descarte de listeners.
