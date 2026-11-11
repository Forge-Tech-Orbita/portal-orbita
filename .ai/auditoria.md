# Auditoria de contexto — Portal Órbita

## Referência e escopo

- Data local da auditoria: **10/11/2026**. Alguns horários do GitHub estão em UTC e já indicam 11/11; não são outra versão da auditoria.
- HEAD inicial: `fc3caaa6a01f81bf0c95f4ae8a85c7a5ea3f42e9`.
- Branch de trabalho: `feature/3-cria-documentacao-e-regras-execucao-projeto`, indicada pelo usuário. O status inicial estava limpo; nenhuma branch foi criada, renomeada ou trocada.
- `origin/development` local e a API pública apontavam para o mesmo HEAD. `development` local e `production` apontavam para `5160faa8e8a372f88f44efbc0eda971c634b286d`; `origin/HEAD` ainda indicava `origin/main`, já desatualizado.
- Escopo: todos os 38 arquivos Dart de `lib/`, inventário dos 14 arquivos em `test/` com leitura de testes representativos e execução da suíte completa, manifests/lockfile/lints, README/plano histórico, configuração nativa representativa, histórico e branches Git, documentação oficial dos formatos de agentes.
- Exclusões: conteúdo removido de `portal-orbita-antigo/`, antigos React Native/Expo, dependências, caches, builds, credenciais e dados reais. Não foi feita auditoria de segurança exaustiva de cada arquivo nativo nem inspeção visual de todas as telas.
- Não havia `AGENTS.md`/`CLAUDE.md` no repositório nem nos ancestrais consultados. Existiam a skill `find-skills`, `skills-lock.json`, um plano de migração geral e planos locais ignorados. Não havia CI versionada em `.github/` nem `.gitlab-ci.yml`.

## Fatos, políticas e lacunas

| Afirmação | Evidência | Classificação |
| --- | --- | --- |
| App Flutter com Android/iOS/Web | `.metadata`, `pubspec.yaml`, `lib/main.dart`, `android/`, `ios/`, `web/` | Observado |
| CLI Flutter/Dart nativo, sem wrapper de runtime versionado | README, manifests, inventário de arquivos | Observado |
| Flutter 3.47.7 / Dart 3.13.5 instalados | `flutter --version` | Observado no ambiente, não pin obrigatório do projeto |
| SDK Dart `^3.13.5`; versão 0.1.0+1 | `pubspec.yaml` | Observado |
| Só Flutter como dependência de produção | `pubspec.yaml`, `pubspec.lock` | Observado |
| `flutter_test` e `flutter_lints` 6.0.0 | Manifest, lockfile, `analysis_options.yaml` | Observado |
| Tema/paleta central claros | `lib/core/theme/orbita_theme.dart`, `lib/app.dart` | Observado |
| Estado local e rotas nomeadas | `lib/features/navigation/presentation/main_navigation_screen.dart`, `lib/app.dart` | Observado |
| Modelos tipados e fixtures locais | `lib/core/models/`, `lib/core/mock/`, `lib/features/grades/data/grade.dart` | Observado |
| Sem backend, Firebase/Firestore ou persistência | Dependências, inicialização e leitura de `lib/` | Observado; não proibição de evolução autorizada |
| Suíte real: 14 arquivos, 123 testes aprovados | `test/`, `flutter test --no-pub --reporter expanded` | Observado; não cabe proibir testes |
| Legado já removido | Árvore atual e commit `8ac6168` | Observado; não foi reaberto pelo histórico |
| GitHub / organização Forge-Tech-Orbita | `git remote -v`, API pública do repositório | Observado |
| `development` é default e ambas as branches são protegidas | API `/repos/Forge-Tech-Orbita/portal-orbita` e `/branches/{branch}` | Observado remotamente |
| Base/PR diário em `development`; promoção estável para `production` | Informação fornecida pelo usuário | Política solicitada |
| Uma aprovação, conversas resolvidas, sem push direto/force push/deleção nas duas principais | Informação fornecida pelo usuário; detalhes da API indisponíveis | Política solicitada, enforcement detalhado não verificado |
| Branch com tipo/issue/descrição; mensagens em português e infinitivo | Histórico, branches e resposta do usuário à pergunta de convenção | Observado + decisão explícita nesta auditoria |
| Não commitar/fazer push automaticamente; perguntar “Aprova o commit?” | Solicitação do usuário | Política solicitada |
| Sem novas pastas raiz em `lib/` ou novos pacotes sem aprovação | Plano histórico e política preservada nesta tarefa | Política documentada; organização atual não exige novas camadas |

## Execução e baseline

Ambiente auditado: Windows 10, PowerShell 5.1, Flutter/Dart disponíveis no PATH e Git Bash 5.3.15 instalado. O launcher `bash` encontrado inicialmente pelo PowerShell era diferente do Git Bash. São evidências desta máquina, não requisitos de sistema operacional ou de diretório para os colegas; use o SDK e o shell configurados no próprio ambiente.

Todos os comandos da aplicação abaixo foram executados na raiz:

| Verificação | Resultado |
| --- | --- |
| `flutter --version` | Exit 0; Flutter 3.47.7 stable, Dart 3.13.5 |
| `flutter analyze --no-pub` | Exit 0; `No issues found!`, aproximadamente 36 s |
| `dart format --output=none --set-exit-if-changed lib test` | Exit 0; 52 arquivos, 0 alterados |
| `flutter test --no-pub --reporter expanded` | Exit 0; 123 testes aprovados, aproximadamente 91 s |
| `flutter build web --no-pub` | Exit 0; `build/web` gerado, aproximadamente 97 s; aviso de fontes abaixo |
| `flutter doctor --verbose` | Android SDK não localizado e Visual Studio ausente; Chrome/Edge e alvo Windows detectados; duas categorias com problemas |
| `flutter devices` | Exit 0; Windows, Chrome e Edge disponíveis; nenhum dispositivo Android/iOS listado |
| `git status --short --branch` | Inicialmente limpo; branch de trabalho preservada |
| `git log -n 30 --oneline`, `git branch -a`, `git remote -v` | Inspecionados; conclusões nas regras Git |
| `git symbolic-ref --quiet refs/remotes/origin/HEAD` | `refs/remotes/origin/main`, referência local desatualizada |
| Inventário Git inicial de instruções e planos | Antes da geração, somente skill preexistente e plano geral rastreados nos caminhos consultados |

As dependências já estavam resolvidas. Não foi necessário instalar pacotes, reexecutar `flutter pub get`, atualizar o lockfile nem limpar caches. Os comandos de instalação/execução/build nativo documentados não foram confundidos com comandos efetivamente executados.

### Aviso de build preexistente

O build Web informou que esperava fontes `MaterialIcons` e `packages/cupertino_icons/CupertinoIcons`, mas encontrou apenas `MaterialIcons`. O build concluiu. Nenhum pacote foi adicionado e nenhuma fonte/configuração foi alterada para eliminar o aviso fora do escopo. A mensagem informativa de dry run Wasm também não equivale a build/teste Wasm solicitado.

### O que os testes realmente cobrem

- Modelos/fixtures, saudação, média com AV2 nula/zero, seleção de dias e filtros.
- Login demonstrativo, loading de 900 ms, validação de obrigatoriedade e descarte durante espera.
- Navegação, retorno, logout com limpeza da pilha e preservação de estado das abas.
- Conteúdo dos módulos, widgets compartilhados, feedback demonstrativo e ausência de funcionalidades remotas inventadas.
- Viewports 360×640, 360×800, 390×844, teclado e casos de texto ampliado.

Não há evidência de testes de integração em dispositivo, cobertura percentual ou CI executando a suíte. O nome `migration_audit_test.dart` não o transforma em teste nativo end-to-end: é widget test com `flutter_test`.

## Git e consulta remota

Consultas somente de leitura à API pública, sem credenciais:

- `GET https://api.github.com/repos/Forge-Tech-Orbita/portal-orbita`: `default_branch: development`.
- `GET .../branches/development`: HEAD `fc3caaa...`, `protected: true`.
- `GET .../branches/production`: HEAD `5160faa...`, `protected: true`.
- `GET .../rulesets`: lista vazia; isso não desmente proteção clássica de branch.
- `GET .../branches/development/protection` e equivalente de `production`: HTTP **401**; não foi possível consultar os detalhes sem autenticação.

Não houve `fetch`, `pull`, alteração de configuração Git, autenticação, push ou PR. As referências locais desatualizadas foram registradas, não “corrigidas” como efeito colateral.

Os commits recentes da migração usam Conventional Commits em português com infinitivo (`criar`, `portar`, `registrar`, `validar`). Há exceções antigas, merges e um tipo `remove` com erro de digitação. A equipe respondeu **“Preservar o predominante”** à escolha entre infinitivo e terceira pessoa. Exemplos e procedimentos estão em `.ai/rules/commits.md` e `.ai/rules/branches.md`.

## Arquitetura e decisões negativas

O mapa completo dos arquivos/responsabilidades está em `.ai/rules/arquitetura.md`; paleta e composição em `.ai/rules/ui-widgets.md`.

- Não invente Firebase, API, camada de domínio/repositório ou estado global já implementados.
- Não transforme strings financeiras demonstrativas em cálculo real nem derive aprovação acadêmica de mocks sem decisão de negócio.
- Não acrescente estilo/cor duplicado quando `OrbitaTheme` resolver, mas não proíba espaçamentos locais que o projeto efetivamente utiliza.
- Não confunda `web/` com o legado removido.
- Não proíba testes: há uma stack ativa e comprovada.
- Não execute o plano de migração concluído como autorização de novos commits automáticos.
- Não distribua release de produção usando a assinatura debug atualmente descrita em `android/app/build.gradle.kts`; application ID/assinatura de template são pendências de uma futura entrega, não corrigidas aqui.

## Entrega documental e compatibilidade

Criados nesta tarefa: entrada canônica `AGENTS.md`, importação em `CLAUDE.md`, regras modulares, template, plano da sessão, três procedimentos em skills e uma adaptação local do modo Ponytail full, adaptadores de clientes e hook de formato/análise. As entradas foram inicialmente cópias idênticas; em 11/11/2026, o usuário autorizou centralizar as instruções com `@AGENTS.md` no Claude, preservando os demais adaptadores. README e plano histórico recebem somente ajustes documentais de orientação; nenhuma mudança de produto foi solicitada.

Fontes oficiais, matriz de carregamento e procedimento de teste: `.ai/compatibilidade.md`. Formatos foram investigados antes da criação. Limites importantes:

- Escopo final confirmado pela equipe: Copilot, Antigravity, ChatGPT/Codex e Claude. Adaptadores de ferramentas não utilizadas foram removidos, sem alterar instruções compartilhadas ou skills.
- Codex documenta leitura nativa de `AGENTS.md`; não foi criado adaptador duplicado. Conversas comuns no ChatGPT exigem fornecer os arquivos ou acesso ao repositório, sem presumir descoberta local.
- Skills em `.agents/skills/` foram reconhecidas pelo harness desta sessão; o carregamento nos quatro clientes confirmados não foi executado.
- Configuração de hook não é proteção técnica contra commit/push e não configura hooks de outras ferramentas.

## Limitações e validação da documentação

- Sem Android SDK, emulador/dispositivo mobile ou macOS/Xcode: não houve build Android/iOS nem conferência visual mobile. Windows desktop também não é alvo versionado da aplicação e falta Visual Studio.
- Sem validação prática dos clientes confirmados: carregamento real e disparo do hook permanecem pendentes. A consulta documental do Codex não equivale a uma execução dessa ferramenta.
- Não foi auditada a aplicação inteira como avaliação de segurança, desempenho sob carga ou fidelidade visual. Esta é uma auditoria de contexto/padrões, com baseline técnico da aplicação.
- `bash -n` nos dois scripts: aprovado usando o Bash do Git for Windows. Auto-checagem isolada: aprovada com fixtures Git e stubs, cobrindo documentação sem gate, Dart não rastreado/staged/unstaged/deletado, manifests, erro de formato/análise, repetição e ferramentas/raiz ausentes. Nenhum commit foi executado nas fixtures ou no projeto. A primeira execução identificou um problema no PATH reduzido do próprio teste; ele foi corrigido para preservar o executável Git, sem mudar o ambiente global.
- Execução direta do hook a partir de `lib/`, sem alterações Dart/configuração: exit 0, sem exigir análise desnecessária. Isso não é disparo real do evento no Claude Code.
- `git check-attr eol -- .claude/hooks/check.sh .claude/hooks/check-self-test.sh`: ambos com `lf`, restritos por `.gitattributes`.
- Verificação inicial com Python da biblioteca padrão: entradas então idênticas byte a byte, JSON válido, frontmatter no subconjunto YAML efetivamente usado (listas/strings JSON e escalares simples), metadados das três skills, links locais, caminhos canônicos, cercas Markdown e ausência de espaços finais nos novos arquivos. Após a simplificação do Claude, o critério de entrada passa a ser a importação `@AGENTS.md` fora de crases/cercas e com alvo existente, sem duplicação de regras; a frase curta `Leia @AGENTS.md` foi preservada. PyYAML não estava instalado; não foi adicionada dependência nem alegada análise de YAML arbitrário.
- `git diff --check`: aprovado para linhas alteradas rastreadas; os novos arquivos foram conferidos separadamente. O Git avisou sobre possível conversão LF/CRLF nos dois documentos rastreados; não houve normalização global nem alteração do histórico além do aviso inicial.
- Comparação de caminhos no Git confirmou que `lib/`, `test/`, manifests/lockfile, lints e plataformas permaneceram intactos e que nada foi staged. Após remover dois adaptadores não utilizados e adicionar a skill local Ponytail, a entrega contém 23 arquivos novos (19 `.md` e quatro de automação/configuração) e dois documentos existentes ajustados, sem mudança funcional.

## Revisão final de consistência — 11/11/2026

- Revisados os 25 arquivos pendentes: 23 novos e dois documentos rastreados alterados. Escopo de execução esperado para o hook: um checkout/sessão local; não é CI nem validação funcional completa.
- Corrigida a lista de skills do Copilot para remeter ao catálogo de `AGENTS.md`, incluindo Ponytail. Alinhado o critério de importação do Claude à frase curta já presente, sem sobrescrevê-la nem exigir igualdade literal dos arquivos.
- Adicionada política de persistência e conclusão verificável em `.ai/rules/geral.md`, referenciada pelas entradas, Ponytail e template. Uma tentativa falha exige investigar, corrigir e revalidar; bloqueios reais continuam explícitos e não autorizam operações fora do escopo.
- Sintaxe dos dois scripts, auto-checagem isolada e execução direta do hook sem mudanças Dart aprovadas. Acrescentado teste de recuperação: após falhar durante Stop ativo, uma nova execução com verificações aprovadas não emite bloqueio JSON. A proteção contra repetição do hook permanece documentada como interrupção técnica, nunca conclusão funcional.
- Validação documental final: JSON válido, 11 frontmatters no subconjunto usado, links locais, caminhos canônicos, cercas e espaços; importação do Claude válida e `AGENTS.md` abaixo do limite padrão documentado para instruções do Codex. Scripts com atributo LF; planos locais ignorados e não rastreados; aplicação, manifests, lockfiles e staging intactos.
- Não repetidos os gates Flutter: nenhuma mudança Dart, de dependências ou configuração da aplicação nesta revisão. A análise/suíte/build anteriores permanecem baseline histórico, não execução nova. Carregamento real nos quatro clientes e validação macOS/Linux continuam pendentes.

Não há decisão de negócio bloqueante pendente. Revisão documental concluída; usuário autorizou o commit em 11/11/2026, com descrição curta da entrega no corpo da mensagem. Validação nos clientes continua pendente. Push/PR continuam sem autorização.
