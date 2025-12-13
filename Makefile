.PHONY: all pdf typ preview $(EXAMPLES)

EXAMPLES = basic-example bibliography dateformat showcase no-justify \
           no-header-footer code-listings titlepage columns tables \
           custom-header-footer glossy images alerts diagrams fonts

all: pdf typ preview

# --- Global PDF ---

pdf:
	@echo "Generating all PDFs"
	@for example in $(EXAMPLES); do \
		examples/md2pdf examples/$$example/document.md; \
	done
	@cd examples/phd-example && bash ../md2pdf *.md --metadata-file=metadata.yaml --output=document.pdf

# --- Global Typst ---

typ:
	@echo "Generating all Typst files"
	@for example in $(EXAMPLES); do \
		examples/md2typ examples/$$example/document.md; \
	done
	@cd examples/phd-example && bash ../md2typ *.md --metadata-file=metadata.yaml --output=document.typ

# --- Global Preview ---

preview:
	@echo "Generating all previews"
	rm -f examples/*/preview-*.png
	@for example in $(EXAMPLES); do \
		echo "Generating preview for $$example"; \
		pdftoppm -r 150 -png examples/$$example/document.pdf examples/$$example/preview; \
	done
	pdftoppm -r 150 -png examples/phd-example/document.pdf examples/phd-example/preview

# --- Per-example rule ---
# Let each example name be a Make target.
# Running `make basic-example` will:
#   - build its PDF
#   - build its Typst file
#   - generate its preview

$(EXAMPLES):
	@echo "Building all outputs for $@"
	examples/md2typ examples/$@/document.md
	examples/md2pdf examples/$@/document.md
	rm -f examples/$@/preview-*.png
	pdftoppm -r 150 -png examples/$@/document.pdf examples/$@/preview
