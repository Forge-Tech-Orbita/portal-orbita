# Portal Órbita

Portal acadêmico desenvolvido em Flutter/Dart para reunir informações e serviços do estudante em uma única aplicação, com estrutura para Android, iOS e Web.

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
O curso é escolhido uma única vez, caso ainda não esteja definido.
Instituição e matrícula permanecem independentes do UID.

O [roteiro de provisionamento](.plan/geral/autenticacao-perfil/provisionamento.md)
descreve três contas fictícias e a publicação das regras de autenticação/perfil.
As novas regras locais de consulta de notas ainda precisam de revisão e publicação autorizada;
não foram publicadas nesta entrega.

| Perfil | Onde entrar | Identificação |
| --- | --- | --- |
| Aluno | Login inicial | Instituição + matrícula + senha da conta provisionada |
| Professor | Botão “Demonstração: Professor” | Protótipo sem autenticação |
| Coordenação | Botão “Demonstração: Coordenação” | Protótipo sem autenticação |
| Administrador | Rota `/admin` (na Web: `/#/admin`) | E-mail `adm.nome@orbita.edu` e qualquer código de 6 dígitos |

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
define o contrato e o cadastro fictício futuro: ainda não houve provisionamento nem
publicação das novas regras de consulta. CRA e métricas históricas sem fonte foram omitidos.

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

Para testar as regras sem acesso ao projeto remoto:

```bash
firebase emulators:exec --project demo-portal-orbita --config firebase.emulators.json --only auth,firestore "node --test test/firestore_rules_test.cjs"
```

Requisitos: Firebase CLI, Node com `node:test`/`fetch`, Java 21+ e emuladores locais.
