# Compatibilidade dos agentes e automação

## Fonte canônica e limites

Use `AGENTS.md` como entrada canônica e `.ai/rules/` para regras temáticas. `CLAUDE.md` importa `@AGENTS.md` em uma frase curta, sem duplicar as instruções. O frontmatter `paths` de `.ai/rules/` é metadado para o índice e para leitura pelo agente; ele não registra essas regras automaticamente em todos os clientes.

Ferramentas confirmadas pela equipe em **11/11/2026**: GitHub Copilot, Antigravity, ChatGPT/Codex e Claude. Mantenha somente as integrações utilizadas; adicione outras quando houver necessidade aprovada. Os formatos foram conferidos em documentação oficial em 10–11/11/2026, incluindo `AGENTS.md` no Codex. Não houve validação nas interfaces desses clientes nem disparo real do hook. **Suporte de formato documentado não equivale a integração executada.**

| Agente | Entrada/adaptador | Mecanismo documentado | Situação / ação da equipe |
| --- | --- | --- | --- |
| Claude Code | `CLAUDE.md`, `.claude/settings.json` | Memória de projeto e evento `Stop` com hook `command` | Arquivos locais verificáveis; disparo no cliente pendente; leia `.ai/rules/index.md` explicitamente |
| ChatGPT / Codex | `AGENTS.md` | Codex lê instruções do projeto nativamente; não requer outro adaptador | Confirme as instruções carregadas no Codex. Em uma conversa comum do ChatGPT, forneça os arquivos ou acesso ao repositório; não presuma leitura automática |
| GitHub Copilot | `.github/copilot-instructions.md` | Instruções de repositório; superfícies/recursos variam por cliente | Confira o arquivo nas referências da resposta; leitura de regras/skills adicionais pode ser manual |
| Antigravity | `AGENTS.md`, `.agents/rules/portal-orbita.md` | Markdown em `.agents/rules/` com `trigger: always_on` | Confira nas Customizations → Rules; não foi usado o caminho legado `.agent/rules/` |

Não dependa de um link ou menção para incluir automaticamente todo o conteúdo. Os adaptadores mandam **ler** o índice e os arquivos pertinentes. Se o cliente não conseguir abrir arquivos, forneça seu conteúdo no contexto; não declare que as regras foram aplicadas sem conferir.

## Reutilização de AGENTS.md sem copiar regras

Consulta documental complementar em **11/11/2026**: diferencie instrução em linguagem natural, leitura nativa e importação de conteúdo.

| Agente | Alternativa documentada à duplicação | Limite |
| --- | --- | --- |
| Claude Code | Use `@AGENTS.md` em `CLAUDE.md`, fora de crases/cercas Markdown, para importar o arquivo relativo a ele | Escrever apenas “leia AGENTS.md” depende de o modelo abrir o arquivo. Leitura nativa de `AGENTS.md` também existe a partir de v2.1.277, mas depende da configuração e da presença de arquivos `CLAUDE.md`/`CLAUDE.local.md` |
| ChatGPT / Codex | Codex usa diretamente `AGENTS.md` | As regras temáticas referenciadas ainda devem ser lidas. Uma conversa comum do ChatGPT não descobre arquivos locais automaticamente |
| Antigravity | Use diretamente `AGENTS.md`; a sintaxe `@[rótulo](caminho)` também permite incluir conteúdo em uma regra | `@arquivo` sozinho não faz inline; a sintaxe de importação do Claude não deve ser presumida equivalente |
| GitHub Copilot | Use `AGENTS.md` nas superfícies que suportam instruções de agente | O suporte varia por cliente/recurso. Não substitua globalmente `.github/copilot-instructions.md` por uma referência sem verificar a matriz oficial |

Para centralizar as instruções do Claude, o conteúdo completo de `CLAUDE.md` é:

```text
Leia @AGENTS.md
```

Essa importação elimina a cópia no repositório, não os tokens das regras: o conteúdo importado continua no contexto. Não prometa mesma latência, custo ou adesão às regras sem medir. A própria documentação do Claude recomenda a importação em vez de uma frase pedindo leitura; confira o carregamento com `/context all` na versão usada.

O token `@AGENTS.md` é a importação; `Leia` é apenas texto ao redor. A forma mínima `@AGENTS.md` também é válida. Não confunda isso com uma frase sem o `@`, que depende de leitura posterior pelo modelo.

Simplificação aplicada em **11/11/2026**, após autorização do usuário: `CLAUDE.md` passou de 101 linhas duplicadas para uma importação. Atualize as instruções gerais somente em `AGENTS.md`; preserve a importação no Claude. Após confirmação da equipe, os adaptadores não utilizados foram removidos; permanecem os de Copilot e Antigravity. Codex reutiliza a entrada canônica sem arquivo adicional. A tabela registra suporte documental, não testes executados nos clientes. Fontes oficiais no fim deste arquivo, além de [instruções e diferenças entre clientes do Copilot](https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions).

## Skills

As quatro skills locais desta entrega ficam em `.agents/skills/<nome>/SKILL.md`, com `name`/`description` no padrão Agent Skills. Incluem três procedimentos do projeto e uma adaptação local do modo Ponytail full. A skill preexistente `find-skills` e `skills-lock.json` foram preservadas; os arquivos locais não exigem pacote instalado nem entrada artificial de lockfile.

- `.agents/skills/infer-conventions/SKILL.md`
- `.agents/skills/flutter-best-practices/SKILL.md`
- `.agents/skills/diagnostico-mobile/SKILL.md`
- `.agents/skills/ponytail/SKILL.md` — menor diff completo, sem cortar validação, segurança ou acessibilidade; adaptação local, não instalação da distribuição externa de Ponytail.

A descoberta depende da ferramenta/versão. Antigravity documenta `.agents/skills/`. Para os demais clientes, a descoberta automática nessa localização não foi validada nesta entrega; leia o arquivo canônico pelo caminho quando necessário. Claude Code documenta `.claude/skills/`, mas não foram criadas cópias ou symlinks desnecessários.

O harness desta sessão reconheceu as três skills após sua criação e carregou `infer-conventions`; essa evidência se limita a esta sessão, não aos quatro clientes da tabela.

A skill local `ponytail` também foi reconhecida e carregada neste harness após sua criação. Isso confirma o arquivo local nesta sessão, não a descoberta automática nos demais clientes.

Prompt de carregamento manual:

```text
Leia AGENTS.md, .ai/rules/index.md e as regras dos caminhos da tarefa.
Para esta tarefa, leia também .agents/skills/<nome>/SKILL.md.
Confirme quais arquivos leu e informe se não conseguir acessá-los.
Não faça commit nem push automaticamente.
```

## Hook Stop do Claude Code

### Pré-requisitos e execução

- Configuração: `.claude/settings.json`. Script: `.claude/hooks/check.sh`.
- Requer Bash e Git; só exige Flutter/Dart quando detectar alterações relevantes. Não requer `jq`, Python, Node nem pacote novo.
- No Windows, execute em um terminal Git Bash com Git, Flutter e Dart no PATH. Um launcher Bash de WSL pode usar outro ambiente; não presuma que ele enxergue o SDK instalado no Windows.
- No macOS/Linux, use um terminal com Bash e as ferramentas no PATH. Na raiz do repositório, confira sintaxe e auto-checagem com os mesmos comandos:

```bash
bash -n .claude/hooks/check.sh
bash .claude/hooks/check-self-test.sh
```

- O hook usa `${CLAUDE_PROJECT_DIR}` para localizar o script e Git para descobrir a raiz ativa; não fixa diretório do usuário ou do SDK. Cada colega configura suas ferramentas no próprio ambiente. A execução foi verificada somente no Windows/Git Bash desta auditoria; macOS/Linux ainda precisam de validação prática.
- A configuração invoca `bash` explicitamente e não depende do bit executável do arquivo no índice Git. Em Unix, `chmod +x .claude/hooks/check.sh .claude/hooks/check-self-test.sh` permite execução direta; não faça staging só para ajustar modo de arquivo. No Windows auditado, `core.filemode=false`.
- `.gitattributes` fixa LF somente em `.claude/hooks/*.sh`, evitando que o checkout com conversão automática para CRLF quebre os scripts Bash. Não muda o formato dos demais arquivos.
- Se o Claude Code resolver o Bash/PATH errado ou bloquear hooks por política administrativa, informe a limitação e use as verificações manuais. Não instale WSL nem altere configurações globais automaticamente.

### Comportamento

1. Receba o evento por stdin; consulte `git rev-parse --show-toplevel` no diretório corrente do hook. O script pode estar no checkout original, mas as verificações usam o repositório ativo, incluindo worktree quando o cliente executar nele. Se não houver repositório corrente válido, bloqueie; não valide outro checkout silenciosamente.
2. Use `git status --porcelain=v1 --untracked-files=all` com pathspecs para Dart em `lib/`/`test/`, `pubspec.yaml`, `pubspec.lock` e `analysis_options.yaml`. Isso inclui staged, unstaged, renames/deleções relevantes e arquivos não rastreados, sem analisar nomes por espaços.
3. Sem alterações relevantes, encerre sem exigir Flutter. Documentação e código legado/gerado ignorado não disparam o gate.
4. Com alterações, execute `dart format --output=none --set-exit-if-changed lib test` e `flutter analyze --no-pub`, sem modificar fonte ou instalar dependências. Logs vão para stderr para não corromper a saída JSON do hook.
5. Falha de Git, ferramenta, formato ou análise devolve exit **2**, bloqueando o primeiro `Stop` e orientando a corrigir ou informar bloqueio.
6. Se falhar novamente num evento com `stop_hook_active: true`, emita JSON `continue: false` com motivo explícito de **gate não aprovado**. Isso interrompe a repetição automática, não transforma a falha em sucesso. A equipe precisa resolver o bloqueio antes de aprovar o commit.

A regra de persistência em `.ai/rules/geral.md` exige retomar a investigação após uma tentativa sem sucesso. A proteção acima limita a repetição automática do evento Stop; se ela interromper a execução, registre a tarefa como bloqueada/pendente, nunca como resolvida. O hook não consegue comprovar que todos os critérios funcionais do pedido foram atendidos.

O hook não roda testes/build, não formata com escrita, não limpa caches, não comita e não impõe proteção de branches. Ele observa o estado atual do Git, não uma comparação com a sessão: pode detectar alterações preexistentes e deixa de detectar conteúdo já commitado. Não use isso como substituto da revisão e dos gates da tarefa.

A auto-checagem usa repositórios temporários e stubs de Flutter/Dart, incluindo casos de sucesso/falha e repetição. Não faz commit, não acessa rede e só usa staging dentro das próprias fixtures. A execução real do evento no Claude Code permanece pendente.

## Segurança e modos autônomos

Instruções em Markdown são orientações de comportamento, não controles de acesso. O hook de qualidade não bloqueia tecnicamente `git commit`/`git push`. Mantenha proteções do servidor e permissões adequadas; não afirme garantia absoluta a partir destes arquivos.

Se um serviço de agente em nuvem exigir criar branch/commits/push/PR automaticamente (por exemplo, modos específicos de coding agent), essa execução conflita com a política de aprovação prévia. Explique a incompatibilidade e escolha com o usuário um modo compatível; não use a autonomia da plataforma como autorização implícita.

## Fontes oficiais consultadas

- [Claude Code: memória](https://code.claude.com/docs/en/memory)
- [Claude Code: hooks](https://code.claude.com/docs/en/hooks)
- [Claude Code: skills](https://code.claude.com/docs/en/skills)
- [Codex: instruções com AGENTS.md](https://developers.openai.com/codex/agent-configuration/agents-md)
- [Copilot: instruções de repositório](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions)
- [Antigravity: rules](https://antigravity.google/docs/rules)
- [Antigravity: skills](https://antigravity.google/docs/skills)
- [Agent Skills: especificação](https://agentskills.io/specification)

Reconfira essas fontes ao atualizar os clientes; redirecionamentos e formatos podem mudar. Não instale adaptadores ou gere cópias adicionais sem necessidade.
