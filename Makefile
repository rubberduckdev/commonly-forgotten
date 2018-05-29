include config.mk

.PHONY: build
build:
	pipenv run mkdocs build -s -d public
serve:
	pipenv run mkdocs serve -s
publish_on_kaka_farm: build
	rsync -Pav public/ $(PUBLISH_TO_KAKA_FARM_TARGET)
