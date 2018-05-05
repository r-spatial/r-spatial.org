NAME	= 2018-05-07-parsing-quantities

all:
	vi $(NAME).Rmd
	sed "s/DOWNLOADHERE/[view raw Rmd](https:\/\/raw.githubusercontent.com\/\/r-spatial\/r-spatial.org\/gh-pages\/_rmd\/$(NAME).Rmd)/g" $(NAME).Rmd > xx.Rmd
	Rscript -e 'library(rmarkdown); render("xx.Rmd", md_document("markdown_mmd"))'
	awk -f dash.awk xx.md | \
		sed 's/images\//\/images\//g' | \
		sed 's/TOC/\* TOC \n\{\:toc\}/g' > \
		../_posts/$(NAME).markdown
	rm -fr xx.md xx.Rmd
	cp -rf images/* ../images
	rm -fr images

storms:
	sed "s/DOWNLOADHERE/[view raw Rmd](https:\/\/raw.githubusercontent.com\/\/r-spatial\/r-spatial.org\/gh-pages\/_rmd\/$(NAME).Rmd)/g" $(NAME).Rmd > xx.Rmd
	Rscript -e 'library(rmarkdown); render("xx.Rmd", "html_document")'
	mv xx.html ../_includes/storm_tracks.html
	rm -fr xx.Rmd
