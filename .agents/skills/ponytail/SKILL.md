---
name: ponytail
description: "Aplique o modo Lazy Senior Dev no Portal Órbita: resolva o pedido inteiro com o menor diff completo. Use ao implementar, corrigir, refatorar ou revisar código, escolher dependências, ou quando o usuário pedir simplicidade, YAGNI ou ponytail."
---

# Ponytail — Lazy Senior Dev

Versão local adaptada do modo Ponytail full para as regras do Portal Órbita. Não depende de instalação global nem de pacote externo.

## Antes de alterar

Leia `AGENTS.md`, `.ai/rules/index.md` e as regras dos caminhos afetados. Os caminhos desta skill são relativos à raiz do repositório.

1. Confira `git status --short --branch` e preserve trabalho existente.
2. Leia o código, todos os consumidores e os testes do ponto alterado. Liste onde a mudança precisa chegar: chamadas, fixtures, configuração e contratos compartilhados.
3. Identifique riscos de perda/exposição de dados, quebra de comportamento e acessibilidade. Pergunte sobre decisões bloqueantes; não invente regra de negócio.
4. Separe o necessário para concluir o pedido de melhorias independentes. Registre estas no plano, sem implementá-las.

## A menor solução completa

- Implemente somente o que foi pedido. Não acrescente opções, camadas, wrappers ou flexibilidade para um futuro hipotético.
- Reutilize primeiro os padrões e componentes do projeto: `OrbitaTheme`, `AppRoutes`, `lib/core/widgets/` e arquivos irmãos. Depois considere recursos da plataforma e dependências já instaladas, sem criar alternativas redundantes.
- Prefira código direto e legível, preservando a organização atual. Não adicione pacote ou pasta raiz em `lib/` sem aprovação.
- Em correções, investigue consumidores e causa raiz; corrija uma vez no ponto compartilhado. Não esconda texto, desative diagnósticos ou remova validações para mascarar falhas.
- Prefira remover duplicação a criar abstração sem necessidade. Código movido ou reunido mantém validação e tratamento de erros.
- Entre soluções de tamanho semelhante, escolha a correta também nos casos extremos.
- Comente apenas motivos que o código não explica. Para um limite conhecido aceito no escopo, use `shortcut: <limite>, <quando revisar>`.
- Nunca sacrifique segurança, acessibilidade, tratamento de erros que evita perda de dados ou qualquer requisito solicitado para reduzir o diff.

## Verificação e entrega

1. Complete os consumidores, fixtures e testes afetados. Lógica nova não trivial deixa uma pequena regressão na stack existente; mudanças triviais não exigem teste artificial.
2. Execute as verificações aplicáveis em `.ai/rules/qualidade.md`. Para UI ou falha de ambiente, leia também a skill específica de Flutter ou diagnóstico; não pule validação por chamar a solução de simples.
   Se a tentativa não resolver o pedido, siga o ciclo de persistência em `.ai/rules/geral.md`: reproduza novamente, investigue e corrija até atender aos critérios ou identificar um bloqueio real. Não entregue uma tentativa como solução concluída.
3. Pare a etapa bloqueada se faltar SDK, dispositivo, acesso ou decisão. Informe comando/erro e não declare sucesso nem instale/atualize ferramentas silenciosamente.
4. Atualize o plano geral com decisões e resultados da equipe; mantenha roteiros individuais em `.plan/local/` ignorados pelo Git.
5. Responda de forma curta: resultado, verificações reais, pendências e commit proposto. Não faça staging, commit ou push automaticamente; pergunte **“Aprova o commit?”**.
6. No fechamento, deixe explícito o que não foi alterado/verificado e qualquer risco restante.
