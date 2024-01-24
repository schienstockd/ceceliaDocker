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
		&& apt-get clean
    # switch java for Fiji
    # TODO do we need this?
    # && update-java-alternatives --set java-1.8.0-openjdk-amd64

### init shiny app
# https://dockerquestions.com/2021/05/23/docker-shiny-app-no-such-file-or-directory-while-running-docker-image/
ENV PATH="/home/shiny/miniconda3/bin:${PATH}"
ARG PATH="/home/shiny/miniconda3/bin:${PATH}"

# https://stackoverflow.com/a/39855387
RUN useradd -ms /bin/bash shiny

# prepare local tools
RUN mkdir /opt/tools \
	&& chown shiny:shiny /opt/tools

# when everything works - this should be one commit?
# Use user library
# https://stackoverflow.com/a/43283085
#RUN R -e 'dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'
RUN R -e 'if (!require("remotes", quietly = TRUE)) install.packages("remotes", repos = "https://cloud.r-project.org")'
RUN R -e 'remotes::install_github("schienstockd/cecelia", Ncpus = 4, repos = "https://cloud.r-project.org", upgrade = "always")'
RUN R -e 'cecelia::cciaAppRequirements(repos = "https://cloud.r-project.org")'
RUN R -e 'cecelia::cciaBiocRequirements(ask = FALSE)'

### SHINY from here on
USER shiny

RUN R -e 'cecelia::cciaSetup()'

# install miniconda for shiny
# https://linuxhandbook.com/dockerize-python-apps/
RUN cd /home/shiny \
		&& wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /home/shiny/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

ADD "https://api.github.com/repos/schienstockd/cecelia/commits?per_page=1" skipcache
RUN R -e 'remotes::install_github("schienstockd/cecelia", Ncpus = 4, repos = "https://cloud.r-project.org", upgrade = "never")'

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
RUN wget -q https://github.com/glencoesoftware/bioformats2raw/releases/download/v0.6.1/bioformats2raw-0.6.1.zip \
	&& unzip bioformats2raw-0.6.1.zip \
	&& rm bioformats2raw-0.6.1.zip

USER root

# add blosc
RUN git clone https://github.com/Blosc/c-blosc.git \
	&& cd c-blosc \
	&& cmake . \
	&& cmake --build . --target install \
	&& cd ..

### run server
# ENTRYPOINT ["sh", "-c"]
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +rx /usr/bin/docker-entrypoint.sh

# update cecelia
# https://stackoverflow.com/a/65762156
ADD "https://api.github.com/repos/schienstockd/cecelia/commits?per_page=1" skipcache
# 'lib = "/usr/local/lib/R/site-library"' is not writable
# https://github.com/rocker-org/rocker/issues/513
RUN chmod -R 775 /usr/local/lib/R/site-library
RUN R -e 'remotes::install_github("schienstockd/cecelia", Ncpus = 4, repos = "https://cloud.r-project.org", upgrade = "never")'

USER shiny
# RUN R -e 'cecelia::cciaCondaCreate(envType = "image-nogui")'

#ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/usr/bin/docker-entrypoint.sh ${JUPYTER_LIB_DIR}"]
