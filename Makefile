build:
	jekyll build --drafts

serve:
	jekyll serve --safe --watch --force_polling --port 4000 --drafts

.PHONY: build serve
