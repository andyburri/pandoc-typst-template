#!/usr/bin/env python3

import subprocess
import argparse
import os
import sys
import time
from pathlib import Path

lua_filters = [
    "include-files.lua",
    "preserve-ref.lua",
    "citations.lua",
    "pagebreak.lua",
    "newline.lua",
    "caption-code-blocks.lua",
    "plantuml.lua",
    "mermaid.lua",
    "align-figures.lua",
    "align-tables.lua",
    "callouts.lua",
]


template = Path(__file__).parent / "template/bergfink.typst"
filters_dir = Path(__file__).parent / "filters"


def main():
    parser = argparse.ArgumentParser(
        description="Convert Markdown to PDF using Pandoc and Typst"
    )
    parser.add_argument("input", nargs="+", help="Input Markdown files")
    parser.add_argument(
        "--output", "-o", help="Output PDF file (defaults to input.pdf)"
    )
    parser.add_argument("--metadata", "-m", help="Metadata file")
    parser.add_argument(
        "--typ", nargs="?", const=True, help="Output typst file (default: input.typ)"
    )
    parser.add_argument("--config", "-c", help="Custom Typst configuration file")
    parser.add_argument(
        "--watch", "-w", action="store_true", help="Watch input files for changes"
    )
    args = parser.parse_args()

    # Resolve paths to absolute before changing directory
    input_paths = [Path(i).resolve() for i in args.input]

    if args.typ:
        if isinstance(args.typ, str):
            args.output = args.typ
        else:
            args.output = str(input_paths[0].with_suffix(".typ"))
    elif not args.output:
        args.output = str(input_paths[0].with_suffix(".pdf"))

    output_path = Path(args.output).resolve()
    metadata_path = Path(args.metadata).resolve() if args.metadata else None
    config_path = Path(args.config).resolve() if args.config else None

    # Change to directory of the first input file
    os.chdir(input_paths[0].parent)

    cmd = [
        "pandoc",
        *[str(p) for p in input_paths],
        "-o",
        str(output_path),
        "--from",
        "markdown",
        "--template",
        str(template),
    ]

    if output_path.suffix == ".typ":
        cmd.extend(["--to", "typst"])
    else:
        cmd.extend(["--pdf-engine", "typst"])

    if lua_filters:
        for lua_filter in lua_filters:
            cmd.extend(["--lua-filter", str(filters_dir / lua_filter)])

    if metadata_path:
        cmd.extend(["--metadata-file", str(metadata_path)])

    if config_path:
        try:
            # Use relative path to avoid Typst root issues when include is used in template
            rel_config_path = os.path.relpath(config_path, input_paths[0].parent)
            cmd.extend(["-V", f"user-config={rel_config_path}"])
        except ValueError:
            cmd.extend(["-V", f"user-config={config_path}"])

    def run_conversion():
        try:
            print(f"Running conversion...")
            subprocess.run(cmd, check=True)
            print("Done.")
            return True
        except subprocess.CalledProcessError as e:
            print(f"Error: {e}")
            return False

    if not args.watch:
        if not run_conversion():
            sys.exit(1)
    else:
        run_conversion()
        files_to_watch = list(input_paths)
        if metadata_path and metadata_path.exists():
            files_to_watch.append(metadata_path)
        if config_path and config_path.exists():
            files_to_watch.append(config_path)

        print(
            f"Watching for changes in {[p.name for p in files_to_watch]}... (Ctrl+C to stop)"
        )
        last_mtimes = {p: p.stat().st_mtime for p in files_to_watch if p.exists()}

        try:
            while True:
                time.sleep(1)
                changed = False
                for p in files_to_watch:
                    if not p.exists():
                        continue
                    mtime = p.stat().st_mtime
                    if p not in last_mtimes or mtime > last_mtimes[p]:
                        last_mtimes[p] = mtime
                        changed = True

                if changed:
                    print("\nChange detected, re-running conversion...")
                    run_conversion()
        except KeyboardInterrupt:
            print("\nStopped watching.")
            sys.exit(0)


if __name__ == "__main__":
    main()
