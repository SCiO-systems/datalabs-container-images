FROM quay.io/jupyter/scipy-notebook:ubuntu-24.04

USER root

### Providing root privillages to default "jovyan" user account
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER jovyan

### OS Packages installation
RUN sudo apt-get update && sudo apt-get install aptitude gdebi-core curl wget tar build-essential cmake make default-jre default-jdk cron screen pkg-config protobuf-compiler \
    libfontconfig1-dev libgsl-dev libudunits2-dev libprotobuf-dev libjq-dev libmagick++-dev gfortran fftw3 fftw3-dev libxml2-dev libcurl4-openssl-dev libfontconfig1-dev libssl-dev libsodium-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libgmp3-dev libmpfr-dev libarchive-dev gnupg software-properties-common dirmngr rsync -y

### GDAL installation (unstable repo)
RUN sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
RUN sudo apt-get update && sudo apt-get install libgdal-dev libgeos-dev libproj-dev -y

### gsutil installation
RUN sudo echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && sudo apt-get update -y && sudo apt-get install google-cloud-cli -y

### NCO installation
RUN sudo aptitude install nco -y

### R installation - https://cran.r-project.org/bin/linux/ubuntu/#acknowledgements
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN sudo apt install --no-install-recommends r-base -y

## Use c2d4u only for IRkernel, because it didn't work on Kubernetes with install.packages.
RUN sudo add-apt-repository ppa:c2d4u.team/c2d4u4.0+
RUN sudo apt-get install r-cran-irkernel -y
## Installing R kernel to jupyterlab
RUN R -e "IRkernel::installspec()"

## Rstudio server installation (It is running under R kernel - https://posit.co/download/rstudio-server/)
RUN echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/focal-security.list && \
    sudo apt-get update && \
    sudo apt-get install libssl1.1 -y

RUN cd /tmp && \
    wget https://download2.rstudio.org/server/focal/amd64/rstudio-server-2024.09.0-375-amd64.deb && \
    sudo gdebi -n rstudio-server-2024.09.0-375-amd64.deb

ENV PATH=$PATH:/usr/lib/rstudio-server/bin

## Rstudio server Jupyter plugin installation
RUN python3 -m pip install jupyter-rsession-proxy
RUN pip install jupyter-server-proxy

### CROP models installation
## DSSAT installation
RUN sudo mkdir -p /opt/DSSAT/v4.7.5.30 && \
    sudo chown -R jovyan:users /opt/DSSAT/v4.7.5.30/.

RUN sudo mkdir -p /opt/DSSAT/v4.8.1.40 && \
    sudo chown -R jovyan:users /opt/DSSAT/v4.8.1.40/.

# v4.7.5.30 installation
RUN cd /opt/DSSAT/v4.7.5.30 && \
    git clone https://github.com/DSSAT/dssat-csm-os.git --depth 1 --branch v4.7.5.30 && \
    git clone https://github.com/DSSAT/dssat-csm-data.git

RUN cd /opt/DSSAT/v4.7.5.30/dssat-csm-os && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make

# Adjusting filesystem to DSSAT compiler requirements
RUN cp /opt/DSSAT/v4.7.5.30/dssat-csm-os/build/bin/* /opt/DSSAT/v4.7.5.30
RUN cp -r /opt/DSSAT/v4.7.5.30/dssat-csm-os/Data/. /opt/DSSAT/v4.7.5.30
RUN cp -r /opt/DSSAT/v4.7.5.30/dssat-csm-data/* /opt/DSSAT/v4.7.5.30
RUN sed -i 's,/usr/local,opt/DSSAT/v4.7.5.30,g' /opt/DSSAT/v4.7.5.30/DSSATPRO.L47
RUN chown -R jovyan:users /opt/DSSAT/v4.7.5.30/*

# v4.8.1.40 installation
RUN cd /opt/DSSAT/v4.8.1.40  && \
    git clone https://github.com/DSSAT/dssat-csm-os.git --depth 1 --branch v4.8.1.40  && \
    git clone https://github.com/DSSAT/dssat-csm-data.git

RUN cd /opt/DSSAT/v4.8.1.40/dssat-csm-os && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make

# Adjusting filesystem to DSSAT compiler requirements
RUN cp /opt/DSSAT/v4.8.1.40/dssat-csm-os/build/bin/* /opt/DSSAT/v4.8.1.40
RUN cp -r /opt/DSSAT/v4.8.1.40/dssat-csm-os/Data/. /opt/DSSAT/v4.8.1.40
RUN cp -r /opt/DSSAT/v4.8.1.40/dssat-csm-data/* /opt/DSSAT/v4.8.1.40
RUN sed -i 's,/usr/local,opt/DSSAT/v4.8.1.40,g' /opt/DSSAT/v4.8.1.40/DSSATPRO.L48
RUN chown -R jovyan:users /opt/DSSAT/v4.8.1.40/*

# ApsimX
RUN sudo apt-get update && sudo apt-get install libsqlite3-dev dotnet-sdk-6.0 gtk-sharp3 libgtksourceview-4-0 zenity -y
COPY ./apsim-7592.deb ./apsim-7592.deb
RUN sudo dpkg -i apsim-7592.deb

### Jupyter extensions & plugins installation
RUN pip install aquirdturtle_collapsible_headings
RUN pip install jupyterlab-spellchecker
RUN pip install --upgrade jupyterlab jupyterlab-git
RUN pip install jupyterlab_code_formatter
RUN pip install lckr-jupyterlab-variableinspector
RUN pip install jupyterlab_execute_time
RUN pip install jupyterlab-hide-code
RUN pip install 'jupyterlab>=3.0.0,<4.0.0a0' jupyterlab-lsp
RUN pip install jupyterlab-geojson
RUN pip install jupyterlab-fasta
RUN pip install jupyterlab-drawio
RUN pip install jupyter-archive

### R packages installation
COPY . .
## rJava dependencies
RUN sudo R CMD javareconf

# From here on: 3 cores: 48m2s, 4 cores 38m4s, 6 cores 37m3s
RUN sudo Rscript packages.R

### Python packages installation
RUN conda install -c conda-forge --file requirements.txt -y

RUN rm packages.R requirements.txt packages_test.R apsim-7592.deb

### Copying .bashrc of default $HOME directory to /opt
RUN sudo cp .bashrc /opt/

### Copying bash scripts to startup notebook directory
COPY scripts/* /usr/local/bin/start-notebook.d/
