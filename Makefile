.POSIX:

HUGO=hugo

S3_BUCKET=volatilethunk.com
OUTPUT_DIR=public

AI_PATHFINDING_RELEASE=0.1.1
CONWAYS_GAME_OF_LIFE_RELEASE=0.1.1

build:
	$(HUGO)

help:
	@echo 'Makefile for VolatileThunk                                            '
	@echo '                                                                      '
	@echo 'Usage:                                                                '
	@echo '   make build                  build the site                         '
	@echo '   make help                   show this help                         '
	@echo '   make clean                  remove the generated files             '
	@echo '   make rm_unused_theme_files  regenerate files upon modification     '
	@echo '   make add_web_artefacts      package webapp projects                '
	@echo '   make serve                  serve at http://localhost:1313         '
	@echo '   make serve-global           serve globally at http://localhost:1313'
	@echo '   make publish                create uploadable package of aretfacts '
	@echo '   make s3_upload              upload the web site via S3             '
	@echo '                                                                      '

clean:
	if [ -d "$(OUTPUT_DIR)" ]; \
	then \
	    rm -rf "$(OUTPUT_DIR)"; \
	fi

rm_unused_theme_files:
	rm \
		"$(OUTPUT_DIR)"/*.png \
		"$(OUTPUT_DIR)"/*.svg \
		"$(OUTPUT_DIR)"/*.ico \
		"$(OUTPUT_DIR)"/browserconfig.xml \
		"$(OUTPUT_DIR)"/site.webmanifest

add_web_artefacts:
	export AI_PATHFINDING_RELEASE="$(AI_PATHFINDING_RELEASE)"; \
	export CONWAYS_GAME_OF_LIFE_RELEASE="$(CONWAYS_GAME_OF_LIFE_RELEASE)"; \
	export OUTPUT_DIR="$(OUTPUT_DIR)"; \
	./scripts/add_web_artefacts.sh "$(OUTPUT_DIR)"

serve:
	$(HUGO) serve

serve-global:
	$(HUGO) serve --bind 0.0.0.0

publish: build rm_unused_theme_files add_web_artefacts

just_s3_upload:
	aws s3 sync "$(OUTPUT_DIR)/" "s3://$(S3_BUCKET)" --delete

s3_upload: publish just_s3_upload

