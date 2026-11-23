# Índice de regras

Leia `AGENTS.md` ou `CLAUDE.md` primeiro. Antes de editar, leia as regras correspondentes aos caminhos e ao tipo de tarefa. O metadado `paths` indica o escopo de cada regra.

| Caminhos afetados | Regra | Quando ler |
| --- | --- | --- |
| `**` | [geral.md](geral.md) | Toda tarefa, inclusive documentação e planejamento |
| `**` | [branches.md](branches.md) | Início de sessão e operações Git/PR |
| `**` | [commits.md](commits.md) | Proposta ou execução autorizada de commit |
| `lib/**`, `test/**`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.claude/hooks/**` | [qualidade.md](qualidade.md) | Implementação, testes, configuração e gates |
| `lib/**`, `pubspec.yaml`, `pubspec.lock`, `android/**`, `ios/**`, `web/**` | [arquitetura.md](arquitetura.md) | Estrutura, dependências, rotas e plataformas |
| `lib/**`, `test/**` | [ui-widgets.md](ui-widgets.md) | Telas, componentes, tema e testes visuais |

Planejamento: `.plan/TEMPLATE.md`. Para alterar integrações dos agentes ou o hook: `.ai/compatibilidade.md`.
