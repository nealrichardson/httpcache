VERSION = $(shell grep ^Version DESCRIPTION | sed s/Version:\ //)

doc:
	R -s -e 'library(roxygen2); roxygenise()'
	git add --all man/*.Rd

test:
	R CMD INSTALL --install-tests .
	export NOT_CRAN=true && R -s -e 'library(httptest); setwd(file.path(.libPaths()[1], "httpcache", "tests")); system.time(test_check("httpcache", filter="${file}", reporter=ifelse(nchar("${r}"), "${r}", "summary")))'

deps:
	R -s -e 'install.packages(c("httr", "codetools", "testthat", "devtools", "digest"), repo="http://cran.at.r-project.org", lib=ifelse(nchar(Sys.getenv("R_LIB")), Sys.getenv("R_LIB"), .libPaths()[1]))'

build: doc
	R CMD build .

check: build
	-R CMD CHECK --as-cran httpcache_$(VERSION).tar.gz
    # cd httpcache.Rcheck/httpcache/doc/ && ls | grep .html | xargs -n 1 egrep "<pre><code>.. NULL" >> ../../../vignette-errors.log
	rm -rf httpcache.Rcheck/
    # cat vignette-errors.log
    # rm vignette-errors.log

vdata:
	cd vignette-data && find *.R | xargs -n 1 R -f

man: doc
	R CMD Rd2pdf man/ --force

md:
	R CMD INSTALL --install-tests .
	mkdir -p inst/doc
	R -e 'setwd("vignettes"); lapply(dir(pattern="Rmd"), knitr::knit, envir=globalenv())'
	mv vignettes/*.md inst/doc/
	-cd inst/doc && ls | grep .md | xargs -n 1 sed -i '' 's/.html)/.md)/g'
	-cd inst/doc && ls | grep .md | xargs -n 1 egrep "^.. Error"

build-vignettes: md
	R -e 'setwd("inst/doc"); lapply(dir(pattern="md"), function(x) markdown::markdownToHTML(x, output=sub("\\\\.md", ".html", x)))'
	cd inst/doc && ls | grep .html | xargs -n 1 sed -i '' 's/.md)/.html)/g'
	# That sed isn't working, fwiw
	open inst/doc/getting-started.html

covr:
	R -s -e 'library(covr); cv <- package_coverage(); df <- covr:::to_shiny_data(cv)[["file_stats"]]; cat("Line coverage:", round(100*sum(df[["Covered"]])/sum(df[["Relevant"]]), 1), "percent\\n")'

style:
	R -s -e 'setwd(".."); if (requireNamespace("styler")) styler::style_file(system("git diff --name-only | grep r/.*R$$", intern = TRUE))'

style-all:
	R -s -e 'styler::style_file(dir(pattern = "R$$", recursive = TRUE))'

build-pkgdown:
	R -e 'pkgdown::build_site()'
	cp ../nealrichardson.github.io/static/favicon.ico docs/

publish-pkgdown:
	rm -rf ../nealrichardson.github.io/static/r/httpcache/
	mkdir ../nealrichardson.github.io/static/r/httpcache/
	cp -r docs/* ../nealrichardson.github.io/static/r/httpcache/
