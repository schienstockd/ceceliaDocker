FROM rocker/ml:4.2.0

### init shiny
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget \
    # for compiling
    cmake \
		# for HPC connection
		ssh \
		rsync \
		# for process management
		psmisc \
    # for R 'misc3d'
    tk \
		# for EBImage
		# libfftw3-dev \
    # for rsvg and sf
    libudunits2-dev \
    librsvg2-dev \
    libgdal-dev \
		# for RBioFormats and Fiji
		openjdk-8-jdk-headless \
		# https://github.com/rstudio/rstudio/issues/2254#issuecomment-413939666
		&& R CMD javareconf \
		&& apt-get clean \
    # switch java for Fiji
    # TODO do we need this?
    && update-java-alternatives --set java-1.8.0-openjdk-amd64

### init shiny app
# https://dockerquestions.com/2021/05/23/docker-shiny-app-no-such-file-or-directory-while-running-docker-image/
ENV PATH="/home/shiny/miniconda3/bin:${PATH}"
ARG PATH="/home/shiny/miniconda3/bin:${PATH}"

# https://stackoverflow.com/a/39855387
RUN useradd -ms /bin/bash shiny

# prepare local tools
RUN mkdir /opt/tools \
	&& chown shiny:shiny /opt/tools

### SHINY from here on
# shiny needs 0.5.4
RUN R -e 'remove.packages(c("htmltools", "tidyr"))'
USER shiny

# when everything works - this should be one commit?
# Use user library
# https://stackoverflow.com/a/43283085
RUN R -e 'dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'
RUN R -e 'if (!require("remotes", quietly = TRUE)) install.packages("remotes", lib = Sys.getenv("R_LIBS_USER"), repos = "https://cloud.r-project.org")'
RUN R -e 'remotes::install_github("schienstockd/cecelia", lib = Sys.getenv("R_LIBS_USER"), Ncpus = 4, repos = "https://cloud.r-project.org")'
RUN R -e 'cecelia::cciaAppRequirements(lib = Sys.getenv("R_LIBS_USER"), repos = "https://cloud.r-project.org")'
RUN R -e 'cecelia::cciaBiocRequirements(lib = Sys.getenv("R_LIBS_USER"), ask = FALSE)'
RUN R -e 'cecelia::cciaSetup()'

# install miniconda for shiny
# https://linuxhandbook.com/dockerize-python-apps/
RUN cd /home/shiny \
		&& wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /home/shiny/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

RUN R -e 'cecelia::cciaCondaCreate(envType = "image-nogui")'
RUN R -e 'cecelia::cciaUse();cecelia::cciaModels()'

# install local tools
RUN mkdir -p /opt/tools/fiji \
	&& mkdir -p /opt/tools/bftools

# install Fiji
# https://github.com/fiji/dockerfiles/blob/master/fiji-openjdk-8/Dockerfile
WORKDIR /opt/tools/fiji

RUN wget -q https://downloads.imagej.net/fiji/latest/fiji-nojre.zip \
 && unzip fiji-nojre.zip \
 && rm fiji-nojre.zip

# add plugin sites and run update
RUN cd Fiji.app/ \
	&& ./ImageJ-linux64 --update add-update-site IJPB-plugins https://sites.imagej.net/IJPB-plugins/ \
	&& ./ImageJ-linux64 --update add-update-site 3D-ImageJ-Suite https://sites.imagej.net/Tboudier/ \
	&& ./ImageJ-linux64 --update add-update-site Bio-Formats https://sites.imagej.net/Bio-Formats/ \
	# && ./ImageJ-linux64 --update add-update-site clij https://sites.imagej.net/clij/ \
	&& ./ImageJ-linux64 --update add-update-site clij2 https://sites.imagej.net/clij2/ \
	&& ./ImageJ-linux64 --update update

# install BFTools
# https://github.com/fiji/dockerfiles/blob/master/fiji-openjdk-8/Dockerfile
WORKDIR /opt/tools

RUN wget -q https://downloads.openmicroscopy.org/bio-formats/6.7.0/artifacts/bftools.zip \
	&& unzip bftools.zip \
	&& rm bftools.zip

# add bioformats2raw
RUN wget -q https://github.com/glencoesoftware/bioformats2raw/releases/download/v0.4.0/bioformats2raw-0.4.0.zip \
	&& unzip bioformats2raw-0.4.0.zip \
	&& rm bioformats2raw-0.4.0.zip

USER root

### run server
# ENTRYPOINT ["sh", "-c"]
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

USER shiny

# update cecelia
# https://stackoverflow.com/a/65762156
ADD "https://api.github.com/repos/schienstockd/cecelia/commits?per_page=1" skipcache
RUN R -e 'lib <- Sys.getenv("R_LIBS_USER")[[1]];remotes::install_github("schienstockd/cecelia", lib = lib, Ncpus = 4, repos = "https://cloud.r-project.org", upgrade = "never")'
RUN R -e 'cecelia::cciaCondaCreate(envType = "image-nogui")'

#ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/usr/bin/docker-entrypoint.sh ${JUPYTER_LIB_DIR}"]
