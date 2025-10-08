FROM rocker/ml:latest

USER root

### init shiny
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    libcurl4-openssl-dev \
    gdal-bin libnode-dev \
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
    # Magick
    libmagick++-dev \
    # igraph
    libglpk-dev \
    # RGL
    libglu1-mesa libxi-dev libxmu-dev libglu1-mesa-dev \
		# for RBioFormats and Fiji
		openjdk-8-jdk-headless \
		# https://github.com/rstudio/rstudio/issues/2254#issuecomment-413939666
		&& R CMD javareconf \
		&& apt-get clean
    # switch java for Fiji
    # TODO do we need this?
    # && update-java-alternatives --set java-1.8.0-openjdk-amd64

### init shiny app
# https://dockerquestions.com/2021/05/23/docker-shiny-app-no-such-file-or-directory-while-running-docker-image/
ENV PATH="/home/shiny/miniconda3/bin:${PATH}"
ARG PATH="/home/shiny/miniconda3/bin:${PATH}"

# add blosc
RUN git clone https://github.com/Blosc/c-blosc.git \
	&& cd c-blosc \
	&& cmake . \
	&& cmake --build . --target install \
	&& cd ..

# create paths for R?
# 'lib = "/usr/local/lib/R/site-library"' is not writable
# https://github.com/rocker-org/rocker/issues/513
RUN mkdir -p /usr/local/lib/R/site-library && chmod 777 -R /usr/local/lib/R/site-library

# https://stackoverflow.com/a/39855387
# RUN useradd -ms /bin/bash jovyan

# prepare local tools
RUN mkdir /opt/tools && chown jovyan:users /opt/tools

### SHINY from here on.. or jovyan
USER jovyan
WORKDIR /home/jovyan

# install miniconda for jovyan
# https://linuxhandbook.com/dockerize-python-apps/
RUN cd /home/jovyan \
		&& wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /home/jovyan/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

# accept conda terms
RUN /home/jovyan/miniconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN /home/jovyan/miniconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN mkdir ~/cecelia

# copy lock file
RUN wget -P ~/cecelia https://github.com/schienstockd/cecelia/raw/refs/heads/master/renv.lock

# init lockfile
RUN R -e 'install.packages("renv");setwd("~/cecelia");renv::init(bare=TRUE);renv::restore(lockfile="./renv.lock",clean=TRUE,prompt=FALSE)'

# init, install python packages, download models, create app
RUN R -e 'Sys.setenv(RETICULATE_MINICONDA_PATH="/home/jovyan/miniconda3");renv::load("~/cecelia");renv::install("schienstockd/cecelia");library(cecelia);cciaSetup("~/cecelia");cciaCondaCreate(envType="image-nogui");cciaModels();cciaCreateApp()'

# install local tools
RUN mkdir -p /opt/tools/bftools

# install BFTools
WORKDIR /opt/tools

RUN wget -q https://downloads.openmicroscopy.org/bio-formats/8.3.0/artifacts/bftools.zip \
	&& unzip bftools.zip \
	&& rm bftools.zip

# add bioformats2raw
RUN wget -q https://github.com/glencoesoftware/bioformats2raw/releases/download/v0.11.0/bioformats2raw-0.11.0.zip \
	&& unzip bioformats2raw-0.11.0.zip \
	&& rm bioformats2raw-0.11.0.zip

# update cecelia
# https://stackoverflow.com/a/65762156
ADD "https://api.github.com/repos/schienstockd/cecelia/commits?per_page=1" skipcache
RUN R -e 'renv::load("/home/jovyan/cecelia");renv::install("schienstockd/cecelia")'
# RUN R -e 'cecelia::cciaCondaCreate(envType = "image-nogui")'

USER root
# prepare server
# ENTRYPOINT ["sh", "-c"]
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +rx /usr/bin/docker-entrypoint.sh

USER jovyan
WORKDIR /home/jovyan

#ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/usr/bin/docker-entrypoint.sh ${JUPYTER_LIB_DIR}"]
