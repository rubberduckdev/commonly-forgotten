include secret-config.mk

.PHONY: build
build:
	pipenv run mkdocs build -s -d public
serve:
	pipenv run mkdocs serve -s
publish_on_kaka_farm: build clean_kaka_farm
	rsync -Pav public/ $(KAKA_FARM_SERVER):$(KAKA_FARM_BLOG_PATH)
clean_kaka_farm:
	ssh $(KAKA_FARM_SERVER) rm -rvf $(KAKA_FARM_BLOG_PATH)/*
