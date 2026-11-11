#!/usr/bin/env bash
set -u

input=$(cat)

block() {
  printf 'Portal Órbita: %s\n' "$1" >&2
  if [[ $input =~ \"stop_hook_active\"[[:space:]]*:[[:space:]]*true ]]; then
    printf '%s\n' '{"continue":false,"stopReason":"Validação técnica ainda bloqueada. Consulte os logs do hook; corrija o problema ou resolva o bloqueio de ambiente antes de aprovar o commit. O gate não passou."}'
    exit 0
  fi
  printf '%s\n' 'Corrija o problema antes de encerrar. Se depender do ambiente ou sair do escopo, informe o bloqueio ao usuário; não repita tentativas sem progresso nem declare sucesso.' >&2
  exit 2
}

command -v git >/dev/null 2>&1 || block 'Git indisponível no PATH do hook.'
root=$(git rev-parse --show-toplevel 2>/dev/null) || block 'Execute o hook dentro do repositório ativo.'
cd "$root" || block 'Não foi possível acessar a raiz do repositório.'

# O pathspec deixa o Git tratar nomes, renames, staging e arquivos não rastreados.
changes=$(git status --porcelain=v1 --untracked-files=all -- \
  ':(glob)lib/**/*.dart' ':(glob)test/**/*.dart' \
  pubspec.yaml pubspec.lock analysis_options.yaml) || block 'Não foi possível consultar as alterações do Git.'

[[ -n $changes ]] || exit 0

command -v dart >/dev/null 2>&1 || block 'Dart indisponível; confira o SDK/PATH. Não instale ou atualize ferramentas automaticamente.'
command -v flutter >/dev/null 2>&1 || block 'Flutter indisponível; confira o SDK/PATH. Não instale ou atualize ferramentas automaticamente.'

if ! dart format --output=none --set-exit-if-changed lib test >&2; then
  block 'Falha na verificação de formato. Formate somente os arquivos da tarefa e execute a checagem novamente.'
fi

if ! flutter analyze --no-pub >&2; then
  block 'Falha na análise. Confira os diagnósticos e as dependências já declaradas; não esconda erros nem execute upgrade automático.'
fi
