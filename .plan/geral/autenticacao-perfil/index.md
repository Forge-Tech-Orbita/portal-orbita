# Autenticação e perfil de demonstração

## Contexto
Implementar acesso do aluno via Firebase Auth e perfil por UID antes de consultar notas.
Base: `development` em `45631ab`. Branch: `feature/integrar-autenticacao-e-perfil`.

## Organização do trabalho
- Plano compartilhado com decisões, escopo e resultados desta entrega.
- Detalhamento pessoal em `.plan/local/`, se necessário, sem versionamento.
- Responsável pela implementação: agente nesta sessão; responsável pelo provisionamento e conferência mobile: desenvolvedor.

## Decisões
| ID | Decisão | Status |
| --- | --- | --- |
| D1 | Catálogo fechado: Sapiens (`inst-demo`: `si`, `adm`) e Horizonte (`inst-horizonte`: `si`) | Aprovado |
| D2 | Matrícula numérica textual; e-mail técnico por instituição; contas criadas previamente | Aprovado |
| D3 | Perfil `students/{uid}`; curso nulo até escolha única; demais vínculos imutáveis pelo cliente | Aprovado |
| D4 | Professor/coordenação em demonstração separada; sem entrada biométrica simulada do aluno | Aprovado |
| D5 | Sem consulta de notas, publicação de regras, criação remota de contas ou commit nesta etapa | Aprovado |
| D6 | Na S02, provisionar catálogo, três contas e perfis em `portal-orbita`, preservando identificadores existentes e senhas privadas | Aprovado |
| D7 | Na S02, comparar novamente as regras, sem publicar; filtrar cursos ativos na tela | Aprovado |
| D8 | Na S03, publicar somente as regras do commit `f548409` se a base remota permanecer sem mudanças inesperadas; preparar Android/Web, sem push | Aprovado |

## Sessões planejadas
### S01: autenticação e perfil
- **Objetivo:** autenticar aluno, validar perfil, escolher curso e encerrar sessão sem reaproveitar dados.
- **Escopo:** `lib/app.dart`, catálogo/modelos em `lib/core/`, Auth, Perfil, consumidores de identidade, saídas, testes, regras locais e roteiro de provisionamento.
- **Fora do escopo:** CRUD acadêmico, consulta de notas, autenticação real dos outros perfis, Storage e persistência de preferências.
- **Passos:** inspecionar regras publicadas; implementar sessão/perfil; adaptar consumidores e testes; preparar regras e roteiro; validar.
- **Critério de conclusão:** nenhum fallback de aluno demonstrativo no fluxo real; escolha de curso protegida; respostas antigas descartadas; gates aprovados; validações remotas pendentes explicitadas.
- **Validação técnica:** format/analyze/test/diff, build Android e Web, regras em emuladores locais.
- **Validação manual:** desenvolvedor confere três contas, primeiro acesso, logout, troca de instituição, texto ampliado e teclado em Android; Web separadamente.

#### Execução da S01
- **Regras publicadas conferidas:** API Firebase Rules consultada em modo leitura; apenas `get` de `students/{uid}/grades/{gradeId}` para próprio UID. Proposta preserva essa permissão, incluindo contas antigas sem perfil novo.
- **Implementado:** login Firebase, catálogo fechado, parsing do perfil, escolha única de curso, identidade nas telas e descarte de respostas de sessão antiga.
- **Verificações:** formatação de `lib test tool`, análise sem diagnósticos, 203 testes Flutter, 4 testes de regras nos emuladores Auth/Firestore, builds Android debug/Web e checagem de diff (incluindo arquivos novos) aprovados. Os três exemplos de e-mail foram conferidos pelo conversor CLI. Cobertura adicional para rejeitar evento tardio de outro login.
- **Critérios de aceite:** fluxo e isolamento cobertos por testes locais; regras publicadas inspecionadas e permissão anterior preservada; validação ponta a ponta remota ainda pendente.
- **Baseline / bloqueios:** sem novos pacotes ou alterações no lockfile. Detalhes operacionais preexistentes no acompanhamento local ignorado.
- **Pendências:** provisionamento, publicação de regras mediante autorização separada e conferência no aparelho/navegador; não houve escrita no projeto remoto.
- **Commit proposto:** `feat(auth): integrar autenticação e perfil do aluno`.

## Roteiro de provisionamento
Ver [provisionamento.md](provisionamento.md). Não há senhas nem UIDs reais neste plano.

## Acompanhamento
| Sessão | Status | Branch | Validações / Pendências |
| --- | --- | --- | --- |
| S01 | Implementado; validação solicitada concluída na S03 | `feature/integrar-autenticacao-e-perfil` | Gates locais aprovados; execução manual registrada na S03 |
| S02 | Provisionado; validação solicitada concluída na S03 | `feature/integrar-autenticacao-e-perfil` | Catálogo, contas, perfis e gates locais conferidos; publicação registrada na S03 |
| S03 | Concluído para os cenários solicitados | `feature/integrar-autenticacao-e-perfil` | Regras conferidas, testes manuais aprovados pelo responsável e vínculos confirmados pelo MCP |

### S02: provisionar demonstração e filtrar cursos ativos
- **Objetivo:** provisionar os dados fictícios autorizados, comparar regras e não oferecer cursos inativos.
- **Responsável:** agente para catálogo/perfis e implementação; responsável pelo projeto para senhas privadas e conferência visual.
- **Escopo / arquivos:** `auth_repository.dart`, `academic_session.dart`, `course_selection_screen.dart`, fake/testes de login e este roteiro.
- **Fora do escopo:** publicação de regras, alteração de contas A/B, consulta de notas, commit ou push sem autorização.
- **Decisões necessárias:** D6 e D7 aprovadas; publicação continua sem autorização nesta etapa.
- **Passos:** conferir ambiente/edição e identificadores; criar catálogo; responsável criar contas com senhas privadas; consultar UIDs; criar perfis com condição de inexistência; filtrar cursos ativos e testar; comparar regras.
- **Validação técnica:** reler os seis documentos pelo MCP, conferir contas, format/analyze/test/diff e builds Android/Web.
- **Validação manual:** acesso ponta a ponta em Android/Web somente após publicação autorizada das regras; conferir filtro, curso único, isolamento e logout.
- **Critério de conclusão:** provisionamento conferido, cursos inativos ausentes da seleção, sem fallback em falha do catálogo, sem reaproveitar resposta de sessão antiga, diff das regras apresentado sem deploy.

#### Execução da S02 — 2026-11-21
- **Implementado:** consulta server-only de cursos com `ativo == true`, limitada aos IDs do catálogo fechado; guarda na seleção; mensagem de catálogo vazio e descarte de catálogo tardio após logout.
- **Provisionado e verificado:** banco `(default)`, edição Standard, em `portal-orbita`; três documentos de cursos ativos, três contas de e-mail/senha habilitadas e três perfis conforme o roteiro, com `cursoId: null`. Criações Firestore com precondição `exists: false`, seguidas de releitura e comparação dos campos.
- **Regras publicadas:** nova leitura pelo MCP confirmou somente o `get` da própria nota, sem mudanças em relação à inspeção anterior. A proposta local preserva essa permissão e acrescenta acesso ao próprio perfil, atribuição única de curso ativo e leitura do catálogo da instituição, inclusive cursos inativos.
- **Verificações locais:** formatação, análise sem diagnósticos, 209 testes Flutter, 5 testes de regras nos emuladores, builds Android debug/Web e diff (incluindo arquivos novos) aprovados. A consulta de ativos e o isolamento entre instituições foram exercitados nos emuladores; cursos inativos continuam legíveis pelo titular, mas não aparecem no resultado filtrado. Widget tests cobrem inativos, catálogo vazio/indisponível, logout durante carregamento e seleção com texto 2×.
- **Pendências / bloqueios:** publicação das regras não autorizada; fluxo remoto Android/Web bloqueado na leitura do perfil até publicação. Conferência visual mobile e ponta a ponta não realizadas.
- **Commit proposto:** `fix(auth): filtrar cursos ativos no primeiro acesso`.

### S03: publicar regras e preparar validação Android/Web
- **Objetivo:** publicar apenas as regras aprovadas e preparar a conferência das três contas nas duas plataformas.
- **Responsável:** agente para deploy e preparação; responsável pelo projeto para entrada privada das senhas e validação visual.
- **Escopo / arquivos:** regras de `f548409`, configuração separada existente `firebase.emulators.json`, execução do app sem mudanças em Dart e registro neste plano/roteiro.
- **Fora do escopo:** push, outros serviços, alteração de configurações, redefinição de curso e coleta de senhas.
- **Decisões necessárias:** D8 aprovada; interromper antes de substituir regras se houver divergência inesperada.
- **Passos:** reler regras publicadas, comparar base e commit, validar, publicar somente `firestore:rules`, reler e conferir conteúdo, iniciar Android/Web e executar a matriz do roteiro.
- **Validação técnica:** sintaxe pelo MCP, 5 testes de regras nos emuladores, releitura remota, início no S200 e resposta HTTP do servidor Web.
- **Validação manual:** primeiras escolhas de Sapiens SI/ADM no Android e Horizonte SI na Web; depois as mesmas contas nas duas plataformas, sem redefinir vínculo. Conferir identidade, catálogo permitido, persistência, logout/troca de conta e senha incorreta.
- **Critério de conclusão:** conteúdo remoto correspondente ao commit, demais serviços/configurações preservados e evidência real por cenário; não confundir app iniciado com login validado.

#### Execução da S03 — 2026-11-21
- **Publicado:** nova leitura confirmou base anterior sem alterações inesperadas. `firestore.rules` local igual ao commit `f548409`; sintaxe validada pelo MCP e 5 testes de emuladores aprovados novamente. Deploy com `npx -y firebase-tools@latest deploy --project portal-orbita --config firebase.emulators.json --only firestore:rules --non-interactive`, saída 0.
- **Verificado após deploy:** regras relidas pelo MCP e comparadas com as 38 linhas do arquivo aprovado, com correspondência após normalizar quebras de linha. Sem alteração em `firebase.json` ou configuração de outros serviços; sem push.
- **Baseline dos perfis:** os três perfis ainda tinham `cursoId: null` antes da validação manual.
- **Android:** `flutter run --no-pub --no-resident -d S200000000000014107`, saída 0; compilado, instalado e iniciado no S200 com Android 14.
- **Web:** alvo Chrome falhou após três tentativas de conexão ao depurador. `flutter doctor --verbose` confirmou pré-requisitos Android/Web; sem troca de SDK, dependências ou limpeza. Fallback `flutter run --no-pub -d web-server --web-hostname 127.0.0.1 --web-port 7357` iniciado; HTTP 200 e abertura da URL solicitada ao navegador do sistema.
- **Critérios manuais — relato do responsável:** confirmou que todos os cenários solicitados passaram seguindo a matriz: primeiras escolhas de Sapiens SI/ADM no Android e Horizonte SI na Web; depois as três contas em ambas as plataformas, com identidade/catálogo corretos, curso persistido após sair/entrar, limpeza de dados na troca de conta e rejeição de senha incorreta. O agente não inspecionou visualmente essas interações nem recebeu senhas.
- **Verificação após testes — MCP:** os três perfis mantêm instituição e matrícula esperadas; vínculos confirmados em Sapiens `202600001` → `si`, Sapiens `202600002` → `adm` e Horizonte `202600001` → `si`. Nenhum curso foi redefinido administrativamente.
- **Pendências / limites:** nenhuma nos cenários solicitados, conforme relato e releitura acima. Cenários complementares do roteiro não foram declarados manualmente executados; não houve push ou novo commit.
- **Commit proposto:** `docs(auth): registrar publicação e validação do acesso`.
