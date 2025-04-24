abbreviate_game_break_labels <- function(summary_data, dictionary, ids) {
  # Step 1: Pull team names to use for abbreviation lookup
  home_team <- trimws(unique(summary_data$home)[1])
  away_team <- trimws(unique(summary_data$away)[1])

  # Step 2: Match to ESPN standard name using dictionary
  get_espn_name <- function(team_name) {
    match_row <- dictionary[
      apply(dictionary, 1, function(row) team_name %in% row),
    ]
    if (nrow(match_row) > 0) {
      return(match_row$ESPN[1])
    } else {
      stop(glue::glue("Could not resolve '{team_name}' to an ESPN name. Check spelling or dictionary entries."))
    }
  }


  espn_home <- get_espn_name(home_team)
  espn_away <- get_espn_name(away_team)

  # Step 3: Match to abbreviation in ids
  get_abbreviation <- function(espn_name) {
    match_row <- ids[ids$team == espn_name, ]
    if (nrow(match_row) > 0 && !is.na(match_row$espn_abbrv[1])) {
      return(match_row$espn_abbrv[1])
    }
    return(espn_name)  # fallback
  }

  abbr_home <- get_abbreviation(espn_home)
  abbr_away <- get_abbreviation(espn_away)

  # Step 4: Create new label column (leaving original untouched)
  summary_data$game_break_label_abbreviated <- summary_data$game_break_label |>
    stringr::str_replace_all(fixed(home_team), abbr_home) |>
    stringr::str_replace_all(fixed(away_team), abbr_away) |>
    stringr::str_replace_all("Official TV Timeout", "TV Timeout") |>
    stringr::str_replace_all("Timeout", "T.O.") |>
    stringr::str_squish()



  return(summary_data)
}
