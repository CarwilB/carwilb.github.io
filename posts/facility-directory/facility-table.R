# facility-table.R (post version)
# SVG renderers and reactable builder for the facility directory table.
# Sourced from index.qmd. Data is pre-built; see copy-data.sh.

library(dplyr)
library(reactable)
library(reactablefmtr)
library(htmltools)
library(crosstalk)

# ── SVG sparkline cell renderer ───────────────────────────────────────────────

sparkline_svg <- function(values, width = 140, line_height = 26,
                           color = "#4682b4", area_opacity = 0.15) {
  if (is.null(values) || length(values) == 0 || all(is.na(values))) return("")
  values[is.na(values)] <- 0
  n <- length(values)
  if (n < 2) return("")
  max_v <- max(values)
  if (max_v == 0) return("")

  label_h <- 9
  total_h <- line_height + label_h

  xs <- (seq_len(n) - 1) / (n - 1) * width
  ys <- line_height - values / max_v * line_height

  pts      <- paste(sprintf("%.1f,%.1f", xs, ys), collapse = " ")
  area_pts <- paste0(
    sprintf("0,%.1f ", line_height), pts,
    sprintf(" %.1f,%.1f", width, line_height)
  )

  # Jan 1 reference lines
  jan_lines <- ""
  if (!is.null(names(values)) && !anyNA(names(values))) {
    start_date <- as.Date(names(values)[1])
    end_date   <- as.Date(tail(names(values), 1))
    span_days  <- as.numeric(end_date - start_date)
    if (span_days > 0) {
      jan1s <- seq(
        as.Date(paste0(as.integer(format(start_date, "%Y")) + 1L, "-01-01")),
        as.Date(paste0(as.integer(format(end_date,   "%Y")),       "-01-01")),
        by = "year"
      )
      jan1s <- jan1s[jan1s > start_date & jan1s < end_date]
      jan_lines <- paste(vapply(jan1s, function(d) {
        xp <- as.numeric(d - start_date) / span_days * width
        sprintf(
          '<line x1="%.1f" x2="%.1f" y1="0" y2="%d" stroke="white" stroke-width="0.8" opacity="0.7"/>',
          xp, xp, line_height
        )
      }, character(1)), collapse = "")
    }
  }

  fmt_date  <- function(d) format(as.Date(d), "%b%y")
  start_lbl <- if (!is.null(names(values))) fmt_date(names(values)[1])        else ""
  end_lbl   <- if (!is.null(names(values))) fmt_date(tail(names(values), 1)) else ""

  lbl_y <- line_height + label_h - 1
  labels <- paste0(
    sprintf('<text x="0" y="%d" font-size="6.5" font-family="sans-serif" fill="#888" text-anchor="start">%s</text>',
            lbl_y, start_lbl),
    sprintf('<text x="%d" y="%d" font-size="6.5" font-family="sans-serif" fill="#888" text-anchor="end">%s</text>',
            width, lbl_y, end_lbl)
  )

  paste0(
    sprintf('<svg width="%d" height="%d" style="display:block;overflow:visible;">',
            width, total_h),
    sprintf('<polygon points="%s" fill="%s" opacity="%.2f"/>',
            area_pts, color, area_opacity),
    sprintf('<polyline points="%s" fill="none" stroke="%s" stroke-width="1.2"/>',
            pts, color),
    jan_lines, labels, "</svg>"
  ) |> HTML()
}

# ── ADP bar chart SVG cell renderer ──────────────────────────────────────────

adp_bars_svg <- function(values, width = 140, bar_h_max = 26, gap = 1.2) {
  if (is.null(values) || all(is.na(values))) return("")
  max_v <- max(values, na.rm = TRUE)
  if (!is.finite(max_v) || max_v == 0) return("")

  n       <- length(values)
  nms     <- names(values)
  total_w <- width - gap * (n - 1)
  bar_w   <- total_w / (n - 0.5)
  half_w  <- bar_w / 2
  label_h <- 9
  total_h <- bar_h_max + label_h

  bar_x      <- numeric(n)
  bar_w_each <- numeric(n)
  x <- 0
  for (i in seq_len(n)) {
    bar_x[i]      <- x
    bar_w_each[i] <- if (nms[i] == "FY18") half_w else bar_w
    x <- x + bar_w_each[i] + gap
  }

  has_data <- !is.na(values) & values > 0
  first_i  <- which(has_data)[1]
  last_i   <- tail(which(has_data), 1)

  rects <- character(n)
  for (i in seq_len(n)) {
    if (has_data[i]) {
      h <- max(1.5, values[[i]] / max_v * bar_h_max)
      rects[i] <- sprintf(
        '<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="#888" rx="0.5"/>',
        bar_x[i], bar_h_max - h, bar_w_each[i], h
      )
    }
  }

  lbl_y  <- bar_h_max + label_h - 1
  labels <- character(0)
  if (!is.na(first_i)) {
    cx <- bar_x[first_i] + bar_w_each[first_i] / 2
    labels <- c(labels, sprintf(
      '<text x="%.1f" y="%d" font-size="5.5" font-family="sans-serif" fill="#888" text-anchor="middle">%s</text>',
      cx, lbl_y, nms[first_i]
    ))
  }
  if (!is.na(last_i) && !identical(last_i, first_i)) {
    cx <- bar_x[last_i] + bar_w_each[last_i] / 2
    labels <- c(labels, sprintf(
      '<text x="%.1f" y="%d" font-size="5.5" font-family="sans-serif" fill="#888" text-anchor="middle">%s</text>',
      cx, lbl_y, nms[last_i]
    ))
  }

  paste0(
    sprintf('<svg width="%d" height="%d" style="display:block;overflow:visible;">',
            width, total_h),
    paste(c(rects, labels), collapse = ""),
    "</svg>"
  ) |> HTML()
}

# ── Reactable builder ─────────────────────────────────────────────────────────

make_facility_table <- function(df,
                                 columns  = c("facility", "type", "status",
                                              "adp", "ddp_peak", "detloc",
                                              "adp_bars", "ddp_sparkline"),
                                 min_peak = 2) {

  df <- df |> filter(is.na(effective_peak) | effective_peak >= min_peak)
  sd <- SharedData$new(df, ~canonical_id)

  key_map <- c(
    facility      = "canonical_name",
    type          = "facility_type_wiki",
    status        = "status_label",
    adp           = "adp_label",
    ddp_peak      = "peak_label",
    detloc        = "detloc",
    adp_bars      = "adp_values",
    ddp_sparkline = "ddp_sparkline"
  )
  selected_data_cols <- unname(key_map[columns])

  all_col_defs <- list(

    canonical_name = colDef(
      name       = "Facility",
      minWidth   = 210,
      filterable = TRUE,
      html       = TRUE,
      filterMethod = JS("function(rows, columnId, filterValue) {
        var lc = filterValue.toLowerCase();
        return rows.filter(function(row) {
          var v = (row.values['canonical_name'] || '') + ' ' +
                  (row.values['location'] || '');
          return v.toLowerCase().indexOf(lc) >= 0;
        });
      }"),
      cell = function(value, index) {
        row <- df[index, ]
        div(
          style = "line-height:1.3;",
          div(style = "font-weight:600; font-size:0.88em;", row$canonical_name),
          div(style = "color:#666; font-size:0.78em;", row$location)
        )
      }
    ),

    facility_type_wiki = colDef(
      name       = "Type",
      minWidth   = 160,
      filterable = TRUE,
      style      = list(fontSize = "0.82em", color = "#444")
    ),

    status_label = colDef(
      name       = "Status",
      minWidth   = 130,
      filterable = TRUE,
      html       = TRUE,
      cell = function(value, index) {
        row <- df[index, ]
        div(
          style = "font-size:0.82em; line-height:1.5;",
          div(span(
            style = paste0("font-weight:600; color:",
                           if (isTRUE(row$status_label == "Active")) "#2a7a2a"
                           else "#888", ";"),
            row$status_label
          )),
          div(style = "color:#666;", row$span_label)
        )
      }
    ),

    adp_label = colDef(
      name       = "ADP",
      minWidth   = 105,
      filterable = FALSE,
      style      = list(fontSize = "0.82em", fontVariantNumeric = "tabular-nums",
                        textAlign = "right")
    ),

    peak_label = colDef(
      name       = "DDP Peak",
      minWidth   = 105,
      filterable = FALSE,
      style      = list(fontSize = "0.82em", fontVariantNumeric = "tabular-nums",
                        textAlign = "right")
    ),

    detloc = colDef(
      name       = "DETLOC",
      minWidth   = 85,
      filterable = TRUE,
      style      = list(fontSize = "0.80em", fontFamily = "monospace", color = "#555")
    ),

    adp_values = colDef(
      name       = "ADP by year",
      minWidth   = 155,
      filterable = FALSE,
      sortable   = FALSE,
      html       = TRUE,
      cell       = function(value, index) adp_bars_svg(df$adp_values[[index]])
    ),

    ddp_sparkline = colDef(
      name       = "Daily pop. (DDP)",
      minWidth   = 145,
      filterable = FALSE,
      sortable   = FALSE,
      html       = TRUE,
      cell       = function(value, index) sparkline_svg(df$ddp_sparkline[[index]])
    )
  )

  hidden_col_defs <- setNames(
    lapply(setdiff(names(df), selected_data_cols), function(.) colDef(show = FALSE)),
    setdiff(names(df), selected_data_cols)
  )

  slider <- filter_slider(
    "peak_slider", "Minimum peak population",
    sd, ~effective_peak,
    min = 0, step = 1, width = "300px"
  )

  tbl <- reactable(
    sd,
    theme               = nytimes(font_size = 13),
    columns             = c(all_col_defs[selected_data_cols], hidden_col_defs),
    sortable            = TRUE,
    pagination          = TRUE,
    defaultPageSize     = 12,
    showPageSizeOptions = TRUE,
    pageSizeOptions     = c(12, 25, 50, 100),
    highlight           = TRUE,
    compact             = TRUE,
    defaultSorted       = list(effective_peak = "desc")
  )

  tagList(div(style = "margin-bottom:12px;", slider), tbl)
}
