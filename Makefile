upload_to_kaka_farm:
	rsync -arvP _site/ blog.kakafarm:/var/www/kaka-farm-blog/

build:
	cobalt build

build-drafts:
	cobalt build --drafts
