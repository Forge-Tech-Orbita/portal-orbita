# Índice de regras

Leia `AGENTS.md` ou `CLAUDE.md` primeiro. Depois leia **todas** as regras que corresponderem aos caminhos da tarefa, antes de editar. `paths` é metadado deste índice: sua presença não configura carregamento automático nos editores.

| Caminhos afetados | Regra | Quando ler |
| --- | --- | --- |
| `**` | [geral.md](geral.md) | Toda tarefa, inclusive documentação e planejamento |
| `**` | [branches.md](branches.md) | Início de sessão e operações Git/PR |
| `**` | [commits.md](commits.md) | Proposta ou execução autorizada de commit |
| `lib/**`, `test/**`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.claude/hooks/**` | [qualidade.md](qualidade.md) | Implementação, testes, configuração e gates |
| `lib/**`, `pubspec.yaml`, `pubspec.lock`, `android/**`, `ios/**`, `web/**` | [arquitetura.md](arquitetura.md) | Estrutura, dependências, rotas e plataformas |
| `lib/**`, `test/**` | [ui-widgets.md](ui-widgets.md) | Telas, componentes, tema e testes visuais |

Fatos e comandos medidos: `.ai/auditoria.md`. Integrações e limites de descoberta: `.ai/compatibilidade.md`. Planejamento: `.plan/TEMPLATE.md`. Não há regra de API/Firestore porque essas integrações não existem.
