---
paths: ["lib/**", "test/**"]
---

# UI e widgets Flutter

## Tema e paleta canônica

Reutilize `OrbitaTheme` de `lib/core/theme/orbita_theme.dart`, aplicado em `lib/app.dart`. Leia tipografia de `Theme.of(context).textTheme`, como em `lib/features/home/presentation/home_screen.dart`.

| Token | Cor |
| --- | --- |
| `background` | `#F6F1E3` |
| `surface` | `#FBF8EF` |
| `border` | `#DECBA0` |
| `text` | `#2B2A22` |
| `primary` | `#2F6F68` |
| `terracotta` | `#A6543B` |
| `green` | `#5B7F3A` |
| `amber` | `#C98A2E` |
| `alert` | `#AF3B2E` |

- Não duplique essas cores com literais. Use `withValues(alpha: ...)` quando precisar da transparência já aplicada em `lib/core/widgets/notice_tile.dart`.
- Não há design tokens de espaçamento/tipografia próprios: valores locais de padding, radius e `SizedBox` existem. Siga o componente irmão; não invente uma regra de centralização total ou proíba todos os valores locais.
- O tema é claro, sem fonte externa ou alternância funcional de modo escuro. O switch em `lib/features/profile/presentation/profile_screen.dart` é demonstrativo.

## Composição

- Reutilize `StudentIdCard`, `NoticeTile`, `DecorativeBarcode` e `OrbitaBottomNav` de `lib/core/widgets/`.
- Mantenha componentes exclusivos na feature, como `lib/features/home/presentation/widgets/quick_action_tile.dart`; widgets pequenos privados podem continuar no arquivo da tela, como `_GradeCard` em `lib/features/grades/presentation/grades_screen.dart`.
- Passe dados e callbacks tipados por construtor. `QuickActionTile` recebe `VoidCallback`; `OrbitaBottomNav` recebe `ValueChanged<int>`. Não crie wrapper de controle Material sem necessidade concreta.
- Use `StatelessWidget` quando não houver estado mutável próprio e `StatefulWidget` quando houver, como Home e Login respectivamente. Preserve `const` quando possível.
- Use `Scaffold`/`AppBar` nas secundárias; preserve a casca das abas descrita em `.ai/rules/arquitetura.md`.

## Responsividade e acessibilidade

- Investigue constraints e textos antes de resolver `RenderFlex overflowed`. Não masque o problema com clipping, texto removido ou redução arbitrária de fonte.
- Use rolagem para conteúdo vertical e teclado, como `SingleChildScrollView` + `SafeArea` em `lib/features/auth/presentation/login_screen.dart`. Preserve `ConstrainedBox(maxWidth: 400)` do formulário quando pertinente.
- Use `Expanded`/`Flexible` para textos em `Row`, como `lib/features/home/presentation/widgets/next_class_card.dart`; use `Wrap` para pares que precisam quebrar, como o Financeiro e o Perfil.
- Use constraints locais com `LayoutBuilder` quando necessário, como as duas colunas de `lib/features/more/presentation/more_screen.dart`. `MediaQuery` pode atender uma necessidade concreta; não é uma abstração obrigatória nem padrão já espalhado no projeto.
- Não coloque `Expanded` no eixo sem limites de uma rolagem. Não fixe altura de tela/celular, notch ou barra de status simulada.
- As listas atuais são fixtures curtas em `Column`/`for`. Não converta todas para `ListView.builder` por princípio; use construção sob demanda quando houver lista longa/dinâmica real, evitando rolagens aninhadas sem limites.
- Preserve labels, tooltips, controles Material e leitura semântica. Exemplos: símbolo do Login com `Semantics`, AV2 ausente em `_AssessmentRow`, barras com `ExcludeSemantics` em `lib/core/widgets/decorative_barcode.dart`.
- Teste 360×640 com teclado, 360×800 e 390×844 conforme `test/migration_audit_test.dart`; confira texto 2× nos testes pertinentes, como `test/more_test.dart`. Peça validação visual mobile ao desenvolvedor.

## Ciclo de vida

- Libere `TextEditingController` e outros recursos possuídos pelo estado em `dispose()`. Use `lib/features/auth/presentation/login_screen.dart` como referência.
- Depois de `await`, confira `mounted`/`context.mounted` antes de acessar estado/contexto. Preserve bloqueio de submissão duplicada e validação do formulário em `_login`.
- Não conecte Firebase/Firestore nem introduza streams por iniciativa própria: não há backend atual. Uma integração futura precisa de autorização e contrato específico, incluindo erros, loading, permissões e descarte de listeners.
