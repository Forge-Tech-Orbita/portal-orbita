# Provisionar contas fictícias

Provisionamento remoto e deploy exigem autorizações separadas. Preserve as contas A/B e documentos existentes; antes de criar, consulte o identificador e use uma condição de inexistência para não sobrescrever dados.

## Contrato
- A instituição vem do catálogo fechado em `lib/core/constants/institution_catalog.dart`.
- Matrícula: texto com 1–20 dígitos ASCII; preservar zeros iniciais.
- E-mail técnico: `<instituicaoId>.<matricula>@auth.orbita.example`.
- O endereço é técnico e não recebe mensagens. Recuperação de senha via responsável pelo projeto.
- Use o mesmo conversor do login antes de provisionar:

```powershell
dart run tool/provisioning_email.dart inst-demo 202600001
dart run tool/provisioning_email.dart inst-demo 202600002
dart run tool/provisioning_email.dart inst-horizonte 202600001
```

Não renomear ou reciclar esses identificadores após criar as contas.

## 1. Catálogo no Firestore
Crie, com acesso administrativo autorizado, os documentos:

| Caminho | `nome` (string) | `ativo` (boolean) |
| --- | --- | --- |
| `institutions/inst-demo/courses/si` | Sistemas de Informação | true |
| `institutions/inst-demo/courses/adm` | Administração | true |
| `institutions/inst-horizonte/courses/si` | Sistemas de Informação | true |

## 2. Contas no Firebase Authentication
No projeto `portal-orbita`, provedor E-mail/senha, crie:

| Conta fictícia | E-mail técnico | Curso final esperado |
| --- | --- | --- |
| Aluno Sapiens SI | `inst-demo.202600001@auth.orbita.example` | `si` |
| Aluno Sapiens ADM | `inst-demo.202600002@auth.orbita.example` | `adm` |
| Aluno Horizonte SI | `inst-horizonte.202600001@auth.orbita.example` | `si` |

Gere senhas únicas fora do código. Não envie senhas ao agente, não salve em Markdown/JSON, argumentos de terminal, fixtures ou commits.
Anote os UIDs apenas no ambiente de configuração e use cada UID como ID do respectivo documento.

## 3. Perfis `students/{uid}`
Exemplo da primeira conta (não substitua `{uid}` por matrícula):

```json
{
  "nome": "Aluno Sapiens SI",
  "matricula": "202600001",
  "instituicaoId": "inst-demo",
  "cursoId": null,
  "semestreLetivo": "2026-2",
  "periodo": 4
}
```

Segunda conta: nome `Aluno Sapiens ADM`, matrícula `"202600002"`, instituição `inst-demo`.
Terceira: nome `Aluno Horizonte SI`, matrícula `"202600001"`, instituição `inst-horizonte`.
Nas três contas, crie `cursoId` como **null**, `periodo` como inteiro e demais campos como string.
O primeiro acesso vincula cada conta ao curso final da tabela. Para repetir o teste, só o responsável administrativo pode remover o vínculo no ambiente de teste.

### Provisionamento realizado em 2026-11-21
- Os três documentos do catálogo foram criados pelo Firebase MCP com condição de inexistência e relidos para conferir os campos.
- As três contas foram criadas pelo responsável em janela local com senhas privadas; existência, e-mails, provedor de senha e contas habilitadas foram conferidos pelo MCP.
- Os perfis foram criados nos UIDs retornados pelo Auth, com condição de inexistência, e relidos. Todos mantêm `cursoId: null`.
- Nenhuma conta ou documento existente foi alterado. Não houve publicação de regras.

## 4. Regras e testes locais
As regras de `firestore.rules` do commit `f548409` foram publicadas em `portal-orbita` em 2026-11-21, após autorização e nova comparação com a base revisada, sem divergências inesperadas. A releitura pelo MCP confirmou correspondência do conteúdo publicado com o arquivo local, normalizando apenas quebras de linha.
O deploy usou `--config firebase.emulators.json --only firestore:rules --project portal-orbita`; o arquivo gerado `firebase.json` e as configurações dos demais serviços foram preservados. Não houve push.

Requisitos dos testes de regras: Node com `node:test`/`fetch`, Java 21+, Firebase CLI e emuladores Auth/Firestore. Instalação/download de ferramentas exige autorização própria.

```powershell
firebase emulators:exec --project demo-portal-orbita --config firebase.emulators.json --only auth,firestore "node --test test/firestore_rules_test.cjs"
```

O script recusa endpoints diferentes de `127.0.0.1:8080` e `127.0.0.1:9099`, usa projeto `demo-portal-orbita` e dados efêmeros.
Antes de publicar futuramente, confira novamente as regras atuais no Console e revise o diff para preservar mudanças da equipe.
O catálogo permite leitura de cursos inativos da própria instituição. A tela consulta apenas `ativo == true`, restringe os IDs ao catálogo fechado e não usa fallback local quando a consulta falha; as regras continuam bloqueando o vínculo com curso inativo.

## 5. Conferência após provisionamento e publicação autorizada
Distribuição da primeira escolha para validar as duas plataformas sem redefinir vínculos:

| Conta | Primeiro acesso / escolha | Curso |
| --- | --- | --- |
| Sapiens `202600001` | Android | Sistemas de Informação |
| Sapiens `202600002` | Android | Administração |
| Horizonte `202600001` | Web | Sistemas de Informação |

Depois, conferir as três contas em ambas as plataformas. Antes da primeira escolha, conferir SI e Administração disponíveis em Sapiens e somente SI em Horizonte. Testar senha incorreta, persistência do curso após sair/entrar e limpeza de identidade/estado na troca de conta. Não redefinir `cursoId` para repetir a seleção.

Preparação em 2026-11-21: app iniciado no S200 (`S200000000000014107`); Web servido em `http://127.0.0.1:7357` pelo alvo `web-server`, com HTTP 200. A abertura automática via alvo Chrome falhou na conexão com o depurador; o fallback não alterou SDKs, dependências ou o app.

Validação em 2026-11-21: o responsável confirmou aprovação de todos os cenários solicitados, seguindo a distribuição de primeiras escolhas acima e conferindo as três contas nas duas plataformas: identidade, catálogo por instituição, persistência do curso, logout/troca de conta e rejeição de senha incorreta. As senhas permaneceram privadas. Após esse relato, o agente releu os três perfis pelo MCP e confirmou instituição/matrícula e vínculos `si`, `adm` e `si`, respectivamente. Não houve redefinição de curso. Os demais cenários de borda abaixo continuam como roteiro complementar; não devem ser considerados manualmente executados sem registro específico.

1. Inst-demo + `202600001`: nome e instituição Sapiens, seleção inicial de SI.
2. Inst-demo + `202600002`: seleção inicial de Administração.
3. Horizonte + `202600001`: perfil diferente da primeira conta, somente SI disponível.
4. Tentar credenciais com instituição errada: não autenticar na outra conta.
5. Curso já definido: não exibir seleção nem permitir alteração via SDK/REST.
6. Sem perfil provisionado: erro explícito, sem abrir a área do aluno.
7. Sair em Perfil/Mais: voltar ao login, limpar identidade e estado; voltar do sistema não reabre sessão.
8. Trocar de conta durante carregamento: nenhuma resposta antiga pode exibir o perfil anterior.
9. Demonstrativos de professor/coordenação: entrada separada, sem sessão Firebase e sem acesso às rotas do aluno.
10. Notas, suporte, materiais e demais dados acadêmicos continuam demonstrativos. Dados pessoais/foto/preferências são locais, não persistidos.

Ocultar cadastro na UI não bloqueia a API de criação de contas do provedor. Contas sem perfil não recebem acesso a perfis/cursos e só podem obter suas próprias notas, conforme a permissão anterior. Se for necessário proibir toda criação externa no Auth, definir um bloqueio no serviço de identidade em tarefa própria.
