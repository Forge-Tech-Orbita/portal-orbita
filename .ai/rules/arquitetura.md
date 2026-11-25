---
paths: ["lib/**", "pubspec.yaml", "pubspec.lock", "android/**", "ios/**", "web/**"]
---

# Arquitetura

## Estrutura

| Caminho | Responsabilidade |
| --- | --- |
| `lib/main.dart`, `lib/app.dart` | Inicialização Firebase em Android/iOS/Web, `MainApp`, sessão, tema e rotas |
| `lib/firebase_options.dart`, `firebase.json`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` | Configuração gerada pelo FlutterFire CLI para Android/iOS/Web; não edite manualmente |
| `lib/features/auth/data/`, `lib/core/models/student_profile.dart` | Autenticação Firebase, perfil por UID e invalidação de respostas antigas |
| `lib/features/grades/data/`, `lib/features/grades/presentation/` | Parser validado em runtime, consulta de notas por UID/semestre/curso e estados sem fallback |
| `lib/core/constants/institution_catalog.dart` | Instituições/cursos fictícios e conversão central de matrícula para e-mail técnico |
| `lib/core/constants/app_routes.dart` | Constantes `AppRoutes` |
| `lib/core/theme/orbita_theme.dart` | Cores do tema vintage e montagem do `ThemeData` |
| `lib/core/theme/orbita_colors.dart` | `OrbitaColors` (extensão de tema) e paletas Vintage, Básico, Forge Tech e UniSapiens |
| `lib/core/theme/orbita_theme_controller.dart` | Tema escolhido (`OrbitaThemeController`) e `OrbitaThemeScope` |
| `lib/core/models/`, `lib/core/mock/`, `lib/core/widgets/` | Modelos, fixtures e componentes compartilhados |
| `lib/features/<feature>/presentation/` | Telas e widgets exclusivos da feature |
| `lib/features/<feature>/data/` | Modelos e fixtures exclusivos, quando necessários |

- Siga arquivos irmãos; não crie camadas ou pastas vazias para uso futuro.
- Use modelos pequenos e imutáveis, com campos `final` e construtores `const`. Imports em `lib/` são relativos; testes usam `package:portal_orbita/...`.
- Compartilhe componentes por `core/`, sem importar internos de outra feature. Os modelos atuais podem depender de Flutter, como `ScheduledClass` com `Color`.

## Navegação e estado

- Registre rotas em `AppRoutes` e associe-as em `lib/app.dart`. Preserve `MaterialPageRoute<void>`, `RouteSettings` e fallback `Rota não encontrada`.
- Cada perfil tem uma casca com `IndexedStack`: aluno em `MainNavigationScreen` (Início, Horário, Notas, Cursos e Mais), professor em `ProfessorShell`, coordenação em `CoordinationShell` e portal administrativo em `AdminShell`. Troque o índice com `setState`, preservando estado e rolagem, sem empilhar rotas.
- Telas secundárias usam `Navigator.pushNamed`, `Scaffold`/`AppBar` próprios e não exibem barra inferior.
- O aluno exige sessão Firebase e perfil válido; curso nulo leva à escolha única. Mudanças de sessão recriam a pilha de navegação e limpam estado/tema do aluno. Professor/coordenação têm entradas explicitamente demonstrativas. O portal administrativo tem rotas próprias (`/admin`, `/admin/mfa`, `/admin/panel`) e continua simulado. Confira os testes de login, navegação, perfil e admin ao alterar esse contrato.
- Estado mutável é local em `StatefulWidget`/`setState`. `MainApp` mantém o tema em `OrbitaThemeScope` e a sessão em `AcademicSessionScope`, ambos com ciclo de vida e descarte definidos. Não introduza outro estado global, guards ou deep links fora do escopo aprovado.

## Dados e limites demonstrativos

- Firebase Auth e Firestore são usados para acesso do aluno, perfil `students/{uid}` e consulta de notas em `students/{uid}/grades` em Android/iOS/Web; o iOS usa o bundle ID `com.forgetech.plataformaorbita` e foi validado em iPhone físico. Instituição/matrícula são independentes do UID; curso só pode ser escolhido quando nulo. A consulta de notas usa servidor, semestre e curso do perfil, com validação de documentos, erro/vazio distintos e descarte de respostas antigas. Fixtures de notas são exclusivas de testes; os nove documentos de apresentação foram provisionados sem sobrescrita na S02. Regras de `list` do commit `1dd6d2d` publicadas, com `get` legado preservado; mudanças futuras exigem nova revisão e publicação autorizada. Validação remota exige token de aluno, não apenas releitura administrativa. Novos serviços, pacotes, SDK/lockfile e camadas exigem aprovação.
- A casca do aluno não exibe banner global de apresentação; os demais módulos continuam demonstrativos, conforme o README e os feedbacks das ações simuladas. Preserve o acesso demonstrativo de professor/coordenação separado do aluno, barras decorativas e feedback via `SnackBar`. Não reintroduza CRA, frequência global ou créditos sem fonte na apresentação do aluno. A busca da Biblioteca filtra empréstimos e acervo localmente. Switches de Perfil não persistem. A troca de tema é feita pelo seletor de tema do Perfil, mantida apenas em memória (volta ao vintage ao reiniciar).
- Valores financeiros são strings para exibição, não cálculo ou cobrança real.
- `Grade.average` só calcula com AV2 informada; status acadêmico vem do documento (ou fixture de teste), não da média. `summarizeGrades` usa somente médias completas e não representa CRA. `ScheduleDay.forDate` mapeia domingo para sábado. Não altere essas decisões silenciosamente.

## Plataformas

- `android/` usa Gradle Kotlin DSL e application ID `com.forgetech.plataformaorbita`. A assinatura debug de release deve ser substituída antes de distribuição de produção.
- `ios/Runner/` contém a inicialização nativa Flutter; preserve o registro de plugins.
- `web/index.html` carrega `flutter_bootstrap.js`; não implemente telas acadêmicas no bootstrap HTML.
- Altere arquivos nativos/bootstrap somente quando o pedido exigir e valide com a ferramenta da plataforma; análise Dart não os cobre. Não gere novas plataformas automaticamente.
