# Notas integradas e apresentação mobile

## Contexto
Preparar o fluxo aluno autenticado → perfil → curso → notas → logout para apresentação no Android e no navegador do celular. Destino atualizado em 2026-11-23: primeira publicação Vercel de produção, após promoção por PR para `production`, sem deploy nesta preparação.

Base remota conferida em 2026-11-22: `origin/development` em `8876c1a`, merge do PR [#21](https://github.com/Forge-Tech-Orbita/portal-orbita/pull/21). PR integrado em 2026-11-21; nenhuma ação de merge pendente para autenticação/perfil. `origin/production` está em `5160faa`, ancestral de `development`, com diferença de 103 commits. A promoção exige revisar o conjunto da entrega, não apenas notas.

Levantamento realizado na branch existente `feature/integrar-autenticacao-e-perfil`, sem trocar/atualizar branches locais. Seu conteúdo rastreado coincide com `origin/development`. Implementação futura deve partir de `development` atualizado, em nova branch `feature/integrar-notas-do-aluno`, com PR próprio para `development`.

O levantamento inicial foi somente documental. A S01 foi autorizada em 2026-11-22 e commitada depois em `1dd6d2d`, com aprovação separada. Na S02 foram autorizados somente os nove documentos planejados, publicação das regras do Firestore e validação técnica com autenticação de aluno; sem redefinir curso/senha, iniciar Android, push, merge ou publicação Vercel.

## Organização do trabalho
- Plano compartilhado neste arquivo; decisões e evidências futuras devem ser registradas aqui.
- Agente: implementação e testes após aprovação; responsável pelo projeto: aprovação do contrato, operações remotas e conferência visual no celular.
- Cada sessão de implementação deve ter escopo fechado e PR para `development`. Preparação Vercel pode seguir em `chore/preparar-preview-web`, após integrar notas.

## Diagnóstico confirmado
- Firestore `(default)` de `portal-orbita`: Standard, `southamerica-east1`, confirmado pela CLI em modo leitura.
- `GradesScreen` recebe `demoGrades` por padrão; `MainNavigationScreen` instancia essa tela sem dados remotos.
- `Grade` e `GradeStage` já representam disciplina, código, etapas, frequência e situação. Os asserts dos construtores não bastam para validar dados remotos em release.
- AV1 = prova (0–7) + TED (0–3); AV2 = prova (0–6) + TED (0–3) + integrada (0–1). Etapa incompleta retorna `null`; média exige ambas completas; zero é nota válida.
- `summarizeGrades` calcula média simples das disciplinas com média disponível e contagens. Situação é informada, não inferida pela média. Preservar essas decisões e `formatGrade`.
- `StudentProfile` fornece UID, `semester` e `courseId`. `AcademicSession` já invalida a navegação em mudanças de conta; não é necessário outro estado global.
- CRA 8,7 e 18 aprovações históricas são constantes de `grades_mock.dart`. Home também mostra CRA 8,7, frequência 91% e créditos 142 fixos, sem fonte acadêmica.
- `firestore.rules` permite apenas `get` das próprias notas e nega `list`/escritas. O contrato legado das contas A/B precisa continuar funcionando, inclusive sem os novos perfis.
- Não há `vercel.json`, script de build Vercel ou vínculo `.vercel` no repositório. Isso não prova ausência de configuração externa no painel.
- Web inicializa Firebase; não há uso de `usePathUrlStrategy`. Manter a estratégia padrão com fragmento (`/#/...`) no primeiro preview. As abas usam `IndexedStack`, sem URLs individuais.
- `web/index.html` usa `$FLUTTER_BASE_HREF` e `flutter_bootstrap.js`; título/descrição e manifest ainda são genéricos.

## Decisões propostas
| ID | Decisão | Bloqueia | Status |
| --- | --- | --- | --- |
| D1 | Usar os documentos, consulta e validação descritos abaixo, sem migrar notas antigas | S01 | Aprovado em 2026-11-22; S01 autorizada |
| D2 | Omitir CRA/históricos e métricas fixas sem fonte; manter somente resumo do semestre consultado | S01 | Diretriz do pedido; solução proposta abaixo |
| D3 | Aprovar os dados fictícios e autorizar separadamente inspeção/cadastro remoto sem sobrescrita e publicação apenas das regras revisadas | S02 | Aprovado após S01; nove documentos e somente regras do Firestore |
| D4 | Confirmar destino Vercel e método de build | S03 | Hobby existente `ricardopmartinsgtpvh-1353`, projeto pretendido `portal-orbita`; primeira publicação assumida como produção. Sem criação/vínculo ou deploy nesta preparação |
| D5 | Preparar promoção do conjunto `development` → `production` após revisão completa | S04 | PR autorizado em 2026-11-23; merge e deploy não autorizados. Regenerar build do commit integrado em `production` |

## Contrato de documentos proposto
Manter a coleção existente `students/{uid}/grades/{gradeId}`. Um documento por disciplina/oferta no semestre e curso; ID determinístico `<semestreLetivo>_<cursoId>_<code>`, com componentes validados, sem barras. Não reutilizar/migrar IDs antigos.

Exemplo de documento novo `2026-2_si_ESW-304`:

```json
{
  "semestreLetivo": "2026-2",
  "cursoId": "si",
  "subject": "Arquitetura de Software",
  "code": "ESW-304",
  "firstStage": {"exam": 6, "ted": 2.6},
  "secondStage": {"exam": 5.5, "ted": 2.5, "integratedAssessment": 1},
  "frequency": 94,
  "status": "inProgress"
}
```

- Preservar nomes/propriedades de `Grade`; metadados acadêmicos seguem o perfil existente. Não duplicar UID, matrícula, instituição ou nome do aluno no documento.
- Todos os campos acima são obrigatórios; componentes de nota aceitam explicitamente `null` para não lançada. Não converter ausência/mau formato em zero ou disciplina demonstrativa.
- `subject`/`code`: strings não vazias, limites propostos de 120/30 caracteres; código restrito a letras maiúsculas, números e hífen. Validar consistência entre ID e metadados.
- `semestreLetivo`: formato `AAAA-1`/`AAAA-2`, exatamente o semestre solicitado; `cursoId`: exatamente o curso solicitado.
- Etapas: mapas apenas com as chaves definidas; números finitos dentro dos limites atuais ou `null`. Converter `num` para `double` somente na fronteira do parser.
- Frequência: inteiro de 0 a 100; situação: um de `inProgress`, `completed`, `approved`, `failed`. Não recalcular situação pela nota ou frequência.
- Não armazenar média, CRA, contagens, créditos ou totais derivados. Sem versão de schema ou campos futuros sem uso.
- Parser validado em runtime antes de construir os modelos atuais. Documento inválido produz erro de dados na consulta inteira: não esconder disciplina nem apresentar resumo parcial como completo.
- Contrato é proposta para os novos documentos; dados legados continuam intactos e não precisam passar pelo novo parser se fora da consulta.

## Consulta, ciclo de vida e estados
Adicionar `lib/features/grades/data/grades_repository.dart`, com contrato pequeno injetável e implementação Firebase, seguindo o padrão de `AuthRepository`, sem dependências novas.

Consulta única ao servidor:

```dart
FirebaseFirestore.instance
    .collection('students/${profile.uid}/grades')
    .where('semestreLetivo', isEqualTo: profile.semester)
    .where('cursoId', isEqualTo: profile.courseId)
    .get(const GetOptions(source: Source.server));
```

- Só consultar após sessão/perfil válidos e curso definido; não aceitar UID ou semestre digitados pelo usuário.
- Ordenar os poucos resultados em memória por código, com desempate por ID; evitar `orderBy` e índice composto sem necessidade. Confirmar índices padrão durante validação remota; não presumir a configuração do servidor.
- Buscar ao montar o conteúdo de notas e por ação explícita de atualizar/tentar novamente; sem listener em tempo real, polling ou persistência nova.
- Injetar repositório por `MainApp` → `MainNavigationScreen` → `GradesScreen`; testes usam fake explícito, nunca fallback automático. Nenhuma mudança na interface de autenticação é necessária.
- Reutilizar estado local da tela e o descarte da árvore na troca de sessão. Chave da carga: UID + semestre + curso; invalidar requisição anterior ao atualizar/trocar chave e verificar montagem antes de aplicar resposta.
- Preservar filtros/expansões ao alternar abas dentro da mesma sessão. Logout/troca de conta descarta notas, erro, filtros e respostas atrasadas.

| Estado | Apresentação |
| --- | --- |
| Carregando | Indicador e texto acessível; sem cards/indicadores fictícios ou dados anteriores |
| Sucesso | Semestre do perfil, disciplinas, detalhes AV1/AV2, frequência e resumo atual |
| Vazio | “Nenhuma nota cadastrada para este semestre”, com atualizar; sem métricas zeradas sugerindo boletim completo |
| Erro de rede/permissão | Mensagem segura e tentar novamente; não tratar como vazio ou usar cache como confirmação do servidor |
| Documento inválido | Mensagem de indisponibilidade dos dados e tentar novamente; sem notas parciais nem detalhes sensíveis |
| Sessão ausente/encerrada | Guard existente; não consultar nem mostrar fixture |

Trocar a alegação “importadas do sistema acadêmico” por identificação verdadeira: dados fictícios de apresentação consultados no Firestore. Remover o default `demoGrades` do caminho de produção; fixtures podem permanecer exclusivamente nos testes.

Remover CRA/anel e total histórico em Notas. Renomear contagem para “Aprovadas no semestre”; manter “Cursando”, “Pendentes” (médias incompletas) e média do semestre com a fórmula atual. Na Home, omitir o bloco fixo CRA/frequência/créditos: não chamar média simples de CRA, nem criar uma regra de frequência global.

Identificar os demais módulos como demonstrativos com aviso visível na casca do aluno, distinguindo o fluxo integrado das demais abas/atalhos. Não conectar horários, disciplinas da aba Cursos, financeiro, biblioteca ou outros módulos nesta entrega.

## Alteração mínima de regras proposta
- Preservar sem alterações a permissão `get` existente de `students/{uid}/grades/{gradeId}` para `owner(uid)`, protegendo compatibilidade A/B.
- Adicionar somente `list` nesse match, condicionado ao próprio UID, perfil com identidade válida, curso não nulo, e `resource.data.semestreLetivo`/`resource.data.cursoId` iguais aos campos correspondentes do perfil.
- A consulta precisa fornecer os dois filtros de igualdade; regras não filtram resultados. Consulta ampla, outro semestre/curso, sem perfil válido, sem login ou para UID alheio deve ser negada.
- Não permitir `create`, `update` ou `delete` de notas pelo cliente, nem coleção de alunos, consulta global/collection group ou acesso entre instituições.
- Campos das notas são escritos somente por operação administrativa autorizada. Validação no provisionamento e no parser continua necessária: Admin SDK ignora regras.
- Não alterar regras de perfil, escolha de curso ou catálogo. Preservar `firebase.json` gerado e usar a configuração separada `firebase.emulators.json` para eventual deploy autorizado somente de `firestore:rules`.
- Trata-se de proposta a revisar e verificar no emulador, não de regra implementada/publicada. Antes de publicar, reler regras remotas, comparar com a base revisada e parar em divergência inesperada.

## Plano de dados fictícios
Usar as mesmas três contas e vínculos registrados no [roteiro de provisionamento](../autenticacao-perfil/provisionamento.md). Confirmar novamente UID, instituição, matrícula, curso e semestre antes de qualquer escrita; não redefinir curso ou senha.

Proposta inicial: três documentos por conta no semestre do perfil (esperado `2026-2`). Cada tupla de etapa abaixo segue `(exam, ted)` / `(exam, ted, integratedAssessment)`.

| Conta / curso | Código / disciplina | AV1 | AV2 | Frequência | Situação |
| --- | --- | --- | --- | --- | --- |
| Sapiens `202600001` / SI | ESW-304 / Arquitetura de Software | (6; 2,6) | (5,5; 2,5; 1) | 94 | inProgress |
| Sapiens `202600001` / SI | ESW-298 / Banco de Dados II | (4,5; 2) | (4,5; 2; 0,5) | 86 | inProgress |
| Sapiens `202600001` / SI | ESW-412 / Inteligência Artificial | (5; 2) | (null; null; null) | 92 | inProgress |
| Sapiens `202600002` / ADM | ADM-201 / Gestão de Pessoas | (7; 3) | (6; 3; 1) | 100 | approved |
| Sapiens `202600002` / ADM | ADM-202 / Contabilidade Gerencial | (4; 2) | (0; 0; 0) | 80 | failed |
| Sapiens `202600002` / ADM | ADM-203 / Marketing | (5; 2) | (null; null; null) | 90 | inProgress |
| Horizonte `202600001` / SI | SIS-201 / Redes de Computadores | (6; 2) | (5; 2; 1) | 96 | approved |
| Horizonte `202600001` / SI | SIS-202 / Sistemas Operacionais | (5; 2) | (4; 2; 1) | 88 | completed |
| Horizonte `202600001` / SI | SIS-203 / Algoritmos | (3; 2) | (null; 2; null) | 84 | inProgress |

São exemplos fictícios, não critérios acadêmicos novos. As médias esperadas dos documentos completos são, respectivamente: SI Sapiens 8,8 e 6,75; ADM 10 e 3; SI Horizonte 8 e 7. Resumos usam somente as disciplinas completas, conforme cálculo atual.

Procedimento futuro, somente após D3:
1. Inspecionar notas existentes das três contas e IDs alvo em modo administrativo de leitura, sem divulgar dados pessoais/credenciais. Essa inspeção não foi realizada nesta sessão.
2. Se já houver documentos que a consulta nova retornaria, avaliar compatibilidade/duplicação e parar para decisão, em vez de anexar disciplinas duplicadas ou migrar silenciosamente.
3. Preparar manifesto fixo apenas com os nove documentos aprovados e validá-lo localmente. Não criar ferramenta administrativa genérica ou adicionar dependência ao app.
4. Criar atomicamente com precondição `exists: false` em cada escrita. Qualquer conflito interrompe o lote; nunca usar `set`/upsert que substitua documento existente.
5. Em repetição, reler: documentos idênticos podem ser reconhecidos como já provisionados; divergência exige decisão. Manter todos os IDs legados e dados das contas A/B.
6. Reler e comparar os nove documentos; testar leitura com sessão de aluno sob as regras publicadas, pois releitura administrativa não prova autorização do cliente.
7. Testar vazio/erro/mau formato em fake/emulador; não apagar dados remotos nem corromper contas de apresentação para simular falhas.

## Preparação Vercel
### Build estático e primeira publicação
- Aplicação estática, sem backend Vercel e sem credenciais administrativas Firebase.
- Compilar localmente o commit validado com Flutter fixo (`3.47.7`, Dart `3.13.5` nesta conferência): `flutter build web --no-pub --base-href /`. Dependências precisam estar resolvidas antes.
- Saída: `build/web`, ignorada pelo Git. A primeira publicação será de produção, no Hobby existente, projeto `portal-orbita`, somente após integração por PR e autorização própria de deploy. Nunca enviar a raiz com arquivos locais/planos privados.
- Para upload estático, usar preset Other e nenhum build remoto adicional. Não presumir Flutter instalado na Vercel.
- Na preparação da S03, foi gerado também pacote [Build Output API v3](https://vercel.com/docs/build-output-api/configuration), com `.vercel/output/static` contendo apenas o build e `config.json` de artefato estático. A publicação futura desse pacote deve usar `--prebuilt`, sem upload da raiz do repositório ou dos demais arquivos locais.
- Manter URLs com fragmento no primeiro preview: refresh solicita `/`, sem precisar de rewrite geral. A aba Notas não possui deep link; atualizar pode retornar à Home após restaurar sessão. Isso é aceitável se aprovado e explicado, não preservação da aba garantida.
- Se URLs sem `#` forem exigidas depois, aprovar mudança de estratégia e fallback SPA que preserve arquivos estáticos; testar refresh e entrada direta com os guards antes de publicar.
- Ajustar `web/index.html` e `web/manifest.json` para nome/descrição corretos. Não prometer instalação/offline como PWA sem validação específica.
- Validar HTTPS, assets/fontes/CanvasKit, rede Firebase, restauração de sessão e logout no domínio real. Conferir domínios autorizados/restrições de chave no Firebase sem flexibilizar regras por suposição; email/senha não exige introduzir OAuth.
- Não configurar cache imutável geral para HTML/bootstrap; conferir atualização de versão sem exigir limpeza manual do navegador.
- **Primeiro deploy:** a [documentação da CLI](https://vercel.com/docs/cli/deploy#prod) informa que o primeiro deploy de projeto novo é de produção mesmo sem `--prod`; esse ambiente foi assumido pelo responsável. Isso não autoriza publicar agora. Não criar/vincular projeto, alterar Production Branch ou ativar integração Git nesta preparação.
- **Origem obrigatória do artefato final:** após integrar S03 em `development` e promover por PR para `production`, obter o SHA remoto de `production`, conferir árvore limpa e regenerar `flutter build web --release --no-pub --base-href /` desse commit. Revalidar gates, pacote e hashes; registrar SHA, versões Flutter/Dart e recibo do artefato. O pacote anterior da S03 é apenas evidência local e **não deve ser publicado**.
- Antes da publicação futura, confirmar projeto/equipe, domínio, políticas do Hobby e restrições Firebase sem flexibilização automática. Publicar somente o pacote Build Output API v3 regenerado; a autorização de deploy continua separada. Por ser a primeira publicação, não existe artefato Vercel anterior para rollback: interromper a publicação ou retirar o deployment se necessário, sem reverter dados/regras automaticamente.

### Automação posterior, se escolhida
Se o responsável preferir deploy por Git desde o começo, confirmar equipe/projeto Vercel, preparar `vercel.json` com saída `build/web` e script de build com SDK Flutter fixo/disponibilidade verificada, resolução de dependências e build release. Arquivos propostos nesse caso: `vercel.json`, `scripts/vercel-build.sh` e `.gitignore` para `.vercel/`. Não usar `latest` nem instalar SDK/pacotes nesta etapa.

Para uma futura automação Git, propor `production` como Production Branch, não `development`; qualquer alteração exige autorização separada. A promoção segue revisão e PR `development` → `production`; Git integration/deploy automático deve ser autorizado antes de ativar. Nenhuma Production Branch foi alterada na S03. Build remoto Linux e configurações de um projeto no painel ainda não foram verificados.

Referência: [configuração de projetos Vercel](https://vercel.com/docs/project-configuration).

## Arquivos envolvidos na implementação
| Arquivo | Alteração prevista |
| --- | --- |
| `lib/features/grades/data/grade.dart` | Parser de fronteira com validação, preservando modelos/getters/cálculos |
| `lib/features/grades/data/grades_repository.dart` (novo) | Consulta de notas por UID/semestre/curso e ordenação |
| `lib/features/grades/presentation/grades_screen.dart` | Carga, retry/atualização, estados, semestre, remoção de históricos e fixture default |
| `lib/features/grades/data/grades_summary.dart` | Preservar cálculos; arquivo de referência/teste, sem mudança prevista |
| `test/grades_fixtures.dart` | Fixtures movidas de `lib/features/grades/data/grades_mock.dart`, exclusivas de testes |
| `lib/features/grades/presentation/widgets/gpa_ring_progress.dart` (removido) | Sem consumidor após omitir CRA; retirar widget e constantes históricas |
| `lib/app.dart` | Injetar repositório de notas, preservando guards e reset de sessão |
| `lib/features/navigation/presentation/main_navigation_screen.dart` | Passar repositório; identificar módulos demonstrativos |
| `lib/features/home/presentation/home_screen.dart` | Omitir métricas fixas sem fonte |
| `firestore.rules` | Acrescentar apenas list próprio condicionado ao perfil/semestre/curso |
| `test/grades_test.dart`, `test/grades_repository_test.dart` (novo), `test/fake_grades_repository.dart` (novo) | Parser, consulta/contrato, estados, filtros, resumo e resposta atrasada |
| `test/helpers.dart`, `test/login_test.dart`, `test/navigation_test.dart`, `test/migration_audit_test.dart`, `test/profile_test.dart` | Injetar fake onde necessário e revisar expectativas de integração/isolamento |
| `test/firestore_rules_test.cjs` | Consultas permitidas/negadas e preservação get legado; suportar maps/null/números fracionários nas fixtures REST |
| `web/index.html`, `web/manifest.json` | Identidade Web e conferência do preview; não reescrever bootstrap |
| `README.md`, `.ai/rules/arquitetura.md`, este plano | Atualizar fontes de dados, limites e instruções após implementação real |

Não alterar `StudentProfile`, cálculos acadêmicos, `AuthRepository`, configuração Firebase gerada, SDK/lockfile ou adicionar dependências sem necessidade demonstrada/aprovação.

## Regras para todas as sessões
1. Ler `AGENTS.md`, índice e regras aplicáveis; preservar alterações existentes.
2. Resolver decisões bloqueantes; nenhuma autorização desta etapa vale como autorização de operação remota.
3. Uma branch/PR por escopo; sem merge, staging, commit, push ou deploy automático.
4. Executar separadamente formato, análise, suíte Flutter e diff; corrigir o primeiro erro antes do próximo gate. Usar emuladores para testar regras antes da publicação.
5. Registrar resultados reais, separando execução técnica, confirmação manual e aprovação Git. Build/testes não substituem celular real.

## Sessões planejadas
### S01: integrar leitura e apresentação de notas
- **Responsável:** agente após aprovação de D1; responsável pelo projeto para revisão.
- **Escopo:** modelos/parser, repositório, tela, injeção, Home, aviso demonstrativo, regras locais, documentação e testes listados.
- **Fora do escopo:** dados remotos, deploy de regras, Vercel, merge/promoção e conexão de outros módulos.
- **Passos:** adicionar parser/testes; consulta e fake; estados/isolamento; remover métricas sem fonte; regra list e regressões.
- **Validação técnica:** `dart format --output=none --set-exit-if-changed lib test`; `flutter analyze --no-pub`; `flutter test --no-pub`; `git diff --check`; emuladores Auth/Firestore conforme roteiro existente; builds Android debug e Web.
- **Regressões obrigatórias:** int/double/null/zero, limites e NaN/infinito, enum inválido, metadados divergentes, AV2 pendente, resumo inalterado, vazio vs erro, retry, troca de conta durante carga e preservação de filtros na mesma sessão.
- **Regras:** listar apenas próprio semestre/curso com perfil válido; negar consulta ampla/outro semestre/curso/UID, sem login/perfil válido e toda escrita; preservar get legado A/B. Testar duas instituições com a mesma matrícula.
- **Critério de conclusão:** gates locais aprovados e nenhuma fixture/histórico sem fonte no fluxo real; validação remota explicitamente pendente até S02.

### S02: provisionar e validar Android/Web
- **Responsável:** agente para operações aprovadas; responsável pelo projeto para senhas privadas e validação visual.
- **Decisão necessária:** D3, com autorização explícita de cadastro e publicação somente de regras.
- **Passos:** reler base remota/regras; inspecionar documentos existentes; cadastrar nove documentos sem sobrescrita; publicar só regras revisadas; reler; executar matriz.
- **Validação manual:** três contas no Android e navegador do celular: login, identidade, curso já vinculado, Home sem indicadores inventados, Notas com dados distintos e semestre correto, detalhes/cálculos, perfil, logout e troca entre contas. Não redefinir curso para repetir escolha única; ela já foi validada na entrega anterior.
- **Ajuste aprovado após S01:** não iniciar Android para conferência rotineira. A validação visual será feita pelo responsável no navegador do celular antes da apresentação, sem bloquear a preparação do preview.
- **Critério técnico de conclusão:** regras publicadas correspondentes ao commit revisado, nove documentos conferidos sem sobrescrita e consultas reais com tokens Firebase de aluno, incluindo isolamento e negativas. Releitura administrativa não substitui esse teste. Layout, navegação e logout visual permanecem pendentes para a conferência completa no celular.

### S03: preparar preview Vercel
- **Responsável:** agente e responsável pelo projeto; D4 obrigatória.
- **Escopo atualizado:** preparação local do artefato estático, identidade Web, configuração mínima e PR para `development`; sem publicação. A promoção por PR pertence à S04.
- **Validação:** navegador real do celular, login/restauração, abas/retorno, refresh com/sem sessão, rota desconhecida, logout seguido de voltar/recarregar, assets, texto ampliado, erros de rede e atualização para novo build.
- **Critério de preparação:** commit/PR e artefato de conferência identificados, destino aprovado e roteiro de regeneração do build final em `production`. URL publicada e aprovação visual são critérios posteriores à autorização própria de deploy.

### S04: promover versão estável
- **Responsável:** responsável pelo projeto, com apoio do agente sob autorização.
- **Decisão necessária:** D5.
- **Passos:** conferir diff completo das branches, gates, aprovação e conversas resolvidas; PR separado de `development` para `production`; publicar somente quando autorizado.
- **Critério de conclusão:** versão/commit publicados conferidos e plano de retorno ao artefato anterior conhecido, sem rollback de dados ou regras automático.

## Acompanhamento
| Sessão | Status | Branch | Escopo resolvido | Validações / Pendências |
| --- | --- | --- | --- | --- |
| Levantamento | Concluído | Branch existente de autenticação; sem troca | PR/branches, código, contrato proposto e Web | D1/D3 aprovadas; D4/D5 pendentes |
| S01 | Implementada e commitada; validação técnica remota na S02 | `feature/integrar-notas-do-aluno` | Parser, consulta, estados, isolamento, apresentação e regras locais | 242 testes Flutter, 9 de regras, análise/formato e builds Android/Web aprovados |
| S02 | Concluída tecnicamente; visual pendente | `feature/integrar-notas-do-aluno` | Nove documentos e regras do commit `1dd6d2d`; consultas reais com autenticação das três contas | 9 testes de regras; 3 logins; 15 leituras/consultas HTTP 200; 24 negativas HTTP 403; parser real aprovado |
| S03 | Preparação local aprovada para commit/push/PR | `chore/preparar-preview-web` | Identidade Web, URLs com #, build release e pacote estático | Destino Hobby definido; sem deploy; visual pendente |
| S04 | Preparação de PR autorizada | `development` → `production` | Revisar conjunto completo, não somente notas | Aguardar S03, revisão/aprovação e conferência visual; sem merge automático |

### Execução do levantamento — 2026-11-22
- **Verificado:** status inicialmente limpo; fetch de referências remotas, sem alterar branches locais; PR #21 `MERGED`; `production` ancestral 103 commits atrás; conteúdo de HEAD igual a `origin/development`; nenhum PR aberto retornado pela consulta.
- **Firestore:** somente metadados do banco consultados pela CLI. Sem leitura dos documentos de notas, regras publicadas ou configurações do painel Vercel nesta sessão; não alegar ausência de conflitos remotos.
- **Web:** Flutter 3.47.7/Dart 3.13.5; `flutter build web --no-pub` aprovado, saída `build/web`. Aviso não bloqueante de fonte CupertinoIcons ausente; não adicionar dependência para suprimi-lo sem localizar impacto.
- **Limites:** nenhum teste Flutter/emulador ou build Android reexecutado neste levantamento documental. Os 209 testes Flutter/5 testes de regras da entrega anterior não validam a integração de notas futura.
- **Servidor anterior:** execução Web local foi cancelada pelo reinício do servidor; não foi reiniciada nem publicada.
- **Commit proposto:** `docs(grades): planejar notas integradas e apresentação mobile`.

### Execução da S01 — 2026-11-22
- **Base:** `development` atualizada por fast-forward em `8876c1a`; criada a branch autorizada `feature/integrar-notas-do-aluno`.
- **Documentação anterior:** plano commitado em `11bdb78` e publicado no [PR #22](https://github.com/Forge-Tech-Orbita/portal-orbita/pull/22), ainda sem aprovação na conferência inicial; merge não executado por política de revisão. O plano foi trazido somente para a árvore de trabalho desta branch para registrar a execução, sem cherry-pick, staging ou commit da implementação.
- **Implementado:** parser estrito em runtime, sem alterar fórmulas; repositório injetado de `MainApp` até a tela; consulta somente ao servidor por UID/semestre/curso; loading/erro/vazio/atualização, rejeição de lote inválido e de respostas antigas; filtros/detalhes mantidos ao alternar abas na mesma sessão.
- **Apresentação:** removidos CRA/indicadores históricos e métricas sem fonte da Home; fixtures movidas para `test/`; aviso visível na casca distingue módulos demonstrativos. Cards usam título e etiquetas em linhas separadas para manter leitura/interação com texto 2× em 360×640.
- **Regras locais:** acrescentado apenas `list` próprio com perfil/identidade, curso e semestre correspondentes; `get` legado preservado, inclusive sem perfil novo; nenhuma escrita de notas concedida.
- **Validação final:** `dart format --output=none --set-exit-if-changed lib test` sem alterações (125 arquivos); `flutter analyze --no-pub` sem diagnósticos; `flutter test --no-pub` com **242 testes aprovados**; `git diff --check` aprovado. Regressões cobrem parser/limites/enum/metadados/números finitos, zero e null, fórmulas existentes, loading/erro/vazio/retry/atualização, resposta atrasada, logout/troca de conta, troca independente de semestre/curso e preservação de estado entre abas. Os componentes são testados com fake explícito; não há mocks de classes sealed ou dependências novas.
- **Regras:** `npx -y firebase-tools@latest emulators:exec --project demo-portal-orbita --config firebase.emulators.json --only auth,firestore "node --test test/firestore_rules_test.cjs"` com **9 testes aprovados**. Sintaxe compilada pelo emulador; consulta REST com os mesmos filtros da aplicação testada em três perfis institucionais, preservando testes anteriores. Negadas consultas sem filtros completos, de outro semestre/curso/UID, collection group, sem login/perfil/curso válido e escritas de notas. `get` legado sem perfil preservado intencionalmente; não deve ser confundido com autorização de `list`.
- **Builds finais:** `flutter build apk --debug --no-pub` aprovado em `build/app/outputs/flutter-apk/app-debug.apk`; `flutter build web --no-pub` aprovado em `build/web`. Toolchain Android/Web disponível. Sem instalação/execução no dispositivo nesta sessão; builds e widget tests não comprovam validação visual ou leitura remota do SDK Flutter.
- **Limites de validação:** a chamada SDK usa `Source.server` e foi revisada no código; sem teste de integração FlutterFire no projeto remoto nesta etapa. Dados fictícios permanecem somente em testes/emuladores. Detalhes dos avisos não bloqueantes preexistentes ficam no acompanhamento local, sem mudanças de SDK/pacotes para silenciá-los.
- **Pendências:** revisão das regras locais, publicação/provisionamento e validação remota pertencem à S02; conferência manual no Android e navegador do celular ainda necessária. Vercel não preparada/publicada.
- **Commit proposto, não autorizado nesta etapa:** `feat(grades): integrar notas do aluno ao Firestore`.

### Execução da S02
- **Git:** commit aprovado `1dd6d2d` (`feat(grades): integrar notas do aluno ao Firestore`), restrito à implementação, testes e documentação da S01; sem push/merge.
- **Inspeção antes de escrever:** três contas habilitadas com provedor de senha e sem claims personalizados; perfis mantêm instituição/matrícula, cursos `si`/`adm`/`si`, semestre `2026-2` e período 4. As três coleções `grades` estavam vazias, sem colisões ou disciplinas duplicadas.
- **Provisionamento:** manifesto fixo dos nove documentos passou pelo parser real `Grade.fromMap` e conferência das médias/pendências. Criação em um único commit REST atômico, com `currentDocument.exists: false` em cada escrita; commit remoto em `2026-11-23T02:10:24.773043Z`. Nenhum documento existente foi substituído; perfis, cursos e senhas não foram alterados.
- **Releitura administrativa:** exatamente três notas por conta; todos os campos dos nove documentos correspondem ao manifesto aprovado. Essa releitura é somente evidência de dados, não de autorização do cliente.
- **Regras:** antes da escrita e novamente imediatamente antes da publicação, regras remotas iguais às 38 linhas do commit `f548409`, sem divergência inesperada. Arquivo local igual ao commit `1dd6d2d`; 9 testes de emuladores aprovados novamente. Publicação por `npx -y firebase-tools@latest deploy --project portal-orbita --config firebase.emulators.json --only firestore:rules --non-interactive`, saída 0. Releitura pela API Rules confirmou as 45 linhas do commit, normalizando apenas finais de linha; `get` legado preservado, sem alteração de configuração/serviços restantes.
- **Autenticação de aluno:** emissão keyless via IAM foi negada (`IAM_PERMISSION_DENIED`); nenhuma API foi habilitada, chave criada ou permissão concedida. Em seguida, o responsável digitou as senhas existentes em formulário local privado, e as **três contas autenticaram por e-mail/senha**. Tokens ID Firebase com UID, e-mail, projeto e provedor `password` conferidos; consultas executadas com esses tokens, nunca com OAuth administrativo. Senhas e tokens somente em memória/stdin privado; sem valores em logs, arquivos, argumentos ou chat.
- **Consultas reais permitidas:** por conta, `get` do próprio perfil (HTTP 200), consulta `students/{uid}/grades` filtrada por `semestreLetivo == "2026-2"` e `cursoId` do perfil (HTTP 200, exatamente três documentos), e `get` das três notas (HTTP 200). Total: **15 leituras/consultas permitidas**, além dos três logins. A consulta usa os mesmos caminhos e filtros do repositório do app; resposta real validada com `Grade.fromMap`, confirmando nove documentos, seis médias completas e três pendentes conforme o plano. Não foi necessário criar índice.
- **Negativas reais:** para cada token de aluno, consulta e `get` de outra conta, consulta com apenas semestre, com apenas curso, outro semestre, outro curso, listagem ampla e a mesma consulta sem autenticação retornaram **HTTP 403**: oito tentativas por conta, **24 negativas**. Nenhuma escrita remota foi tentada com aluno; negação de escrita está coberta pelos emuladores e pelo conteúdo publicado.
- **Preservação final:** releitura MCP confirmou `updateTime` dos três perfis idêntico ao observado antes da operação, com cursos e semestre intactos. Somente os nove documentos de notas foram criados; não houve alteração de senha, claims, vínculo de curso ou documento anterior.
- **Validação visual:** pendente, a cargo do responsável no navegador do celular antes da apresentação. Não iniciar Android nesta etapa; isso não bloqueia a preparação futura do preview Vercel. Não alegar validação visual a partir das consultas REST.
- **Preparação:** artefatos Android debug e Flutter Web da S01 disponíveis; app não alterado nesta operação remota. Sem publicação Vercel, redefinição de curso, alteração de senha, push ou merge.
- **Commit documental proposto:** `docs(grades): registrar provisionamento e validação técnica`.

### Preparação da S03
- **Compatibilidade:** [PR #23](https://github.com/Forge-Tech-Orbita/portal-orbita/pull/23) integrado pelo responsável em `development` (`26eb28a`), com árvore idêntica à base `f9389db` da S03. Preparação Web separada, sem alterar código Dart, regras ou dados das notas.
- **Destino aprovado:** Hobby existente `ricardopmartinsgtpvh-1353`, projeto pretendido `portal-orbita`, com primeira publicação assumida como produção. Na inspeção de acesso ainda não havia projetos nesse escopo; nenhum projeto criado/vinculado ou deployment realizado nesta preparação.
- **Identidade Web:** `web/index.html` passou a usar `lang="pt-BR"`, título e nome iOS `Portal Órbita`; `web/manifest.json` usa nome `Portal Órbita`, nome curto `Órbita` e a mesma descrição acadêmica de apresentação. Não alterados bootstrap, ícones, estratégia de rotas, SDK, dependências, Firebase ou `start_url`.
- **Validação final:** formato sem alterações, análise sem diagnósticos, **242 testes Flutter aprovados novamente** e `flutter build web --release --no-pub --base-href /` aprovado em `build/web`. Nenhum Dart funcional foi alterado; não foi necessário novo build/início Android nem republicação de regras.
- **Pacote local de conferência:** formato `.vercel/output/config.json` v3 e `.vercel/output/static`; 37 arquivos públicos conferidos byte a byte com o build, excluindo apenas `.last_build_id`. Sem fontes, diretórios privados, credenciais ou vínculo de projeto. Artefato não publicável: o build final deve ser regenerado do commit integrado em `production`.
- **Rotas/cache:** URLs com fragmento preservadas, sem `usePathUrlStrategy`/rewrites SPA. Pacote configura revalidação de cache, sem `immutable`. Smoke HTTP local verificou `/`, `/#/login`, `/#/main` e cinco assets (incluindo WASM), com HTTP 200; o servidor recebeu `/` para os fragmentos, e `/main` sem fragmento retornou 404. Servidor temporário encerrado; isso não é teste visual do app ou da CDN Vercel.
- **Antes de publicar:** integrar S03 em `development`, revisar/aprovar promoção para `production`, regenerar e validar o artefato do SHA final. Somente depois, mediante autorização de deploy, vincular/publicar o pacote no destino aprovado. Não usar `--prebuilt` diretamente em `build/web` sem o formato Build Output API. Nenhuma variável administrativa Firebase é necessária no frontend.
- **Pendências:** revisão dos PRs, conferência completa no navegador do celular (login, perfil/curso, Home, notas, atualização, retorno, logout, troca de conta, assets e texto ampliado), regeneração do build final e autorização de publicação. Sem instalação/início Android, criação de projeto/deploy Vercel, mudança de Production Branch ou merge automático.
- **Commit proposto:** `chore(web): preparar build estático para preview`.

### Revisão da promoção S04 — 2026-11-23
- **Referências:** `origin/production` em `5160faa`, ancestral de `origin/development` em `26eb28a` (PR #23 integrado). Comparação completa inventariada: 109 commits, 266 arquivos, 30.650 adições e 5.585 remoções, antes da S03. O PR de promoção deve ter origem em `development`, destino `production` e permanecer em rascunho até receber a S03 e nova conferência do diff.
- **App e contratos:** revisados inicialização, rotas/guards, sessão e descarte de respostas, perfil, escolha única por transação, parser/consulta de notas, resumos, temas/widgets e módulos demonstrativos de aluno, professor, coordenação e admin. Escala prevista: apresentação com três contas fictícias, não operação acadêmica real. Notas não usam fixtures em falhas/vazio; dados remotos só nos repositórios Auth/Firestore. Escrita do cliente restrita ao primeiro vínculo de curso; sem migração ou exclusão de dados na promoção.
- **Plataformas/dependências:** comparação inclui configuração Firebase Android/Web, identidade Android, permissões de foto iOS, Firebase e image_picker no manifest/lockfile (Flutter mínimo do lockfile `3.47.0`). iOS não tem Firebase configurado; assinatura Android release ainda usa debug e não autoriza distribuição nativa de produção. Remoções incluem o protótipo HTML legado e componentes/fixtures substituídos, não dados do banco.
- **Ferramentas/documentação:** regras/planos, adaptadores, hook, MCP e skills importadas também entram na promoção; não fazem parte do artefato público Web. Não há workflow GitHub de deploy nem configuração Vercel versionados. Não ativar automação remota por inferência. A revisão do material de referência importado não equivale a executar seus exemplos ou certificar SDKs externos.
- **Verificações atuais:** formato (125 arquivos), análise, **242 testes Flutter**, **9 testes Auth/Firestore em emuladores demo**, sintaxe e autoteste Bash do hook aprovados. Build Web release e smoke HTTP da S03 já aprovados para a mesma árvore funcional/metadata; não são o futuro build de `production`. Sem reexecução Android, consultas de produção ou publicação de regras nesta revisão.
- **Pendência de gate da promoção:** `git diff --check origin/production origin/development` retorna **2**, por **90 espaços finais em 18 arquivos exclusivamente de `.opencode/skills`**, introduzidos no commit já integrado `3d63a4d`. Diff da aplicação e diff local S03 passam. Não limpar material importado fora do escopo; registrar a falha no PR de promoção e resolver antes de liberá-lo para integração, sem esconder o diagnóstico ou declarar o conjunto aprovado.
- **Limites relevantes para publicação:** admin/MFA, professor e coordenação são protótipos acessíveis, não segurança administrativa real; não inserir dados reais ou conceder acesso remoto administrativo a esses módulos. Validação visual completa no celular e domínio final ainda pendente. Revalidação/hash routing não comprovam comportamento de CDN, HTTPS, restrições Firebase ou atualização real de navegador.
- **Ordem de liberação:** revisar/integrar PR S03 em `development`; atualizar/revisar diff e gates do PR de promoção, resolver a pendência acima e concluir revisão humana/conversas; integrar `development` → `production` somente pelo responsável. Depois regenerar build/pacote do SHA de `production`, conferir recibo/assets e obter autorização separada de deploy no Hobby `portal-orbita`. Nenhum merge ou deploy automático.
