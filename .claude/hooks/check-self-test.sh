#!/usr/bin/env bash
set -eu

hook="$(cd "$(dirname "$0")" && pwd)/check.sh"
git_bin=$(dirname "$(command -v git)")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/repo com espacos/lib" "$tmp/repo com espacos/test"
repo="$tmp/repo com espacos"
git -C "$repo" init --quiet
export HOOK_TEST_LOG="$tmp/commands.log"

cat > "$tmp/bin/dart" <<'STUB'
#!/usr/bin/env bash
printf 'dart %s\n' "$*" >> "$HOOK_TEST_LOG"
exit "${HOOK_FORMAT_EXIT:-0}"
STUB
cat > "$tmp/bin/flutter" <<'STUB'
#!/usr/bin/env bash
printf 'flutter %s\n' "$*" >> "$HOOK_TEST_LOG"
exit "${HOOK_ANALYZE_EXIT:-0}"
STUB
chmod +x "$tmp/bin/dart" "$tmp/bin/flutter"
export PATH="$tmp/bin:$PATH"

run() {
  local expected=$1 payload=${2:-'{"stop_hook_active":false}'} code=0
  : > "$HOOK_TEST_LOG"
  (cd "$repo" && printf '%s\n' "$payload" | bash "$hook") > "$tmp/out" 2> "$tmp/err" || code=$?
  if [[ $code != "$expected" ]]; then
    cat "$tmp/out" "$tmp/err" >&2
    printf 'Esperado exit %s, recebido %s\n' "$expected" "$code" >&2
    exit 1
  fi
}

printf '# Documento\n' > "$repo/README.md"
run 0
[[ ! -s $HOOK_TEST_LOG ]]

printf 'void main() {}\n' > "$repo/lib/exemplo com espacos.dart"
run 0
grep -qx 'dart format --output=none --set-exit-if-changed lib test' "$HOOK_TEST_LOG"
grep -qx 'flutter analyze --no-pub' "$HOOK_TEST_LOG"

# O staging abaixo pertence apenas à fixture temporária, nunca ao projeto do usuário.
git -c core.autocrlf=false -C "$repo" add 'lib/exemplo com espacos.dart'
run 0
[[ $(wc -l < "$HOOK_TEST_LOG") -eq 2 ]]
printf 'void main() { print(1); }\n' > "$repo/lib/exemplo com espacos.dart"
run 0
[[ $(wc -l < "$HOOK_TEST_LOG") -eq 2 ]]
rm "$repo/lib/exemplo com espacos.dart"
run 0
[[ $(wc -l < "$HOOK_TEST_LOG") -eq 2 ]]

HOOK_FORMAT_EXIT=1 run 2
[[ $(wc -l < "$HOOK_TEST_LOG") -eq 1 ]]
HOOK_ANALYZE_EXIT=1 run 2
[[ $(wc -l < "$HOOK_TEST_LOG") -eq 2 ]]
HOOK_ANALYZE_EXIT=1 run 0 '{"stop_hook_active":true}'
grep -q '"continue":false' "$tmp/out"
grep -q 'O gate não passou' "$tmp/out"
run 0 '{"stop_hook_active":true}'
[[ $(wc -l < "$HOOK_TEST_LOG") -eq 2 ]]
[[ ! -s $tmp/out ]]
HOOK_ANALYZE_EXIT=1 run 2 '{"last_assistant_message":"texto com \"stop_hook_active\": true","stop_hook_active":false}'

for manifest in pubspec.yaml pubspec.lock analysis_options.yaml; do
  repo="$tmp/$manifest"
  mkdir -p "$repo"
  git -C "$repo" init --quiet
  printf '# Configuração\n' > "$repo/$manifest"
  run 0
  [[ $(wc -l < "$HOOK_TEST_LOG") -eq 2 ]]
done

repo="$tmp/tests"
mkdir -p "$repo/test"
git -C "$repo" init --quiet
printf 'void main() {}\n' > "$repo/test/exemplo_test.dart"
run 0
[[ $(wc -l < "$HOOK_TEST_LOG") -eq 2 ]]

mv "$tmp/bin/flutter" "$tmp/flutter-disabled"
PATH="$tmp/bin:$git_bin:/usr/bin:/bin" run 2
grep -q 'Flutter indisponível' "$tmp/err"
mv "$tmp/flutter-disabled" "$tmp/bin/flutter"
mv "$tmp/bin/dart" "$tmp/dart-disabled"
PATH="$tmp/bin:$git_bin:/usr/bin:/bin" run 2
grep -q 'Dart indisponível' "$tmp/err"

repo="$tmp/fora-do-repositorio"
mkdir -p "$repo"
run 2
grep -q 'dentro do repositório ativo' "$tmp/err"

printf '%s\n' 'Auto-checagem aprovada: seleção Git, formato/análise, falhas, repetição e ambiente; nenhum comando Flutter real ou commit executado.'
