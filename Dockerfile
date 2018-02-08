From rocker/rstudio:3.4.2

RUN apt-get update && apt-get -y install\
 	unixodbc \
	unixodbc-dev \
	libxml2-dev

# install packrat
RUN R -e 'install.packages("packrat", repos="http://cran.rstudio.com", dependencies=TRUE, lib="/usr/local/lib/R/site-library");'

USER rstudio

# copy lock file & install deps
COPY --chown=rstudio:rstudio packrat/packrat.* /home/rstudio/project/packrat/
RUN R -e 'packrat::restore(project="/home/rstudio/project");'

# copy the rest of the directory
# .dockerignore can ignore some files/folders if desirable
COPY --chown=rstudio:rstudio . /home/rstudio/project

USER root
