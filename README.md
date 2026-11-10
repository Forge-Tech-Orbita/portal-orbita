# Portal Órbita

Aplicação Flutter migrada estruturalmente a partir do protótipo web legado mantido em `portal-orbita-antigo/` (`index.html`, `style.css` e `script.js`).

## Como executar

```bash
flutter pub get
flutter run
```

## Verificações e testes

```bash
flutter analyze
flutter test
flutter build web
```

## Estrutura de telas migradas (P01–P14)

- **Autenticação:**
  - `LoginScreen` (`/`): formulário demonstrativo com atraso simulado de 900 ms e atalho de biometria simulada.
- **Casca principal (`MainNavigationScreen` em `/main` com `IndexedStack` e `OrbitaBottomNav`):**
  1. `HomeScreen`: saudação por faixa de horário, carteirinha estudantil (`StudentIdCard`), métricas acadêmicas, próxima aula, atalhos rápidos e resumos do mural (`NoticeTile`).
  2. `ScheduleScreen`: grade semanal por dia (`SEG` a `SÁB`), com seleção preservada entre abas e fallback de domingo para sábado.
  3. `GradesScreen`: resumo de CRA com anel determinístico (`GpaRingProgress`), filtros (`Todas`, `Cursando`, `Concluídas`) e cards expansíveis com AV1, AV2, frequência e situação.
  4. `CoursesScreen`: lista de disciplinas do semestre `2026.2` com professor, créditos, progresso e sala.
  5. `MoreScreen`: grade de acesso às cinco telas secundárias e encerramento de sessão.
- **Rotas secundárias (`Scaffold` e `AppBar` próprios, sem barra inferior):**
  - `FinancialScreen` (`/financial`): fatura em aberto, código de barras decorativo (`DecorativeBarcode`), botão demonstrativo de 2ª via e histórico de pagamentos.
  - `LibraryScreen` (`/library`): campo de busca e categorias demonstrativas e lista de empréstimos com destaque de prazo.
  - `NoticesScreen` (`/notices`): mural completo compartilhando a mesma fixture de avisos da Home.
  - `SupportScreen` (`/support`): card da secretaria com abertura demonstrativa de chamado e perguntas frequentes (FAQ).
  - `ProfileScreen` (`/profile`): carteirinha compacta compartilhada, dados cadastrais mascarados, switches locais de preferências demonstrativas e encerramento de sessão limpando a pilha.

## Recursos simulados e limitações desta etapa

- **Sem backend ou persistência:** todos os dados (estudante, aulas, notas, disciplinas, faturas, empréstimos e comunicados) vêm de fixtures locais imutáveis.
- **Login e biometria:** validam apenas o preenchimento dos campos e aguardam 900 ms localmente; não há autenticação remota nem leitura biométrica do dispositivo.
- **Métricas, CRA e próxima aula:** valores (`CRA 8.7`, `94%`, `142 créditos`, legenda `18/5/0` e `"em 47 min"`) são fixtures estáticas do protótipo, sem recálculo acadêmico ou timer regressivo.
- **Financeiro e Suporte:** os botões *"Gerar 2ª via"* e *"Abrir novo chamado"* exibem apenas feedback via `SnackBar` (`"Recurso demonstrativo, sem integração"`). O código de barras é determinístico e sem valor bancário.
- **Biblioteca:** o campo de busca e os chips de categoria são demonstrativos e não filtram nem consultam acervo real.
- **Preferências do Perfil:** os switches (*Notificações push*, *Modo escuro* e *Biometria facial*) alteram apenas o estado visual na instância da tela, sem persistência, permissões nativas ou troca do tema claro da aplicação.

## Próximas etapas previstas

1. **Fidelidade visual (`style.css`):** tipografia externa, texturas, sombras finas, gradientes, responsividade refinada e animações decorativas.
2. **Comportamento complementar (`script.js`):** relógio/saudação contínua e refinamentos adicionais de interação.
3. **Evolução além do protótipo:** integração com APIs, autenticação real, regras acadêmicas dinâmicas, busca de acervo e persistência de preferências.

