# Portal Órbita

Portal acadêmico desenvolvido em Flutter/Dart para reunir informações e serviços do estudante em uma única aplicação, com estrutura para Android, iOS e Web.

## Funcionalidades

Interface baseada no protótipo "Portal Órbita — Protótipo de interface", com quatro perfis.

- **Aluno:** início com carteirinha, indicadores, próxima aula calculada pela grade e notificações; horário semanal; notas com AV1/AV2, TED e avaliação integrada; disciplinas; financeiro com pagamento simulado por Pix ou boleto; biblioteca com busca e acervo (reserva e fila); materiais das disciplinas; mural com confirmação de presença; suporte com novo chamado e confirmação; perfil com edição de dados, foto e escolha do tema do aplicativo.
- **Professor:** início, turmas, materiais (novo PDF ou link), frequência somente leitura e comunicados.
- **Coordenação:** painel com indicadores agregados, turmas do curso, materiais e publicação de eventos e comunicados.
- **Portal Administrativo (separado):** login próprio com verificação em duas etapas, painel, usuários, chamados, permissões com segunda aprovação e auditoria.

Temas do aplicativo, escolhidos no Perfil: Vintage (padrão), Básico com cor de destaque selecionável, Forge Tech (escuro) e UniSapiens.

## Contas de demonstração

O acesso é simulado e não confere senha (qualquer senha não vazia).

| Perfil | Onde entrar | Identificação |
| --- | --- | --- |
| Aluno | Login inicial | Matrícula `2023104567` |
| Professor | Login inicial | Matrícula `P2019042` |
| Coordenação | Login inicial | Matrícula `C2015007` |
| Administrador | Rota `/admin` (na Web: `/#/admin`) | E-mail `adm.nome@orbita.edu` e qualquer código de 6 dígitos |

Outras matrículas mostram erro de credencial e, após 5 tentativas, bloqueio temporário.

## Status do projeto

A versão atual é demonstrativa e utiliza dados locais, sem persistência. A integração com o Firebase está em andamento: por enquanto ele é inicializado apenas na Web, ainda sem uso de autenticação ou Firestore pelas telas. Login, biometria e MFA são simulados; pagamentos, chamados, reservas, materiais, comunicados, dados pessoais, foto, tema escolhido e preferências ainda não têm integração real nem persistência. Abrir PDF ou link de material e anexar arquivos informam que dependem da integração.

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
