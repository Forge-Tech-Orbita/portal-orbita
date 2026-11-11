---
paths: ["lib/**", "pubspec.yaml", "pubspec.lock", "android/**", "ios/**", "web/**"]
---

# Arquitetura observada

## Entrada e recursos compartilhados

| Caminho real | Responsabilidade |
| --- | --- |
| `lib/main.dart` | `runApp(const MainApp())`, sem inicialização de backend |
| `lib/app.dart` | `MaterialApp`, tema, rota inicial e `onGenerateRoute` com fallback |
| `lib/core/constants/app_routes.dart` | Constantes de rotas `AppRoutes` |
| `lib/core/theme/orbita_theme.dart` | Paleta e `ThemeData` claro |
| `lib/core/models/student.dart`, `lib/core/models/notice.dart` | Modelos compartilhados imutáveis |
| `lib/core/mock/student_mock.dart`, `lib/core/mock/notices_mock.dart` | Fixtures únicas de estudante e avisos |
| `lib/core/widgets/student_id_card.dart` | Carteirinha normal/compacta, usada em Home/Perfil |
| `lib/core/widgets/notice_tile.dart` | Aviso resumido/completo, usado em Home/Mural |
| `lib/core/widgets/decorative_barcode.dart` | Barras determinísticas decorativas, sem valor bancário |
| `lib/core/widgets/orbita_bottom_nav.dart` | Barra inferior de cinco abas e callback tipado |

## Funcionalidades

Em cada linha, o caminho da tela é `lib/features/<feature>/presentation/<arquivo>`.

| Feature | Tela / arquivo | Dados e widgets locais existentes |
| --- | --- | --- |
| `auth` | `LoginScreen` / `login_screen.dart` | Controllers/validação locais; sem serviço de autenticação |
| `navigation` | `MainNavigationScreen` / `main_navigation_screen.dart` | Índice local e `IndexedStack` |
| `home` | `HomeScreen` / `home_screen.dart` | `presentation/widgets/academic_stat_tile.dart`, `next_class_card.dart`, `quick_action_tile.dart` |
| `schedule` | `ScheduleScreen` / `schedule_screen.dart` | `data/schedule.dart`, `data/schedule_mock.dart` |
| `grades` | `GradesScreen` / `grades_screen.dart` | `data/grade.dart`, `data/grades_mock.dart`, `presentation/widgets/gpa_ring_progress.dart` |
| `courses` | `CoursesScreen` / `courses_screen.dart` | `data/course.dart`, `data/courses_mock.dart` |
| `more` | `MoreScreen` / `more_screen.dart` | Opções/rotas na própria tela |
| `financial` | `FinancialScreen` / `financial_screen.dart` | `data/financial.dart`, `data/financial_mock.dart` |
| `library` | `LibraryScreen` / `library_screen.dart` | `data/loan.dart`, `data/loans_mock.dart` |
| `notices` | `NoticesScreen` / `notices_screen.dart` | Reutiliza `core/mock/notices_mock.dart` e `NoticeTile` |
| `support` | `SupportScreen` / `support_screen.dart` | FAQs constantes locais na tela |
| `profile` | `ProfileScreen` / `profile_screen.dart` | Estudante compartilhado e switches locais |

A casca `navigation` não é uma décima segunda tela funcional: há Login, cinco abas e cinco secundárias. A auditoria contou 38 arquivos em `lib/`.

## Navegação e estado

- Defina rotas em `lib/core/constants/app_routes.dart` e associe-as em `lib/app.dart`. Valores existentes: `/`, `/main`, `/financial`, `/library`, `/notices`, `/support`, `/profile`.
- Preserve `MaterialPageRoute<void>` e `RouteSettings`; rota desconhecida exibe `Rota não encontrada`. Não invente guards, deep links ou autenticação por rota.
- Abas Início/Horário/Notas/Cursos/Mais pertencem ao `IndexedStack` de `MainNavigationScreen`. Alterná-las muda `selectedIndex` com `setState`, sem empilhar rotas.
- Secundárias abrem com `Navigator.pushNamed`, possuem `Scaffold`/`AppBar` próprios e não exibem barra inferior.
- Login/logout usam `pushNamedAndRemoveUntil(..., (_) => false)` para limpar a pilha. Preserve os contratos exercitados em `test/navigation_test.dart` e `test/profile_test.dart`.
- Estado mutável é local em `StatefulWidget`; não há Provider, Riverpod, BLoC, injeção de dependência ou store global. `ProfileScreen` não persiste switches e não altera o tema.

## Dados, limites e dependências

- Use classes pequenas com campos `final` e construtor `const`, como `Grade` e `Course`. Dados compartilhados ficam em `core/models`/`core/mock`; exclusivos ficam na `data/` já existente da feature.
- Imports relativos predominam em `lib/`; testes importam `package:portal_orbita/...`. Preserve a direção de uso: Perfil não deve importar componentes internos de Home.
- `ScheduledClass` contém `Color` e fixtures do horário referenciam `OrbitaTheme`. Não alegue camada de domínio independente de Flutter: ela não existe.
- Backend, serviços HTTP, repositórios, Firebase/Firestore e persistência **não existem**. `pubspec.yaml` só declara Flutter em produção; não crie integração ou pasta vazia para antecipar evolução.
- Preserve as simulações: login/biometria de 900 ms, valores financeiros como strings, busca passiva, métricas fixas, barras decorativas e feedback via `SnackBar`. Mudá-las para regras reais exige escopo e decisão próprios.
- Mantenha AV2 anulável e média somente quando ela existe em `lib/features/grades/data/grade.dart`. Situação vem da fixture, não da média. Domingo mapeia para sábado em `lib/features/schedule/data/schedule.dart`; não altere essas decisões silenciosamente.
- Não adicione pacote, mude SDK/lockfile ou crie camada/pasta raiz em `lib/` sem aprovação explícita.

## Plataformas

- `android/` usa Gradle Kotlin DSL e integração Flutter (`android/settings.gradle.kts`, `android/app/build.gradle.kts`). O application ID ainda é de template e release usa chave de debug: não faça distribuição de produção assim.
- `ios/Runner/AppDelegate.swift` inicializa o Flutter e registra plugins gerados. Não há integração Firebase nesse arquivo.
- `web/index.html` inicializa `flutter_bootstrap.js`; é plataforma Flutter ativa, não base HTML/CSS/JS para novas telas.
- Só altere arquivos nativos/bootstrap quando o escopo exigir; o analyzer Dart não valida essas alterações. Não gere novas plataformas automaticamente.
