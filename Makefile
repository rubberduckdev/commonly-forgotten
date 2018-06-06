.PHONY: build
build:
	pipenv run pelican \
		--ignore-cache \
		-s pelican_publication_configuration.py

.PHONY: kaka.farm
kaka.farm:
	pipenv run pelican \
		--ignore-cache \
		--delete-output-directory \
		-s pelican_publication_configuration.py
	rsync \
	       --progress \
	       --verbose \
	       --archive \
	       output/ \
	       blog.kakafarm:/var/www/kaka-farm-blog/

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
