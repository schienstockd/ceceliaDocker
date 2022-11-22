FROM rocker/ml:4.0.3

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
		# for HPC connection
		ssh \
		rsync \
		# for process management
		psmisc \
		# for EBImage
		libfftw3-dev \
		# for RBioFormats and Fiji
		openjdk-8-jdk-headless \
		# https://github.com/rstudio/rstudio/issues/2254#issuecomment-413939666
		&& R CMD javareconf \
		&& apt-get clean

# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'))" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    chown shiny:shiny /var/lib/shiny-server

# copy app to server location
# https://stackoverflow.com/a/54725355/13766165
# COPY apps/[^.]* /srv/shiny-server/
# allow permission
# RUN sudo chown -R shiny:shiny /srv/shiny-server

ENV PATH="/home/shiny/miniconda3/bin:${PATH}"
ARG PATH="/home/shiny/miniconda3/bin:${PATH}"

# Copy further configuration files into the Docker image
COPY conf/shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh

# install libraries for shiny app
COPY init-libraries.R /tmp/setup-R-libraries.R
COPY init-biocManager.R /tmp/setup-R-biocManager.R
RUN Rscript /tmp/setup-R-libraries.R
RUN Rscript /tmp/setup-R-biocManager.R

### init shiny app
# https://dockerquestions.com/2021/05/23/docker-shiny-app-no-such-file-or-directory-while-running-docker-image/

# prepare local tools
RUN mkdir /opt/tools \
	&& chown shiny:shiny /opt/tools

### SHINY from here on
USER shiny

# install python packages directly for tensorflow
COPY init-py-modules.txt /tmp/init-py-modules.txt
RUN pip3 install -r /tmp/init-py-modules.txt
COPY init-py-bioformats.txt /tmp/init-py-ml.txt
RUN pip3 install -r /tmp/init-py-ml.txt
COPY init-py-bioformats.txt /tmp/init-py-bioformats.txt
RUN pip3 install -r /tmp/init-py-bioformats.txt

# install miniconda for shiny
# https://linuxhandbook.com/dockerize-python-apps/
RUN cd /home/shiny \
		&& wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /home/shiny/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

# Create conda environment
# install python packages in conda environment
# https://stackoverflow.com/a/60148365/13766165
#SHELL ["conda", "run", "-n", "shiny-env", "/bin/bash", "-c"]
COPY environment.yml .
RUN conda env create -f environment.yml

# install local tools
RUN mkdir /opt/tools/fiji \
	&& mkdir /opt/tools/bftools

# install Fiji
# https://github.com/fiji/dockerfiles/blob/master/fiji-openjdk-8/Dockerfile
WORKDIR /opt/tools/fiji

RUN wget -q https://downloads.imagej.net/fiji/latest/fiji-nojre.zip \
 && unzip fiji-nojre.zip \
 && rm fiji-nojre.zip

# switch java for Fiji
USER root
RUN update-java-alternatives --set java-1.8.0-openjdk-amd64
USER shiny

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

EXPOSE 6860

### run server
# ENTRYPOINT ["sh", "-c"]
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/usr/bin/shiny-server.sh"]
