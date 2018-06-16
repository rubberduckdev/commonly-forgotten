.PHONY: build
build:
	pipenv run pelican \
		--delete-output-directory \
		--ignore-cache \
		-s pelican_publication_configuration.py

.PHONY: kaka.farm
kaka.farm:
	pipenv run pelican \
		--delete-output-directory \
		--ignore-cache \
		-s pelican_publication_configuration.py
	rsync \
	       --archive \
	       --delete-after \
	       --progress \
	       --verbose \
	       output/ \
	       blog.kakafarm:/var/www/kaka-farm-blog/

.PHONY: gitlab
gitlab:
	pipenv run pelican \
		--delete-output-directory \
		--ignore-cache \
		-s pelican_gitlab_configuration.py


.PHONY: dev
dev:
	pipenv run python pelican_development_server.py
