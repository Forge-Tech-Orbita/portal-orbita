# GitHub Copilot — Portal Órbita

Leia `AGENTS.md`, `.ai/rules/index.md` e as regras aplicáveis antes de editar. Os caminhos são relativos à raiz do repositório.

- **Git:** não faça staging, commit ou push automaticamente. Commit exige aprovação explícita; push, PR, merge, release e deploy exigem autorizações separadas. Se o modo do cliente exigir publicação automática, esclareça a incompatibilidade antes de iniciar.
- **Escopo:** confira `git status --short --branch`, preserve trabalho existente e faça o menor diff completo. Não adicione pacotes/camadas sem aprovação nem edite gerados.
- **Projeto:** Flutter/Dart com fixtures locais. Reutilize `lib/core/`, `lib/features/`, `OrbitaTheme`, `AppRoutes`, widgets, estado local e navegação existentes, conforme `.ai/rules/arquitetura.md` e `.ai/rules/ui-widgets.md`.
- **Conclusão:** se uma tentativa falhar, continue investigando, corrigindo e validando dentro do escopo, conforme `.ai/rules/geral.md`. Registre bloqueios reais sem declarar sucesso.
- **Validação:** execute os gates de `.ai/rules/qualidade.md` aplicáveis à tarefa. Documentação não exige gates Flutter; UI exige conferência mobile além dos testes.
- **Planejamento:** siga `.plan/TEMPLATE.md`; planos compartilhados ficam em `.plan/geral/`, detalhamentos individuais em `.plan/local/` ignorados pelo Git. Registre decisões e resultados no plano geral.
- **Branch/commit:** base e PR diário em `development`; preserve a branch indicada. Use Conventional Commits em português no infinitivo, conforme as regras Git.
- **Fechamento:** resumo, verificações reais, pendências/riscos, mensagem proposta e **“Aprova o commit?”**.

Skills: consulte o catálogo em `AGENTS.md`.
