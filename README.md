# Portal Órbita

Portal acadêmico desenvolvido em Flutter/Dart para reunir informações e serviços do estudante em uma única aplicação, com estrutura para Android, iOS e Web.

## Demonstração publicada

**Acesse:** https://portal-orbita-rho.vercel.app

A demonstração usa dados fictícios. Solicite à equipe as contas de acesso do aluno;
não há cadastro público e as senhas de acesso não são divulgadas aqui.

O fluxo integrado inclui:

- Autenticação do aluno com instituição, matrícula e senha via Firebase Authentication.
- Perfil acadêmico no Firestore e escolha única do curso, quando ainda não vinculado.
- Consulta de notas do próprio aluno por semestre e curso, sem substituir falhas ou ausência de notas por dados demonstrativos.
- Logout com limpeza da sessão e dos dados do aluno em memória.

A versão publicada corresponde ao commit `9d67d04`.
O responsável pelo projeto confirmou o funcionamento no navegador do celular com
as contas de demonstração; essa conferência visual/funcional foi realizada por ele,
não pelo agente. Os resultados técnicos e o aceite estão no
[plano da apresentação](.plan/geral/notas-apresentacao-mobile/index.md).

## Funcionalidades

Interface baseada no protótipo "Portal Órbita — Protótipo de interface", com quatro perfis.

- **Aluno:** início com carteirinha, próxima aula demonstrativa e notificações; horário semanal; notas com AV1/AV2, TED e avaliação integrada consultadas no Firestore; disciplinas; financeiro com pagamento simulado por Pix ou boleto; biblioteca com busca e acervo (reserva e fila); materiais das disciplinas; mural com confirmação de presença; suporte com novo chamado e confirmação; perfil com edição de dados, foto e escolha do tema do aplicativo.
- **Professor:** início, turmas, materiais (novo PDF ou link), frequência somente leitura e comunicados.
- **Coordenação:** painel com indicadores agregados, turmas do curso, materiais e publicação de eventos e comunicados.
- **Portal Administrativo (separado):** login próprio com verificação em duas etapas, painel, usuários, chamados, permissões com segunda aprovação e auditoria.

Temas do aplicativo, escolhidos no Perfil: Vintage (padrão), Básico com cor de destaque selecionável, Forge Tech (escuro) e UniSapiens.

## Contas de demonstração

O aluno usa Firebase Authentication com instituição, matrícula numérica e senha.
Somente contas previamente provisionadas com perfil válido em `students/{uid}` podem entrar.
Use a instituição, matrícula e senha fornecidas pela equipe, sem publicar credenciais.
O curso é escolhido uma única vez, caso ainda não esteja definido.
Instituição e matrícula permanecem independentes do UID.

O [roteiro de provisionamento](.plan/geral/autenticacao-perfil/provisionamento.md)
descreve três contas fictícias e a publicação das regras de autenticação/perfil.
As regras de consulta de notas do commit `1dd6d2d` foram publicadas na S02,
preservando a leitura individual legada e os demais serviços.

| Perfil | Onde entrar | Identificação |
| --- | --- | --- |
| Aluno | Login inicial | Instituição + matrícula + senha da conta provisionada |
| Professor | Botão “Demonstração: Professor” | Protótipo sem autenticação |
| Coordenação | Botão “Demonstração: Coordenação” | Protótipo sem autenticação |
| Administrador | Rota `/admin` (na Web: `/#/admin`) | Protótipo com login e verificação em duas etapas simulados |

Não há cadastro público nem acesso do aluno por biometria simulada.
O portal administrativo e sua verificação em duas etapas continuam demonstrativos;
não são autenticação ou autorização reais.

## Status do projeto

Firebase é inicializado em Android e Web. O acesso do aluno usa autenticação real,
perfil no Firestore e vínculo inicial de curso. Logout remove a sessão e os dados
do aluno em memória. As demais plataformas não têm configuração Firebase.

Notas são consultadas somente para o UID autenticado, semestre e curso do perfil,
em `students/{uid}/grades`, com carregamento, atualização, erro e ausência de notas
sem fallback demonstrativo. O [plano de notas](.plan/geral/notas-apresentacao-mobile/index.md)
define o contrato e registra o provisionamento fictício: nove documentos, três por conta,
criados sem sobrescrita na S02. CRA e métricas históricas sem fonte foram omitidos.
As três contas passaram em login real e consultas REST com tokens de aluno, com conferência
dos documentos pelo parser do app e negativas de acesso. A conferência visual/funcional
da versão publicada no navegador do celular foi confirmada pelo responsável pelo projeto;
os registros técnicos do agente e o aceite manual do usuário estão separados no plano.

Os demais módulos acadêmicos permanecem demonstrativos, identificados na casca do aluno.
Pagamentos, chamados, reservas, materiais, comunicados, edição de dados
pessoais, foto, tema escolhido e preferências continuam locais, sem persistência.
Professor, coordenação e portal administrativo são protótipos separados. Abrir PDF
ou link de material e anexar arquivos informam que dependem da integração.

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

A primeira publicação usou o commit `9d67d04`, com HTTPS, raiz e 37 arquivos
estáticos conferidos. O [plano da apresentação](.plan/geral/notas-apresentacao-mobile/index.md)
registra a URL, o SHA completo e a validação no celular.

Para testar as regras sem acesso ao projeto remoto:

```bash
firebase emulators:exec --project demo-portal-orbita --config firebase.emulators.json --only auth,firestore "node --test test/firestore_rules_test.cjs"
```

Requisitos: Firebase CLI, Node com `node:test`/`fetch`, Java 21+ e emuladores locais.
