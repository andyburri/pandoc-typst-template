.PHONY: all pdf typ preview $(EXAMPLES)

EXAMPLES = basic-example bibliography dateformat showcase no-justify \
           no-header-footer code-listings titlepage columns tables \
           custom-header-footer glossary images alerts diagrams fonts custom-config blocks \
           yaml-table

all: pdf typ preview phd

# --- Global PDF ---

pdf:
	@echo "Generating all PDFs"
	@for example in $(EXAMPLES); do \
		echo "Generating PDF for $$example"; \
		./md2pdf.sh examples/$$example/document.md; \
	done

# --- Global Typst ---

typ:
	@echo "Generating all Typst files"
	@for example in $(EXAMPLES); do \
		echo "Generating Typst for $$example"; \
		./md2pdf.sh examples/$$example/document.md --typ; \
	done

# --- Global Preview ---

preview:
	@echo "Generating all previews"
	rm -f examples/*/preview-*.png
	@for example in $(EXAMPLES); do \
		echo "Generating preview for $$example"; \
		pdftoppm -r 150 -png examples/$$example/document.pdf examples/$$example/preview; \
	done
	pdftoppm -r 150 -png examples/phd-example/document.pdf examples/phd-example/preview

phd:
	@echo "Generating Phd Example"
	./md2pdf.sh examples/phd-example/*.md --typ examples/phd-example/document.typ --metadata examples/phd-example/metadata.yaml
	./md2pdf.sh examples/phd-example/*.md --output examples/phd-example/document.pdf --metadata examples/phd-example/metadata.yaml
	rm -f examples/phd-example/preview-*.png
	pdftoppm -r 150 -png examples/phd-example/document.pdf examples/phd-example/preview

# --- Per-example rule ---
# Let each example name be a Make target.
# Running `make basic-example` will:
#   - build its PDF
#   - build its Typst file
#   - generate its preview

$(EXAMPLES):
	@echo "Building all outputs for $@"
	./md2pdf.sh examples/$@/document.md --typ
	./md2pdf.sh examples/$@/document.md
	rm -f examples/$@/preview-*.png
	pdftoppm -r 150 -png examples/$@/document.pdf examples/$@/preview
