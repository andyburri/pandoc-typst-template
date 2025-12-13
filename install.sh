#!/bin/bash

BIN_PATH="$HOME/.local/bin"
SHARE_DIR="$HOME/.local/share/md2pdf"

# download bin
wget https://git.qxp.ch/andy/pandoc-typst-template/raw/branch/main/cmd/md2pdf -O "$BIN_PATH"/md2pdf && chmod +x "$BIN_PATH"/md2pdf

# create share dir if it doesn't exist
mkdir -p "$SHARE_DIR"

#create filter dir
mkdir -p "$SHARE_DIR/filters"

# create template dir
mkdir -p "$SHARE_DIR/templates"

#download filters

filters=(typst-filters.lua diagram.lua include-files.lua puppeteer-config.json)

for filter in "${filters[@]}"; do
    wget https://git.qxp.ch/andy/pandoc-typst-template/raw/branch/main/cmd/filters/$filter -O "$SHARE_DIR/filters/$filter"
done

# download template files

templates=(abstract.typ bergfink.typst default_styles.typ titlepage.typ toc.typ)

for template in "${templates[@]}"; do
    wget https://git.qxp.ch/andy/pandoc-typst-template/raw/branch/main/cmd/template/$template -O "$SHARE_DIR/templates/$template"
done
