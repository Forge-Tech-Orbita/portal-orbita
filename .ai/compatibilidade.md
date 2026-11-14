# Integrações dos agentes

Consulte ao alterar adaptadores, skills ou o hook. As regras de execução ficam em `AGENTS.md` e `.ai/rules/`; mantenha uma única fonte por assunto.

## Arquivos

| Finalidade | Local |
| --- | --- |
| Instruções gerais / Codex | `AGENTS.md` |
| Entrada Claude | `CLAUDE.md`, com importação `@AGENTS.md` |
| Entrada Copilot | `.github/copilot-instructions.md` |
| Entrada Antigravity | `.agents/rules/portal-orbita.md` |
| Skills | `.agents/skills/<nome>/SKILL.md`; catálogo em `AGENTS.md` |
| Configuração do hook Claude | `.claude/settings.json` |
| Hook e autoteste | `.claude/hooks/check.sh`, `.claude/hooks/check-self-test.sh` |

Atualize referências e consumidores quando mover esses arquivos. Preserve a importação Claude e evite copiar regras para os adaptadores.

## Hook

- Requer Bash e Git; Dart/Flutter são necessários quando há alterações relevantes no status.
- Executa verificação de formato e análise, sem modificar fontes. Não substitui os gates de `.ai/rules/qualidade.md` nem autoriza commit ou publicação.
- Uma falha ou interrupção do hook não conclui a tarefa: siga o diagnóstico e os critérios de aceite do plano.
- Ao alterar os scripts, valide a sintaxe dos arquivos afetados e execute `bash .claude/hooks/check-self-test.sh`.
