# Disciplinas demonstrativas por curso

## Contexto

Na demonstração do aluno, Cursos, Horário, a próxima aula da Home e
Materiais selecionam conteúdo a partir de instituição, curso e semestre do
perfil. A base da implementação é `development` em `9cf8bbc`.

## S01 · Selecionar conteúdo por perfil acadêmico

- Responsável pela tarefa na equipe: Rogério.
- Branch: `feature/diferenciar-disciplinas-por-curso`.
- Catálogo para `2026-2`: Administração na Sapiens Demonstração e
  Sistemas de Informação nas duas instituições cadastradas. Perfis sem
  combinação prevista exibem estados vazios.
- Administração usa a turma ADM-4N e as três disciplinas abaixo. Os
  percentuais representam progresso demonstrativo do semestre.

| Disciplina | Dia e hora | Professor | Sala | Créditos | Progresso |
| --- | --- | --- | --- | --- | --- |
| Gestão de Pessoas | Segunda, 19h | Prof.ª M. Costa | Sala 101 | 4 | 72% |
| Contabilidade Gerencial | Terça, 19h | Prof. P. Lima | Sala 102 | 4 | 65% |
| Marketing | Quinta, 19h | Prof.ª A. Rocha | Sala 103 | 4 | 80% |

- Horário e Home usam a mesma grade. Os filtros de Materiais combinam
  disciplina e tipo. O Manual do Aluno 2026 é compartilhado pelos dois
  cursos.
- A validação do fluxo inclui a troca SI → ADM → SI e a ausência de
  catálogo para outro semestre.
- Conferência visual em dispositivo e revisão Git pendentes.

## Execução em 23/11/2026

- A formatação passou em 126 arquivos Dart.
- A suíte Flutter passou com 260 testes, incluindo troca de conta,
  próxima aula com data fixa, semestre sem catálogo e texto a 200% nos
  três tamanhos de tela para Cursos e Materiais.
- O analisador com Flutter 3.50.0 apontou as mesmas 87 ocorrências
  de depreciação do baseline.
