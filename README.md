# episodic-river-salinization-model
Modeling code in a targets pipeline for understanding characteristics of rivers that experience episodic salinization from winter road salting events.
This repo was forked from the original repository: https://github.com/lindsayplatt/episodic-river-salinization-model

This repository contains reproducible code for downloading, processing, and modeling data related to river salinization dynamics. Using [The Turing Ways's definitions](https://the-turing-way.netlify.app/reproducible-research/overview/overview-definitions), this code and analysis are intended to be *fully reproducible* and could be *somewhat replicable* with different states and/or dates. 

## Associated publications and resources

The code is adapted from the analysis for Lindsay Platt's ([@lindsayplatt](https://github.com/lindsa%5D(https://github.com/lindsayplatt))) Master's Thesis:

> Platt, L. (2024). *Basins modulate signatures of river salinization* (Master's thesis). University of Wisconsin-Madison, Freshwater and Marine Sciences.
> Platt, L. (2024). Source code: Basins modulate signatures of river salinization (v1.0.0). Zenodo. https://doi.org/10.5281/zenodo.11130548

This code is associated with Platt, L and Dugan, HA. (2025) Episodic salinization of Midwestern and Northeastern US rivers by road salt. _Water Resources Research._

## Running the code 

This repository is setup as an automated pipeline using the [`targets` R package](https://books.ropensci.org/targets/) in order to orchestrate a complex, modular workflow where dependency tracking determines which components need to be built. As written, this pipeline will need about 2.5 hours to build and will need to have an internet connection.

The pipeline is broken into 7 different phases:

* `1_Download` contains all the code that pulls from NWIS, ScienceBase, NHD+, etc. It will require an internet connection. It also sets the spatial and temporal limits for the analysis.
* `2_Prepare` this phase is doing all of the heavy lifting to process data into a useable state for both our time series data (prefixed with `p2_ts`) and our static attributes data (prefixed with `p2_attr`).
* `3_Filter` applies all of our criteria to remove sites that are not up to our minimum standards and/or are sites with unexpected features (tidal, in a really high agricultural area, don't have an associated NHD+ catchment area, etc).
* `4_EpisodicSalinization` applies an algorithm that has been used to identify storms by finding steep peaks in a hydrograph to the specific conductance time series in order to identify winter storms where road salts are washed into streams and cause sharp peaks (similar to storm hydrographs). In the end, this phase identifies sites with specific conductance data that exhibit this episodic behavior.
* `5_DefineCharacteristics` uses the information gathered in `4_EpisodicSalinization` and applies random forest models to these categorizations with the collection of static attributes prepared and filtered in `2_Prepare` and `3_Filter` to define the attributes and values that are important for determining a site's category.
* `6_PredictClass` uses the optimized model and defined outlet locations to download/prepare attributes for ALL COMIDs within the upstream watershed of these outlet locations to predict whether they are likely to be episodic or not. TODO: APPLY TO MORE THAN JUST YAHARA, ROCK, AND MAUMEE.
* `7_Disseminate` takes all of the model input output to generate figures and explain the results. The figures generated in this phase were all used in the manuscript. Three datasets are also saved in this step and represent the final salinization signature classifications for each site, values for all 16 static attributes, and metadata for all 16 attributes. The first two datasets were used by the random forest models to create final results explaining which characteristics were important for each of the salinization signatures.

### Pipeline setup

Run the following command to make sure you have all the necessary packages before trying to build the pipeline.

``` r
install.packages(c(
    'targets', 
    'tarchetypes',
    'accelerometry',
    'arrow',
    'cowplot',
    'dataRetrieval',
    'exactextractr',
    'GGally', 
    'httr',
    'MESS',
    'nhdplusTools',
    'pdp',
    'qs',
    'randomForest',
    'raster',
    'sbtools',
    'scico',
    'sf',
    'tidytext',
    'tidyverse',
    'units',
    'usmap',
    'yaml',
    'zip'
))
```

The following package versions were used during the original pipeline build. You shouldn't need to install these versions specifically, but if there are errors cropping up, you could try installing these specific versions and see if you can get past the issue.

Known issues: 

* We have had problems with the arrow package on MacOS. The version used to build this pipeline was Arrow 19.0.1
* https://github.com/DOI-USGS/dataRetrieval/issues/759 dataRetrieval has a limit of 400 navigation requests per hour per user. Since this pipeline pulls > 400 sites, this presents a problem. The dataRetrieval may have to be run in chunks or slowed down. 
* We used dataRetrieval 2.7.17 

## Session Info

```text
─ Session info ──────────────────────────────────────────────────────────────────────────────────────
 setting  value
 version  R version 4.4.2 (2024-10-31)
 os       macOS Sequoia 15.3.1
 system   aarch64, darwin20
 ui       RStudio
 language (EN)
 collate  en_US.UTF-8
 ctype    en_US.UTF-8
 tz       America/Chicago
 date     2025-09-09
 rstudio  2024.12.0+467 Kousa Dogwood (desktop)
 pandoc   3.2 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64/ (via rmarkdown)
 quarto   1.5.57 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto

─ Packages ──────────────────────────────────────────────────────────────────────────────────────────
 package        * version date (UTC) lib source
 abind          * 1.4-8   2024-09-12 [1] CRAN (R 4.4.1)
 accelerometry  * 3.1.2   2018-08-24 [1] CRAN (R 4.4.0)
 arrow          * 19.0.1  2025-02-26 [1] CRAN (R 4.4.1)
 assertthat       0.2.1   2019-03-21 [1] CRAN (R 4.4.1)
 backports        1.5.0   2024-05-23 [1] CRAN (R 4.4.1)
 base64url        1.4     2018-05-14 [1] CRAN (R 4.4.1)
 BiocGenerics   * 0.52.0  2024-11-08 [1] Bioconductor 3.20 (R 4.4.1)
 bit              4.6.0   2025-03-06 [1] CRAN (R 4.4.1)
 bit64            4.6.0-1 2025-01-16 [1] CRAN (R 4.4.1)
 broom            1.0.9   2025-07-28 [1] CRAN (R 4.4.1)
 cachem           1.1.0   2024-05-16 [1] CRAN (R 4.4.1)
 callr            3.7.6   2024-03-25 [1] CRAN (R 4.4.0)
 car              3.1-3   2024-09-27 [1] CRAN (R 4.4.1)
 carData          3.0-5   2022-01-06 [1] CRAN (R 4.4.1)
 class            7.3-23  2025-01-01 [1] CRAN (R 4.4.1)
 classInt         0.4-11  2025-01-08 [1] CRAN (R 4.4.1)
 cli              3.6.5   2025-04-23 [1] CRAN (R 4.4.1)
 clipr            0.8.0   2022-02-22 [1] CRAN (R 4.4.1)
 codetools        0.2-20  2024-03-31 [1] CRAN (R 4.4.2)
 cowplot        * 1.2.0   2025-07-07 [1] CRAN (R 4.4.1)
 crayon           1.5.3   2024-06-20 [1] CRAN (R 4.4.1)
 curl             6.4.0   2025-06-22 [1] CRAN (R 4.4.1)
 data.table       1.17.8  2025-07-10 [1] CRAN (R 4.4.1)
 dataRetrieval  * 2.7.20  2025-07-15 [1] CRAN (R 4.4.1)
 DBI              1.2.3   2024-06-02 [1] CRAN (R 4.4.1)
 DelayedArray   * 0.32.0  2024-11-08 [1] Bioconductor 3.20 (R 4.4.1)
 dichromat        2.0-0.1 2022-05-02 [1] CRAN (R 4.4.1)
 digest           0.6.37  2024-08-19 [1] CRAN (R 4.4.1)
 doParallel     * 1.0.17  2022-02-07 [1] CRAN (R 4.4.0)
 dplyr          * 1.1.4   2023-11-17 [1] CRAN (R 4.4.0)
 dvmisc           1.1.4   2019-12-16 [1] CRAN (R 4.4.0)
 e1071            1.7-16  2024-09-16 [1] CRAN (R 4.4.1)
 evaluate         1.0.4   2025-06-18 [1] CRAN (R 4.4.1)
 exactextractr  * 0.10.0  2023-09-20 [1] CRAN (R 4.4.0)
 farver           2.1.2   2024-05-13 [1] CRAN (R 4.4.1)
 fastmap          1.2.0   2024-05-15 [1] CRAN (R 4.4.1)
 forcats        * 1.0.0   2023-01-29 [1] CRAN (R 4.4.0)
 foreach        * 1.5.2   2022-02-02 [1] CRAN (R 4.4.0)
 Formula          1.2-5   2023-02-24 [1] CRAN (R 4.4.1)
 fs               1.6.6   2025-04-12 [1] CRAN (R 4.4.1)
 fst              0.9.8   2022-02-08 [1] CRAN (R 4.4.0)
 fstcore          0.10.0  2025-02-10 [1] CRAN (R 4.4.1)
 geeM             0.10.1  2018-06-18 [1] CRAN (R 4.4.0)
 geepack          1.3.12  2024-09-23 [1] CRAN (R 4.4.1)
 generics         0.1.4   2025-05-09 [1] CRAN (R 4.4.1)
 GGally         * 2.3.0   2025-07-18 [1] CRAN (R 4.4.1)
 ggformula        0.12.2  2025-07-31 [1] CRAN (R 4.4.1)
 ggplot2        * 3.5.2   2025-04-09 [1] CRAN (R 4.4.1)
 ggridges         0.5.6   2024-01-23 [1] CRAN (R 4.4.0)
 ggspatial      * 1.1.9   2023-08-17 [1] CRAN (R 4.4.0)
 ggstats          0.10.0  2025-07-02 [1] CRAN (R 4.4.1)
 glue             1.8.0   2024-09-30 [1] CRAN (R 4.4.1)
 gtable           0.3.6   2024-10-25 [1] CRAN (R 4.4.1)
 haven            2.5.5   2025-05-30 [1] CRAN (R 4.4.1)
 hms              1.1.3   2023-03-21 [1] CRAN (R 4.4.0)
 htmltools        0.5.8.1 2024-04-04 [1] CRAN (R 4.4.1)
 httr           * 1.4.7   2023-08-15 [1] CRAN (R 4.4.0)
 httr2            1.2.1   2025-07-22 [1] CRAN (R 4.4.1)
 hydroloom      * 1.1.0   2024-08-26 [1] CRAN (R 4.4.1)
 igraph           2.1.4   2025-01-23 [1] CRAN (R 4.4.1)
 IRanges        * 2.40.1  2024-12-05 [1] Bioconductor 3.20 (R 4.4.2)
 iterators      * 1.0.14  2022-02-05 [1] CRAN (R 4.4.1)
 janeaustenr      1.0.0   2022-08-26 [1] CRAN (R 4.4.1)
 jsonlite         2.0.0   2025-03-27 [1] CRAN (R 4.4.1)
 kableExtra       1.4.0   2024-01-24 [1] CRAN (R 4.4.0)
 KernSmooth       2.23-26 2025-01-01 [1] CRAN (R 4.4.1)
 knitr            1.50    2025-03-16 [1] CRAN (R 4.4.1)
 labeling         0.4.3   2023-08-29 [1] CRAN (R 4.4.1)
 labelled         2.14.1  2025-05-06 [1] CRAN (R 4.4.1)
 lattice          0.22-7  2025-04-02 [1] CRAN (R 4.4.1)
 lifecycle        1.0.4   2023-11-07 [1] CRAN (R 4.4.1)
 lubridate      * 1.9.4   2024-12-08 [1] CRAN (R 4.4.1)
 lwgeom         * 0.2-14  2024-02-21 [1] CRAN (R 4.4.0)
 magick         * 2.8.7   2025-06-06 [1] CRAN (R 4.4.1)
 magrittr       * 2.0.3   2022-03-30 [1] CRAN (R 4.4.1)
 MASS             7.3-65  2025-02-28 [1] CRAN (R 4.4.1)
 Matrix         * 1.7-3   2025-03-11 [1] CRAN (R 4.4.1)
 MatrixGenerics * 1.18.1  2025-01-09 [1] Bioconductor 3.20 (R 4.4.2)
 matrixStats    * 1.5.0   2025-01-07 [1] CRAN (R 4.4.1)
 memoise          2.0.1   2021-11-26 [1] CRAN (R 4.4.0)
 MESS           * 0.5.12  2023-08-20 [1] CRAN (R 4.4.0)
 mime             0.13    2025-03-17 [1] CRAN (R 4.4.1)
 mitools          2.4     2019-04-26 [1] CRAN (R 4.4.1)
 mosaicCore       0.9.5   2025-07-30 [1] CRAN (R 4.4.1)
 mvtnorm          1.3-3   2025-01-10 [1] CRAN (R 4.4.1)
 nhdplusTools   * 1.3.2   2025-06-10 [1] CRAN (R 4.4.1)
 paws.common      0.8.5   2025-07-25 [1] CRAN (R 4.4.1)
 paws.storage   * 0.9.0   2025-03-14 [1] CRAN (R 4.4.1)
 pbapply          1.7-4   2025-07-20 [1] CRAN (R 4.4.1)
 pdp            * 0.8.2   2024-10-28 [1] CRAN (R 4.4.1)
 pillar           1.11.0  2025-07-04 [1] CRAN (R 4.4.1)
 pkgconfig        2.0.3   2019-09-22 [1] CRAN (R 4.4.1)
 prettymapr     * 0.2.5   2024-02-23 [1] CRAN (R 4.4.0)
 processx         3.8.6   2025-02-21 [1] CRAN (R 4.4.1)
 proxy            0.4-27  2022-06-09 [1] CRAN (R 4.4.1)
 ps               1.9.1   2025-04-12 [1] CRAN (R 4.4.1)
 purrr          * 1.1.0   2025-07-10 [1] CRAN (R 4.4.1)
 qs             * 0.27.3  2025-03-11 [1] CRAN (R 4.4.1)
 R.methodsS3      1.8.2   2022-06-13 [1] CRAN (R 4.4.1)
 R.oo             1.27.1  2025-05-02 [1] CRAN (R 4.4.1)
 R.utils          2.13.0  2025-02-24 [1] CRAN (R 4.4.1)
 R6               2.6.1   2025-02-15 [1] CRAN (R 4.4.1)
 randomForest   * 4.7-1.2 2024-09-22 [1] CRAN (R 4.4.1)
 RANN             2.6.2   2024-08-25 [1] CRAN (R 4.4.1)
 RApiSerialize    0.1.4   2024-09-28 [1] CRAN (R 4.4.1)
 rappdirs         0.3.3   2021-01-31 [1] CRAN (R 4.4.1)
 Rarr           * 1.6.0   2024-11-08 [1] Bioconductor 3.20 (R 4.4.1)
 raster         * 3.6-32  2025-03-28 [1] CRAN (R 4.4.1)
 rbenchmark       1.0.0   2012-08-30 [1] CRAN (R 4.4.1)
 RColorBrewer     1.1-3   2022-04-03 [1] CRAN (R 4.4.1)
 Rcpp             1.0.14  2025-01-12 [1] CRAN (R 4.4.1)
 RcppParallel     5.1.10  2025-01-24 [1] CRAN (R 4.4.1)
 readr          * 2.1.5   2024-01-10 [1] CRAN (R 4.4.0)
 rlang            1.1.6   2025-04-11 [1] CRAN (R 4.4.1)
 rmarkdown        2.29    2024-11-04 [1] CRAN (R 4.4.1)
 rstatix        * 0.7.2   2023-02-01 [1] CRAN (R 4.4.0)
 rstudioapi       0.17.1  2024-10-22 [1] CRAN (R 4.4.1)
 S4Arrays       * 1.6.0   2024-11-08 [1] Bioconductor 3.20 (R 4.4.1)
 S4Vectors      * 0.44.0  2024-11-08 [1] Bioconductor 3.20 (R 4.4.1)
 S7               0.2.0   2024-11-07 [1] CRAN (R 4.4.1)
 sbtools        * 1.4.1   2025-07-14 [1] CRAN (R 4.4.1)
 scales           1.4.0   2025-04-24 [1] CRAN (R 4.4.1)
 scico          * 1.5.0   2023-08-14 [1] CRAN (R 4.4.0)
 secretbase       1.0.5   2025-03-04 [1] CRAN (R 4.4.1)
 sessioninfo    * 1.2.3   2025-02-05 [1] CRAN (R 4.4.1)
 sf             * 1.0-21  2025-05-15 [1] CRAN (R 4.4.1)
 SnowballC        0.7.1   2023-04-25 [1] CRAN (R 4.4.1)
 sp             * 2.2-0   2025-02-01 [1] CRAN (R 4.4.1)
 SparseArray    * 1.6.2   2025-02-20 [1] Bioconductor 3.20 (R 4.4.2)
 spData         * 2.3.4   2025-01-08 [1] CRAN (R 4.4.1)
 stringfish       0.17.0  2025-07-13 [1] CRAN (R 4.4.1)
 stringi          1.8.7   2025-03-27 [1] CRAN (R 4.4.1)
 stringr        * 1.5.1   2023-11-14 [1] CRAN (R 4.4.0)
 survey           4.4-2   2024-03-20 [1] CRAN (R 4.4.0)
 survival         3.8-3   2024-12-17 [1] CRAN (R 4.4.1)
 svglite          2.2.1   2025-05-12 [1] CRAN (R 4.4.1)
 systemfonts      1.2.3   2025-04-30 [1] CRAN (R 4.4.1)
 tab              5.1.1   2021-08-02 [1] CRAN (R 4.4.0)
 tarchetypes    * 0.13.0  2025-04-10 [1] CRAN (R 4.4.1)
 targets        * 1.8.0   2024-10-02 [1] CRAN (R 4.4.2)
 terra            1.8-60  2025-07-21 [1] CRAN (R 4.4.1)
 textshaping      1.0.1   2025-05-01 [1] CRAN (R 4.4.1)
 tibble         * 3.3.0   2025-06-08 [1] CRAN (R 4.4.1)
 tidyr          * 1.3.1   2024-01-24 [1] CRAN (R 4.4.1)
 tidyselect       1.2.1   2024-03-11 [1] CRAN (R 4.4.0)
 tidytext       * 0.4.3   2025-07-25 [1] CRAN (R 4.4.1)
 tidyverse      * 2.0.0   2023-02-22 [1] CRAN (R 4.4.0)
 timechange       0.3.0   2024-01-18 [1] CRAN (R 4.4.1)
 tokenizers       0.3.0   2022-12-22 [1] CRAN (R 4.4.0)
 tzdb             0.5.0   2025-03-15 [1] CRAN (R 4.4.1)
 units          * 0.8-7   2025-03-11 [1] CRAN (R 4.4.1)
 usmap          * 0.8.0   2025-05-28 [1] CRAN (R 4.4.1)
 utf8             1.2.6   2025-06-08 [1] CRAN (R 4.4.1)
 vctrs            0.6.5   2023-12-01 [1] CRAN (R 4.4.0)
 viridisLite      0.4.2   2023-05-02 [1] CRAN (R 4.4.1)
 vroom            1.6.5   2023-12-05 [1] CRAN (R 4.4.0)
 withr            3.0.2   2024-10-28 [1] CRAN (R 4.4.1)
 xfun             0.52    2025-04-02 [1] CRAN (R 4.4.1)
 xml2             1.3.8   2025-03-14 [1] CRAN (R 4.4.1)
 XVector          0.46.0  2024-11-08 [1] Bioconductor 3.20 (R 4.4.1)
 yaml           * 2.3.10  2024-07-26 [1] CRAN (R 4.4.1)
 zip            * 2.3.3   2025-05-13 [1] CRAN (R 4.4.1)
 zlibbioc         1.52.0  2024-11-08 [1] Bioconductor 3.20 (R 4.4.1)

 [1] /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library
 * ── Packages attached to the search path.

─────────────────────────────────────────────────────────────────────────────────────────────────────
```

### Pipeline build

To build this pipeline (after running the setup section), you should 

1. Open the `run_pipeline.R` script.
1. Click on the `Background Jobs` tab in RStudio (next to `Console` and `Terminal`).
1. Choose `Start Background Job` and make sure the `run_pipeline.R` script is selected.
1. Accept the defaults and click `Start` to kick off the pipeline build.

This will build the pipeline in the background, so that your RStudio session can still be used as the job is running.

### Pipeline outputs

Many of the pipeline's artifacts are "object targets" but there are some files created. As of 09/09/2025, the best way to see how the pipeline and analysis ran is to open the figures and data stored in `7_Disseminate/out/`. This will only have built if all the other pipeline steps were successfully run. 

Final manuscript figures and manuscript stats are available in `7_Disseminate/out/`.
