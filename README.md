# Portal Órbita

Portal acadêmico desenvolvido em Flutter/Dart para reunir informações e serviços do estudante em uma única aplicação, com estrutura para Android, iOS e Web.

## Funcionalidades

- Início com carteirinha estudantil, indicadores acadêmicos e atalhos.
- Horário semanal de aulas.
- Notas, avaliações e frequência.
- Disciplinas do semestre.
- Financeiro com fatura e histórico de pagamentos demonstrativos.
- Biblioteca com empréstimos demonstrativos.
- Mural de avisos e central de suporte com abertura simulada de chamados e aba da equipe de suporte.
- Perfil do estudante com atualização de telefone, e-mail pessoal e foto de perfil.
- Temas do aplicativo escolhidos no Perfil: Vintage (padrão), Básico com cor de destaque selecionável, Forge Tech (escuro) e UniSapiens.

## Status do projeto

A versão atual é demonstrativa e utiliza dados locais, sem persistência. A integração com o Firebase está em andamento: por enquanto ele é inicializado apenas na Web, ainda sem uso de autenticação ou Firestore pelas telas. Login e biometria são simulados; emissão de boletos, chamados de suporte, busca no acervo, dados pessoais, foto, tema escolhido e preferências do perfil ainda não têm integração real nem persistência.

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
