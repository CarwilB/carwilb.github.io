# render_talks.R
# Parse talks/talks.ris and render entries as markdown.
#
# RIS field conventions used in talks.ris:
#
# Invited presentations (TY = GEN or SLIDE):
#   TY  type (GEN or SLIDE)
#   ID  unique key
#   AU  author
#   TI  talk title
#   PY  year (YYYY)
#   DA  date (YYYY/MM//)
#   CY  location (city / venue city)
#   PB  host institution
#   N1  month (display name, e.g. "June")
#   N2  speaker role, if not primary invited speaker
#       (e.g. "Panelist", "Moderator", "Keynote")
#   M1  compensation / logistical notes (e.g. "honorarium", "travel expenses")
#   M2  additional context (e.g. "panel with Jorge Derpic")
#   ER  end of record
#
# Conference papers (TY = CPAPER):
#   TY  type (CPAPER)
#   ID  unique key
#   AU  author(s)
#   TI  paper title
#   PY  year (YYYY)
#   DA  date (YYYY/MM//)
#   T2  conference name
#   CY  location (city)
#   N1  month (display name)
#   N2  session role, if not presenter (e.g. "Discussant", "Chair")
#   M1  compensation / logistical notes
#   M2  additional context (e.g. co-authors on paper, session title)
#   ER  end of record

# ---------------------------------------------------------------------------
# parse_ris()
# Returns a list of named lists, one per RIS entry.
# ---------------------------------------------------------------------------
parse_ris <- function(file) {
  lines <- readLines(file, encoding = "UTF-8", warn = FALSE)
  entries <- list()
  current <- NULL

  for (line in lines) {
    line <- trimws(line, which = "right")
    if (nchar(trimws(line)) == 0L) next

    # RIS lines are "XX  - value" (2-char tag, 2 spaces, dash, optional space+value)
    if (!grepl("^[A-Z][A-Z0-9]  -", line)) next
    tag   <- substr(line, 1L, 2L)
    value <- trimws(substr(line, 6L, nchar(line)))
    value <- sub("^-\\s*", "", value)  # strip leading "- "

    if (tag == "TY") {
      current <- list(TY = value)
    } else if (tag == "ER") {
      if (!is.null(current)) {
        entries <- c(entries, list(current))
        current <- NULL
      }
    } else if (!is.null(current)) {
      # Allow repeated tags → accumulate into a character vector
      if (is.null(current[[tag]])) {
        current[[tag]] <- value
      } else {
        current[[tag]] <- c(current[[tag]], value)
      }
    }
  }
  entries
}

# ---------------------------------------------------------------------------
# sort_entries()
# Sort a list of parsed RIS entries.
#   order: "desc" (newest first, default) or "asc"
# ---------------------------------------------------------------------------
sort_entries <- function(entries, order = "desc") {
  # Primary sort key: DA (YYYY/MM//), fall back to PY
  key <- function(e) {
    da <- e[["DA"]] %||% paste0(e[["PY"]], "/00//")
    # Convert "YYYY/MM//" → sortable integer YYYYMM
    parts <- strsplit(da, "/")[[1]]
    yr <- as.integer(parts[1])
    mo <- suppressWarnings(as.integer(parts[2]))
    mo <- ifelse(is.na(mo), 0L, mo)
    yr * 100L + mo
  }
  keys <- sapply(entries, key)
  entries[order(keys, decreasing = (order == "desc"))]
}

# Null-coalescing helper (like %||% in rlang)
`%||%` <- function(a, b) if (!is.null(a)) a else b

# ---------------------------------------------------------------------------
# format_entry_cv()
# Format a single entry in traditional CV / invited-talks style:
#   Role, "Title." Institution (Location, Month Year)[. Notes].
# ---------------------------------------------------------------------------
format_entry_cv <- function(entry) {
  role  <- entry[["N2"]] %||% ""
  title <- entry[["TI"]] %||% "(untitled)"
  inst  <- entry[["PB"]] %||% ""
  loc   <- entry[["CY"]] %||% ""
  month <- entry[["N1"]] %||% ""
  year  <- entry[["PY"]] %||% ""
  notes <- entry[["M1"]] %||% ""
  ctx   <- entry[["M2"]] %||% ""   # extra context (co-panelists, etc.)

  # Build location/date string
  loc_date <- paste0(
    if (nzchar(loc) && nzchar(month)) paste0(loc, ", ", month)
    else if (nzchar(loc)) loc
    else month,
    if (nzchar(year)) paste0(" ", year) else ""
  )

  # Notes string: context then compensation
  note_parts <- c(
    if (nzchar(ctx))   ctx   else NULL,
    if (nzchar(notes)) notes else NULL
  )
  note_str <- if (length(note_parts)) paste0(". ", paste(note_parts, collapse = "; ")) else ""

  # Assemble
  paste0(
    if (nzchar(role)) paste0(role, ", ") else "",
    "\u201c", title, ".\u201d ",
    if (nzchar(inst)) paste0(inst, " ") else "",
    if (nzchar(loc_date)) paste0("(", loc_date, ")") else "",
    note_str,
    "."
  )
}

# ---------------------------------------------------------------------------
# format_entry_cpaper()
# Format a single CPAPER entry in CV style:
#   Role, "Title." Conference Name (Location, Month Year)[. Notes].
# ---------------------------------------------------------------------------
format_entry_cpaper <- function(entry) {
  role  <- entry[["N2"]] %||% ""
  title <- entry[["TI"]] %||% "(untitled)"
  conf  <- entry[["T2"]] %||% entry[["PB"]] %||% ""
  loc   <- entry[["CY"]] %||% ""
  month <- entry[["N1"]] %||% ""
  year  <- entry[["PY"]] %||% ""
  notes <- entry[["M1"]] %||% ""
  ctx   <- entry[["M2"]] %||% ""

  loc_date <- paste0(
    if (nzchar(loc) && nzchar(month)) paste0(loc, ", ", month)
    else if (nzchar(loc)) loc
    else month,
    if (nzchar(year)) paste0(" ", year) else ""
  )

  note_parts <- c(
    if (nzchar(ctx))   ctx   else NULL,
    if (nzchar(notes)) notes else NULL
  )
  note_str <- if (length(note_parts)) paste0(". ", paste(note_parts, collapse = "; ")) else ""

  paste0(
    if (nzchar(role)) paste0(role, ", ") else "",
    "\u201c", title, ".\u201d ",
    if (nzchar(conf)) paste0(conf, " ") else "",
    if (nzchar(loc_date)) paste0("(", loc_date, ")") else "",
    note_str,
    "."
  )
}

# ---------------------------------------------------------------------------
# render_talks_list()
# Read one or more RIS files and return a markdown string (or named list).
#
# Arguments:
#   ris_files         path (or character vector of paths) to .ris file(s)
#   format            "ul"       – bulleted list (default)
#                     "ol"       – numbered list
#                     "cv_year"  – items grouped under bold year headers
#                     "table"    – markdown table (Year | Talk)
#   sort              "desc" (newest first) or "asc"
#   min_year          integer; if set, only entries with PY >= min_year
#                     are included (e.g. min_year = 2023 for recent talks)
#   formatter         function(entry) → character(1) for invited talks
#                     (GEN / SLIDE); defaults to format_entry_cv
#   cpaper_formatter  function(entry) → character(1) for CPAPER entries;
#                     defaults to format_entry_cpaper
#   include_cpaper    TRUE  (default) – CPAPER entries are interleaved into
#                             the same list as invited talks, using
#                             cpaper_formatter for their formatting.
#                     FALSE – CPAPER entries are rendered into a *separate*
#                             list. The function returns a named list:
#                               $talks  – markdown for invited talks
#                               $papers – markdown for conference papers
# ---------------------------------------------------------------------------
render_talks_list <- function(
    ris_files,
    format           = "cv_year",
    sort             = "desc",
    min_year         = NULL,
    formatter        = format_entry_cv,
    cpaper_formatter = format_entry_cpaper,
    include_cpaper   = TRUE
) {
  entries <- do.call(c, lapply(ris_files, parse_ris))
  entries <- sort_entries(entries, order = sort)

  if (!is.null(min_year)) {
    entries <- Filter(function(e) {
      yr <- suppressWarnings(as.integer(e[["PY"]] %||% "0"))
      !is.na(yr) && yr >= min_year
    }, entries)
  }

  is_cpaper <- vapply(entries, function(e) identical(e[["TY"]], "CPAPER"), logical(1))

  # Helper: pick the right formatter per entry
  dispatch_formatter <- function(e) {
    if (identical(e[["TY"]], "CPAPER")) cpaper_formatter(e) else formatter(e)
  }

  render_one_list <- function(ents) {
    if (format == "ul") {
      lines <- vapply(ents, function(e) paste0("- ", dispatch_formatter(e)), character(1))
      return(paste(lines, collapse = "\n"))
    }
    if (format == "ol") {
      lines <- vapply(seq_along(ents), function(i) {
        paste0(i, ". ", dispatch_formatter(ents[[i]]))
      }, character(1))
      return(paste(lines, collapse = "\n"))
    }
    if (format == "cv_year") {
      years <- vapply(ents, function(e) e[["PY"]] %||% "n.d.", character(1))
      unique_years <- unique(years)
      chunks <- vapply(unique_years, function(yr) {
        yr_entries <- ents[years == yr]
        items <- vapply(yr_entries, function(e) paste0("- ", dispatch_formatter(e)), character(1))
        paste0("**", yr, "**\n\n", paste(items, collapse = "\n"))
      }, character(1))
      return(paste(chunks, collapse = "\n\n"))
    }
    if (format == "table") {
      header <- "| Year | Talk |\n|------|------|\n"
      rows <- vapply(ents, function(e) {
        yr   <- e[["PY"]] %||% "n.d."
        text <- dispatch_formatter(e)
        paste0("| ", yr, " | ", text, " |")
      }, character(1))
      return(paste0(header, paste(rows, collapse = "\n")))
    }
    stop("Unknown format: ", format,
         ". Use 'ul', 'ol', 'cv_year', or 'table'.")
  }

  if (include_cpaper) {
    # All entries in one list
    render_one_list(entries)
  } else {
    # Two separate lists
    list(
      talks  = render_one_list(entries[!is_cpaper]),
      papers = render_one_list(entries[is_cpaper])
    )
  }
}
