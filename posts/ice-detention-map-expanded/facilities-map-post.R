# facilities-map-post.R — Expanded ICE Detention Map
# Extends the ICE-only map with DDP daily population data (FY24–FY26 partial),
# adding hold rooms, ERO field offices, county jails, and medical facilities
# not reported in ICE annual statistics.
#
# Data loaded from local RDS files (copied by copy-data.sh).

library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(sf)
library(leaflet)
library(scales)
library(htmltools)
library(leaflet.extras)

# ── Load data ────────────────────────────────────────────────────────────────

expanded_panel   <- readRDS("data/expanded_panel.rds")
expanded_presence <- readRDS("data/expanded_presence.rds")
expanded_geocoded <- readRDS("data/expanded_geocoded.rds") |>
  dplyr::mutate(
    # Consolidate fine-grained ERO/hold types (all lack useful distinction at map scale)
    facility_type_wiki = dplyr::case_match(
      facility_type_wiki,
      c("ICE ERO Field Office", "ICE ERO Sub-Office", "ICE ERO Hold Room",
        "ICE Custody/Case Facility", "ICE Command Center",
        "ICE Staging Facility") ~ "ICE Hold Room",
      .default = facility_type_wiki
    )
  )

# Canonical year order (FY18 omitted — no data)
year_order <- c("FY10","FY11","FY12","FY13","FY14","FY15","FY16","FY17",
                "FY19","FY20","FY21","FY22","FY23","FY24","FY25","FY26")

fy_levels       <- grep("^FY", names(expanded_presence), value = TRUE)
most_recent_fy  <- tail(fy_levels, 1)

# ── Color palette ────────────────────────────────────────────────────────────

type_colors <- c(
  # Jails / prisons
  "Jail"                                          = "#377eb8",
  "Jail/Prison"                                   = "#377eb8",
  "State Prison"                                  = "#6baed6",
  "Federal Prison"                                = "#f781bf",
  # ICE dedicated / private
  "Dedicated Migrant Detention Center"            = "#4daf4a",
  "ICE Migrant Detention Center"                  = "#984ea3",
  "Private Migrant Detention Center"              = "#e41a1c",
  "State Migrant Detention Center"                = "#e6ab02",
  # Short-term / hold
  "ICE Short-Term Migrant Detention Center"       = "#ff7f00",
  "ICE Hold Room"                                 = "#b3cde3",
  "CBP Hold Facility"                             = "#9ecae1",
  # Special
  "Family Detention Center"                       = "#a65628",
  "Juvenile Detention Center"                     = "#543005",
  "Medical Facility"                              = "#c7e9c0",
  "Military Detention Center"                     = "#66c2a5",
  "Other"                                         = "#1b9e77"
)

desaturate_hex <- function(hex, amount = 0.65) {
  rgb_mat <- col2rgb(hex) / 255
  grey    <- 0.299 * rgb_mat[1, ] + 0.587 * rgb_mat[2, ] + 0.114 * rgb_mat[3, ]
  blended <- rgb_mat * (1 - amount) + grey * amount
  rgb(blended[1, ], blended[2, ], blended[3, ])
}

type_colors_closed <- desaturate_hex(type_colors)
names(type_colors_closed) <- names(type_colors)

# Fallback for types not in palette
type_color_default        <- unname(type_colors["Other"])
type_color_closed_default <- unname(type_colors_closed["Other"])

get_type_color <- function(types, closed = FALSE) {
  pal <- if (closed) type_colors_closed else type_colors
  coalesce(unname(pal[types]), if (closed) type_color_closed_default else type_color_default)
}

# ── ADP data from panel ──────────────────────────────────────────────────────

adp_by_year <- expanded_panel |>
  filter(!is.na(canonical_id)) |>
  summarise(adp = sum(adp, na.rm = TRUE), .by = c(canonical_id, fiscal_year))

adp_wide <- adp_by_year |>
  pivot_wider(names_from = fiscal_year, values_from = adp, names_sort = TRUE)

fy_cols <- grep("^FY", names(adp_wide), value = TRUE)

latest_adp <- adp_by_year |>
  filter(!is.na(adp), adp > 0) |>
  arrange(canonical_id, desc(fiscal_year)) |>
  distinct(canonical_id, .keep_all = TRUE) |>
  transmute(canonical_id, latest_adp = round(adp), adp_fy = fiscal_year)

# Peak population per facility: DDP peak_population where available;
# max ICE ADP as fallback for ice_only facilities (they have real population).
peak_by_facility <- expanded_panel |>
  filter(!is.na(canonical_id)) |>
  group_by(canonical_id) |>
  summarise(
    ddp_peak   = suppressWarnings(max(peak_population, na.rm = TRUE)),
    max_ice_adp = suppressWarnings(max(ice_adp, na.rm = TRUE)),
    has_ice    = any(data_source != "ddp_only"),
    .groups = "drop"
  ) |>
  mutate(
    ddp_peak    = if_else(is.finite(ddp_peak),    ddp_peak,    NA_real_),
    max_ice_adp = if_else(is.finite(max_ice_adp), max_ice_adp, NA_real_),
    # effective_peak: DDP peak if available; ICE max ADP otherwise
    effective_peak = coalesce(ddp_peak, max_ice_adp),
    # low_peak: DDP data exists, peak < 2, and facility not in ICE annual stats
    low_peak = !has_ice & !is.na(ddp_peak) & ddp_peak < 2
  )

# ── Sparkbar SVG ─────────────────────────────────────────────────────────────

# Bar colors by data_source
source_color <- c(
  ice_only            = "#6b6b6b",
  ice_ddp_agree       = "#6b6b6b",
  ddp_only            = "#4682b4",
  ice_ddp_diverge_high = "#6b6b6b",
  ice_ddp_diverge_low  = "#6b6b6b"
)

make_expanded_sparkbar <- function(rows, chart_width = 270,
                                    bar_height = 11, gap = 2) {
  # rows: tibble with columns fiscal_year, adp, ice_adp, ddp_adp, data_source
  # One row per fiscal year. For years with both ICE and DDP data:
  #   - solid gray base bar up to min(ice_adp, ddp_adp)
  #   - blue extension where DDP > ICE
  #   - light-grey extension where ICE > DDP
  rows <- rows |>
    arrange(match(fiscal_year, year_order))

  all_vals <- c(
    rows$ice_adp[!is.na(rows$ice_adp)],
    rows$ddp_adp[!is.na(rows$ddp_adp)]
  )
  max_val <- if (length(all_vals) > 0 && any(all_vals > 0, na.rm = TRUE))
    max(all_vals, na.rm = TRUE) else 0
  if (max_val == 0) return("")

  # Enforce minimum x-axis scale of 20 so small values aren't misleadingly large
  max_val <- max(max_val, 20)

  label_width     <- 36
  val_label_width <- nchar(format(round(max_val), big.mark = ",")) * 6 + 8
  bar_area        <- chart_width - label_width - val_label_width

  px <- function(v) if (v > 0) max(2, v / max_val * bar_area) else 0

  bars <- pmap_chr(rows, \(fiscal_year, adp, ice_adp, ddp_adp, data_source, ...) {
    y <- (match(fiscal_year, rows$fiscal_year) - 1) * (bar_height + gap)

    ice <- coalesce(ice_adp, 0)
    ddp <- coalesce(ddp_adp, 0)
    has_both <- str_starts(data_source, "ice_ddp")

    # Year label
    lbl <- sprintf(
      '<text x="%d" y="%.1f" font-size="9" font-family="sans-serif" fill="#333" text-anchor="end" dominant-baseline="central">%s</text>',
      label_width - 3, y + bar_height / 2, fiscal_year
    )

    if (has_both) {
      base  <- min(ice, ddp)
      w_base <- px(base)
      w_ice  <- px(ice)
      w_ddp  <- px(ddp)

      # Gray base up to min(ice, ddp)
      rect_base <- if (w_base > 0) sprintf(
        '<rect x="%d" y="%.1f" width="%.1f" height="%d" fill="#6b6b6b" rx="1"/>',
        label_width, y, w_base, bar_height
      ) else ""

      # Blue extension where DDP > ICE
      rect_ext <- if (ddp > ice && w_ddp > w_base) sprintf(
        '<rect x="%.1f" y="%.1f" width="%.1f" height="%d" fill="#4682b4" rx="1"/>',
        label_width + w_base, y, w_ddp - w_base, bar_height
      ) else ""

      # Light-grey reduction where ICE > DDP
      rect_red <- if (ice > ddp && w_ice > w_base) sprintf(
        '<rect x="%.1f" y="%.1f" width="%.1f" height="%d" fill="#d0d0d0" rx="1"/>',
        label_width + w_base, y, w_ice - w_base, bar_height
      ) else ""

      # Value label: show the value at the bar's visible end
      primary_val <- max(ice, ddp)
      w_primary   <- w_ice
      val_lbl <- if (primary_val > 0) sprintf(
        '<text x="%.1f" y="%.1f" font-size="8" font-family="sans-serif" fill="#333" dominant-baseline="central">%s</text>',
        label_width + max(w_primary, w_ddp) + 3, y + bar_height / 2,
        format(round(primary_val), big.mark = ",")
      ) else ""

      paste0(lbl, rect_base, rect_ext, rect_red, val_lbl)

    } else {
      # Single-source year
      v   <- if (data_source == "ddp_only") ddp else ice
      col <- if (data_source == "ddp_only") "#4682b4" else "#6b6b6b"
      w   <- px(v)

      rect <- if (w > 0) sprintf(
        '<rect x="%d" y="%.1f" width="%.1f" height="%d" fill="%s" rx="1"/>',
        label_width, y, w, bar_height, col
      ) else ""

      val_lbl <- if (v > 0) sprintf(
        '<text x="%.1f" y="%.1f" font-size="8" font-family="sans-serif" fill="#333" dominant-baseline="central">%s</text>',
        label_width + w + 3, y + bar_height / 2,
        format(round(v), big.mark = ",")
      ) else ""

      paste0(lbl, rect, val_lbl)
    }
  })

  n_rows       <- nrow(rows)
  total_height <- n_rows * (bar_height + gap)

  sprintf(
    '<svg width="%d" height="%d" xmlns="http://www.w3.org/2000/svg">%s</svg>',
    chart_width, total_height, paste0(bars, collapse = "")
  )
}

# ── Popup HTML ───────────────────────────────────────────────────────────────

build_popup_html_expanded <- function(row, panel_rows) {
  # row: one row from map_df
  # panel_rows: expanded_panel rows for this canonical_id (pre-filtered)

  sources <- unique(panel_rows$data_source)
  has_ice <- any(sources %in% c("ice_only","ice_ddp_agree",
                                  "ice_ddp_diverge_high","ice_ddp_diverge_low"))
  has_ddp <- any(sources %in% c("ddp_only","ice_ddp_agree",
                                  "ice_ddp_diverge_high","ice_ddp_diverge_low"))

  source_badge <- if (has_ice && has_ddp) {
    '<span style="background:#e8f0e8;border-radius:3px;padding:1px 4px;font-size:10px;color:#2a5a2a;">ICE + DDP</span>'
  } else if (has_ddp) {
    '<span style="background:#e8eef8;border-radius:3px;padding:1px 4px;font-size:10px;color:#1a3a6a;">DDP only</span>'
  } else {
    '<span style="background:#f0f0f0;border-radius:3px;padding:1px 4px;font-size:10px;color:#444;">ICE stats only</span>'
  }

  ddp_note <- if (!has_ddp && has_ice) {
    '<br><span style="color:#999;font-size:10px;">Not found in DDP daily data</span>'
  } else if (has_ddp && !has_ice) {
    '<br><span style="color:#999;font-size:10px;">Absent from ICE annual statistics</span>'
  } else ""

  status_html <- if (row$status == "open") {
    '<span style="color:#2a7;font-weight:bold;">Active</span>'
  } else {
    '<span style="color:#a55;">Closed</span>'
  }

  detloc_html <- if (!is.na(row$detloc)) {
    sprintf('<span style="color:#888;font-size:10px;">DETLOC: %s</span>', row$detloc)
  } else ""

  adp_line <- if (!is.na(row$latest_adp) && row$latest_adp > 0) {
    sprintf('<br><b>ADP: %s</b> (%s)', format(row$latest_adp, big.mark = ","), row$adp_fy)
  } else {
    '<br><span style="color:#999;">No ADP data</span>'
  }

  peak_line <- if (!is.na(row$ddp_peak) && row$ddp_peak > 0) {
    sprintf('<br>DDP peak: %s (%s)',
            format(as.integer(row$ddp_peak), big.mark = ","),
            row$peak_fy %||% "")
  } else ""

  chart <- make_expanded_sparkbar(panel_rows)

  # Bar color legend: shown whenever both ICE and DDP data are present
  chart_legend <- if (has_ice && has_ddp) {
    '<div style="font-size:9px;color:#666;margin-top:2px;">
     <span style="display:inline-block;width:10px;height:8px;background:#6b6b6b;margin-right:3px;vertical-align:middle;"></span>ICE&nbsp;
     <span style="display:inline-block;width:10px;height:8px;background:#4682b4;margin-left:6px;margin-right:3px;vertical-align:middle;"></span>DDP higher&nbsp;
     <span style="display:inline-block;width:10px;height:8px;background:#d0d0d0;border:1px solid #bbb;margin-left:6px;margin-right:3px;vertical-align:middle;box-sizing:border-box;"></span>DDP lower</div>'
  } else ""

  chart_section <- if (nchar(chart) > 0) {
    sprintf(
      '<div style="margin-top:6px;border-top:1px solid #ddd;padding-top:4px;">
       <span style="font-size:10px;color:#666;">ADP by fiscal year</span>%s<br>%s</div>',
      chart_legend, chart
    )
  } else ""

  sprintf(
    '<div style="min-width:290px;font-family:sans-serif;font-size:12px;">
     <b style="font-size:13px;">%s</b> %s<br>
     %s, %s<br>
     <span style="color:#666;">Type: %s</span><br>
     <span style="color:#666;">%s | First: %s | Last: %s</span>
     %s %s %s%s%s</div>',
    htmlEscape(row$canonical_name),
    source_badge,
    htmlEscape(coalesce(row$facility_city, "")),
    htmlEscape(coalesce(row$facility_state, "")),
    htmlEscape(coalesce(row$facility_type_wiki, "Unknown")),
    status_html,
    coalesce(row$first_seen, "?"),
    coalesce(row$last_seen, "?"),
    adp_line,
    peak_line,
    ddp_note,
    if (nchar(detloc_html) > 0) paste0("<br>", detloc_html) else "",
    chart_section
  )
}

# ── Assemble map data ────────────────────────────────────────────────────────

# Peak date per facility (year of DDP peak, for popup)
peak_date_by_facility <- expanded_panel |>
  filter(!is.na(canonical_id), !is.na(peak_date)) |>
  group_by(canonical_id) |>
  slice_max(peak_population, n = 1, with_ties = FALSE) |>
  ungroup() |>
  transmute(
    canonical_id,
    peak_fy = fiscal_year
  )

map_df <- expanded_geocoded |>
  filter(!is.na(lat), !is.na(lon)) |>
  left_join(
    expanded_presence |> select(canonical_id, first_seen, last_seen),
    by = "canonical_id"
  ) |>
  left_join(latest_adp,         by = "canonical_id") |>
  left_join(peak_by_facility,   by = "canonical_id") |>
  left_join(peak_date_by_facility, by = "canonical_id") |>
  mutate(
    facility_type_wiki = replace_na(facility_type_wiki, "Other"),
    status = case_when(
      is.na(last_seen)                   ~ "closed",
      last_seen == most_recent_fy        ~ "open",
      TRUE                               ~ "closed"
    ),
    # Marker size: peak population throughout (DDP peak where available, max ICE ADP otherwise)
    size_adp = replace_na(effective_peak, 0),
    fill_color = if_else(
      status == "open",
      get_type_color(facility_type_wiki, closed = FALSE),
      get_type_color(facility_type_wiki, closed = TRUE)
    ),
    label = str_c(canonical_name, " (", coalesce(facility_city, ""), ", ",
                  coalesce(facility_state, ""), ")")
  )

map_df <- map_df |>
  mutate(radius = rescale(sqrt(pmax(size_adp, 1)), to = c(3, 25)))

# Assign marker groups for layered control.
# ICE-reported = appears in ICE annual statistics (has_ice = TRUE).
# DDP-only = only found in DDP daily data, absent from ICE annual stats.
map_df <- map_df |>
  mutate(
    map_group = case_when(
      !coalesce(has_ice, FALSE) & coalesce(low_peak, FALSE) ~ "Low population (peak < 2)",
      !coalesce(has_ice, FALSE)                              ~ "DDP-only (not in ICE annual stats)",
      status == "open"                                       ~ "Open (ICE-reported)",
      TRUE                                                   ~ "Closed (ICE-reported)"
    )
  )

# ── Build popups ─────────────────────────────────────────────────────────────

# Split expanded_panel by canonical_id for popup lookup
panel_split <- expanded_panel |>
  filter(!is.na(canonical_id)) |>
  split(~canonical_id)

popup_html <- map_chr(seq_len(nrow(map_df)), \(i) {
  row <- as.list(map_df[i, ])
  cid <- as.character(row$canonical_id)
  prows <- panel_split[[cid]]
  if (is.null(prows)) prows <- tibble()
  build_popup_html_expanded(row, prows)
})

# ── ADP-weighted centroid by fiscal year ─────────────────────────────────────

centroid_by_fy <- expanded_panel |>
  filter(!is.na(adp), adp > 0, !is.na(canonical_id)) |>
  inner_join(
    expanded_geocoded |> select(canonical_id, lat, lon),
    by = "canonical_id"
  ) |>
  filter(!is.na(lat), !is.na(lon)) |>
  summarise(
    lat          = weighted.mean(lat, w = adp),
    lon          = weighted.mean(lon, w = adp),
    total_adp    = sum(adp),
    n_facilities = n(),
    .by = fiscal_year
  ) |>
  mutate(year_rank = match(fiscal_year, year_order)) |>
  arrange(year_rank)

centroid_sf   <- st_as_sf(centroid_by_fy, coords = c("lon", "lat"), crs = 4326)
centroid_line <- centroid_sf |>
  summarise(geometry = st_combine(geometry)) |>
  st_cast("LINESTRING")

centroid_popup <- map_chr(seq_len(nrow(centroid_by_fy)), \(i) {
  r <- centroid_by_fy[i, ]
  sprintf(
    '<div style="font-family:sans-serif;font-size:12px;">
     <b>%s weighted centroid</b><br>
     Total ADP: %s<br>Facilities: %s<br>
     Lat: %.3f, Lon: %.3f</div>',
    r$fiscal_year,
    format(round(r$total_adp), big.mark = ","),
    r$n_facilities,
    st_coordinates(centroid_sf[i, ])[2],
    st_coordinates(centroid_sf[i, ])[1]
  )
})

# ── Build leaflet map ────────────────────────────────────────────────────────

map_sf     <- st_as_sf(map_df, coords = c("lon", "lat"), crs = 4326)
is_open    <- map_sf$map_group == "Open (ICE-reported)"
is_closed  <- map_sf$map_group == "Closed (ICE-reported)"
is_ddp     <- map_sf$map_group == "DDP-only (not in ICE annual stats)"
is_low     <- map_sf$map_group == "Low population (peak < 2)"

legend_types <- sort(setdiff(unique(map_df$facility_type_wiki), "Other"))
if ("Other" %in% unique(map_df$facility_type_wiki)) legend_types <- c(legend_types, "Other")
legend_colors <- get_type_color(legend_types)

all_groups <- c("Open (ICE-reported)", "Closed (ICE-reported)",
                "DDP-only (not in ICE annual stats)", "Low population (peak < 2)",
                "ADP Centroid")

facilities_map_expanded <- leaflet() |>
  fitBounds(lng1 = -125, lat1 = 17.5, lng2 = -65, lat2 = 49.5) |>
  addProviderTiles(providers$CartoDB.Positron) |>
  # Closed ICE-reported facilities
  addCircleMarkers(
    data = map_sf[is_closed, ],
    radius      = ~radius,
    color       = "#666",
    weight      = 0.5,
    fillColor   = ~fill_color,
    fillOpacity = 0.45,
    popup       = popup_html[is_closed],
    label       = ~label,
    group       = "Closed (ICE-reported)"
  ) |>
  # Open ICE-reported facilities
  addCircleMarkers(
    data = map_sf[is_open, ],
    radius      = ~radius,
    color       = "#333",
    weight      = 0.8,
    fillColor   = ~fill_color,
    fillOpacity = 0.82,
    popup       = popup_html[is_open],
    label       = ~label,
    group       = "Open (ICE-reported)"
  ) |>
  # DDP-only facilities (unreported in ICE annual stats; default on)
  addCircleMarkers(
    data = map_sf[is_ddp, ],
    radius      = ~radius,
    color       = "#4682b4",
    weight      = 0.6,
    fillColor   = ~fill_color,
    fillOpacity = 0.72,
    popup       = popup_html[is_ddp],
    label       = ~label,
    group       = "DDP-only (not in ICE annual stats)"
  ) |>
  # Low-population DDP facilities (default hidden)
  addCircleMarkers(
    data = map_sf[is_low, ],
    radius      = 3,
    color       = "#999",
    weight      = 0.5,
    fillColor   = ~fill_color,
    fillOpacity = 0.55,
    popup       = popup_html[is_low],
    label       = ~label,
    group       = "Low population (peak < 2)"
  ) |>
  # ADP centroid path
  addPolylines(
    data      = centroid_line,
    color     = "#222",
    weight    = 2,
    opacity   = 0.5,
    dashArray = "4,4",
    group     = "ADP Centroid"
  ) |>
  addCircleMarkers(
    data        = centroid_sf,
    radius      = 5,
    color       = "#222",
    weight      = 1.5,
    fillColor   = "#fff",
    fillOpacity = 0.9,
    popup       = centroid_popup,
    label       = ~fiscal_year,
    group       = "ADP Centroid"
  ) |>
  addLegend(
    position = "bottomright",
    colors   = legend_colors,
    labels   = legend_types,
    title    = "Facility Type",
    opacity  = 0.85
  ) |>
  addLayersControl(
    overlayGroups = all_groups,
    options = layersControlOptions(collapsed = FALSE)
  ) |>
  hideGroup("Low population (peak < 2)") |>
  addSearchFeatures(
    targetGroups = head(all_groups, -1),   # all except ADP Centroid
    options = searchFeaturesOptions(
      zoom              = 9,
      openPopup         = TRUE,
      position          = "topleft",
      hideMarkerOnCollapse = TRUE
    )
  )
