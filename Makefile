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
	       --delete-after \
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
		--ignore-cache \
		--verbose \
		-s pelican_development_configuration.py \
		; \
	pipenv run pelican \
		--autoreload \
		--ignore-cache \
		--verbose \
		-s pelican_development_configuration.py \
		& \
	cd output \
		; \
	python3 -m http.server --bind localhost 8000
