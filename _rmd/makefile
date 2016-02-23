NAME	= 2016-02-14-gstat-variogram-fitting

all:
	vi $(NAME).Rmd
	sed "s/DOWNLOADHERE/[view raw Rmd](https:\/\/raw.githubusercontent.com\/edzer\/r-spatial\/gh-pages\/_rmd\/$(NAME).Rmd)/g" $(NAME).Rmd > xx.Rmd
	Rscript -e 'library(rmarkdown); render("xx.Rmd", md_document(preserve_yaml = TRUE))'
	#sed 's/images\//\/r-spatial\/images\//g' xx.md > ../_posts/$(NAME).markdown
	sed 's/images\//\/images\//g' xx.md > ../_posts/$(NAME).markdown
	# mv xx.md ../_posts/$(NAME).markdown
	rm -fr xx.md xx.Rmd
	cp -r images/* ../images
	rm -fr images
