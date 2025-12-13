---
listings: true
---

# Some Code Listings

The code in [@fibo] is a simple implementation of the Fibonacci sequence in Python.

```python {#fibo caption="Code for the Fibonacci number"}
import numpy as np

def fibonacci(x):
    if x < 2:
        return x
    else:
        return fibonacci(x - 1) + fibonacci(x - 2)
```

# Some bash Code

```bash
#!/bin/bash

BIN_PATH="$HOME/.local/bin"
SHARE_DIR="$HOME/.local/share/md2pdf"

# download bin
wget https://git.qxp.ch/andy/pandoc-typst-template/raw/branch/main/cmd/md2pdf -O "$BIN_PATH"/md2pdf && chmod +x "$BIN_PATH"/md2pdf

#download filters

filters=(typst-filters.lua diagram.lua include-files.lua)

for filter in "${filters[@]}"; do
    wget https://git.qxp.ch/andy/pandoc-typst-template/raw/branch/main/cmd/filters/$filter -O "$SHARE_DIR/filters/$filter"
done

# download template files

templates=(abstract.typ bergfink.template config.typ default_styles.typ page.typ titlepage.typ toc.typ)

for template in "${templates[@]}"; do
    wget https://git.qxp.ch/andy/pandoc-typst-template/raw/branch/main/cmd/template/$template -O "$SHARE_DIR/templates/$template"
done
```

The above listing hasn't a caption.
