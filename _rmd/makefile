NAME	= 2016-02-14-gstat-variogram-fitting

all:
	vi $(NAME).Rmd
	Rscript -e 'library(rmarkdown); render("2016-02-14-gstat-variogram-fitting.Rmd", md_document(preserve_yaml = TRUE))'
	sed 's/images\//\/r-spatial\/images\//g' $(NAME).md > ../_posts/$(NAME).markdown
	rm $(NAME).md
	cp -r images/* ../images
	rm -fr images
