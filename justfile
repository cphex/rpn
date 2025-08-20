default:
  just --list

check-formatting:
  mix format --check-formatted

format:
  mix format

docs:
  mix docs

docs-browser:
  mix docs --open

compile:
  mix compile --warnings-as-errors

test:
  mix test --warnings-as-errors

npm-install:
  npm --prefix assets install assets
