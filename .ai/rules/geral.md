---
paths: ["**"]
---

# Regras gerais

## Padrão atual

- Leia os arquivos irmãos e consumidores antes de editar. Reproduza a organização em `lib/features/home/presentation/home_screen.dart` e `lib/core/widgets/student_id_card.dart`, sem impor camadas teóricas.
- Siga as convenções de nomenclatura observadas: arquivos `snake_case.dart`, classes `PascalCase`, membros `lowerCamelCase`, privados com `_`; exemplos: `StudentIdCard`, `HomeScreen` e `_login` em `lib/features/auth/presentation/login_screen.dart`.
- Não adicione pacotes, novas pastas diretamente em `lib/`, serviços globais ou bibliotecas de estado/rotas sem aprovação. `pubspec.yaml` tem somente Flutter em produção.
- Não trate fixtures como regras acadêmicas reais. Preserve os limites explícitos de `lib/features/grades/data/grade.dart`, `lib/features/financial/data/financial.dart` e dos comentários `shortcut:`.

## Escopo e segurança

- Preserve o estado inicial mostrado por `git status --short --branch`. Não reverta, remova ou inclua trabalho de terceiros.
- Não restaure/edite/importe `portal-orbita-antigo/`, React Native ou Expo. O legado foi removido; `web/index.html` é bootstrap Flutter ativo e não está nessa exclusão.
- Não edite artefatos em `build/`, `.dart_tool/`, registradores gerados ou `.metadata` manualmente. Respeite `.gitignore`.
- Não leia/reproduza segredos sem necessidade; documente nomes de variáveis, nunca valores. O app atual não exige credenciais de backend.
- Não altere persistência, autenticação, navegação ou contratos compartilhados fora do pedido. Registre descobertas fora do escopo sem implementar.
- Mantenha acessibilidade, validação de entrada, tratamento de erros e descarte de recursos. Não reduza essas proteções para encurtar o diff.

## Planejamento

1. Use `.plan/TEMPLATE.md` para os planos maiores de toda a equipe em `.plan/geral/<nome>/index.md`. Versione objetivos, decisões, divisão de tarefas, responsáveis e acompanhamento compartilhado.
2. Use `.plan/local/<integrante>/<nome>/index.md` para destrinchar individualmente as tarefas designadas ao integrante, referenciando o plano geral. Essa pasta deve continuar ignorada em `.gitignore`; não use inclusão forçada. O roteiro local não substitui decisões ou status compartilhados: registre esses resultados no plano geral, sem exigir acesso ao arquivo individual. O formato novo não exige converter planos antigos.
3. Defina objetivo, branch/commit base, decisões pendentes, arquivos, fora de escopo, validação e acompanhamento. Faça sessões pequenas, com uma branch e um PR por sessão de implementação.
4. Se a branch correta já tiver sido indicada pelo usuário, preserve-a. Não recomece nem renomeie trabalho existente para adequá-lo a exemplos novos.
5. Pergunte decisões bloqueantes antes de codificar. Mudança adicional indispensável deve ser mínima e registrada; melhoria independente fica para outra sessão.
6. Atualize o acompanhamento com o que foi realmente executado; mantenha validação manual e aprovação de commit como pendências separadas.

## Persistência e conclusão verificável

- Defina os critérios de aceite a partir do pedido/plano antes de alterar. Uma tentativa, um patch aplicado ou um comando com exit 0 não prova que o problema foi resolvido.
- Use o ciclo **reproduzir → investigar → corrigir → reexecutar a reprodução e as verificações afetadas**. Se o resultado ainda não atender ao pedido, continue investigando e ajustando a solução dentro do escopo autorizado; não encerre como concluído, não deixe TODO substituindo requisito e não transfira ao usuário uma correção que você pode executar.
- Quando um gate falhar, interrompa a sequência de comandos, não a investigação. Depois da correção, reexecute a verificação que falhou e complete as demais verificações aplicáveis; não esconda a falha desativando testes ou diagnósticos.
- Não repita a mesma tentativa sem novas evidências ou mudança de hipótese. Se houver bloqueio real de acesso, SDK, dispositivo, credencial, decisão de negócio, autorização ou limite da ferramenta, pare somente a etapa afetada e peça o necessário. Continue o trabalho independente que ainda for seguro e autorizado.
- Diferencie **concluído**, **implementado com validação pendente** e **bloqueado**. Só declare concluído o escopo cujos critérios foram verificados; registre exatamente o que falta e por quê. Interrupção/cancelamento pelo usuário deve ser respeitado.
- Essas regras não autorizam instalações, upgrades, ampliação de escopo, operações destrutivas ou Git/produção sem aprovação. Markdown e hooks não garantem execução infinita nem substituem evidência de validação.

## Precedência e fechamento

- O plano de migração concluído `.plan/geral/plano-migracao-index-html.md` documenta decisões históricas. Sua antiga instrução de commit por etapa não autoriza commits em novas tarefas.
- Separe observado, política solicitada e recomendação. Uma boa prática ainda não adotada não deve ser descrita como implementação existente.
- Não faça staging, commit ou push automaticamente. Siga `.ai/rules/commits.md`; peça autorização separada para operações remotas.
- Encerre com resumo, validações, bloqueios, commit proposto e **“Aprova o commit?”**.
