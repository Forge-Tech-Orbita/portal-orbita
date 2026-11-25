# Portal Órbita — plano geral de novas implementações

## Contexto

Completar os fluxos da demonstração e ampliar a persistência no Firestore.
Base de referência em `development`: `fd71f454243c92687def1abcaec45e8476ba43b3`.
Preservar login, vínculo e notas. Ao migrar disciplinas, horários e materiais,
preservar a seleção por instituição, curso e semestre e a grade comum ao Horário
e à próxima aula da Home.

## Organização do trabalho

- Combinar no grupo quem assume cada tarefa. Imagens/RustFS e autenticação dos
  três perfis ficam com o responsável pelo projeto Firebase.
- Manter o roteiro de execução em `.plan/local/<integrante>/<tarefa>/index.md`,
  vinculado pelo ID da sessão e ignorado pelo Git. Registrar no plano geral
  apenas decisões e resultados relevantes para a equipe.
- Medir a meta de 80% após aprovar o inventário de conjuntos de dados (D12).
  Contar cada conjunto uma vez e só após comprovar uso da fonte remota.

## Decisões pendentes

| ID | Decisão | Bloqueia | Estado |
| --- | --- | --- | --- |
| D01 | Confirmar escopo inicial, responsável pela revisão e reserva de arquivos de cada sessão | Início de cada sessão | A combinar no grupo |
| D02 | Aprovar campos, consultas, limites, regras, dados fictícios e responsável pelo provisionamento para cada frente remota | Sessões com Firestore | Pendente por sessão |
| D03 | Fechar detalhes de eventos locais: data, hora, fuso e públicos suportados | S02 | Pendente |
| D04 | Aprovar cálculo, arredondamento e tratamento de etapa incompleta | S03 | Pendente |
| D05 | Fechar origem e entrega inicial de notificações e como impedir que uma excluída reapareça; definir consulta do badge | S05 | Pendente |
| D06 | Aprovar identidade dos funcionários, fonte de papéis/vínculos, resolução de sessão, rotas e separação da demo | S11–S14 | Pendente |
| D07 | Decidir MFA administrativo real, provedor, custo e recuperação | S14 | Pendente |
| D08 | Aprovar fonte dos eventos, fuso, público e política de confirmação/cancelamento | S15–S17 | Pendente |
| D09 | Aprovar formato/plataformas do boletim e escopo da agenda | S18–S19 | Pendente por sessão |
| D10 | Aprovar dependência, política de bloqueio e aparelhos físicos para testes | S20 | Pendente |
| D11 | Confirmar servidor, HTTPS, volume persistente, API autorizadora e manutenção | S21 | Pendente |
| D12 | Aprovar denominador, exceções e evidências para a meta de 80% | Medição da cobertura | Pendente |

## Regras para trabalho em paralelo

1. Ler `AGENTS.md`, `.ai/rules/index.md` e as regras aplicáveis. Começar do
   `development` atualizado, preservar alterações existentes e usar uma
   branch e um PR de escopo fechado por sessão.
2. Confirmar os arquivos reais antes de editar. Se precisar tocar arquivo
   reservado por outra tarefa, parar e combinar a integração; não copiar
   sessão, repositório ou regra para contornar a sobreposição.
3. S01, S02 e S03 podem começar em paralelo **se** respeitarem seus módulos e
   decisões. S01/S02 não devem disputar os mesmos arquivos com S12/S13.
4. Nas frentes remotas, trabalhar em paralelo nos módulos independentes, mas
   combinar a ordem de mudanças em `lib/app.dart`, `lib/core/constants/app_routes.dart`,
   `firestore.rules` e `test/firestore_rules_test.cjs`. Notificações e mural
   também compartilham a Home. Após o merge anterior, atualizar a base e
   revalidar o fluxo seguinte. Cada PR remoto deve carregar as regras e os
   testes necessários à própria entrega, sem publicação concorrente.
5. Sessão e autenticação compartilhadas (`lib/features/auth/data/academic_session.dart`
   e `auth_repository.dart`) têm uma fundação única. As três UIs não começam
   mudanças nesse contrato em paralelo. Não desenvolver novos acessos usando
   a rota simulada como autorização.
6. Executar os gates e a conferência mobile previstos em
   [qualidade.md](../../../.ai/rules/qualidade.md). Para Firestore, rodar também
   a suíte de regras no emulador
   (`test/firestore_rules_test.cjs` com `firebase.emulators.json`), verificar
   negações entre contas/papéis e preservar as regras de perfil, curso e notas.
7. Seguir [commits.md](../../../.ai/rules/commits.md). Teste remoto e
   provisionamento exigem autorização própria. Não alterar projeto Firebase,
   faturamento ou hospedagem Vercel sem aprovação.

## Sessões planejadas

Os IDs identificam tarefas, não impõem uma fila única. As áreas abaixo
indicam fronteiras iniciais, não autorização para editar tudo na pasta.
Todos os itens dependem de D01; itens remotos dependem também de D02.

| ID | Entrega e limite | Área principal | Dependência específica | Aceite mínimo |
| --- | --- | --- | --- | --- |
| S01 | Comunicados locais do professor: preservar mensagem e exibir detalhes; sem envio real | `lib/features/professor/` | Nenhuma | Publicar, abrir e ler a mensagem integral; feedback não promete notificação |
| S02 | Eventos/comunicados locais da coordenação: preservar campos e abrir detalhes; sem presença remota | `lib/features/coordination/` | D03 | Data/hora/local/descrição e público reaparecem corretamente; campos de evento não são exigidos em comunicado |
| S03 | Simulador de meta; não recalcular nota oficial nem escrever no banco | `lib/features/grades/` | D04 | Testar valores-limite e etapa incompleta; resultado identificado como simulação |
| S04 | Chamados privados do aluno: criar, consultar e ver situação; sem integrar admin demonstrativo | `lib/features/support/` | D02 | Protocolo confirmado pelo servidor; histórico sobrevive a novo login; outro aluno não tem acesso |
| S05 | Notificações: listar, marcar lida e excluir da própria caixa, sem push | `lib/features/notifications/`, Home e navegação | D05 | Badge acompanha alterações; releitura persiste e exclusão não apaga o evento/chamado de origem |
| S06 | Tema por UID; apenas opção de tema e cor básica | Perfil e `lib/core/theme/` | D02 | Outra sessão recupera a escolha; nenhum vazamento de estado na troca de aluno |
| S07 | Acervo remoto por instituição, leitura sem PDF | `lib/features/library/` | D02 | Alteração de metadados aparece sem recompilar; aluno não cadastra livros |
| S08 | Empréstimos privados, sem gestão de estoque | `lib/features/library/` | S07 | Lista e prazo corretos; registros de outro UID são inacessíveis |
| S09 | Solicitação de reserva persistente, sem garantir exemplar ou posição na fila | `lib/features/library/` | S07–S08 | Reabertura mantém o pedido próprio; repetição não duplica |
| S10 | Migrar o conteúdo acadêmico demonstrativo para fonte remota | Cursos, Horário/Home e Materiais | D02 | Preservar contexto e filtros. Dividir por fonte (disciplinas, grade, materiais), com aceite próprio |
| S11 | Fundação comum de sessão, papéis, vínculos e guards; sem operações administrativas | Auth, rotas e regras | D06 | Aluno continua funcionando; papel incorreto, inativo ou sem vínculo é negado antes de exibir conteúdo protegido |
| S12 | Login e área protegida do professor; publicação real fora do escopo | `lib/features/professor/` | S11; combinar precedência com S01 | Acesso por papel e vínculo; URL direta, reload e logout sem contorno |
| S13 | Login e área protegida da coordenação; presença remota fora do escopo | `lib/features/coordination/` | S11; combinar precedência com S02 | Coordenação só acessa escopo autorizado; nenhuma lista privada na demo |
| S14 | Login administrativo e MFA real conforme decisão; sem CRUD de contas e papéis | `lib/features/admin/` | S11, D07 | Sem desafio válido não há acesso quando MFA for exigido; papel admin não concede acesso global |
| S15 | Mural remoto de leitura, com publicação por operador autorizado | Avisos e Home | D08; coordenar Home com S05 | Aluno vê eventos apenas do escopo autorizado; sem gravação pelo perfil simulado |
| S16 | Confirmação/cancelamento persistentes pelo aluno | Avisos e regras | S15 | Sobrevive ao login, não duplica e não confirma evento cancelado ou inacessível |
| S17 | Acompanhamento da presença pela coordenação autorizada | Coordenação e regras | S13, S16 | Confirmar e cancelar mudam o total do mesmo evento; acesso a identidades só se aprovado |
| S18 | Agenda de eventos derivada do mural, sem calendário fictício paralelo | Avisos/agenda | S15, D09 | Exibe eventos por data, com vazio e cancelamento coerentes |
| S19 | Espelho de boletim demonstrativo exportável, sem gravar notas | `lib/features/grades/` | D09; coordenar com S03 | Exporta só dados da sessão atual; AV2 ausente não vira zero |
| S20 | Extra: desbloqueio biométrico nativo de sessão existente, não novo login ou MFA | Auth, perfil e plataformas nativas | D10; coordenar com S11 | Testes em Android e iPhone físicos; falha e logout não liberam sessão |
| S21 | Prova de conceito de foto privada com RustFS; não é adoção definitiva | Perfil e ambiente isolado | D11; coordenar perfil com S06/S22 | Upload e leitura privados, isolamento e persistência após reinício; implementação definitiva exige aprovação separada |
| S22 | Contato pessoal textual por UID, sem foto ou alteração do perfil acadêmico | `lib/features/profile/` | D02; coordenar com S06/S21 | Dados reaparecem após login e não podem alterar identidade, curso ou notas |

Ao dividir S10, registrar os sub-IDs e as dependências entre as fontes.

## Dificuldade de implementação por sessão

Dificuldade relativa, não prazo: considera decisões pendentes, impacto nos
arquivos e requisitos externos, como provisionamento e testes em aparelho.

| Sessão | Tarefa | Dificuldade | O que pesa na classificação |
| --- | --- | --- | --- |
| S01 | Comunicados locais do professor | Baixa | Modelo, tela e testes no mesmo módulo; sem Firebase. |
| S02 | Eventos locais da coordenação | Média | Fechar data, fuso e público; ajustar formulário, detalhes, painel e testes; sem backend. |
| S03 | Simulador de meta | Média | Aprovar fórmula e arredondamento; mudanças isoladas em Notas e testes, sem escrita externa. |
| S04 | Chamados privados do aluno | Alta | Formulário, histórico, protocolo e tentativas de reenvio; regras por UID, emulador e operador de situação. |
| S05 | Notificações persistentes | Alta | Lista e badge em telas diferentes; fechar contagem, exclusão e entrega inicial; regras, emulador e dados de teste. |
| S06 | Tema por UID | Média | Perfil e controlador de tema precisam respeitar carregamento e troca de sessão; regras e emulador. |
| S07 | Acervo remoto | Média | Consulta institucional e busca existente; regras, emulador e provisionamento do catálogo. |
| S08 | Empréstimos privados | Média | Biblioteca, relação com acervo e cálculo de prazos; regras por UID e registros de teste. |
| S09 | Solicitação de reserva | Alta | Definir estados e evitar pedidos duplicados; Biblioteca, gravação privada e testes de concorrência no emulador. |
| S10 | Disciplinas, horários e materiais remotos | Alta | Vários módulos e consumidores, incluindo Home; fechar fontes, consultas e dados por contexto. Dividir antes de atribuir. |
| S11 | Fundação de sessão e permissões | Muito alta | Modifica autenticação, rotas e regras compartilhadas; exige fechar identidade, vínculos e provisionamento sem regressão no aluno. |
| S12 | Acesso do professor | Alta | Depende da fundação; login, telas e vínculos a turmas; contas de teste e permissões por papel. |
| S13 | Acesso da coordenação | Alta | Depende da fundação; login, painel e escopo por curso; contas de teste e validação entre instituições. |
| S14 | Acesso administrativo e MFA | Muito alta | Sessão privilegiada, rotas e regras; depende de provedor, suporte nas plataformas, recuperação e possível custo. |
| S15 | Mural remoto de leitura | Alta | Avisos e Home compartilham fonte; fechar público, modelo e fuso; regras, consultas e publicação por operador. |
| S16 | Confirmação e cancelamento de presença | Alta | Definir estados e tentativas repetidas no mesmo evento; regras precisam verificar acesso e situação do evento. |
| S17 | Acompanhamento pela coordenação | Alta | Cruza coordenação, evento e presença; validar contagem e acesso restrito a participantes com perfis de teste. |
| S18 | Agenda de eventos | Média | Depende do mural; organizar datas, filtros e cancelamentos, sem criar outro banco ou fonte. |
| S19 | Exportação de boletim | Média | Fechar formato e plataformas; muda Notas e exportação; pode exigir pacote e teste de download no celular/Web. |
| S20 | Desbloqueio biométrico | Alta | Sessão, ciclo de vida e configuração nativa; requer dependência aprovada e testes em Android e iPhone físicos. |
| S21 | Prova de foto com RustFS | Muito alta | App, API autorizadora, Firestore e armazenamento; depende de HTTPS, disco persistente e testes na hospedagem. |
| S22 | Contato pessoal textual | Média | Formulário, persistência e regras privadas; validar campos sem abrir edição acadêmica, com emulador. |

## Acompanhamento

Após a entrega, registrar o `@` GitHub confirmado de quem implementou, branch,
PR/SHA e evidências. Sem validação obrigatória, usar **implementado — validação
pendente**.

| Sessão | Implementado por (`@` GitHub) | Status | Branch / PR / SHA | Escopo resolvido / validações / pendências |
| --- | --- | --- | --- | --- |
| S01 | — | Planejada | — | — |
| S02 | — | Planejada | — | — |
| S03 | — | Planejada | — | — |
| S04 | — | Planejada | — | — |
| S05 | — | Planejada | — | — |
| S06 | — | Planejada | — | — |
| S07 | — | Planejada | — | — |
| S08 | — | Planejada | — | — |
| S09 | — | Planejada | — | — |
| S10 | — | A dividir | — | — |
| S11 | — | Planejada | — | — |
| S12 | — | Depende de S11 | — | — |
| S13 | — | Depende de S11 | — | — |
| S14 | — | Depende de S11 e D07 | — | — |
| S15 | — | Planejada | — | — |
| S16 | — | Depende de S15 | — | — |
| S17 | — | Depende de S13 e S16 | — | — |
| S18 | — | Depende de S15 | — | — |
| S19 | — | Planejada | — | — |
| S20 | — | Extra | — | — |
| S21 | — | Viabilidade pendente | — | — |
| S22 | — | Planejada | — | — |

## Prompt padrão para iniciar qualquer tarefa

```text
Leia .plan/geral/novas-implementacoes/index.md, AGENTS.md ou CLAUDE.md e as regras aplicáveis.
Antes de implementar, pergunte: “Qual sessão (ID ou título) você combinou com a equipe e quer iniciar?”
Aguarde a resposta. Não escolha a tarefa, não troque de branch e não altere o app enquanto a sessão não for confirmada.
Confirme o identificador da pasta local do integrante se ainda não estiver definido. Confira git status, a base development, o escopo, as dependências e a reserva de arquivos. Se houver decisão bloqueante ou sobreposição, peça alinhamento antes de editar; não decida pela equipe.
Antes de criar um roteiro, procure em .plan/local/ pelo plano recebido para a sessão, mesmo que o nome ou caminho sejam diferentes. Leia o arquivo indicado pelo usuário; se houver dúvida entre dois planos, confirme qual usar.
Se já houver roteiro individual, continue nele. Se o plano recebido for mais amplo, use-o como base e extraia só a sessão escolhida para .plan/local/<integrante>/<tarefa>/index.md, sem modificar as outras frentes. Só comece do zero se não houver material aplicável.
Preserve decisões aprovadas, checklists e evidências existentes. Confira o que ainda vale no código e no plano geral, refine apenas lacunas e pontos desatualizados e peça confirmação se houver divergência de escopo ou contrato. Registre ID da sessão, base, arquivos permitidos, passos, testes com resultado esperado, pontos de parada e o que fica fora do escopo. Mantenha o roteiro ignorado pelo Git.
Com a tarefa confirmada e os bloqueios resolvidos, implemente somente a sessão escolhida e execute as verificações aplicáveis. Atualize o roteiro individual com a execução e as evidências reais.
No plano geral, registre só conclusões úteis à equipe: decisões confirmadas, escopo resolvido, testes executados, pendências e impactos em outras sessões. Ao entregar, preencha o @ GitHub confirmado de quem de fato implementou e o PR/SHA quando existirem. Não declare concluído o que ainda tem validação pendente.
Não copie credenciais, logs sensíveis nem detalhes individuais para o plano geral. Não faça staging, commit, push, PR, merge ou deploy sem as autorizações correspondentes.
```
