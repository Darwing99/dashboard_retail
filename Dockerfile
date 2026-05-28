FROM rocker/r-ver:4.4.2

# Dependencias del sistema necesarias para los paquetes R
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libgit2-dev \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# Instalar paquetes R (orden optimizado: base primero, luego dependencias)
RUN R -e "install.packages(c(\
    'shiny', \
    'shinydashboard', \
    'DT', \
    'plotly', \
    'tidyverse', \
    'lubridate', \
    'scales', \
    'caret', \
    'randomForest', \
    'pROC', \
    'corrplot', \
    'readxl', \
    'summarytools', \
    'stringr', \
    'ggplot2' \
  ), repos='https://packagemanager.posit.co/cran/__linux__/noble/latest', \
  Ncpus = parallel::detectCores())"

# Copiar la aplicación
WORKDIR /app
COPY . .

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('.', host='0.0.0.0', port=3838, launch.browser=FALSE)"]
