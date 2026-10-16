.PHONY: docs-mkdocs docs-mkdocs-serve docs-mkdocs-clean docs-mkdocs-assets

# Stage bench figures into the site source (single source of truth: media/).
# docs/assets/ is generated and gitignored.
docs-mkdocs-assets:
	mkdir -p docs/assets
	cp media/*.png docs/assets/ 2>/dev/null || true
	cp media/*.gif docs/assets/ 2>/dev/null || true

# Strict MkDocs build into site/ (fails on warnings).
docs-mkdocs: docs-mkdocs-assets
	mkdocs build --strict

# Local preview on http://localhost:8000 (no Node, Python only).
docs-mkdocs-serve: docs-mkdocs-assets
	mkdocs serve --dev-addr localhost:8000

# Remove generated documentation.
docs-mkdocs-clean:
	rm -rf site docs/assets/*.png docs/assets/*.gif

# --- Static docs (Asciidoctor, sealion-style template) ---
.PHONY: docs docs-clean docs-open docs-check docs-diagrams

# Build the complete static documentation into build/docs/.
docs:
	bash scripts/build-docs.sh

# Remove generated documentation.
docs-clean:
	rm -rf build/docs

# Serve the built manual locally (requires `make docs` first).
# Uses only the Python standard library; no npm or extra tooling.
docs-open: docs
	python3 -m http.server --directory build/docs 8000

# Regenerate lightweight SVG diagrams after editing docs/diagrams/*.json.
docs-diagrams:
	python3 scripts/render-docs-diagrams.py

# The same static validation used in CI; no third-party Python packages.
docs-check: docs
	python3 scripts/render-docs-diagrams.py --check
	python3 scripts/check-docs.py
	python3 scripts/test-docs-template.py

