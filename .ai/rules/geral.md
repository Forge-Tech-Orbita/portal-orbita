---
paths: ["**"]
---

# Regras gerais

## Escopo e segurança

- Confira `git status --short --branch` e leia arquivos envolvidos, irmãos e consumidores antes de editar. Preserve alterações existentes; não reverta, remova ou inclua trabalho alheio.
- Faça o menor diff completo. Reutilize padrões existentes e registre melhorias independentes sem implementá-las.
- Não adicione pacotes, pastas diretamente em `lib/`, camadas, serviços globais ou bibliotecas de estado/rotas sem aprovação.
- Não edite manualmente `build/`, `.dart_tool/`, registradores gerados ou `.metadata`. Respeite `.gitignore`.
- Não leia nem reproduza segredos sem necessidade; documente nomes de variáveis, nunca valores. Não exponha dados pessoais.
- Preserve acessibilidade, validação, tratamento de erros e descarte de recursos. Não altere autenticação, persistência, navegação ou contratos fora do pedido.
- Fixtures e limites `shortcut:` não definem regras de negócio reais. Pergunte antes de mudar essas decisões.

## Planejamento

1. Use `.plan/TEMPLATE.md` para planos maiores compartilhados em `.plan/geral/<nome>/index.md`, com objetivo, referência Git, decisões, escopo, tarefas, responsáveis, validação e acompanhamento.
2. Detalhamentos individuais ficam em `.plan/local/<integrante>/<nome>/index.md`, referenciando o plano geral. Mantenha-os ignorados pelo Git, sem inclusão forçada; não é necessário converter planos antigos.
3. Registre decisões e resultados da equipe no plano geral, sem depender do roteiro local. Separe execução, validação manual e aprovação Git.
4. Resolva decisões bloqueantes antes de implementar. Mudanças adicionais indispensáveis devem ser mínimas e registradas; melhorias independentes ficam para outra sessão.
5. Siga `.ai/rules/branches.md`; preserve a branch já indicada pelo usuário.

## Persistência e conclusão verificável

- Defina critérios de aceite antes de alterar. Um patch aplicado ou comando com exit 0 não prova resolução.
- Siga **reproduzir → investigar → corrigir → reexecutar a reprodução e as verificações afetadas**. Continue dentro do escopo até atender ao pedido; não entregue tentativa, TODO ou correção executável pelo agente como responsabilidade do usuário.
- Se um gate falhar, interrompa a sequência para corrigir, não a investigação. Reexecute o gate e as verificações restantes; não desative testes ou diagnósticos para esconder a falha.
- Não repita tentativas sem nova evidência ou hipótese. Em bloqueio real de acesso, SDK, dispositivo, credencial, decisão, autorização ou ferramenta, pare só a etapa afetada, informe o necessário e continue as etapas independentes seguras.
- Diferencie **concluído**, **implementado com validação pendente** e **bloqueado**, com evidências e pendências exatas. Respeite cancelamento ou interrupção pelo usuário.
- Persistência não autoriza instalações, upgrades, ampliação de escopo, operações destrutivas ou uso de produção. Instruções e hooks não substituem validação funcional.

## Precedência e fechamento

- Confira fatos no código/configuração atuais. Diferencie implementação existente, política e recomendação; não apresente sugestões como funcionalidades prontas.
- Siga as instruções vigentes e o escopo autorizado do plano.
- Não faça staging, commit ou push automaticamente. Siga `.ai/rules/commits.md`, com autorização separada para operações remotas.
- Encerre com resumo, verificações reais, pendências/riscos, mensagem de commit proposta e **“Aprova o commit?”**.
