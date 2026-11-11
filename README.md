# Portal Órbita

Portal acadêmico desenvolvido em Flutter/Dart para reunir informações e serviços do estudante em uma única aplicação, com estrutura para Android, iOS e Web.

## Funcionalidades

- Início com carteirinha estudantil, indicadores acadêmicos e atalhos.
- Horário semanal de aulas.
- Notas, avaliações e frequência.
- Disciplinas do semestre.
- Financeiro com fatura e histórico de pagamentos demonstrativos.
- Biblioteca com empréstimos demonstrativos.
- Mural de avisos, central de suporte e perfil do estudante.

## Status do projeto

A versão atual é demonstrativa e utiliza dados locais, sem backend ou persistência. Login e biometria são simulados; emissão de boletos, abertura de chamados, busca no acervo e preferências do perfil ainda não têm integração real.

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
