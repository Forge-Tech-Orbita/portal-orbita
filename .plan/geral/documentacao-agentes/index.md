# Documentação e regras de execução para agentes — issue 3

## Contexto
Audite o Portal Órbita Flutter e documente os padrões existentes, a colaboração Git e os procedimentos de agentes. A referência é `fc3caaa6a01f81bf0c95f4ae8a85c7a5ea3f42e9`, igual a `origin/development` e ao HEAD inicial desta sessão. A API pública confirmou o mesmo commit em `development`; a branch local `development` estava desatualizada e não foi alterada.

O usuário já escolheu `feature/3-cria-documentacao-e-regras-execucao-projeto`. Preserve-a. A entrega é uma sessão e um PR futuro para `development`; não faça operações remotas automaticamente.

## Decisões pendentes
| ID | Decisão | Bloqueia | Status / Resposta |
| --- | --- | --- | --- |
| D1 | Preservar o infinitivo predominante ou adotar terceira pessoa em branches/commits? | S01: convenções Git | Respondida: preservar o predominante, com verbos no infinitivo |

## Regras para todas as sessões
- Use `.plan/TEMPLATE.md`, `AGENTS.md` e `.ai/rules/index.md`. Execute apenas o escopo abaixo.
- Preserve a aplicação, a suíte existente e os manifests. Não instale dependências nem transforme recomendações em implementação.
- Separe fatos observados, políticas solicitadas e itens não verificados.
- Não faça staging, commit, push ou PR automaticamente; peça aprovação do commit e autorização separada para operações remotas.

## Sessões planejadas

### S01: Auditar e documentar o contexto dos agentes
- **Objetivo:** entregar instruções utilizáveis por agentes sem inventar arquitetura, testes ou integrações.
- **Escopo / arquivos:** `AGENTS.md`, `CLAUDE.md`, `.ai/`, adaptadores por ferramenta, `.agents/skills/`, `.claude/`, `.gitattributes` restrito aos hooks, `.plan/TEMPLATE.md`, este acompanhamento e ajustes documentais mínimos no README/plano histórico.
- **Fora do escopo:** código em `lib/` e `test/`, pacotes, configuração nativa, CI, correção de warnings de build, instalação de SDKs, autenticação no GitHub e execução manual mobile.
- **Decisões necessárias:** D1 respondida.
- **Passos:**
  1. Investigue código Flutter, configurações, testes, Git e ambiente.
  2. Confirme formatos dos adaptadores em documentação oficial; não alegue execução nos clientes ausentes.
  3. Gere entrada canônica com adaptadores, regras modulares, template, skills e gate não destrutivo com auto-checagem isolada.
  4. Verifique os arquivos, registre limitações e proponha o commit sem executá-lo.
- **Validação técnica:** baseline de análise/formatação/suíte/build Web; sintaxe e auto-checagem do hook; consistência documental, caminhos e espaços do diff.
- **Validação manual:** sem mudança visual no app. Teste de carregamento nos quatro clientes confirmados e disparo real do hook dependem das instalações dos integrantes.
- **Critério de conclusão:** arquivos coerentes e verificações documentais aprovadas, com limitações dos clientes e mobile claramente registradas.

#### Execução da S01 — issue 3 — 10/11/2026
- **Implementado:** entradas, regras, template, registro de auditoria, adaptadores, três skills locais e hook de formato/análise com auto-checagem. README aponta para a documentação atual; o plano histórico recebeu aviso sem reescrita das etapas concluídas.
- **Verificado:** `flutter analyze --no-pub` sem problemas; `dart format --output=none --set-exit-if-changed lib test` sem alterações nos 52 arquivos; `flutter test --no-pub --reporter expanded` com 123 testes aprovados; `flutter build web --no-pub` concluído. Sintaxe/auto-checagem isolada do hook, execução direta sem alterações Dart, atributos LF, JSON/frontmatter restrito, links/caminhos, sincronização das entradas e espaços do diff conferidos. Aplicação/lockfile intactos e nenhum staging no projeto.
- **Baseline / bloqueios:** build Web avisa sobre fontes MaterialIcons/CupertinoIcons; Android SDK e Visual Studio ausentes; iOS requer macOS/Xcode. API pública confirma branch padrão/proteção genérica, mas o endpoint detalhado respondeu 401. Clientes de IA não disponíveis no PATH.
- **Pendências:** validar carregamento e disparo real do hook nos clientes usados pela equipe; revisão e aprovação do commit. Não houve conferência visual mobile, commit ou push.
- **Commit proposto:** `docs(agents): documentar regras e fluxo de execucao do projeto`

#### Revisão da S01 — 11/11/2026
- **Solicitado:** confirmar reutilização de `AGENTS.md` entre agentes e tornar o README uma apresentação do projeto, sem instruções internas desnecessárias.
- **Alterado:** README com apresentação, funcionalidades, status demonstrativo, pré-requisitos, execução, verificações e links de desenvolvimento. Removidas referências ao legado, detalhes de classes/rotas, etapas de migração e políticas operacionais do texto de boas-vindas; essas orientações continuam na documentação técnica.
- **Confirmado documentalmente:** Claude suporta importação `@AGENTS.md`; Antigravity lê `AGENTS.md` nativamente; suporte do Copilot varia por superfície. O levantamento inicial incluiu outras ferramentas, posteriormente retiradas do escopo pela equipe. Registro atual em `.ai/compatibilidade.md`.
- **Limite:** nenhuma entrada/adaptador foi reduzida nesta revisão; a importação é uma recomendação, não alteração aplicada. Não houve mudança de aplicação, execução nos clientes ou novo teste Flutter.
- **Verificado:** links locais, cercas Markdown e espaços dos três documentos revisados aprovados; `git diff --check` sem erros (com avisos LF/CRLF já registrados). Entradas continuam idênticas, aplicação/lockfile intactos e nenhum staging. Aprovação de commit e operações remotas continuam pendentes.

#### Simplificação do Claude — 11/11/2026
- **Autorizado e aplicado:** substituir as 101 linhas duplicadas de `CLAUDE.md` somente por `@AGENTS.md`. Instruções gerais permanecem em `AGENTS.md`; regras temáticas, em `.ai/rules/`.
- **Consistência:** ajustar a skill de convenções, o critério de qualidade, a compatibilidade e a auditoria para preservar a importação em vez de exigir cópias idênticas. Os registros anteriores de igualdade descrevem as verificações da versão anterior, não o estado atual.
- **Verificado:** importação exata e alvo existente, links locais, cercas Markdown e espaços dos seis arquivos desta revisão aprovados com Python. `git diff --check` falhou por linha vazia extra preexistente no fim de `README.md` (linha 40); preservada por estar fora desta alteração. Testes Flutter não repetidos por se tratar apenas de documentação.
- **Limites:** demais adaptadores, README, hooks e aplicação preservados nesta revisão. Validação no cliente Claude continua pendente; não executar commit/push automaticamente.

#### Organização compartilhada e portabilidade — 11/11/2026
- **Solicitado e aplicado:** planos maiores da equipe em `.plan/geral/`, usando o template, com responsáveis e acompanhamento compartilhado. `.plan/local/` serve ao detalhamento individual das tarefas designadas, referencia o plano geral e continua ignorado pelo Git. Orientação alinhada em `AGENTS.md`, regras gerais, template e entrada Copilot.
- **Portabilidade:** remover os caminhos absolutos de instalação da auditoria e da compatibilidade; documentar comandos relativos ao repositório em Bash, com pré-requisitos por plataforma. Não alterar hooks nem SDKs. A configuração do hook já usa a variável do projeto, não um caminho fixo da máquina.
- **Versionamento nesta etapa:** antes de fechar as ferramentas utilizadas, foram conferidos 19 novos arquivos `.md`, uma regra de editor e quatro arquivos de automação/configuração. Auditoria e plano desta entrega são registros de contexto, não requisitos de execução do app. A redução posterior está registrada abaixo.
- **Conferido:** `.plan/local/` e o script gerado de ambiente iOS estão ignorados e não rastreados. O script gerado contém caminhos locais, mas não integra esta entrega e não foi editado.
- **Validação:** contagem dos Markdown, links locais, cercas e espaços dos documentos revisados aprovados; importação do Claude preservada, sem caminhos absolutos de instalação nos novos documentos e nenhum staging. `git diff --check` passou nesta revisão, com os avisos LF/CRLF já conhecidos. Não repetir testes Flutter para esta mudança exclusivamente documental; validação macOS/Linux e nos clientes continua pendente.

#### Ferramentas confirmadas pela equipe — 11/11/2026
- **Escopo final:** GitHub Copilot, Antigravity, ChatGPT/Codex e Claude. Remover os dois adaptadores não utilizados e suas orientações/fontes da documentação ativa; atualizar a auditoria sem manter referências a arquivos removidos.
- **Codex:** confirmar em documentação oficial a leitura nativa de `AGENTS.md`; reutilizar esse arquivo, sem criar configuração ou cópia adicional. ChatGPT sem acesso aos arquivos precisa recebê-los explicitamente.
- **Entrega atual:** 22 arquivos novos, sendo 18 Markdown e quatro arquivos de automação/configuração; aplicação, hooks e regras de planejamento preservados. Carregamento real nos clientes continua pendente.
- **Verificado:** ausência de referências às ferramentas retiradas nos documentos/configurações, links locais, cercas Markdown, espaços, importação do Claude e contagem dos arquivos aprovados. `git diff --check` passou com os avisos LF/CRLF conhecidos. Aplicação e staging intactos; testes Flutter não repetidos nesta revisão documental.

#### Skill Ponytail local — 11/11/2026
- **Solicitado e aplicado:** adicionar `.agents/skills/ponytail/SKILL.md` como adaptação local do modo full, alinhada às regras existentes. Incluir referências e critérios de uso em `AGENTS.md` e no catálogo de compatibilidade.
- **Limites:** não instalar pacote/global, duplicar skills por cliente ou alterar `skills-lock.json`. A leitura manual do arquivo canônico atende clientes que não o descobrem automaticamente; isso não garante invocação automática.
- **Entrega atual:** 23 arquivos novos, sendo 19 Markdown e quatro de automação/configuração. Aplicação, hooks e planos locais preservados; carregamento nos clientes continua pendente.
- **Verificado:** skill local reconhecida e carregada neste harness; metadados, referências, links, cercas Markdown e espaços aprovados. `git diff --check` passou com avisos LF/CRLF conhecidos. Aplicação, lockfiles e staging intactos; testes Flutter não repetidos. `CLAUDE.md` já estava como `Leia @AGENTS.md` no início desta revisão e foi preservado, sem restaurar a versão anterior.

#### Revisão final e persistência — 11/11/2026
- **Revisado:** conjunto completo de 25 arquivos pendentes, incluindo consumidores das regras, adaptadores, quatro skills locais, configuração e scripts do hook. Nenhuma alteração da aplicação ou de planos locais.
- **Corrigido:** catálogo incompleto de skills no Copilot; exigência documental de conteúdo literal em `CLAUDE.md`, agora alinhada à importação válida `Leia @AGENTS.md` já existente e preservada.
- **Política adicionada:** continuar reproduzindo, investigando, corrigindo e validando enquanto o pedido não atender aos critérios, dentro do escopo autorizado. Um gate falho interrompe a sequência de comandos para correção, não encerra a investigação. Bloqueios reais, cancelamento e autorizações continuam respeitados; nunca declarar sucesso parcial.
- **Verificado:** sintaxe dos dois scripts, auto-checagem isolada com teste adicional de recuperação após falha, execução direta do hook a partir de `lib/`, JSON/frontmatter restrito, links/caminhos/cercas/espaços, LF dos scripts e exclusão dos planos locais. `git diff --check` aprovado com avisos LF/CRLF conhecidos; app, lockfiles e staging intactos.
- **Limites:** regras textuais não garantem adesão dos modelos. O hook cobre somente formato/análise e pode interromper repetição automática sem resolver a tarefa; não declarar conclusão nesse caso. Validação real nos clientes e macOS/Linux pendente; gates Flutter não repetidos por ser revisão documental e do autoteste isolado, sem mudança da aplicação.

#### Aprovação do commit — 11/11/2026
- **Autorizado pelo usuário:** criar o commit desta entrega com descrição curta dos arquivos e funcionalidades de regras, skills, adaptadores e validações no corpo da mensagem, para apoiar a revisão do futuro PR.
- **Limite da autorização:** sem push, abertura de PR ou merge. Validação real nos clientes, mobile e macOS/Linux permanece pendente; o corpo do commit deve distinguir as checagens finais do baseline Flutter anterior.

### S02: Refinar as regras de consulta dos agentes
- **Objetivo:** tornar as instruções diretas e precisas, separando orientação operacional de histórico de descoberta, sem enfraquecer políticas aprovadas.
- **Responsável:** agente executor; revisão e aprovação pelo solicitante.
- **Referência — 12/11/2026:** HEAD `1e6c227e096f5d6710e1fab8cc9a71110553e30e`; referência local `origin/development` em `fc3caaa6a01f81bf0c95f4ae8a85c7a5ea3f42e9`, sem atualização remota nesta etapa. Preservar a branch indicada `feature/3-cria-documentacao-e-regras-execucao-projeto` e continuar este plano, sem reescrever a S01.
- **Escopo / arquivos:** os sete arquivos em `.ai/rules/`; conferir consumidores em `AGENTS.md`, `CLAUDE.md`, `.agents/skills/`, `.agents/rules/`, `.github/` e `.ai/compatibilidade.md`, ajustando apenas referências e resumos necessários à consistência. Atualizar este acompanhamento.
- **Fora do escopo:** aplicação, testes Flutter, dependências, configuração nativa, comportamento dos hooks, novas políticas, novos adaptadores, instalação de ferramentas e operações remotas.
- **Decisões necessárias:** nenhuma para o refinamento editorial. Perguntar antes de alterar significado ou resolver conflito entre políticas.
- **Passos:**
  1. Conferir estado do Git e reler regras e consumidores antes de editar. Confirmar fatos no código e configuração atuais.
  2. Refinar cada regra conforme a tabela abaixo, preservando comandos, contratos, condições de parada e autorizações necessários.
  3. Concentrar cada assunto em uma fonte principal e usar referências curtas nos consumidores. Não duplicar regras em adaptadores nem impor leitura integral da auditoria a toda tarefa.
  4. Conferir o conjunto contra as instruções anteriores: retirar histórico e redundância, sem remover requisitos de segurança, acessibilidade, validação ou conclusão verificável.
  5. Validar documentação e diff, registrar resultados reais e propor commit sem staging ou execução automática.

| Arquivo | Refinamento previsto |
| --- | --- |
| `.ai/rules/index.md` | Manter mapa de leitura e limite de carregamento de `paths`; retirar justificativas históricas. |
| `.ai/rules/geral.md` | Concentrar escopo, segurança, planejamento e conclusão verificável; reduzir exemplos e referências circunstanciais à migração. |
| `.ai/rules/branches.md` | Manter nomenclatura, destinos de PRs, proteção das principais e autorizações; retirar resultados antigos de API, referências locais desatualizadas e exceções desta entrega. |
| `.ai/rules/commits.md` | Manter formato, tipos, português no infinitivo e aprovação; substituir tabela de commits reais por poucos exemplos diretos e retirar erros históricos/discussão do prompt original. |
| `.ai/rules/arquitetura.md` | Manter estrutura, contratos de navegação/estado e limites demonstrativos relevantes; reduzir inventário, contagens e negações redundantes de arquiteturas inexistentes. |
| `.ai/rules/qualidade.md` | Manter comandos, pré-requisitos, tratamento de falhas e validação por tipo de mudança; deixar contagens e resultados históricos na auditoria. |
| `.ai/rules/ui-widgets.md` | Manter reutilização, composição, acessibilidade e ciclo de vida; retirar tabela de cores duplicada do código e exemplos redundantes. |

- **Validação técnica:** conferir caminhos, links, frontmatter, importação `@AGENTS.md`, referências dos consumidores e `git diff --check`; conferir separadamente arquivos não rastreados, caso existam. Não executar gates Flutter para mudanças exclusivamente documentais.
- **Validação manual:** revisão editorial do conjunto e comparação das políticas antes/depois. Carregamento real nos clientes de IA permanece pendente e não será apresentado como validado.
- **Critério de conclusão:** cada instrução define ação, condição ou limite útil; histórico não ocupa as regras operacionais; fontes e consumidores permanecem coerentes; nenhuma política aprovada é perdida; verificações documentais passam e limites são registrados.
- **Commit proposto:** `docs(agents): refinar regras de consulta dos agentes`

#### Preparação da S02 — issue 3 — 12/11/2026
- **Autorizado:** salvar o plano de continuação neste diretório. A revisão das regras ainda não foi executada.
- **Registrado:** escopo, refinamento por arquivo, responsáveis, referências Git, limites e critérios de validação.
- **Pendências:** executar a S02 e registrar suas verificações; aprovação de commit e operações remotas continuam separadas.

#### Execução da S02 — issue 3 — 12/11/2026
- **Autorizado:** aplicar o refinamento. O solicitante apontou excesso de informação no registro de auditoria e indicou possível exclusão ao fim das melhorias; nesta etapa, o arquivo permaneceu como histórico, sem leitura obrigatória nas instruções operacionais.
- **Implementado:** sete regras refinadas, com remoção de relatos de descoberta, commits históricos, resultados antigos da API, inventário excessivo, contagens de baseline e paleta duplicada. `AGENTS.md` e Copilot reduzidos para encaminhar às fontes temáticas; skills de convenções/diagnóstico e compatibilidade alinhadas ao uso de evidência atual.
- **Preservado:** políticas Git e autorizações, planejamento compartilhado/local, contratos demonstrativos, segurança, acessibilidade, gates e persistência até resolução ou bloqueio real. Histórico da S01, importação Claude, adaptador Antigravity e comportamento dos hooks mantidos.
- **Verificado:** revisão editorial do diff e dos consumidores; checagem com Python da biblioteca padrão em 18 Markdown, 11 frontmatters no subconjunto usado, 14 links locais e 217 caminhos literais, além da importação Claude e JSON do hook. O verificador inicial confundiu exemplos de sintaxe e um caminho explicitamente não criado com referências quebradas; corrigida a classificação, a checagem passou sem alterar a documentação para mascarar erro. `git diff --check` aprovado, com avisos de conversão LF/CRLF. Status sem arquivos não rastreados e staging vazio; aplicação, dependências, plataformas, hooks e auditoria intactos. Gates Flutter não executados por ser mudança exclusivamente documental.
- **Critérios de aceite:** concluído o refinamento editorial e a validação documental; fontes temáticas e consumidores coerentes, sem leitura obrigatória da auditoria nem remoção das políticas aprovadas. Documentação operacional alterada reduzida de 64.355 para 44.061 bytes UTF-8, com quebras normalizadas (31,5%); o acompanhamento histórico não entra nessa medida.
- **Pendências:** revisão/aprovação do commit; decisão futura sobre exclusão da auditoria. Carregamento real nos clientes continua não validado. Nenhum staging, commit ou operação remota autorizado nesta execução.
- **Commit proposto:** `docs(agents): refinar regras de consulta dos agentes`

#### Revisão operacional da S02 — 13/11/2026
- **Solicitado:** retirar referências ao código removido, detalhes de shell/sistema da máquina e explicações de descoberta de instruções. A documentação ativa deve servir à execução dos planos.
- **Aplicado:** limpeza em regras, entradas, skill de convenções e template. `.ai/compatibilidade.md` reduzida a mapa de arquivos e requisitos do hook, consultada apenas na manutenção dessas integrações. Políticas Git, gates e segurança preservados.
- **Git:** mantidos a branch e os refinamentos pendentes. O merge em `development` foi informado pelo solicitante; não houve consulta nem atualização remota nesta revisão.
- **Validado:** revisão editorial e checagem de 18 Markdown, 11 frontmatters no subconjunto usado, 14 links locais, 187 caminhos literais, importação Claude e JSON do hook. Regras, entradas, skills do projeto e template sem referências ao código removido, detalhes de sistema local ou discussão de descoberta. `git diff --check` aprovado, com avisos LF/CRLF. Aplicação, hooks e auditoria intactos; sem gates Flutter por ser alteração documental.
- **Pendências:** aprovação do commit e decisão sobre a auditoria, que permanece intacta. Descoberta automática nos clientes não é critério de aceite desta revisão documental.

#### Aprovação do commit da S02 — 13/11/2026
- **Autorizado pelo solicitante:** criar o commit `docs(agents): refinar regras de consulta dos agentes`, incluindo as revisões documentais acima.
- **Limites:** sem push, PR, merge, release ou deploy. A auditoria permanece intacta até decisão própria.

#### Arquivamento local da auditoria — 13/11/2026
- **Solicitado e aplicado:** agrupar `P01.md` a `P14.md` em `.plan/local/sol/planos/` e mover a auditoria para `.plan/local/sol/auditoria/auditoria.md`, fora da árvore versionada.
- **Verificado:** os 15 arquivos mantêm seus hashes SHA-256 e todos os destinos são ignorados pelo Git. Links, cercas Markdown, espaços e ausência de referências versionadas aos caminhos antigos conferidos; `git diff --check` aprovado, com aviso LF/CRLF. O arquivo local não é pré-requisito para executar tarefas compartilhadas.
- **Pendências nesta etapa:** aprovação do commit da retirada. O histórico Git existente não foi reescrito; app, hooks e regras permanecem intactos. Sem testes Flutter por ser reorganização documental.
- **Commit proposto:** `docs(agents): retirar auditoria historica do versionamento`

#### Autorização de publicação — 13/11/2026
- **Autorizado:** criar o commit da retirada, revisar os commits da sessão, publicar a branch e abrir PR para `development` como `ricardopmartins`, nome confirmado pelo solicitante. Merge autorizado se não houver conflitos e forem atendidas as aprovações e verificações aplicáveis, sem bypass.
- **Conferido:** conta autenticada pela API; `origin/development` atualizado com `git fetch origin`. O PR anterior da documentação já consta na base; os commits de planejamento e refinamento permanecem fora dela.
- **Ferramentas:** GitHub CLI indisponível; usar a API com a credencial existente da conta confirmada, sem instalar ferramentas nem expor credenciais.
- **Revisão:** nenhuma falha bloqueante nos commits de planejamento/refinamento e na retirada pendente; políticas e contratos preservados, sem alteração da aplicação ou dos hooks. Revalidados 18 Markdown, 11 frontmatters restritos, 14 links, 186 caminhos, importação Claude e JSON do hook; 15 arquivos locais presentes e ignorados. Testes Flutter não aplicáveis ao diff documental.

## Prompt-modelo
```text
Leia .plan/geral/documentacao-agentes/index.md, AGENTS.md e .ai/rules/index.md.
Confira o acompanhamento antes de executar qualquer trabalho adicional.
Se eu pedir uma revisão da S01, limite-se à documentação e aos adaptadores.
Não implemente Firebase, altere a aplicação nem faça commit/push automaticamente.
Apresente verificações, pendências e commit proposto; pergunte “Aprova o commit?”.
```

## Acompanhamento
| Sessão | Status | Branch | Escopo resolvido | Validações / Pendências |
| --- | --- | --- | --- | --- |
| S01 | Implementada e revisada; commit autorizado | `feature/3-cria-documentacao-e-regras-execucao-projeto` | Auditoria, regras, planos, adaptadores, skills e hook | Baseline Flutter e checagens documentais/isoladas aprovados; clientes reais pendentes; push/PR não autorizados |
| S02 | Refinamento commitado em `092a055`; commit da retirada e publicação autorizados | `feature/3-cria-documentacao-e-regras-execucao-projeto` | Regras refinadas; auditoria e planos individuais organizados em pasta local ignorada | Documentação validada; revisão dos commits e publicação em andamento; merge condicionado a conflitos, aprovações e gates |
