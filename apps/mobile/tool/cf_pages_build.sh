#!/usr/bin/env bash
# Build do GB CERNE (app Flutter) para o Cloudflare Pages.
#
# As imagens de build do Cloudflare Pages não trazem o SDK Flutter — este
# script baixa uma cópia rasa do canal `stable`, builda o app principal e a
# galeria de componentes (Widgetbook, F2.5) e combina os dois num único
# diretório de saída (`build/site`), com a galeria publicada em `/storybook`.
#
# Configuração no dashboard Cloudflare Pages (Workers & Pages → seu projeto →
# Settings → Builds):
#   Root directory:      apps/mobile
#   Build command:       bash tool/cf_pages_build.sh
#   Build output directory: build/site
#   (Framework preset: None)
#
# Rodar localmente para testar o mesmo pipeline: `bash tool/cf_pages_build.sh`
# a partir de `apps/mobile/`.

set -euo pipefail
cd "$(dirname "$0")/.."

# Git Bash/MSYS no Windows reescreve argumentos que começam com "/" (como
# --base-href /storybook/) para caminhos de arquivo do Windows. Só afeta quem
# roda este script localmente no Windows — inofensivo no Linux do Cloudflare
# Pages, mas desativamos a conversão para o script funcionar nos dois.
export MSYS2_ARG_CONV_EXCL="*"

FLUTTER_SDK_DIR="$(pwd)/.flutter-sdk"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

if [ ! -d "$FLUTTER_SDK_DIR" ]; then
  echo "==> Baixando Flutter SDK ($FLUTTER_CHANNEL)…"
  git clone --depth 1 --branch "$FLUTTER_CHANNEL" https://github.com/flutter/flutter.git "$FLUTTER_SDK_DIR"
fi

export PATH="$FLUTTER_SDK_DIR/bin:$PATH"

flutter --version
flutter config --enable-web >/dev/null
flutter pub get

echo "==> Buildando app principal (lib/main.dart) em build/site…"
flutter build web --release -o build/site

echo "==> Buildando galeria Widgetbook (lib/widgetbook_app.dart) em build/site/storybook…"
flutter build web --release -t lib/widgetbook_app.dart --base-href /storybook/ -o build/site/storybook

echo "==> Build combinado pronto em build/site (app na raiz, galeria em /storybook)."
