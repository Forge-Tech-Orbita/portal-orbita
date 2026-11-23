# Portal Órbita

Ambiente acadêmico simulado desenvolvido em Flutter/Dart, com acesso do aluno,
perfil e notas integrados ao Firebase e demais funcionalidades demonstrativas.
O projeto tem estrutura para Android, iOS e Web; Firebase está configurado somente
em Android e Web.

## Demonstração publicada

**Acesse:** https://portal-orbita-rho.vercel.app

A versão publicada foi validada no navegador do celular.

## Contas de demonstração

No login do aluno, selecione a instituição e informe a matrícula e a senha da conta.

| Instituição | Matrícula | Curso |
| --- | --- | --- |
| Sapiens — Demonstração | `202600001` | Sistemas de Informação |
| Sapiens — Demonstração | `202600002` | Administração |
| Instituto Horizonte — Demonstração | `202600001` | Sistemas de Informação |

Solicite à equipe a senha de acesso. As contas e os dados são fictícios, e não há cadastro público.

## Funcionalidades e limites

### Integradas ao Firebase

- **Acesso do aluno:** autenticação real por instituição, matrícula e senha via Firebase Authentication, somente para contas provisionadas. Não há acesso por biometria simulada.
- **Perfil e curso:** perfil acadêmico no Firestore e escolha única do curso, quando ainda não vinculado.
- **Notas:** AV1/AV2, TED, avaliação integrada e frequência consultadas no Firestore somente para o aluno autenticado, semestre e curso do perfil. Há estados de carregamento, atualização, erro e ausência de notas, sem fallback para dados demonstrativos. CRA e métricas históricas sem fonte não são exibidos.
- **Logout:** encerramento da sessão e limpeza dos dados do aluno em memória.

### Ainda simuladas

- **Aluno:** próxima aula, horário, notificações, disciplinas, financeiro/Pix/boleto, biblioteca/reservas, materiais, mural e suporte. Esses módulos não consultam dados acadêmicos reais.
- **Professor:** início, turmas, materiais, frequência somente leitura e comunicados.
- **Coordenação:** painel com indicadores, turmas, materiais, eventos e comunicados.
- **Portal administrativo:** login e verificação em duas etapas simulados, painel, usuários, chamados, permissões e auditoria. Não há autenticação ou autorização administrativa real.

Professor e coordenação têm botões de demonstração no login, sem autenticação.
O portal administrativo separado é acessado em `/#/admin` na Web.

Edição de dados pessoais, foto, tema e preferências ficam apenas em memória, sem
persistência. Os temas disponíveis no Perfil são Vintage (padrão), Básico com cor
selecionável, Forge Tech (escuro) e UniSapiens. Abrir PDF/link de material e anexar
arquivos dependem de integração futura.

## Pré-requisitos

- Flutter SDK com Dart compatível com `pubspec.yaml` (`^3.13.5`).
- Dispositivo, emulador ou navegador configurado para executar o app.

## Como executar

```bash
flutter pub get
flutter run
```

Para executar no Chrome, use `flutter run -d chrome`.

## Verificações e testes

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
git diff --check
```

Para compilar a versão Web, use `flutter build web --no-pub`.

### Build Web e publicação manual

```bash
flutter build web --release --no-pub --base-href /
```

A saída estática fica em `build/web`; as URLs continuam com `#`, sem mudança
para path routing. A publicação na Vercel é **manual**, no projeto `portal-orbita`
do plano Hobby, sem integração Git ou deploy automático.

Para cada nova publicação, integrar as alterações por PR em `development` e promover
por PR para `production`. Gerar e validar um novo build em árvore limpa do commit
final de `production`, empacotar somente os arquivos públicos em
`.vercel/output/static` com configuração Build Output API v3 e conferir os hashes.
Somente após autorização própria de deploy, publicar esse pacote com
`vercel deploy --prebuilt --prod --project portal-orbita --scope ricardopmartinsgtpvh-1353`,
executado na raiz do pacote estático conferido, não na raiz do repositório.
Não enviar a raiz do repositório, fontes ou arquivos privados, nem reutilizar
um pacote de outro commit.

O [plano da apresentação](.plan/geral/notas-apresentacao-mobile/index.md)
registra a publicação e as validações.

Para testar as regras sem acesso ao projeto remoto:

```bash
firebase emulators:exec --project demo-portal-orbita --config firebase.emulators.json --only auth,firestore "node --test test/firestore_rules_test.cjs"
```

Requisitos: Firebase CLI, Node com `node:test`/`fetch`, Java 21+ e emuladores locais.
