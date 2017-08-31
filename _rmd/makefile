# NAME	= 2016-03-08-plotting-spatial-grids

# NAME	= 2017-01-30-mapedit_intro
NAME	= nest

all:
	vi $(NAME).Rmd
	sed "s/DOWNLOADHERE/[view raw Rmd](https:\/\/raw.githubusercontent.com\/edzer\/r-spatial\/gh-pages\/_rmd\/$(NAME).Rmd)/g" $(NAME).Rmd > xx.Rmd
	Rscript -e 'library(rmarkdown); render("xx.Rmd", md_document("markdown_mmd"))'
	awk -f dash.awk xx.md | \
		sed 's/images\//\/images\//g' | \
		sed 's/TOC/\* TOC \n\{\:toc\}/g' > \
		../_posts/$(NAME).markdown
	rm -fr xx.md xx.Rmd
	cp -rf images/* ../images
	# rm -fr images

storms:
	sed "s/DOWNLOADHERE/[view raw Rmd](https:\/\/raw.githubusercontent.com\/edzer\/r-spatial\/gh-pages\/_rmd\/$(NAME).Rmd)/g" $(NAME).Rmd > xx.Rmd
	Rscript -e 'library(rmarkdown); render("xx.Rmd", "html_document")'
	mv xx.html ../_includes/storm_tracks.html
	rm -fr xx.Rmd
