# GBIF Species Occurrence Mapper Assignment

## Overview
This assignment teaches you to retrieve, analyze, and visualize species occurrence data from GBIF using R and Quarto.

## Getting Started
1. Accept the GitHub Classroom assignment
2. Clone your repository
3. Open gbif-species-mapper.qmd in Positron
4. Customize the taxon parameters
5. Run the analysis and answer questions

## Required R Packages
install.packages(c("rgbif", "leaflet", "dplyr", "DT", "htmlwidgets", "ggplot2"))

## Files
- gbif-species-mapper.qmd - Main assignment notebook
- assignment-instructions.qmd - Detailed instructions
- data/ - Downloaded GBIF data
- outputs/ - Generated maps and reports


## Automated HCFS GBIF Widget

This repo also includes an automated data-refresh and interactive map for the Hill Country Field Station AOI.

- AOI: `data/aoi/hcfs.geojson` (already included)
- Fetch script: `scripts/fetch_gbif.R`
- Map page: `pages/gbif-map.qmd`
- Data outputs: `data/gbif/`

### Local run in terminal

```bash
Rscript scripts/fetch_gbif.R
quarto render
```

### Deploy with GitHub Pages

Uncomment `output-dir: docs` in `_quarto.yml`, then enable Pages (Settings → Pages → Deploy from `docs/`).

