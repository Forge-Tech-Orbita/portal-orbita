# Notas integradas e apresentação mobile

## Contexto
Preparar o fluxo aluno autenticado → perfil → curso → notas → logout para apresentação no Android e no navegador do celular, seguido de preview Vercel e eventual promoção para `production`.

Base remota conferida em 2026-11-22: `origin/development` em `8876c1a`, merge do PR [#21](https://github.com/Forge-Tech-Orbita/portal-orbita/pull/21). PR integrado em 2026-11-21; nenhuma ação de merge pendente para autenticação/perfil. `origin/production` está em `5160faa`, ancestral de `development`, com diferença de 103 commits. A promoção exige revisar o conjunto da entrega, não apenas notas.

Levantamento realizado na branch existente `feature/integrar-autenticacao-e-perfil`, sem trocar/atualizar branches locais. Seu conteúdo rastreado coincide com `origin/development`. Implementação futura deve partir de `development` atualizado, em nova branch `feature/integrar-notas-do-aluno`, com PR próprio para `development`.

Nesta etapa: somente levantamento e este plano. Sem alteração do app, regras, dados remotos, staging, commit, push, merge ou publicação.

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
| D1 | Usar os documentos, consulta e validação descritos abaixo, sem migrar notas antigas | S01 | Aguardando aprovação |
| D2 | Omitir CRA/históricos e métricas fixas sem fonte; manter somente resumo do semestre consultado | S01 | Diretriz do pedido; solução proposta abaixo |
| D3 | Aprovar os dados fictícios e autorizar separadamente inspeção/cadastro remoto sem sobrescrita e publicação apenas das regras revisadas | S02 | Ainda não autorizado |
| D4 | Confirmar projeto/equipe Vercel, acesso, exposição pública do preview e método de build | S03 | Pendente; recomendar primeiro preview estático compilado localmente |
| D5 | Aprovar promoção do conjunto `development` → `production` após validação e revisão | S04 | Ainda não autorizado |

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
### Primeiro preview recomendado
- Aplicação estática, sem backend Vercel e sem credenciais administrativas Firebase.
- Compilar localmente o commit validado com Flutter fixo (`3.47.7`, Dart `3.13.5` nesta conferência): `flutter build web --no-pub --base-href /`. Dependências precisam estar resolvidas antes.
- Saída: `build/web`, ignorada pelo Git. Publicar somente esse artefato como preview Vercel após autorização, nunca a raiz com arquivos locais/planos privados.
- Para upload estático, usar preset Other e nenhum build remoto adicional. Não presumir Flutter instalado na Vercel.
- Manter URLs com fragmento no primeiro preview: refresh solicita `/`, sem precisar de rewrite geral. A aba Notas não possui deep link; atualizar pode retornar à Home após restaurar sessão. Isso é aceitável se aprovado e explicado, não preservação da aba garantida.
- Se URLs sem `#` forem exigidas depois, aprovar mudança de estratégia e fallback SPA que preserve arquivos estáticos; testar refresh e entrada direta com os guards antes de publicar.
- Ajustar `web/index.html` e `web/manifest.json` para nome/descrição corretos. Não prometer instalação/offline como PWA sem validação específica.
- Validar HTTPS, assets/fontes/CanvasKit, rede Firebase, restauração de sessão e logout no domínio real. Conferir domínios autorizados/restrições de chave no Firebase sem flexibilizar regras por suposição; email/senha não exige introduzir OAuth.
- Não configurar cache imutável geral para HTML/bootstrap; conferir atualização de versão sem exigir limpeza manual do navegador.

### Automação posterior, se escolhida
Se o responsável preferir deploy por Git desde o começo, confirmar equipe/projeto Vercel, preparar `vercel.json` com saída `build/web` e script de build com SDK Flutter fixo/disponibilidade verificada, resolução de dependências e build release. Arquivos propostos nesse caso: `vercel.json`, `scripts/vercel-build.sh` e `.gitignore` para `.vercel/`. Não usar `latest` nem instalar SDK/pacotes nesta etapa.

Configurar `production` como Production Branch, não `development`; branches de trabalho/development geram apenas previews. A promoção segue revisão e PR `development` → `production`; Git integration/deploy automático deve ser autorizado antes de ativar. Build remoto Linux e configurações do painel ainda não foram verificados.

Referência: [configuração de projetos Vercel](https://vercel.com/docs/project-configuration).

## Arquivos envolvidos na implementação
| Arquivo | Alteração prevista |
| --- | --- |
| `lib/features/grades/data/grade.dart` | Parser de fronteira com validação, preservando modelos/getters/cálculos |
| `lib/features/grades/data/grades_repository.dart` (novo) | Consulta de notas por UID/semestre/curso e ordenação |
| `lib/features/grades/presentation/grades_screen.dart` | Carga, retry/atualização, estados, semestre, remoção de históricos e fixture default |
| `lib/features/grades/data/grades_summary.dart` | Preservar cálculos; arquivo de referência/teste, sem mudança prevista |
| `lib/features/grades/data/grades_mock.dart` | Remover dependência do runtime; manter fixtures só onde testes precisarem |
| `lib/features/grades/presentation/widgets/gpa_ring_progress.dart` | Verificar consumidores e retirar se ficar sem uso após omitir CRA |
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
- **Critério de conclusão:** leituras do cliente autorizadas, dados conferidos, sem vazamento/nota anterior após logout, layout 360 px e texto ampliado aprovados pelo responsável.

### S03: preparar preview Vercel
- **Responsável:** agente e responsável pelo projeto; D4 obrigatória.
- **Escopo:** artefato estático validado, identidade Web, configuração mínima necessária e preview autorizado; sem promoção para produção.
- **Validação:** navegador real do celular, login/restauração, abas/retorno, refresh com/sem sessão, rota desconhecida, logout seguido de voltar/recarregar, assets, texto ampliado, erros de rede e atualização para novo build.
- **Critério de conclusão:** URL de preview e commit/artefato identificados; responsável aprova fluxo e limites demonstrativos.

### S04: promover versão estável
- **Responsável:** responsável pelo projeto, com apoio do agente sob autorização.
- **Decisão necessária:** D5.
- **Passos:** conferir diff completo das branches, gates, aprovação e conversas resolvidas; PR separado de `development` para `production`; publicar somente quando autorizado.
- **Critério de conclusão:** versão/commit publicados conferidos e plano de retorno ao artefato anterior conhecido, sem rollback de dados ou regras automático.

## Acompanhamento
| Sessão | Status | Branch | Escopo resolvido | Validações / Pendências |
| --- | --- | --- | --- | --- |
| Levantamento | Concluído | Branch existente de autenticação; sem troca | PR/branches, código, contrato proposto e Web | D1/D3/D4/D5 pendentes |
| S01 | Planejada | `feature/integrar-notas-do-aluno` (proposta) | — | Aprovação do contrato |
| S02 | Planejada | Conforme S01 | — | Autorização remota e validação manual |
| S03 | Planejada | `chore/preparar-preview-web` (proposta) | — | Definir método/projeto Vercel |
| S04 | Planejada | `development` → `production` | — | Revisão e autorização separadas |

### Execução do levantamento — 2026-11-22
- **Verificado:** status inicialmente limpo; fetch de referências remotas, sem alterar branches locais; PR #21 `MERGED`; `production` ancestral 103 commits atrás; conteúdo de HEAD igual a `origin/development`; nenhum PR aberto retornado pela consulta.
- **Firestore:** somente metadados do banco consultados pela CLI. Sem leitura dos documentos de notas, regras publicadas ou configurações do painel Vercel nesta sessão; não alegar ausência de conflitos remotos.
- **Web:** Flutter 3.47.7/Dart 3.13.5; `flutter build web --no-pub` aprovado, saída `build/web`. Aviso não bloqueante de fonte CupertinoIcons ausente; não adicionar dependência para suprimi-lo sem localizar impacto.
- **Limites:** nenhum teste Flutter/emulador ou build Android reexecutado neste levantamento documental. Os 209 testes Flutter/5 testes de regras da entrega anterior não validam a integração de notas futura.
- **Servidor anterior:** execução Web local foi cancelada pelo reinício do servidor; não foi reiniciada nem publicada.
- **Commit proposto:** `docs(grades): planejar notas integradas e apresentação mobile`.
