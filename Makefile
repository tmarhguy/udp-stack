.PHONY: docs docs-serve docs-clean docs-assets

# Stage bench figures into the site source (single source of truth: media/).
# docs/assets/ is generated and gitignored.
docs-assets:
	mkdir -p docs/assets
	cp media/*.png docs/assets/ 2>/dev/null || true
	cp media/*.gif docs/assets/ 2>/dev/null || true

# Strict MkDocs build into site/ (fails on warnings).
docs: docs-assets
	mkdocs build --strict

# Local preview on http://localhost:8000 (no Node, Python only).
docs-serve: docs-assets
	mkdocs serve --dev-addr localhost:8000

# Remove generated documentation.
docs-clean:
	rm -rf site docs/assets/*.png docs/assets/*.gif
