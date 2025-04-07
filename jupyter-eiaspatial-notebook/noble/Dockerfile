FROM quay.io/jupyter/scipy-notebook:ubuntu-24.04

USER root

### Providing root privillages to default "jovyan" user account
RUN echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER jovyan

### OS Packages installation
RUN sudo apt-get update && sudo apt-get install aptitude gdebi-core curl wget tar build-essential cmake make default-jre default-jdk cron screen pkg-config protobuf-compiler \
    libfontconfig1-dev libgsl-dev libudunits2-dev libprotobuf-dev libjq-dev libmagick++-dev gfortran libxml2-dev libcurl4-openssl-dev libfontconfig1-dev libssl-dev libsodium-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libgmp3-dev libmpfr-dev libarchive-dev gnupg software-properties-common dirmngr rsync -y

### GDAL installation (unstable repo)
RUN sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
RUN sudo apt-get update && sudo apt-get install libgdal-dev libgeos-dev libproj-dev -y

### gsutil installation
RUN sudo echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && sudo apt-get update -y && sudo apt-get install google-cloud-cli -y

### NCO installation
RUN sudo aptitude install nco -y

### R installation
RUN sudo apt update -qq
RUN sudo apt install --no-install-recommends software-properties-common dirmngr
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN sudo apt install --no-install-recommends r-base -y

### Rstudio Server installation
RUN sudo apt --fix-broken install -y
RUN sudo apt-get install gdebi-core -y
RUN wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.12.1-563-amd64.deb && sudo gdebi rstudio-server-2024.12.1-563-amd64.deb -n

ENV PATH=$PATH:/usr/lib/rstudio-server/bin

## Rstudio server Jupyter plugin installation
RUN python3 -m pip install jupyter-rsession-proxy
RUN pip install jupyter-server-proxy

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

RUN sudo Rscript packages.R

### Python packages installation
RUN conda install -c conda-forge --file requirements.txt --solver=classic -y

### Copying .bashrc of default $HOME directory to /opt
RUN sudo cp .bashrc /opt/

### Copying bash scripts to startup notebook directory
COPY scripts/* /usr/local/bin/start-notebook.d/
