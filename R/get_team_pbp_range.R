#' Pull play-by-play data for a team across multiple seasons
#'
#' This helper wraps `ncaahoopR::get_pbp()` to collect multiple seasons of data for a single team.
#' It allows flexible season inputs and provides clean console feedback.
#'
#' @param team Character. Team name (e.g., "Utah State").
#' @param start_year Integer (optional). Start of range, e.g., 2020 for 2020-21.
#' @param end_year Integer (optional). End of range, e.g., 2023 for 2023-24.
#' @param seasons Optional vector of season inputs like 2021, "2020-2021", or "22".
#'
#' @return A data frame combining play-by-play data for the given team and seasons.
get_team_pbp_range <- function(team,
                               start_year = NULL,
                               end_year = NULL,
                               seasons = NULL) {
  if (!requireNamespace("ncaahoopR", quietly = TRUE)) {
    stop("The 'ncaahoopR' package is required for this function.")
  }

  # --- Helper to convert season formats ---
  parse_season_inputs <- function(season_input) {
    parsed <- character(0)
    assumed <- character(0)

    for (s in season_input) {
      s <- trimws(as.character(s))

      if (grepl("^\\d{4}$", s)) {
        # e.g., 2022 to "2022-23"
        s_num <- as.numeric(s)
        parsed <- c(parsed, paste0(s, "-", substr(s_num + 1, 3, 4)))
      } else if (grepl("^\\d{4}-\\d{4}$", s)) {
        # e.g., "2020-2021" to "2020-21"
        start <- substr(s, 1, 4)
        end <- substr(s, 9, 10)
        parsed <- c(parsed, paste0(start, "-", end))
      } else if (grepl("^\\d{2}$", s)) {
        # e.g., "21" to "2021-22"
        assumed <- c(assumed, s)
        parsed <- c(parsed, paste0("20", s, "-", formatC(as.numeric(s) + 1, width = 2, flag = "0")))
      } else if (grepl("^\\d{4}-\\d{2}$", s)) {
        # e.g., already in "2020-21" format
        parsed <- c(parsed, s)
      } else {
        stop("Unrecognized season format: ", s)
      }
    }

    return(list(parsed = parsed, assumed = assumed))
  }

  # --- Build season list ---
  if (!is.null(start_year) && !is.null(end_year)) {
    if (!is.numeric(start_year) || !is.numeric(end_year) || start_year > end_year) {
      stop("Please provide valid numeric start and end years.")
    }
    raw_seasons <- start_year:end_year
  } else if (!is.null(seasons)) {
    raw_seasons <- seasons
  } else {
    stop("You must supply either start_year and end_year, or a vector of seasons.")
  }

  # --- Parse seasons and confirm with user ---
  parsed_result <- parse_season_inputs(raw_seasons)
  parsed_seasons <- parsed_result$parsed
  assumed_inputs <- parsed_result$assumed

  message("Assuming the following seasons:")
  for (s in parsed_seasons) message("- ", s)

  confirm <- readline("Proceed with these seasons? [y/n]: ")
  if (tolower(confirm) != "y") stop("Aborted by user.")

  if (length(assumed_inputs) > 0) {
    warning("Shorthand inputs assumed: ", paste(assumed_inputs, collapse = ", "))
  }

  # --- Pull and combine PBP data ---
  all_data <- purrr::map_dfr(parsed_seasons, function(season) {
    message("\nScraping data for season: ", season)
    result <- tryCatch({
      df <- invisible(utils::capture.output(ncaahoopR::get_pbp(team, season)))
      message(season, " added to data frame")
      df
    }, error = function(e) {
      warning("Failed to pull ", season, ": ", e$message)
      NULL
    })
    result
  })

  message("\n Process completed.")
  return(all_data)
}
