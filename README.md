README
================

## Server setup

See server\_setup.md for the steps needed to setup a Shiny Server as
well as the database. The schema for the database used in this project
is found in database\_schema.sql. This script will generate all the
tables used in this project on a mySQL/MariaDB database. Please create
this as a new database as it will drop any existing tables.

## Documents and Folders

### Shiny

This is the repository to call the Shiny Code. However, most of the code
is found within the functions.

This section contains the following apps:

Any app not listed here or not connected on the dashboard is a work in
progress that is being “live-tested” on the main server.

#### Dashboard

This app uses iframes to call different shiny apps and present them in a
single webpage. It calls apps via iframes, with the sidebar generated
relationally via the app\_list table.

#### GeneExOT

This is a simple app that is designed to pull the transcriptome data
over time for whatever gene is of interest. Use the datatable to filter
and select the gene by clicking on it. A graph will populate with the
expression levels over each timepoint on a log2 scale. The second page
shows the numerical statistics and the 3rd page is a link to the NCBI
gene page for that gene.

#### KEGG Pathway Analysis

This is a KEGG pathway analysis of the genes throughout the timeseries,
with every KEGG pathway shown. The numbers correspond to the -log of the
p-value using a hypergeometric test (similar to a Fisher’s exact test,
but less computationally intensive), with genes that have a p\<0.05
counting as regulated. The script used to generate that test can be
found in analysis\_scripts/kegg\_stats.R. Genes were mapped to each
ontology and uploaded to the database using the KEGG API, the script to
do so can be found in data\_scripts/keggpw\_upload.R.

#### Volcano Plot Analysis

This is a tool designed to find the most substantially and significantly
regulated genes. Initially the general trend of regulation is displayed,
with the bulk of the genes shown in a 2D density plot using a
volcano-themed color scheme. Use the sliders to adjust by timepoint, and
for the maximum p and q values as well as the minimum fold change
differences. Click on a specific point to obtain details about that gene
similar to the GeneExOt results.

#### Transcription Factor Analysis

The analysis here uses the TF2DNA annotations of transcription factor
binding (<http://www.fiserlab.org/tf2dna_db/>). Scripts designed to
upload the data can be found in
data\_scripts/transcription\_factor\_mapping.R. This data was analyzed
in a similar manner to KEGG via the use of the
analysis\_scripts/tf\_stats.R. Since these experiments often looked at
transcription factor bining to a large portion of the genome, only the
target genes with binding scores one SD above the mean were used. Again
a hypergeometric test was used and shown in the initial table. When a
transcription factor is selected, the first tab shows the behavior of
the top 50 genes, by binding score, over time. Click on a gene for a
closer look. The second tab shows the transcript levels of the
transcription factor gene itself.

### Functions

This is the main repository for the key functions required for running
the shiny programs and contains both functions and modules.

The main files are below.

#### CommonFunctions.R

This sourcefile contains all the code that is required to connect to the
database.

#### gene\_ot.R

This sourcefile contains functions and modules for analysing specific
genes over time and outputting the results.

#### kegg\_functions.R

This sourcefile contains functions and modules for analyzing the KEGG
pathway analysis (<https://www.genome.jp/kegg/>)

#### tf\_functions.R

This sourcefile contains functions and modules for analyzing genes over
time.

### Data Scripts and Analysis Scripts

Data Scripts are the tools used to format the raw data into a format
that can be uploaded to the database, while Analysis Scripts are a
preprocessing of the data for the use in shiny apps, such as the
generation of statistics. Many of these scripts were described earler.
These scripts usually upload to the database, or to a static file.

### Data

The data folder contains a number of files that are more easily
processed as a static file. Most of the data is obviously stored on the
database, however. Due to size most of this data is absent in the
repository though could be generated from the various scripts.

### Config file

This is not found in the repository but needs to be present in order to
work. This is a YML file, which contains the working directory of the
project, and the SQL credentials for two users: one user with INSERT,
UPDATE, DELETE, etc. access, for uploading data (macrophage\_mysql), and
another with SELECT only access for use in shiny apps (shiny\_mysql).

An example is provided below:

``` yml
default:
  working_directory: /###/####/MacrophageShiny
  macrophage_mysql:
    host: macrophage.cieply.com
    port: 3306
    database: transcriptome
    username: ######
    password: ######
  shiny_mysql:
    host: macrophage.cieply.com
    port: 3306
    database: transcriptome
    username: ######
    password: ######
```
