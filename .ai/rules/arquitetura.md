---
paths: ["lib/**", "pubspec.yaml", "pubspec.lock", "android/**", "ios/**", "web/**"]
---

# Arquitetura

## Estrutura

| Caminho | Responsabilidade |
| --- | --- |
| `lib/main.dart`, `lib/app.dart` | Inicialização de `MainApp`, `MaterialApp`, tema e rotas |
| `lib/core/constants/app_routes.dart` | Constantes `AppRoutes` |
| `lib/core/theme/orbita_theme.dart` | Paleta e `ThemeData` |
| `lib/core/models/`, `lib/core/mock/`, `lib/core/widgets/` | Modelos, fixtures e componentes compartilhados |
| `lib/features/<feature>/presentation/` | Telas e widgets exclusivos da feature |
| `lib/features/<feature>/data/` | Modelos e fixtures exclusivos, quando necessários |

- Siga arquivos irmãos; não crie camadas ou pastas vazias para uso futuro.
- Use modelos pequenos e imutáveis, com campos `final` e construtores `const`. Imports em `lib/` são relativos; testes usam `package:portal_orbita/...`.
- Compartilhe componentes por `core/`, sem importar internos de outra feature. Os modelos atuais podem depender de Flutter, como `ScheduledClass` com `Color`.

## Navegação e estado

- Registre rotas em `AppRoutes` e associe-as em `lib/app.dart`. Preserve `MaterialPageRoute<void>`, `RouteSettings` e fallback `Rota não encontrada`.
- Início, Horário, Notas, Cursos e Mais pertencem ao `IndexedStack` de `MainNavigationScreen`. Troque o índice com `setState`, preservando estado e rolagem, sem empilhar rotas.
- Telas secundárias usam `Navigator.pushNamed`, `Scaffold`/`AppBar` próprios e não exibem barra inferior.
- Login/logout limpam a pilha com `pushNamedAndRemoveUntil(..., (_) => false)`. Confira `test/navigation_test.dart` e `test/profile_test.dart` ao alterar esse contrato.
- Estado mutável é local em `StatefulWidget`/`setState`. Não introduza estado global, guards ou deep links fora do escopo aprovado.

## Dados e limites demonstrativos

- O app usa fixtures locais, sem backend, autenticação real ou persistência. Não crie integrações por antecipação; pacotes, SDK/lockfile e novas camadas exigem aprovação.
- Preserve login/biometria simulados de 900 ms, métricas fixas, busca passiva, barras decorativas e feedback via `SnackBar`. Switches de Perfil não persistem nem alteram o tema.
- Valores financeiros são strings para exibição, não cálculo ou cobrança real.
- `Grade.average` só calcula com AV2 informada; status acadêmico vem da fixture, não da média. `ScheduleDay.forDate` mapeia domingo para sábado. Não altere essas decisões silenciosamente.

## Plataformas

- `android/` usa Gradle Kotlin DSL. Application ID de template e assinatura debug de release devem ser substituídos antes de distribuição de produção.
- `ios/Runner/` contém a inicialização nativa Flutter; preserve o registro de plugins.
- `web/index.html` carrega `flutter_bootstrap.js`; não implemente telas acadêmicas no bootstrap HTML.
- Altere arquivos nativos/bootstrap somente quando o pedido exigir e valide com a ferramenta da plataforma; análise Dart não os cobre. Não gere novas plataformas automaticamente.
