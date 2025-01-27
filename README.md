
# QFieldSync (in development)

This package contains a suite of functions to simplify the
synchronisation (merging and duplicate control) of shared datasets used
by several co-workers using individual projects that are processed with
[QGIS](https://www.qgis.org/) and/or
[QField](https://github.com/opengisch/QField/).

------------------------------------------------------------------------

## Install package

``` r
devtools::install_github("mottensmann/QFieldSync")
```

## Load package once installed

``` r
## load package
library(QFieldSync)
```

## Merging observations

### Prerequisites:

Merging observations recorded in separate QGIS projects requires that
the following attributes/fields are configured:

- 1)  [uuid](https://en.wikipedia.org/wiki/Universally_unique_identifier):
      a *universal-unique-identifier* identifying each record.
- 2)  [MTIME](https://www.fosslinux.com/121740/linux-file-timestamps-how-to-use-atime-mtime-and-ctime.htm):
      *Modification Time*, time-stamp denoting the last modification of
      a record\*

### `db_unique` function

The function `db_unique` allows to identify and subsequently remove
duplicated entries from the database. For each identical record -
sharing the same uuid - always the most recently updated case is
selected based on the MTIME attribute. Older records are removed.

Create a simple non-spatial dataset for illustration purposes:

``` r
## code a toy dataset: Ten obseravation A:J
(db <- data.frame(uuid = LETTERS[1:10], MTIME = Sys.time()))
#>    uuid               MTIME
#> 1     A 2025-01-14 11:29:13
#> 2     B 2025-01-14 11:29:13
#> 3     C 2025-01-14 11:29:13
#> 4     D 2025-01-14 11:29:13
#> 5     E 2025-01-14 11:29:13
#> 6     F 2025-01-14 11:29:13
#> 7     G 2025-01-14 11:29:13
#> 8     H 2025-01-14 11:29:13
#> 9     I 2025-01-14 11:29:13
#> 10    J 2025-01-14 11:29:13

## now duplicate record J and update MTIME value
db <- rbind(db,db[10,])
db[11, "MTIME"] <- db[11, "MTIME"] + 60*60
db
#>     uuid               MTIME
#> 1      A 2025-01-14 11:29:13
#> 2      B 2025-01-14 11:29:13
#> 3      C 2025-01-14 11:29:13
#> 4      D 2025-01-14 11:29:13
#> 5      E 2025-01-14 11:29:13
#> 6      F 2025-01-14 11:29:13
#> 7      G 2025-01-14 11:29:13
#> 8      H 2025-01-14 11:29:13
#> 9      I 2025-01-14 11:29:13
#> 10     J 2025-01-14 11:29:13
#> 101    J 2025-01-14 12:29:13
```

Handle duplicated entry J (indices 10 and 101):

``` r
## removes the older record (index 10)
(db <- db_unique(db))
#>     uuid               MTIME
#> 1      A 2025-01-14 11:29:13
#> 2      B 2025-01-14 11:29:13
#> 3      C 2025-01-14 11:29:13
#> 4      D 2025-01-14 11:29:13
#> 5      E 2025-01-14 11:29:13
#> 6      F 2025-01-14 11:29:13
#> 7      G 2025-01-14 11:29:13
#> 8      H 2025-01-14 11:29:13
#> 9      I 2025-01-14 11:29:13
#> 101    J 2025-01-14 12:29:13
```

Example using GeoPackage layers:

``` r
## load example datasets: 
path <- "~/../QField/cloud/BsGtBi_Projekte/bsgtbi/"
QField_1 <-  sf::read_sf(file.path(path, 'bsgtbi_mo/Avifauna.gpkg'), 'Aves') 
dim(QField_1)
#> [1] 11571    72
QField_2 <-  sf::read_sf(file.path(path, 'bsgtbi_bw/Avifauna.gpkg'), 'Aves') 
dim(QField_2)
#> [1] 11568    72

## merge data frames
db <- rbind(QField_1, QField_2)
dim(db)
#> [1] 23139    72
db <- db_unique(db)
dim(db)
#> [1] 11575    72

## export to GeoPackage (NOT RUN)
# sf::st_write(
#   db, 
#   dsn = file.path(pfad_cloud, "Avifauna.gpkg"),
#   layer = 'Aves',
#   layer_options = "OVERWRITE=YES",
#   append = FALSE)
```
