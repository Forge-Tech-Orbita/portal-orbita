---
name: infer-conventions
description: "Investigue convenções novas ou divergentes no Portal Órbita e atualize as regras com evidências. Use ao adicionar módulos, rever arquitetura ou detectar documentação desatualizada."
---

# Inferir convenções do Portal Órbita

## Pré-condições e leitura

Leia `AGENTS.md`, `.ai/rules/index.md` e o plano da tarefa. Confirme fatos no código/configuração atuais. Execute na raiz do repositório. Os caminhos deste procedimento são relativos à raiz, não à pasta da skill.

## Procedimento

1. Execute `git status --short --branch` e identifique trabalho preexistente. Não troque branches nem atualize remotes só para investigar.
2. Liste arquivos ativos com `git ls-files lib test pubspec.yaml pubspec.lock analysis_options.yaml`. Para arquivos novos não rastreados, confira também o status. Não inspecione caches ou builds.
3. Leia o ponto alterado, seus consumidores e arquivos irmãos. Compare com `lib/app.dart`, `lib/core/theme/orbita_theme.dart`, `lib/features/home/presentation/home_screen.dart` e a feature pertinente.
4. Identifique se há repetição real ou uma exceção: localização, nomes, imports, estado, dados, componentes e navegação. Uma única implementação diferente não cria automaticamente um novo padrão global.
5. Confira `pubspec.yaml`, `pubspec.lock` e inicializações antes de afirmar que um pacote ou serviço existe. Não descreva integração planejada como implementada; verifique código e configuração reais, sem ler segredos.
6. Se o fluxo Git mudou, leia `git remote -v`, `git branch -a` e `git log -n 30 --oneline`; oculte credenciais. Verifique a branch padrão no provedor quando possível. Não presuma `main` nem deduza proteções pelo nome.
7. Monte uma tabela curta: afirmação, arquivo/símbolo ou configuração, categoria (observado/política/recomendação) e impacto nas regras. Peça decisão quando a documentação exigir escolher entre padrões conflitantes.
8. Atualize somente regras afetadas em `.ai/rules/` e os globs do índice. Mantenha orientações gerais em `AGENTS.md` e preserve a importação `@AGENTS.md` em `CLAUDE.md`, sem duplicar regras; uma frase curta junto da importação é aceita. Confira os resumos dos demais adaptadores sem copiar as regras para o Claude.
9. Se alterar caminhos de skills/hooks/adaptadores, confira `.ai/compatibilidade.md` e atualize seus consumidores.
10. Confira links, caminhos, frontmatter e `git diff --check`; execute os gates de código somente se houver mudança que os exija. Registre comandos realmente executados e limites.

## Pare quando

- Uma nova convenção exigir pacote, camada, backend ou alteração funcional fora do escopo.
- A evidência estiver apenas em um plano futuro ou dependência não usada.
- Faltar decisão da equipe sobre um conflito. Documente a dúvida, não imponha sua preferência.

## Resultado esperado

Entregue regras atualizadas com referências reais, lista do que mudou e decisões pendentes. Não reestruture o app para satisfazer a documentação. Não faça staging/commit/push automaticamente; proponha o commit e pergunte **“Aprova o commit?”**.
