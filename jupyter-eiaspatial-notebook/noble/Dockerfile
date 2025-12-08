FROM quay.io/jupyter/scipy-notebook:ubuntu-24.04

USER root

### Providing root privillages to default "jovyan" user account
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER jovyan

### OS Packages installation
RUN sudo apt-get update && sudo apt-get install aptitude gdebi-core curl wget tar build-essential cmake make default-jre default-jdk cron screen pkg-config protobuf-compiler \
    libfontconfig1-dev libgsl-dev libudunits2-dev libprotobuf-dev libjq-dev libmagick++-dev gfortran libxml2-dev libcurl4-openssl-dev libfontconfig1-dev libssl-dev \ 
    libsodium-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libgmp3-dev libmpfr-dev libarchive-dev gnupg software-properties-common \ 
    dirmngr rsync libfftw3-dev libtirpc-dev -y

### GDAL installation (unstable repo)
RUN sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
RUN sudo apt-get update && sudo apt-get install libgdal-dev libgeos-dev libproj-dev libnetcdf-dev libhdf5-dev -y

### gsutil installation
RUN sudo echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && sudo apt-get update -y && sudo apt-get install google-cloud-cli -y

### NCO installation
RUN sudo aptitude install nco -y

### R installation
RUN sudo apt-get update -qq
RUN sudo apt-get install --no-install-recommends software-properties-common dirmngr
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN sudo apt-get install --no-install-recommends r-base -y

### Rstudio Server installation
RUN sudo apt-get --fix-broken install -y
RUN sudo apt-get install gdebi-core -y
RUN wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.12.1-563-amd64.deb && sudo gdebi rstudio-server-2024.12.1-563-amd64.deb -n

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

COPY . .

# ApsimX
RUN sudo apt-get update && sudo apt-get install libsqlite3-dev dotnet-sdk-8.0 gtk-sharp3 libgtksourceview-4-0 zenity -y
RUN sudo dpkg -i apsim-*.deb

### Jupyter extensions & plugins installation
RUN pip install --no-cache-dir -r jupyter.requirements.txt

### Python packages installation
# RUN conda update --all -y
# RUN conda install -c conda-forge --file conda.requirements.txt --solver=libmamba -y
RUN mamba install -c conda-forge --file conda.requirements.txt cdsapi -y
# Do NOT "update --all" – it breaks the base env and pins
# Just install the extra stuff we care about using mamba
RUN mamba install -c conda-forge libgdal netcdf4 libnetcdf hdf5 --force-reinstall --strict-channel-priority -y
RUN mamba clean -afy
### R packages installation
RUN sudo Rscript packages.R

### Copying .bashrc of default $HOME directory to /opt
RUN sudo cp .bashrc /opt/

### Copying bash scripts to startup notebook directory
COPY scripts/* /usr/local/bin/start-notebook.d/
