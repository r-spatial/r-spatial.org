NAME	= 2022-12-12-evolution2
#NAME	= 2021-04-21-xx
#NAME	= 2022-03-05-sftime-1
NAME	= 2022-03-16-openeo

all:
	vi $(NAME).Rmd
	sed "s/DOWNLOADHERE/[view raw Rmd](https:\/\/raw.githubusercontent.com\/\/r-spatial\/r-spatial.org\/gh-pages\/_rmd\/$(NAME).Rmd)/g" $(NAME).Rmd > xx.Rmd
	#Rscript -e 'library(rmarkdown); render("xx.Rmd", md_document("markdown_mmd"))'
	Rscript -e 'library(rmarkdown); render("xx.Rmd", md_document())'
	#awk -f dash.awk xx.md |
	head -8 $(NAME).Rmd > head.md
	cat head.md xx.md | \
		sed 's/xx_files\//\/images\//g' | \
		sed 's/TOC/\* TOC \n\{\:toc\}/g' > \
		../_posts/$(NAME).markdown
	# rm -fr xx.md xx.Rmd
	cp -rpf xx_files/* ../images
	#rm -fr xx_images

sftime:
	vi $(NAME).Rmd
	sed "s/DOWNLOADHERE/[view raw Rmd](https:\/\/raw.githubusercontent.com\/\/r-spatial\/r-spatial.org\/gh-pages\/_rmd\/$(NAME).Rmd)/g" $(NAME).Rmd > xx.Rmd
	Rscript -e 'library(rmarkdown); render("xx.Rmd", md_document("markdown_mmd"))'
	head -9 xx.Rmd > xx.hd
	cat xx.hd xx.md | \
		sed 's/xx_files\//\/images\//g' | \
		sed 's/TOC/\* TOC \n\{\:toc\}/g' > \
		../_posts/$(NAME).markdown
	cp -rpf xx_files/* ../images


all0:
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
