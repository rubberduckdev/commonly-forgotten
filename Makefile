.PHONY: build
build:
	pipenv run pelican \
		--ignore-cache \
		-s pelican_publication_configuration.py

.PHONY: gitlab
gitlab:
	pipenv run pelican \
		--ignore-cache \
		-s pelican_gitlab_configuration.py


.PHONY: dev
dev:
	pipenv run pelican \
		--autoreload \
		--ignore-cache \
		-s pelican_development_configuration.py
