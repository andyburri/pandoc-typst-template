#!/bin/bash

BIN_PATH="$HOME/.local/bin"
SHARE_DIR="$HOME/.local/share/md2pdf"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/andyburri/pandoc-typst-template/main"

# create bin dir if it doesn't exist
mkdir -p "$BIN_PATH"

# download bin
wget "$GITHUB_RAW_BASE/cmd/md2pdf" -O "$BIN_PATH/md2pdf" && chmod +x "$BIN_PATH/md2pdf"

# create share dir if it doesn't exist
mkdir -p "$SHARE_DIR"

#create filter dir
mkdir -p "$SHARE_DIR/filters"

# create template dir
mkdir -p "$SHARE_DIR/templates"

#download filters

filters=(typst-filters.lua diagram.lua include-files.lua puppeteer-config.json)

for filter in "${filters[@]}"; do
    wget "$GITHUB_RAW_BASE/cmd/filters/$filter" -O "$SHARE_DIR/filters/$filter"
done

# download template files

templates=(abstract.typ bergfink.typst default_styles.typ titlepage.typ toc.typ)

for template in "${templates[@]}"; do
    wget "$GITHUB_RAW_BASE/cmd/template/$template" -O "$SHARE_DIR/templates/$template"
done
