# Portal Órbita — plano refinado de migração estrutural para Flutter

> Plano geral de referência para execução por Sol medium.
> Documento: `.plan/geral/plano-migracao-index-html.md`.
> Fontes: `portal-orbita-antigo/index.html`, `style.css` e `script.js`.
> Status: P01 concluída; partes P02–P14 pendentes.
> Esta versão substitui o planejamento estrutural original e deve ser executada uma parte por vez.

## 1. Objetivo e limites

Converter as 11 telas do protótipo HTML em uma aplicação Flutter com navegação nativa, widgets reutilizáveis, conteúdo demonstrativo e interações locais mínimas necessárias para validar a estrutura.

Não usar WebView, não copiar a moldura de celular, notch, relógio ou bateria simulados. Usar `Scaffold`, `SafeArea`, rolagem e controles Flutter.

Este plano continua sendo a etapa estrutural derivada do HTML. Consultar o CSS e o JavaScript desde o início para não perder conteúdo e comportamento, mas NÃO antecipar toda a migração desses arquivos.

### Incluído nesta etapa

- As 11 telas e seus elementos de conteúdo.
- Cinco abas principais e cinco rotas secundárias, além do Login.
- Login demonstrativo, logout, retorno, seleção de dias, filtros e expansão de notas.
- Dados mockados mínimos e tipados para renderizar as telas.
- Paleta básica do legado e componentes legíveis/adaptáveis.
- Testes de widgets e testes unitários onde houver cálculo ou seleção.

### Fora desta etapa

- Backend, API, banco de dados, autenticação real e armazenamento de credenciais.
- Biometria real, notificações push, emissão/pagamento de boletos e criação de chamados.
- Busca real no acervo, dados de ISBN inexistentes ou renovação de empréstimos.
- Persistência de preferências, modo escuro funcional e estado global de conta.
- Reprodução visual exata: fontes externas, texturas, sombras finas, gradientes, efeito tilt e animações decorativas.
- Cálculo real de CRA, calendário acadêmico ou contagem regressiva da próxima aula.
- Novos pacotes, arquitetura de repositórios/serviços ou bibliotecas de estado/rotas sem aprovação específica.

## 2. Regra principal: execução por partes e um commit por parte

**Executar somente UMA parte por solicitação. Não executar o plano inteiro automaticamente.**

Cada parte é uma entrega pequena que deve compilar e passar nas verificações, mesmo quando outras telas ainda forem placeholders. A sequência padrão é P01 até P14. Não assumir que uma parte anterior foi feita apenas porque está marcada: conferir seus arquivos e testes.

Para cada parte:

1. Ler este plano, o status compartilhado, os arquivos de origem indicados e a implementação atual relacionada.
2. Verificar `git status --short` e identificar trabalho preexistente. Não alterar, reverter nem incluir trabalho de terceiros no commit.
3. Confirmar dependências e reservar a parte no plano geral, indicando responsável e estado `em andamento`.
4. Registrar o roteiro individual em `.plan/local/<integrante>/Pxx.md`, somente em modo de implementação e quando autorizado pelas instruções da sessão. O plano local não substitui o status compartilhado.
5. Implementar apenas o escopo da parte, incluindo os testes especificados.
6. Executar as verificações da seção 8 e revisar `git diff` e `git diff --cached`.
7. Atualizar o status geral e registrar verificações realmente executadas. Não marcar como concluído se houver falha ou bloqueio.
8. Fazer **um commit exclusivo dessa parte**, com os arquivos da implementação, seus testes e a atualização correspondente do plano geral. Adicionar arquivos por caminhos explícitos; não usar `git add .` ou `git add -A`.
9. Informar ao usuário: parte concluída, arquivos principais, verificações, limitações e hash do commit. Então PARAR e aguardar a próxima solicitação.

Se instruções da sessão proibirem commits ou alterações, não contornar a restrição: informar o bloqueio. Não criar commit com testes falhando, salvo autorização expressa do usuário. Falha de ferramenta/SDK também deve ser comunicada, sem alegar validação inexistente.

### Padrão de commits

O histórico existente usa Conventional Commits. Manter:

```text
<tipo>(<escopo>): <resumo curto em português>
```

Tipos desta migração: `feat` para funcionalidades/telas, `test` para consolidação de testes e `docs` para publicação exclusiva de planejamento. Sem ponto final, sem misturar partes e sem amend/rebase de commits de outros integrantes. As mensagens propostas em cada parte já seguem esse formato.

O hash do commit pode ser informado no relatório final ou registrado numa atualização futura; não alterar o plano depois do commit apenas para adicionar o próprio hash e gerar um segundo commit.

### Situação observada ao elaborar este plano

- Flutter inicial: `lib/main.dart` contém apenas `MainApp` com `Hello World!`.
- `pubspec.yaml`: somente Flutter como dependência de produção; `flutter_test` e `flutter_lints` em desenvolvimento.
- Não foi encontrado `AGENTS.md` na árvore consultada. Verificar novamente na execução.
- Havia alteração preexistente em `.gitignore` e `.plan/` estava não rastreado. Reavaliar o status antes de cada entrega; esta observação não autoriza incluir essas alterações indiscriminadamente.
- `.gitignore` contém `.plan/local`: não forçar a inclusão de planos individuais no Git.

## 3. Decisões técnicas fechadas para esta etapa

### 3.1 Navegação

- `MainApp` permanece o widget raiz público, definido em `lib/app.dart`; `main.dart` apenas importa o app e chama `runApp(const MainApp())`.
- Usar `MaterialApp` com `initialRoute: AppRoutes.login` e `onGenerateRoute`. Não usar `home` simultaneamente.
- Constantes em `lib/core/constants/app_routes.dart`:
  - `login = '/'`
  - `main = '/main'`
  - `financial = '/financial'`
  - `library = '/library'`
  - `notices = '/notices'`
  - `support = '/support'`
  - `profile = '/profile'`
- `onGenerateRoute` associa exclusivamente essas rotas às telas correspondentes, usando `MaterialPageRoute` e preservando `RouteSettings`. Rota desconhecida deve mostrar uma página simples de rota não encontrada, sem ser interpretada como sessão autenticada.
- `MainNavigationScreen`, um `StatefulWidget`, mantém `selectedIndex` com `setState` e mostra as cinco abas em `IndexedStack`, nesta ordem: Início, Horário, Notas, Cursos, Mais.
- `OrbitaBottomNav` recebe `currentIndex` e `ValueChanged<int> onTap`; usar `BottomNavigationBar` com tipo fixo para exibir as cinco opções.
- Abas não geram rotas ou entradas extras na pilha. O `IndexedStack` preserva o estado local ao trocar de aba.
- Telas secundárias abrem com `Navigator.pushNamed` sobre a casca principal. Cada uma tem seu próprio `Scaffold` e `AppBar` com retorno; a barra inferior não aparece nelas.
- Login bem-sucedido: `pushNamedAndRemoveUntil(AppRoutes.main, (_) => false)`.
- Logout: `pushNamedAndRemoveUntil(AppRoutes.login, (_) => false)`. Voltar não deve recuperar telas da sessão anterior.
- Não criar lista manual de histórico como a do JavaScript. Não implementar proteção de rotas ou deep links nesta etapa.

### 3.2 Estado e dados

- Usar estado local com `StatefulWidget`/`setState`, sem Provider, Riverpod, BLoC ou singleton mutável.
- Listas demonstrativas devem usar pequenas classes Dart imutáveis com campos tipados; não usar mapas dinâmicos nem espalhar acesso por strings nas telas.
- Dados compartilhados de estudante e avisos ficam em `core/models/` e `core/mock/`; dados exclusivos de uma funcionalidade ficam em `features/<feature>/data/`.
- Criar classes e fixtures somente quando a parte correspondente precisar delas. Não montar uma camada de domínio abstrata antecipadamente.
- Não duplicar dados compartilhados: Home e Perfil usam o mesmo estudante; Home e Mural usam a mesma lista de avisos.
- Datas, valores, contagens e nomes são demonstrativos, não devem ser atualizados para a data atual por iniciativa do executor.
- Não criar rede, arquivos de persistência, permissões de dispositivo ou serviços externos.

### 3.3 Apresentação mínima

- `lib/core/theme/orbita_theme.dart` fornece um `ThemeData` claro com: fundo `#F6F1E3`, superfície `#FBF8EF`, borda `#DECBA0`, texto `#2B2A22`, destaque `#2F6F68`, terracota `#A6543B`, verde `#5B7F3A`, âmbar `#C98A2E` e alerta `#AF3B2E`.
- Não instalar fontes/pacotes nem baixar assets. Fontes padrão do Flutter são temporárias até o plano visual.
- Ícones podem ser equivalentes Material; o símbolo orbital usa desenho simples com `CustomPainter`, sem pacote SVG.
- Usar `AppBar` padrão nas rotas secundárias: não criar um `OrbitaTopBar` redundante nesta etapa.
- Não usar altura fixa de dispositivo. Evitar larguras rígidas em textos; usar `Expanded`, `Flexible` e `Wrap` onde necessário.
- Conteúdo deve funcionar em 360 × 800 e 390 × 844; testar também 360 × 640 com teclado no Login. Em larguras maiores, admitir composição simples e legível, sem criar layout desktop fora do escopo.
- Usar controles interativos acessíveis (`IconButton`, botões, chips, `SwitchListTile`), labels e tooltips onde aplicável.

## 4. Fontes da verdade e divergências conhecidas

| Informação | Fonte / decisão |
| --- | --- |
| Estrutura e textos das 11 telas | `index.html`, seções identificadas por `screen-*` |
| Paleta inicial | variáveis de `style.css`, bloco `:root` |
| Dias/aulas, notas e disciplinas | arrays `schedule`, `grades`, `courses` de `script.js` |
| Estudante | Marina Duarte Costa, matrícula 2023104567, Engenharia de Software, 6º período, validade 12/2027 |
| Métricas | CRA 8.7, frequência 94%, créditos 142: fixtures, não resultados calculados |
| Resumo de notas | 18 aprovadas, 5 cursando, 0 pendentes: fixtures independentes da pequena lista de exemplo |
| Próxima aula | Inteligência Artificial, sala 304/bloco C, Prof. R. Nakamura, 19:00, “em 47 min”: conteúdo fixo |
| Login | atraso simulado de 900 ms; não valida credenciais em backend |
| Biometria | atalho para a mesma simulação de login, com indicação explícita de demonstração |
| Biblioteca | busca e categorias não têm lógica no legado; não inventar acervo ou ISBN |
| Financeiro/Suporte | botões não têm implementação no legado; feedback “Recurso demonstrativo, sem integração” via `SnackBar` |
| Preferências | switches apenas mudam o próprio estado em memória; não ativam tema, push ou biometria real |
| Código de barras | decoração sem valor bancário; desenho determinístico, sem `Random` em `build` |

Regras adicionais para evitar interpretações incorretas:

- O HTML contém cinco abas, cinco telas secundárias e Login: 11 telas no total. A casca `MainNavigationScreen` é infraestrutura, não uma décima segunda funcionalidade.
- “Cursos” é o rótulo da aba; a tela apresenta “Minhas disciplinas”. Não criar catálogo de cursos.
- O Perfil não possui botão voltar no HTML, mas será uma rota secundária com `AppBar` e retorno no Flutter, conforme a intenção do plano original.
- O JavaScript trata domingo como sábado no seletor de dias. Nesta etapa, preservar esse fallback e documentá-lo no teste; não criar uma coluna de domingo ou calendário novo.
- A média só existe quando AV2 não é nula: `(av1 + av2) / 2`, exibida com uma casa decimal. AV2 ausente aparece como “—”; não tratá-la como zero.
- O legado marca Banco de Dados II como concluída/aprovada apesar da média 6.75, exibida como 6.8. Preservar status e regra visual existentes; não implementar regulamento acadêmico nem corrigir os mocks silenciosamente.
- A lista de avisos da Home usa resumo diferente do texto completo em alguns itens. O modelo pode ter `summary` e `body`; transcrever cada um da sua fonte sem inventar conteúdo.
- O CRA e a legenda não devem ser recalculados usando apenas as cinco notas demonstrativas. Progresso do anel pode representar 8.7/10; não alegar cálculo acadêmico real.
- Não inventar linha digitável bancária, CPF completo, telefone completo, credenciais válidas, histórico adicional ou novos recursos.

## 5. Organização esperada

Criar arquivos conforme necessários, não todos antecipadamente exceto os placeholders de navegação da P01.

```text
lib/
  main.dart
  app.dart
  core/
    constants/app_routes.dart
    theme/orbita_theme.dart
    models/                       # Student e Notice, introduzidos na P03
    mock/                         # fixtures compartilhadas, introduzidas na P03
    widgets/
      orbita_bottom_nav.dart
      student_id_card.dart         # compartilhado entre Home e Perfil
      notice_tile.dart             # compartilhado entre Home e Mural
  features/
    navigation/presentation/main_navigation_screen.dart
    auth/presentation/login_screen.dart
    home/presentation/home_screen.dart
    home/presentation/widgets/     # NextClassCard, AcademicStatTile, QuickActionTile
    schedule/data/                # modelo e fixtures de aulas
    schedule/presentation/schedule_screen.dart
    grades/data/                  # modelo e fixtures de notas
    grades/presentation/grades_screen.dart
    grades/presentation/widgets/gpa_ring_progress.dart
    courses/data/                 # modelo e fixtures de disciplinas
    courses/presentation/courses_screen.dart
    more/presentation/more_screen.dart
    financial/data/               # apenas dados/modelos necessários à tela
    financial/presentation/financial_screen.dart
    library/data/                 # empréstimos demonstrativos
    library/presentation/library_screen.dart
    notices/presentation/notices_screen.dart
    support/presentation/support_screen.dart
    profile/presentation/profile_screen.dart
test/
  ...                             # organização correspondente ao código testado
```

Contratos mínimos compartilhados:

- Todas as telas: construtor público `const NomeDaScreen({super.key})`, lendo fixtures locais, sem argumentos de rota obrigatórios.
- `StudentIdCard`: recebe `Student student` e `bool compact = false`. A versão compacta omite matrícula/validade/código decorativo como no Perfil original.
- `NoticeTile`: recebe `Notice notice` e `bool compact = false`. Home usa resumo; Mural usa corpo, categoria e data.
- Widgets menores recebem somente os dados/callbacks necessários, sem navegar ou buscar dados implicitamente quando isso não for sua responsabilidade.
- Manter os nomes das telas descritos nas partes abaixo. Não renomear arquivos ou contratos de outra parte sem justificar e coordenar.

## 6. Partes executáveis

Cada parte inclui implementação, testes, atualização de status e **seu único commit**. Os testes abaixo são mínimos, não uma substituição das verificações gerais.

### P01 — Fundação e navegação completa com placeholders

**Dependência:** nenhuma.
**Ler:** `main.dart`, `pubspec.yaml`, HTML de `bottomnav`, `go`, `goBack` e `doLogin` no JavaScript.

- Criar `app.dart`, constantes de rota, tema básico, `MainNavigationScreen` e `OrbitaBottomNav` conforme a seção 3.
- Criar os 11 arquivos de tela com construtores definitivos e conteúdo temporário identificado como placeholder.
- Login temporário tem botão para entrar; Mais temporário oferece cinco atalhos secundários e logout para testar a pilha. Estes controles serão substituídos em P02/P08.
- Rotas secundárias já possuem `Scaffold`/`AppBar` próprios, sem barra inferior.
- Não implementar os detalhes das telas posteriores.

**Aceite/testes:** app inicia no Login; entrar abre Início; as cinco abas alternam sem empilhar; cada atalho de Mais abre a rota correta e volta à aba de origem; logout limpa a pilha; rota desconhecida tem fallback explícito. `flutter analyze` e `flutter test` passam.

**Commit:** `feat(navigation): criar estrutura e rotas do portal`

### P02 — Login demonstrativo

**Dependência:** P01.
**Ler:** HTML `screen-login`, JavaScript `doLogin`.

- Substituir o placeholder por logotipo orbital simples, título, subtítulo, formulário e rodapé institucional.
- Matrícula e senha começam com valores demonstrativos equivalentes aos do legado. Senha usa `obscureText`; nunca registrar seu conteúdo em logs.
- Validar somente campos obrigatórios; não inventar tamanho de matrícula ou política de senha.
- Simular espera de 900 ms; mostrar “AUTENTICANDO...”, bloquear disparos duplicados e navegar conforme P01.
- Atalho de biometria segue a mesma simulação, com texto/tooltip que informe que não há biometria real.
- Usar formulário rolável e liberar controllers; após operações assíncronas, verificar `mounted` antes de acessar contexto/estado.

**Aceite/testes:** vazio exibe erro e não navega; valores demonstrativos permitem entrar; loading impede novo envio; biometria simulada entra; teclado não causa overflow no viewport mínimo. Testes controlam o avanço dos 900 ms sem espera real.

**Commit:** `feat(auth): portar login demonstrativo para flutter`

### P03 — Dados e widgets compartilhados

**Dependência:** P01.
**Ler:** carteirinhas de Home/Perfil; mural recente e `screen-notices`; dados cadastrais do HTML.

- Criar modelos imutáveis `Student` e `Notice` e respectivas fixtures compartilhadas.
- Transcrever os quatro avisos e os três resumos de Home; manter identificação/categoria consistentes.
- Implementar `StudentIdCard` normal/compacto e `NoticeTile` normal/compacto conforme contratos da seção 5.
- A carteirinha normal exibe instituição, iniciais, nome, curso/período, matrícula e validade. Código de barras é apenas decorativo e determinístico.
- Compartilhar os widgets em `core/widgets/`; não fazer Perfil importar widgets internos de Home.

**Aceite/testes:** versões normal/compacta exibem seus campos corretos; estudante é o mesmo nos dois usos; resumo e corpo de um aviso podem ser diferentes; textos longos não geram overflow em largura de 360 px.

**Commit:** `feat(shared): criar carteirinha e avisos reutilizaveis`

### P04 — Início / dashboard

**Dependências:** P02 e P03.
**Ler:** HTML `screen-home`; JavaScript `updateClock`, somente para a regra da saudação.

- Implementar `HomeScreen` rolável e widgets locais `AcademicStatTile`, `NextClassCard` e `QuickActionTile`.
- Saudação por horário: antes de 12h “Bom dia”, antes de 18h “Boa tarde”, demais “Boa noite”. Calcular na construção da tela; relógio/timer contínuo fica fora desta etapa.
- Exibir nome curto, sino, carteirinha, métricas 8.7/94%/142, próxima aula fixa e quatro atalhos.
- Sino, “ver tudo” e Avisos abrem `AppRoutes.notices`; demais atalhos abrem Financeiro, Biblioteca e Suporte.
- Usar os três avisos resumidos compartilhados.

**Aceite/testes:** todos os blocos existem; atalhos/sino/ver tudo abrem destinos corretos; voltar restaura Home; próxima aula continua explicitamente mockada, sem countdown real.

**Commit:** `feat(home): portar painel inicial do aluno`

### P05 — Horário semanal

**Dependências:** P01 e P04, seguindo a sequência padrão.
**Ler:** HTML `screen-schedule`; JavaScript `schedule`, `dayNames`, `dayKeys`, `selectDay` e `renderClasses`.

- Criar modelo tipado e fixtures com todas as aulas do array, sem alterar professores, salas ou horários.
- Chips horizontais SEG, TER, QUA, QUI, SEX e SÁB; selecionar inicialmente pelo dia atual, preservando fallback de domingo para sábado.
- Seleção atualiza a lista; sábado exibe estado “Sem aulas em Sábado”.
- Manter o dia selecionado ao trocar de aba via `IndexedStack`.

**Aceite/testes:** segunda tem duas aulas; terça uma; sábado vazio; domingo mapeia para sábado; seleção persiste ao sair/voltar à aba. Testes definem o dia/seleção explicitamente, sem depender da data da máquina.

**Commit:** `feat(schedule): portar horario semanal e selecao de dias`

### P06 — Notas e frequência

**Dependência:** P05 na sequência padrão.
**Ler:** HTML `screen-grades`; JavaScript `grades`, `renderGrades` e `filterGrades`.

- Criar modelo de nota com AV2 anulável e status explícito; copiar as cinco entradas do legado.
- Exibir CRA fixo 8.7, anel simples e legenda fixa 18/5/0.
- Filtros Todas, Cursando e Concluídas; cards expansíveis com AV1, AV2, frequência e situação.
- Calcular média apenas com as duas avaliações; uma casa decimal. Se média >= 7 usar destaque positivo; abaixo de 7 usar alerta. AV2 nula usa “Cursando” e traço no detalhe.
- Mostrar situação conforme fixture, sem deduzir aprovação da média. Ao trocar filtro, cards podem voltar fechados como no legado.

**Aceite/testes:** filtros retornam 5/1/4 itens; expansão mostra avaliações/frequência; 8.5 e 9.0 geram média exibida 8.8; AV2 nula não vira zero; Banco de Dados II mantém situação demonstrativa original. Testar cálculo separadamente.

**Commit:** `feat(grades): portar notas filtros e detalhes de avaliacao`

### P07 — Disciplinas

**Dependência:** P06 na sequência padrão.
**Ler:** HTML `screen-courses`; JavaScript array `courses`.

- Criar modelo e fixtures das cinco disciplinas.
- Exibir semestre 2026.2, nome, professor, créditos, progresso e sala de cada entrada.
- Progresso visual usa `prog / 100`; não criar detalhe de disciplina, edição ou catálogo.

**Aceite/testes:** cinco cards; valores correspondem ao array; barra de Arquitetura representa 78%; conteúdo pode ser alcançado por rolagem sem overflow.

**Commit:** `feat(courses): portar lista de disciplinas do semestre`

### P08 — Mais opções

**Dependência:** P07 na sequência padrão.
**Ler:** HTML `screen-more`.

- Substituir atalhos provisórios pela grade Financeiro, Biblioteca, Mural, Perfil, Suporte e Sair.
- Manter rótulos e descrições do legado; não adicionar configurações extras.
- Usar as rotas existentes. Sair limpa a pilha conforme P01.

**Aceite/testes:** seis opções presentes; os cinco destinos abrem sem barra inferior; voltar retorna à aba Mais; após Sair, voltar não restaura sessão.

**Commit:** `feat(more): portar menu de opcoes e encerramento de sessao`

### P09 — Financeiro

**Dependência:** P08 na sequência padrão.
**Ler:** HTML `screen-financial`.

- Exibir alerta de fatura em aberto, mensalidade de setembro, vencimento 10/09/2026, valor R$ 1.240,00 e desconto R$ 62,00.
- Exibir histórico de maio a agosto/2026, cada um pago por R$ 1.178,00, mantendo a ordem do HTML.
- Usar código decorativo determinístico, sem linha digitável válida nem geração de arquivo.
- “Gerar 2ª via” mostra feedback demonstrativo, sem download, HTTP ou alteração de pagamento.

**Aceite/testes:** valores/datas corretos; quatro pagamentos; botão informa ausência de integração; voltar retorna à origem da navegação.

**Commit:** `feat(financial): portar fatura e historico demonstrativos`

### P10 — Biblioteca

**Dependência:** P09 na sequência padrão.
**Ler:** HTML `screen-library`.

- Exibir campo com hint “Buscar título, autor ou ISBN...” e categorias Todos, Exatas, Computação, Humanas, Periódicos.
- Campo e categorias são apresentação nesta etapa: indicar “Busca e categorias demonstrativas” e não prometer filtragem real. Não acrescentar ISBN ou categorias aos livros por inferência.
- Exibir os três empréstimos: Estruturas de Dados e Algoritmos / T. Cormen / 2 dias; Arquitetura Limpa / R. C. Martin / 12 dias; Redes Neurais e Deep Learning / I. Goodfellow / 18 dias.
- Prazo de 2 dias usa destaque de alerta. Não inventar datas de retirada/devolução nem renovação.

**Aceite/testes:** três empréstimos e prazos corretos; indicação de demonstração visível; nenhum filtro ou resultado real é alegado; campo não causa overflow com teclado.

**Commit:** `feat(library): portar emprestimos e estrutura da biblioteca`

### P11 — Mural de avisos

**Dependências:** P03 e P10 na sequência padrão.
**Ler:** HTML `screen-notices` e fixtures compartilhadas já existentes.

- Renderizar quatro avisos com `NoticeTile` completo: título, categoria, corpo e data textual demonstrativa.
- Manter Hoje · 08:12, Ontem · 17:40, 2 dias atrás e 4 dias atrás como textos mockados, não datas recalculadas.
- Não criar leitura/não leitura, detalhes de aviso ou atualização remota.

**Aceite/testes:** quatro avisos na ordem do HTML; resumos da Home correspondem aos mesmos IDs; navegação funciona tanto pela Home quanto por Mais, retornando à origem correta.

**Commit:** `feat(notices): portar mural com comunicados compartilhados`

### P12 — Central de suporte

**Dependência:** P11 na sequência padrão.
**Ler:** HTML `screen-support`.

- Exibir card de secretaria com descrição, botão “Abrir novo chamado” e três FAQs originais.
- Botão mostra feedback demonstrativo, sem formulário, envio ou registro de protocolo.
- FAQ pode ser texto simples; não inventar fluxo de atendimento ou navegação pelo texto das respostas.

**Aceite/testes:** três perguntas e respostas presentes; botão informa ausência de integração; conteúdo rolável e retorno preservado.

**Commit:** `feat(support): portar central de ajuda e perguntas frequentes`

### P13 — Perfil e preferências locais

**Dependências:** P03 e P12 na sequência padrão.
**Ler:** HTML `screen-profile`.

- Usar `StudentIdCard` compacto com a fixture compartilhada; exibir CPF/telefone mascarados e e-mail institucional exatamente como no legado.
- Switches: Notificações push inicialmente ligado, Modo escuro inicialmente ligado e Biometria facial inicialmente desligado, conforme HTML.
- Preservar esses estados visuais sem ativar recursos reais; mostrar indicação explícita de que são preferências demonstrativas. O tema do app continua claro.
- Estado vive somente na instância da tela e pode reiniciar ao fechar/reabrir; não implementar persistência.
- Botão “Encerrar sessão” limpa a pilha, inclusive se Perfil foi aberto sobre outra rota.

**Aceite/testes:** dados mascarados corretos; switches alternam independentemente; não alteram tema nem pedem permissões; logout leva ao Login sem retorno à sessão.

**Commit:** `feat(profile): portar perfil e preferencias demonstrativas`

### P14 — Auditoria e testes da migração estrutural

**Dependências:** P01–P13 concluídas.
**Ler:** todas as caixas de aceite deste plano e as 11 seções HTML.

- Acrescentar teste de fluxo representativo: Login → Home → Horário/Notas/Disciplinas/Mais → secundária → retorno → Perfil → logout.
- Confirmar as 11 telas implementadas e remover somente placeholders introduzidos por esta migração.
- Testar preservação de estado das abas e pilha de retorno/encerramento de sessão.
- Acrescentar verificações de layout nos viewports mínimos; verificar Login com teclado e listas com rolagem. Não tratar ausência de exceções como prova de fidelidade visual total.
- Atualizar README com execução, testes e lista clara de recursos simulados e etapas ainda pendentes.
- Executar build Web de fumaça, se o ambiente suportar. Android/iOS dependem de SDKs disponíveis; não instalar ferramentas ou alterar configurações nativas sem aprovação.
- Se aparecer defeito pequeno da migração, corrigir e testar nesta parte. Se exigir funcionalidade nova, arquitetura ou retrabalho amplo, registrar bloqueio e discutir antes de expandir o escopo.

**Aceite:** todos os testes passam, análise sem novos problemas, nenhuma tela de placeholder, limitações documentadas e build Web verificado ou bloqueio técnico explicitamente informado. Pendência de validação impede marcar a etapa como totalmente validada.

**Commit:** `test(migration): validar fluxos e documentar limites do prototipo`

## 7. Organização entre integrantes

- A ordem P01–P14 é o caminho padrão para um executor individual. Uma solicitação pode selecionar uma parte posterior somente se as dependências técnicas já existirem.
- Dependências “na sequência padrão” organizam a execução, mas não significam dependência de código entre funcionalidades independentes.
- Trabalho simultâneo exige combinar explicitamente responsáveis e dependências; não autoriza disparar subagentes automaticamente.
- P01 e P03 definem os contratos compartilhados antes de dividir telas.
- Após P01/P03, telas independentes podem ser distribuídas, desde que Login esteja disponível para validar o fluxo e cada integrante trabalhe em arquivos próprios.
- Reservar arquivos compartilhados (`app.dart`, rotas, fixtures, tema e plano geral) e coordenar atualizações. Não editar contrato compartilhado silenciosamente.
- Não duplicar widgets ou mocks para evitar combinar mudanças. Se o contrato estiver insuficiente, discutir a alteração.
- Cada parte mantém seu commit próprio também no trabalho em equipe. Não juntar entregas diferentes num único commit.

### Quadro de acompanhamento inicial

Estados permitidos: `pendente`, `em andamento`, `bloqueada`, `concluída`.

| Parte | Entrega | Estado | Responsável | Validação / observação |
| --- | --- | --- | --- | --- |
| P01 | Fundação/navegação | concluída | Sol | Análise sem problemas; 12 testes aprovados em 27/10/2026 |
| P02 | Login | pendente | — | — |
| P03 | Compartilhados | pendente | — | — |
| P04 | Home | pendente | — | — |
| P05 | Horário | pendente | — | — |
| P06 | Notas | pendente | — | — |
| P07 | Disciplinas | pendente | — | — |
| P08 | Mais | pendente | — | — |
| P09 | Financeiro | pendente | — | — |
| P10 | Biblioteca | pendente | — | — |
| P11 | Avisos | pendente | — | — |
| P12 | Suporte | pendente | — | — |
| P13 | Perfil | pendente | — | — |
| P14 | Auditoria | pendente | — | — |

### Resultado da P01 — 27/10/2026

- Criados app, rotas, tema claro, barra inferior fixa, casca com `IndexedStack` e as 11 telas provisórias.
- Login demonstrativo e Sair limpam a pilha; as cinco secundárias abrem sem barra inferior e retornam à aba Mais; rotas desconhecidas exibem fallback.
- Ambiente conferido: Flutter 3.47.7 e Dart 3.13.5; `flutter pub get` concluído, sem novos pacotes ou alteração do lockfile.
- `dart format` executado nos 18 arquivos Dart da entrega; `flutter analyze` sem problemas e `flutter test` com 12 testes aprovados.
- Testes de layout da estrutura executados em 360 × 800, 390 × 844 e 360 × 640, sem exceções de overflow.
- `git diff --check` e revisão dos diffs realizados antes do commit; alterações preexistentes fora do escopo não incluídas.
- Não houve teste manual em dispositivo, build Android/iOS/Web ou validação de fidelidade visual. As telas ainda são placeholders; formulário e simulação de espera pertencem à P02.
- Próxima parte: P02, somente após confirmação do usuário.

## 8. Verificações obrigatórias de cada parte

Executar no diretório do projeto, sem alterar ou formatar o legado:

```text
flutter --version
flutter pub get
dart format <arquivos Dart criados ou alterados na parte>
flutter analyze
flutter test
git diff --check
git diff
git diff --cached
```

- Conferir a versão do Flutter/Dart pelo SDK instalado e pelo `pubspec.yaml`; não inventar versão, atualizar SDK ou alterar restrição para contornar erro sem aprovação.
- `flutter pub get` não autoriza novos pacotes. Investigar mudanças inesperadas no lockfile antes de incluí-las.
- `dart format` recebe caminhos explícitos da parte; não reformatar trabalho alheio.
- Testes de widgets usam `flutter_test`, `pumpWidget`, `pump`/`pumpAndSettle` e interações reais com os controles. Não usar apenas comparação de snapshots nem testar somente construtores.
- Para telas longas, rolar antes de procurar/tocar componentes fora da área visível.
- Não usar `pumpAndSettle` com animação infinita; preferir indicador estático do anel de CRA e avanço controlado de tempo durante loading.
- Testes de viewport devem ajustar/restaurar as configurações de tamanho da view com as APIs compatíveis com o SDK instalado.
- No P14, acrescentar `flutter build web`. Registrar falha de ambiente separadamente de falha de código.
- Se não for possível executar um comando, informar o comando e o erro. Não registrar “passou” por inspeção visual ou por suposição.
- Antes de commitar, conferir que somente os caminhos da parte estão staged. Não incluir `.gitignore`, legado, arquivos de IDE ou alterações nativas preexistentes sem relação explícita com a entrega.

## 9. Protocolo contra suposições e expansão de escopo

1. O plano orienta; os arquivos reais comprovam. Ler o trecho fonte antes de transcrever dados ou implementar comportamento.
2. Caminho ausente/contrato diferente deve ser investigado, não substituído por API inventada.
3. Não escrever “autenticação”, “pagamento”, “push ativado” ou “chamado criado” como se fossem reais. Usar linguagem de demonstração na interface e documentação onde esses recursos aparecem.
4. Não adicionar pacote, arquivo de asset inexistente, serviço remoto, permissão ou credencial para preencher lacuna.
5. Não corrigir divergências de mocks sem decisão do usuário. Registrar a inconsistência e preservar o comportamento delimitado neste plano.
6. Não criar todo o tema CSS ou toda a lógica JavaScript como efeito colateral de uma tela.
7. Se a parte ficar grande demais, propor sua divisão antes de começar. Uma subdivisão aprovada recebe identificador e commit próprios; não executar várias partes disfarçadas de uma só.
8. Nunca declarar entrega, teste ou commit que não ocorreu. Ao final de cada parte, parar.

## 10. Etapas futuras, sem execução implícita

Após a conclusão estrutural, elaborar planos próprios para:

1. **Fidelidade visual de `style.css`:** tipografia, assets, texturas, bordas, sombras, gradientes, responsividade refinada e animações decorativas.
2. **Comportamento completo de `script.js`:** revisar os estados locais já portados, relógio/saudação atualizada, efeitos e demais detalhes ainda pendentes, sem reescrever código funcional desnecessariamente.
3. **Evolução além do protótipo:** somente com requisitos novos aprovados, definir autenticação/backend, integrações, regras acadêmicas reais, biblioteca pesquisável, persistência e recursos nativos.

Nenhuma dessas etapas está autorizada pela seleção de uma parte deste plano estrutural.
