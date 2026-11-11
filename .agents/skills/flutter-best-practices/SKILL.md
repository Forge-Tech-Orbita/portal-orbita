---
name: flutter-best-practices
description: "Altere telas, widgets e lógica Dart do Portal Órbita preservando tema, navegação, estado local, acessibilidade e testes existentes. Use também para corrigir overflow e ciclo de vida."
---

# Flutter/Dart no Portal Órbita

## Pré-condições e leitura

Leia `AGENTS.md`, `.ai/rules/arquitetura.md`, `.ai/rules/qualidade.md`, `.ai/rules/ui-widgets.md` e os arquivos da feature. Todos os caminhos abaixo são relativos à raiz do repositório. Não adicione dependências nem arquitetura sem aprovação.

## Procedimento

1. Localize consumidores e testes antes de editar. Para navegação, leia `lib/app.dart`, `lib/core/constants/app_routes.dart` e `test/navigation_test.dart`; para widget compartilhado, localize todos os seus usos.
2. Reutilize `OrbitaTheme` e `Theme.of(context).textTheme`; preserve os contratos de `StudentIdCard`, `NoticeTile` e callbacks tipados. Não espalhe cópias da paleta nem crie wrappers Material redundantes.
3. Escolha `StatelessWidget` para apresentação sem estado próprio, como `HomeScreen`. Use `StatefulWidget` para interação local, como `ScheduleScreen` e `ProfileScreen`. Não introduza Provider/Riverpod/BLoC para uma mudança pontual.
4. Ao investigar overflow, reproduza largura/altura, escala de texto, teclado e mensagem de constraints. Use os testes em `test/migration_audit_test.dart` como referência; peça confirmação visual mobile.
5. Corrija a composição: `Expanded`/`Flexible` dentro de `Row` com largura finita, `Wrap` para pares quebráveis e rolagem para conteúdo/teclado. Consulte `next_class_card.dart` na feature Home, `MoreScreen` com `LayoutBuilder` e o formulário rolável do Login. Não use `Expanded` no eixo ilimitado de um scroll nem esconda conteúdo para evitar erro.
6. Preserve labels, tooltips e semântica. AV2 ausente deve ser anunciada como não informada; barras decorativas continuam excluídas da leitura assistiva. Não faça feedback depender só de cor.
7. Se possuir controllers, focus nodes, subscriptions ou timers, encerre-os em `dispose()`. O Login já libera `TextEditingController` e confere `mounted` após o `await`; preserve validação e bloqueio de submissão duplicada.
8. Mantenha as listas pequenas atuais em `Column`/`for` quando isso resolver o escopo. Para uma lista realmente longa/dinâmica, prefira `ListView.builder` sob constraints adequadas; essa é uma decisão contextual, não padrão já aplicado ao app todo.
9. Preserve fixtures e null safety: `Grade.average` exige AV2, status acadêmico vem da fixture, dinheiro exibido permanece string demonstrativa e domingo mapeia para sábado. Mudança dessas regras exige decisão própria.
10. Atualize/acrescente teste pequeno na suíte `flutter_test` para lógica/contrato alterado. Use avanço de tempo controlado e restaure viewport/teclado nos teardowns.
11. Formate arquivos editados e execute a sequência de `.ai/rules/qualidade.md`. Registre a necessidade de build/validação manual conforme o impacto.

## Firebase/Firestore — limite atual

Não há Firebase, Firestore ou serviços remotos em `pubspec.yaml`/`lib/`. Não crie integração, repositório vazio, código de inicialização ou regras de segurança por antecipação.

Se uma tarefa futura autorizar a integração, pergunte primeiro sobre serviços, ambientes, autenticação e contratos de dados. Só então planeje loading/erro, validação na fronteira, autorização no backend e descarte de listeners, sem embutir segredos ou alegar segurança por esconder a UI. Esses cuidados são condicionais, não arquitetura já existente.

## Critérios de parada e resultado

Pare para decidir negócio, dependência ou estrutura nova. Entregue o menor diff completo, testes pertinentes e resultados reais; não declare validação Android/iOS a partir do Web. Sem staging/commit/push automático; pergunte **“Aprova o commit?”**.
