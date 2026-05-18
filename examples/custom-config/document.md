---
title: Custom Configuration Example
user-config: customcfg.typ
---

# Custom Configuration

This document demonstrates how to use a custom Typst configuration file to override the default template settings.

By using the `--config` or `-c` flag, we have changed the following settings:

- **Language**: Set to German (`de`).
- **Region**: Set to Germany (`DE`).
- **Paper Size**: Set to `a5`.
- **Authors**: Custom author list defined in the config file.

## How to run this example

```bash
python3 convert.py examples/custom-config/document.md --config examples/custom-config/custom_cfg.typ
```

Or set it in the frontmatter:

```yaml
user-config: customcfg.typ
```

> [!NOTE]
> Don't use characters that get escaped (like `\` or `_`) by pandoc as a config file name.
