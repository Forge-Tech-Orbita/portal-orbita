# Integrar o aplicativo iOS ao Firebase

## Contexto
Habilitar no aplicativo nativo iOS o Firebase já usado em Android/Web (login do aluno, perfil, curso e notas), reutilizando o projeto `portal-orbita` e os repositórios existentes. Base: `development` em `030f27e`. Branch: `feature/integrar-firebase-no-ios`, um PR para `development`.

## Decisões
| ID | Decisão | Resposta |
| --- | --- | --- |
| D1 | Bundle ID iOS | `com.forgetech.plataformaorbita`, igual ao `applicationId` do Android |
| D2 | Assinatura | Apple Team pessoal (gratuito), configurado localmente no Xcode e fora do diff |
| D3 | Projeto Firebase | Existente `portal-orbita`; somente o app iOS foi registrado (`1:591651377504:ios:e5c80cea2b50a82b914e05`). Android e Web não foram alterados |
| D4 | SDK | Flutter 3.50.1 mantido; `flutter analyze` acusa 87 avisos `deprecated_member_use` de `material.dart`, preexistentes e sem relação com esta entrega |
| D5 | Plugins nativos | Mantido o Swift Package Manager já usado; nenhum Podfile criado |

## Execução
- `lib/firebase_options.dart` e `firebase.json` regenerados pelo FlutterFire, preservando Android e Web.
- `ios/Runner/GoogleService-Info.plist` gerado e vinculado ao target Runner (Resources).
- Bundle ID do Runner ajustado no Xcode; `lib/main.dart` inicializa o Firebase também no iOS.
- Teste de regressão em `test/firebase_options_test.dart`.

## Resultados
| Verificação | Resultado |
| --- | --- |
| `dart format` | Sem alterações |
| `flutter analyze --no-pub` | 87 avisos informativos preexistentes; nenhum novo |
| `flutter test --no-pub` | 253 testes passaram |
| `flutter build ios --debug --no-codesign` | Concluído |
| `flutter build ios --release --no-codesign` | Concluído; `CFBundleIdentifier` correto |
| `flutter build web --no-pub` | Concluído |
| iPhone físico, debug (`flutter run`) | Edu relatou que o fluxo funcionou; sem registro caso a caso |
| iPhone físico, release assinado (`flutter run --release`) | Edu relatou que o fluxo funcionou; sem registro caso a caso |

## Pendências e limites
- O aceite no iPhone físico foi relatado pelo Edu de forma geral (instalação, abertura e uso nos dois modos). Casos individuais — troca de conta, senha incorreta, falta de rede, segundo plano, seletor de foto, texto ampliado e VoiceOver — não foram registrados um a um e ficam sem evidência detalhada.
- Personal Team: o perfil de provisionamento expira em 7 dias; não há distribuição pela App Store/TestFlight.
- Fora de escopo: Analytics, Crashlytics, Messaging, App Check, login Apple/Google, regras Firestore e dados existentes.
