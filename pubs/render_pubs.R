# render_pubs.R
# Parse pubs/pubs.ris and render entries as markdown.
#
# RIS field conventions used in pubs.ris:
#
# Journal articles (TY = JOUR):
#   TY  type (JOUR)
#   ID  unique key
#   AU  author(s)
#   TI  article title
#   T2  journal name
#   PY  year (YYYY)
#   DA  date (YYYY/MM//)
#   VL  volume
#   IS  issue
#   SP  start page
#   EP  end page
#   DO  DOI
#   UR  URL
#   N1  month (display name, e.g. "June")
#   N2  additional notes (e.g. "open access", "peer reviewed")
#   AB  abstract
#   ER  end of record
#
# Book chapters (TY = CHAP):
#   TY  type (CHAP)
#   ID  unique key
#   AU  author(s)
#   TI  chapter title
#   T2  book title
#   T3  series name (optional)
#   PY  year (YYYY)
#   DA  date (YYYY/MM//)
#   A2  editor(s)
#   PB  publisher
#   CY  city of publication
#   SP  start page
#   EP  end page
#   DO  DOI
#   UR  URL
#   N1  month (display name)
#   N2  additional notes
#   AB  abstract
#   ER  end of record
#
# Books (TY = BOOK):
#   TY  type (BOOK)
#   ID  unique key
#   AU  author(s)
#   TI  book title
#   PY  year (YYYY)
#   DA  date (YYYY/MM//)
#   PB  publisher
#   CY  city of publication
#   DO  DOI
#   UR  URL
#   N1  month (display name)
#   N2  additional notes
#   AB  abstract
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
# format_authors()
# Format author list: "Last, F." style, Oxford comma for 3+.
# ---------------------------------------------------------------------------
format_authors <- function(au_vec) {
  if (is.null(au_vec) || length(au_vec) == 0L) return("")
  n <- length(au_vec)
  if (n == 1L) return(au_vec[1L])
  if (n == 2L) return(paste(au_vec, collapse = " and "))
  paste0(paste(au_vec[-n], collapse = ", "), ", and ", au_vec[n])
}

# ---------------------------------------------------------------------------
# format_entry_jour()
# Format a single JOUR entry in CV / bibliography style:
#   Author(s). "Title." *Journal* Volume, no. Issue (Year): Pages. DOI.
# ---------------------------------------------------------------------------
format_entry_jour <- function(entry) {
  authors <- format_authors(entry[["AU"]])
  title   <- entry[["TI"]] %||% "(untitled)"
  journal <- entry[["T2"]] %||% ""
  year    <- entry[["PY"]] %||% ""
  vol     <- entry[["VL"]] %||% ""
  iss     <- entry[["IS"]] %||% ""
  sp      <- entry[["SP"]] %||% ""
  ep      <- entry[["EP"]] %||% ""
  doi     <- entry[["DO"]] %||% ""
  url     <- entry[["UR"]] %||% ""
  notes   <- entry[["N2"]] %||% ""

  # Pages string
  pages <- if (nzchar(sp) && nzchar(ep)) paste0(sp, "\u2013", ep)
            else if (nzchar(sp)) sp
            else ""

  # Volume/issue string
  vol_iss <- if (nzchar(vol) && nzchar(iss)) paste0(vol, ", no.\u00a0", iss)
              else if (nzchar(vol)) vol
              else ""

  # Year + pages in parentheses
  year_pages <- paste0(
    if (nzchar(year)) paste0("(", year, ")") else "",
    if (nzchar(pages)) paste0(": ", pages) else ""
  )

  # Link: prefer DOI, fall back to URL
  link <- if (nzchar(doi))  paste0("https://doi.org/", doi)
           else if (nzchar(url)) url
           else ""

  # Assemble
  out <- paste0(
    if (nzchar(authors)) paste0(authors, ". ") else "",
    "\u201c", title, ".\u201d ",
    if (nzchar(journal)) paste0("*", journal, "*") else "",
    if (nzchar(vol_iss)) paste0(" ", vol_iss) else "",
    if (nzchar(year_pages)) paste0(" ", year_pages) else "",
    ".",
    if (nzchar(link))  paste0(" <", link, ">") else "",
    if (nzchar(notes)) paste0(" [", notes, "]") else ""
  )
  out
}

# ---------------------------------------------------------------------------
# format_entry_chap()
# Format a single CHAP entry:
#   Author(s). "Chapter Title." In *Book Title*, edited by Editor(s), Pages.
#   City: Publisher, Year. DOI.
# ---------------------------------------------------------------------------
format_entry_chap <- function(entry) {
  authors <- format_authors(entry[["AU"]])
  title   <- entry[["TI"]] %||% "(untitled)"
  book    <- entry[["T2"]] %||% ""
  editors <- format_authors(entry[["A2"]])
  pub     <- entry[["PB"]] %||% ""
  city    <- entry[["CY"]] %||% ""
  year    <- entry[["PY"]] %||% ""
  sp      <- entry[["SP"]] %||% ""
  ep      <- entry[["EP"]] %||% ""
  doi     <- entry[["DO"]] %||% ""
  url     <- entry[["UR"]] %||% ""
  notes   <- entry[["N2"]] %||% ""

  pages <- if (nzchar(sp) && nzchar(ep)) paste0(sp, "\u2013", ep)
            else if (nzchar(sp)) sp
            else ""

  link <- if (nzchar(doi))  paste0("https://doi.org/", doi)
           else if (nzchar(url)) url
           else ""

  pub_place <- paste0(
    if (nzchar(city)) paste0(city, ": ") else "",
    pub
  )

  out <- paste0(
    if (nzchar(authors)) paste0(authors, ". ") else "",
    "\u201c", title, ".\u201d ",
    if (nzchar(book)) paste0("In *", book, "*") else "",
    if (nzchar(editors)) paste0(", edited by ", editors) else "",
    if (nzchar(pages)) paste0(", ", pages) else "",
    ".",
    if (nzchar(pub_place)) paste0(" ", pub_place, ",") else "",
    if (nzchar(year)) paste0(" ", year) else "",
    ".",
    if (nzchar(link)) paste0(" <", link, ">") else "",
    if (nzchar(notes)) paste0(" [", notes, "]") else ""
  )
  out
}

# ---------------------------------------------------------------------------
# format_entry_book()
# Format a single BOOK entry:
#   Author(s). *Title*. City: Publisher, Year. DOI.
# ---------------------------------------------------------------------------
format_entry_book <- function(entry) {
  authors <- format_authors(entry[["AU"]])
  title   <- entry[["TI"]] %||% "(untitled)"
  pub     <- entry[["PB"]] %||% ""
  city    <- entry[["CY"]] %||% ""
  year    <- entry[["PY"]] %||% ""
  doi     <- entry[["DO"]] %||% ""
  url     <- entry[["UR"]] %||% ""
  notes   <- entry[["N2"]] %||% ""

  link <- if (nzchar(doi))  paste0("https://doi.org/", doi)
           else if (nzchar(url)) url
           else ""

  pub_place <- paste0(
    if (nzchar(city)) paste0(city, ": ") else "",
    pub
  )

  out <- paste0(
    if (nzchar(authors)) paste0(authors, ". ") else "",
    "*", title, "*.",
    if (nzchar(pub_place)) paste0(" ", pub_place, ",") else "",
    if (nzchar(year)) paste0(" ", year) else "",
    ".",
    if (nzchar(link)) paste0(" <", link, ">") else "",
    if (nzchar(notes)) paste0(" [", notes, "]") else ""
  )
  out
}

# ---------------------------------------------------------------------------
# render_pubs_list()
# Read one or more RIS files and return a markdown string.
#
# Arguments:
#   ris_files   path (or character vector of paths) to .ris file(s)
#   format      "ul"       – bulleted list (default)
#               "ol"       – numbered list
#               "cv_year"  – items grouped under bold year headers
#               "table"    – markdown table (Year | Citation)
#   sort        "desc" (newest first) or "asc"
#   min_year    integer; if set, only entries with PY >= min_year are included
#   types       character vector of TY values to include; NULL means all types
# ---------------------------------------------------------------------------
render_pubs_list <- function(
    ris_files,
    format   = "cv_year",
    sort     = "desc",
    min_year = NULL,
    types    = NULL
) {
  entries <- do.call(c, lapply(ris_files, parse_ris))
  entries <- sort_entries(entries, order = sort)

  if (!is.null(min_year)) {
    entries <- Filter(function(e) {
      yr <- suppressWarnings(as.integer(e[["PY"]] %||% "0"))
      !is.na(yr) && yr >= min_year
    }, entries)
  }

  if (!is.null(types)) {
    entries <- Filter(function(e) e[["TY"]] %||% "" %in% types, entries)
  }

  dispatch_formatter <- function(e) {
    ty <- e[["TY"]] %||% ""
    if (ty == "JOUR") return(format_entry_jour(e))
    if (ty == "CHAP") return(format_entry_chap(e))
    if (ty == "BOOK") return(format_entry_book(e))
    # Fallback: treat like JOUR
    format_entry_jour(e)
  }

  render_one_list <- function(ents) {
    if (length(ents) == 0L) return("")

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
      header <- "| Year | Publication |\n|------|-------------|\n"
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

  render_one_list(entries)
}
