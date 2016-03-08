# NAME	= 2016-03-08-plotting-spatial-grids

NAME	= 2016-03-09-MNF-PCA-EOF

all:
	vi $(NAME).Rmd
	sed "s/DOWNLOADHERE/[view raw Rmd](https:\/\/raw.githubusercontent.com\/edzer\/r-spatial\/gh-pages\/_rmd\/$(NAME).Rmd)/g" $(NAME).Rmd > xx.Rmd
	Rscript -e 'library(rmarkdown); render("xx.Rmd", md_document(preserve_yaml = TRUE))'
	sed 's/images\//\/images\//g' xx.md | sed 's/TOC/\* TOC \n\{\:toc\}/g' > ../_posts/$(NAME).markdown
	rm -fr xx.md xx.Rmd
	cp -rf images/* ../images
	rm -fr images
