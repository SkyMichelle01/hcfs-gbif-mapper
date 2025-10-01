#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(sf)
  library(dplyr)
  library(rgbif)
  library(readr)
  library(jsonlite)
  library(tidyr)
})

aoi_path <- "data/aoi/hcfs.geojson"
out_csv  <- "data/gbif/occurrences.csv"
out_geo  <- "data/gbif/occurrences.geojson"
dir.create("data/gbif", showWarnings = FALSE, recursive = TRUE)

if (!file.exists(aoi_path)) stop("AOI file missing: ", aoi_path, call. = FALSE)

aoi <- st_read(aoi_path, quiet = TRUE) |> st_make_valid() |> st_transform(4326)
aoi_union <- st_union(aoi) |> st_geometry()
wkt <- st_as_text(aoi_union)

state_path <- "data/gbif/state.json"
since <- if (file.exists(state_path)) {
  tryCatch(fromJSON(state_path)$since, error = function(e) NULL)
} else NULL

current_year <- as.integer(format(Sys.Date(), "%Y"))
year_min <- max(current_year - 5L, 2000L)

limit <- 300
start <- 0
all <- list()

repeat {
  res <- occ_search(
    geometry = wkt,
    hasCoordinate = TRUE,
    year = paste0(year_min, ",", current_year),
    limit = limit,
    start = start,
    hasGeospatialIssue = FALSE,
    occurrenceStatus = "PRESENT",
    fields = c("key","scientificName","kingdom","phylum","class","order",
               "family","genus","species","decimalLatitude","decimalLongitude",
               "eventDate","year","basisOfRecord","datasetKey","institutionCode",
               "occurrenceID","recordedBy","identifiedBy","taxonKey")
  )
  if (is.null(res$data) || nrow(res$data) == 0) break
  all[[length(all)+1]] <- res$data
  start <- start + nrow(res$data)
  if (start >= 100000) break
}

if (length(all) == 0) {
  write_lines("", out_csv)
  write_lines('{"type":"FeatureCollection","features":[]}', out_geo)
  quit(save = "no", status = 0)
}

occ <- bind_rows(all) |> distinct(key, .keep_all = TRUE) |> drop_na(decimalLatitude, decimalLongitude)

write_csv(occ, out_csv)

sf_occ <- st_as_sf(occ, coords = c("decimalLongitude","decimalLatitude"), crs = 4326, remove = FALSE)
st_write(sf_occ, out_geo, delete_dsn = TRUE, quiet = TRUE)

state <- list(since = as.character(Sys.time()), n = nrow(occ))
write(toJSON(state, auto_unbox = TRUE, pretty = TRUE), state_path)
