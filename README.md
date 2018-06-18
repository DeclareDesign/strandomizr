# randomizr
The stata version of randomizr. randomizr is designed to make conducting field, lab, survey, or online experiments easier by automating the random assignment process. To install from SSC just open Stata and type the following in the command line:

``` r
ssc install randomizr
```

Or you can install the most current development release directly from the github:

``` r
net install randomizr, from(https://raw.githubusercontent.com/DeclareDesign/strandomizr/master/) replace
```

The unit tests folder contains a series of do files that error-check the functions. The vignette directory contains a do file that generates an html using the function markdoc in Stata. The vignette provides a walkthrough for how to use the various random assignment functions in randomizr.  

There are five main random assignment functions in randomizr: simple_ra, complete_ra, block_ra, cluster_ra, and block_and_cluster_ra, which correspond to common experimental designs.

complete_ra is the workhorse function that will be most appropriate for a large number of experimental situations: it assigns m of N units to treatment:

``` r
ssc install randomizr
set obs 100
complete_ra, prob_each(.1 .2 .7) conditions(control placebo treatment)
```

A more complicated design that, for example, assigns different numbers of clusters to three different treatments can be accomodated like this:

``` r
set obs 100
gen cluster=runiformint(1,26) 
cluster_ra, clusters(cluster) m_each(7 7 12) conditions(control placebo treatment)
```

Happy randomizing!
___
This package was written by John Ternovski and Alex Coppock.
