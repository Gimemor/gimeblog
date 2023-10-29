docker run -p 4000:4000 --rm --volume="%CD%:/srv/jekyll:Z" --publish [::1]:4000:4000 jekyll/jekyll jekyll serve  --force_polling
