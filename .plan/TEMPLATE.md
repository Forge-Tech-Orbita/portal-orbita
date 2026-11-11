# [Nome do plano, feature ou auditoria]

## Contexto
[Descreva objetivo, escopo e commit base de referência em `development`. Confira a base real; não copie um hash antigo. Cada sessão representa uma branch e um PR de escopo fechado para `development`.]

## Organização do trabalho
- Salve este plano maior em `.plan/geral/<nome>/index.md`, versionado para toda a equipe, com decisões, tarefas, responsáveis e andamento compartilhados.
- Cada integrante pode detalhar suas tarefas designadas em `.plan/local/<integrante>/<nome>/index.md`, indicando o plano geral e a sessão de origem. Esses roteiros individuais continuam ignorados pelo Git e não precisam reproduzir o template completo.
- Atualize no plano geral os resultados e decisões relevantes para a equipe; não dependa de links para arquivos locais que os colegas não recebem.

## Decisões pendentes
| ID | Decisão | Bloqueia | Status / Resposta |
| --- | --- | --- | --- |
| D1 | [Dúvida objetiva de negócio, layout ou dependência] | S01 | Pendente |

## Regras para todas as sessões
1. Leia `AGENTS.md` ou `CLAUDE.md`, `.ai/rules/index.md` e todas as regras aplicáveis aos caminhos da sessão.
2. Confira `git status --short --branch` e preserve alterações existentes. Não descarte nem inclua trabalho alheio.
3. Siga `.ai/rules/branches.md`: base `development` atualizada, branch `<tipo>/<issue>-<descricao>` e PR para `development`. Peça a issue se ausente. Atualize com `git pull --ff-only origin development` somente na branch base e no contexto autorizado; pare em divergência. Se o usuário já indicar a branch correta, preserve-a.
4. Confirme arquivos e consumidores antes de editar. Reutilize `lib/core/` e as features existentes; não crie pastas raiz em `lib/` nem adicione pacotes sem aprovação.
5. Implemente apenas o escopo da sessão. Faça alterações adicionais somente quando indispensáveis à entrega e registre-as. Anote bugs/melhorias independentes para outra sessão.
6. Resolva decisões bloqueantes antes de mudar negócio, navegação ou contratos. Não restaure nem consulte o legado removido como padrão atual.
7. Siga `.ai/rules/qualidade.md`: formate somente arquivos afetados quando necessário e execute as verificações abaixo separadamente. No primeiro erro, interrompa a sequência, investigue/corrija e reexecute antes de prosseguir:
   - `dart format --output=none --set-exit-if-changed lib test`
   - `flutter analyze --no-pub`
   - `flutter test --no-pub`
   - `git diff --check`
8. Preserve a suíte real em `test/`. Atualize testes de comportamento afetado; não introduza outra stack. Para documentação apenas, use as validações documentais em `.ai/rules/qualidade.md` sem reformatação ampla do app.
9. Registre baseline, comandos e bloqueios. Para UI/fluxos, solicite conferência mobile com `flutter run -d <id>` pelo desenvolvedor; build Web e testes não substituem essa conferência.
10. Atualize o acompanhamento e a subseção de execução. Separe implementação, validação manual e autorização Git.
11. Não faça staging, commit, push ou abertura de PR automaticamente. Apresente resumo, verificações, pendências e mensagem de commit no padrão `.ai/rules/commits.md`; pergunte exatamente: **“Aprova o commit?”**
12. Aprovação de commit não autoriza push, PR, merge, release ou deploy.
13. Siga o ciclo de persistência de `.ai/rules/geral.md`: se a solução tentada não resolver o pedido, continue investigando, corrigindo e validando dentro do escopo autorizado. Só declare conclusão com critérios de aceite verificados; em bloqueio real, registre o necessário para retomar e continue as etapas independentes possíveis.

---

## Sessões planejadas

### S01: [Título]
- **Objetivo:** [Entrega verificável]
- **Responsável:** [Integrante designado ou a definir]
- **Escopo / arquivos:** [Caminhos reais e consumidores envolvidos]
- **Fora do escopo:** [Limites explícitos]
- **Decisões necessárias:** [IDs ou nenhuma]
- **Passos:**
  1. [Passo 1]
  2. [Passo 2]
- **Validação técnica:** [Comandos reais e critérios aplicáveis]
- **Validação manual:** [Telas/fluxos, dispositivo e responsável; ou não aplicável]
- **Critério de conclusão:** [Resultado esperado e pendências aceitáveis explicitamente identificadas]

#### Execução da S01 — issue [X] — [data]
- **Implementado:** [Preencher durante a execução]
- **Verificado:** [Comandos, códigos de saída e validações efetivamente realizadas]
- **Critérios de aceite:** [Evidência por critério; diferencie concluído, validação pendente e bloqueado]
- **Baseline / bloqueios:** [Problemas anteriores e limitações do ambiente]
- **Pendências:** [Conferência visual, revisão, aprovação ou outra]
- **Commit proposto:** [Tipo/escopo e resumo em português no infinitivo]

---

## Prompt-modelo
```text
Execute a sessão <Sxx> do plano compartilhado .plan/geral/<nome-do-plano>/index.md.
Se houver roteiro individual, leia também .plan/local/<integrante>/<nome>/index.md.
Mantenha o roteiro individual ignorado pelo Git e atualize o andamento compartilhado no plano geral.
Leia AGENTS.md ou CLAUDE.md e .ai/rules/index.md.
Pergunte antes de implementar se houver decisão bloqueante sem resposta.
Confira o estado do Git e siga o fluxo de branches documentado.
Implemente apenas o escopo da sessão.
Execute as validações aplicáveis e atualize o acompanhamento.
Se a tentativa não resolver o pedido, continue o ciclo de investigação e validação; não declare sucesso parcial. Respeite bloqueios reais e autorizações.
Não faça staging, commit nem push automaticamente.
Ao terminar, apresente resumo, verificações, pendências e commit proposto.
Pergunte: “Aprova o commit?”
```

## Acompanhamento
| Sessão | Status | Branch | Escopo resolvido | Validações / Pendências |
| --- | --- | --- | --- | --- |
| S01 | Pendente | — | — | — |
