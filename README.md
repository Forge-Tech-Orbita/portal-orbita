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

## Status do projeto

A versão atual é demonstrativa e utiliza dados locais, sem backend ou persistência. Login e biometria são simulados; emissão de boletos, chamados de suporte, busca no acervo, dados pessoais, foto e preferências do perfil ainda não têm integração real nem persistência.

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
flutter analyze
flutter test
flutter build web
```
