.POSIX:

HUGO=hugo

S3_BUCKET=volatilethunk.com
OUTPUT_DIR=public

all:
	$(HUGO)

.PHONY: all help clean rm-unused-theme-files add-web-artefacts serve serve-global publish just-s3-upload s3-upload

help:
	@echo Makefile for VolatileThunk
	@echo
	@echo Usage:
	@echo    make build                  Build the site.
	@echo    make help                   Show this help.
	@echo    make clean                  Remove the generated files.
	@echo    make rm_unused_theme_files  Regenerate files upon modification.
	@echo    make add_web_artefacts      Package webapp projects.
	@echo    make serve                  Serve at http://localhost:1313
	@echo    make serve-global           Serve globally at http://localhost:1313
	@echo    make publish                Create uploadable package of aretfacts.
	@echo    make s3_upload              Upload the web site via S3.
	@echo

clean:
	if [ -d "$(OUTPUT_DIR)" ]; \
	then \
	    rm -rf "$(OUTPUT_DIR)"; \
	fi

rm-unused-theme-files:
	rm \
		"$(OUTPUT_DIR)"/*.png \
		"$(OUTPUT_DIR)"/*.svg \
		"$(OUTPUT_DIR)"/*.ico \
		"$(OUTPUT_DIR)"/browserconfig.xml \
		"$(OUTPUT_DIR)"/site.webmanifest

add-web-artefacts:
	export OUTPUT_DIR="$(OUTPUT_DIR)"; \
	./scripts/add_web_artefacts.sh "$(OUTPUT_DIR)"

serve:
	$(HUGO) serve

serve-global:
	$(HUGO) serve --bind 0.0.0.0

publish: build rm-unused-theme-files add-web-artefacts

just-s3-upload:
	aws s3 sync "$(OUTPUT_DIR)/" "s3://$(S3_BUCKET)" --delete

s3-upload: publish just-s3-upload

