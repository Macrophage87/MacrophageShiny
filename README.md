How to Setup an R and Shiny Server
================

## Startup

Start with runnning this command.

``` bash
sudo apt-get update
```

## Install Dependencies

First you should download all the latest dependencies of R. Many of
these packages only work with the development version.

``` bash
sudo apt-get install libpng-dev -y &&
sudo apt-get install cpp -y &&
sudo apt-get install gfortran -y &&
sudo apt-get install python3.7-dev -y &&
sudo apt-get install gdal-bin -y &&
sudo apt-get install libgdal-dev -y &&
sudo apt-get install libx11-dev -y &&
sudo apt-get install tcl-dev -y &&
sudo apt-get install libssl-dev -y &&
sudo apt-get install tk-dev -y &&
sudo apt-get install pandoc -y &&
sudo apt-get install texlive -y
```

## Install R

Afterwards, download and install R. Please note that this repository is
only for Unbuntu 18.04 “Bionic Beaver”. Search rproject.org for your
version if you use a different
version.

``` bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 &&
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' &&
sudo apt update &&
sudo apt install r-base -y &&
sudo apt-get build-dep r-base-core &&
sudo -i R
```

## Capabilities check

To ensure that the R is built with the proper capabilities, enter this
command into the console.

``` r
capabilities()
```

You should at least get these capabilites as true. X11 is used and
everything appears to run fine with that capability as false. However if
for some reason you decided to use Amazon Linux, please note that tcltk
is not supported and hence Shiny will not work, so go back and get an
Unbuntu server. Tcltk is used to pass graphics through the server to the
user.

``` 
       jpeg         png        tiff       tcltk         X11        aqua 
       TRUE        TRUE        TRUE        TRUE       FALSE       FALSE 
   http/ftp     sockets      libxml        fifo      cledit       iconv 
       TRUE        TRUE        TRUE        TRUE        TRUE        TRUE 
        NLS     profmem       cairo         ICU long.double     libcurl 
       TRUE        TRUE        TRUE        TRUE        TRUE        TRUE 
```

## Main Packages

Install the required packages. The first 3 are neccisary for later
tests, the rest are the major dependencies that will be used. Please
note that the “tidyverse” package can take a long time, so plan
accordingly. Download Rcpp from source do to some dependency issues with
tidyverse (<https://github.com/tidyverse/dplyr/issues/36>).

``` r
install.packages("shiny")
install.packages("rmarkdown")
install.packages("rprojroot")
install.packages("Rcpp", type = "source")

install.packages("data.table")
install.packages("tidyverse")
install.packages("RMariaDB")
install.packages("leaflet")
install.packages("devtools")
```

Once these dependencies are installed, quit R.

``` r
q("no")
```

## Install Shiny Server

Then install shiny-server. Make sure port 3838 is open.

``` bash
cd ~ &&
sudo apt-get install gdebi-core &&
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb &&
sudo gdebi shiny-server-1.5.9.923-amd64.deb 
```

## Install rstudio-server (Optional)

If you want the capability of running and editing R scripts on this
server, then install . Make sure port 3838 is
open.

``` bash
wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb &&
sudo gdebi rstudio-server-1.2.1335-amd64.deb 
```

## Verify Installations

To verify installation of Shiny, visit this page:
<http://><server_address>:3838

To verify installation of Rstudio, visit this page:
<http://><server_address>:8787

## Package

After installation is successful, install the rest of the packages.

``` r
install.packages(package)
```

## Install MariaDB (Optional)

If a local database is required or desired, this is the protocol for
installing MariaDB.

``` bash
sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64] http://mirror.zol.co.zw/mariadb/repo/10.3/ubuntu bionic main'
sudo apt update
sudo apt -y install mariadb-server mariadb-client
```

Enter in a root password.
