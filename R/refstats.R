#' Summarize Referee Stats from Raw Game Data
#'
#' This function computes summary statistics for each referee, including total
#' fouls called, number of games officiated, fouls on a specific team, fouls on
#' opponents, and the foul ratio. It is built to work on raw play-by-play data
#' where referees are listed in a single string column.
#'
#' @param data A data frame containing play-by-play or foul event data.
#' @param ref_col Column name containing referee names (separated by "/").
#' @param foul_col Column name indicating whether the row is a foul
#'   (TRUE/FALSE).
#' @param game_id_col Column name for unique game identifiers.
#' @param home_col Column name indicating the home team.
#' @param action_team_col Column name indicating if the actioning team was
#'   "home" or "away".
#' @param team_name (Optional) The name of the team you want foul comparison
#'   stats for.
#'
#' @return A data frame summarizing referee stats, including fouls called,
#'   games worked, fouls on the selected team and opponent, foul ratio, and
#'   fouls per game.
#' @export
#'
#' @examples
#' data(usu_data)
#' refstats(usu_data, team_name = "Utah State")
refstats <- function(data,
                     ref_col = "referees",
                     foul_col = "foul",
                     game_id_col = "game_id",
                     home_col = "home",
                     action_team_col = "action_team",
                     team_name = NULL) {
  long_data <- split_refs(data, ref_col)

  foul_counts <- count_total_fouls(long_data, foul_col)
  game_counts <- count_games_worked(long_data, game_id_col)

  if (!is.null(team_name)) {
    foul_details <- count_team_fouls(long_data, foul_col, home_col,
                                     action_team_col, team_name)
  } else {
    foul_details <- tibble::tibble(
      referee = character(),
      fouls_on_team = integer(),
      fouls_on_opponent = integer(),
      fouls_ratio = numeric()
    )
  }

  dplyr::full_join(foul_counts, game_counts, by = "referee") |>
    dplyr::full_join(foul_details, by = "referee") |>
    tidyr::replace_na(list(
      fouls_called = 0,
      games_worked = 0,
      fouls_on_team = 0,
      fouls_on_opponent = 0,
      fouls_ratio = NA
    )) |>
    dplyr::mutate(
      fouls_per_game = dplyr::if_else(games_worked == 0, NA_real_,
        fouls_called / games_worked
      )
    ) |>
    dplyr::arrange(dplyr::desc(fouls_ratio))
}

#' Split Referees into Individual Rows
#'
#' Helper function to split referees listed as a single string into individual
#'   rows.
#'
#' @param data A data frame with a referee column.
#' @param ref_col The name of the referee column (default is "referees").
#'
#' @return A data frame with one row per referee per play.

split_refs <- function(data, ref_col = "referees") {
  dplyr::mutate(data,
    RefereesList = stringr::str_split(.data[[ref_col]], "/\\s*")
  ) |>
    tidyr::unnest(RefereesList) |>
    dplyr::rename(referee = RefereesList)
}

#' Count Total Fouls Called by Referees
#'
#' Helper function to count total fouls per referee.
#'
#' @param data A long-format data frame with a `referee` column.
#' @param foul_col The name of the foul indicator column (default is "foul").
#'
#' @return A data frame with referee and foul count.

count_total_fouls <- function(data, foul_col = "foul") {
  data |>
    dplyr::filter(.data[[foul_col]] == TRUE) |>
    dplyr::count(referee, name = "fouls_called")
}

#' Count Games Officiated by Referees
#'
#' Helper function to count unique games worked per referee.
#'
#' @param data A long-format data frame with a `referee` column.
#' @param game_id_col The column name for unique game IDs.
#'
#' @return A data frame with referee and number of games worked.

count_games_worked <- function(data, game_id_col = "game_id") {
  data |>
    dplyr::distinct(.data[[game_id_col]], referee) |>
    dplyr::count(referee, name = "games_worked")
}

#' Count team-specific fouls per referee
#'
#' Helper function to calculate how many fouls each referee called against a
#'   specified team and against the opposing team, along with the foul ratio.
#'
#' @param data Long-format data with one referee per row.
#' @param foul_col Column name indicating if the action was a foul.
#' @param home_col Column name for the home team name.
#' @param action_team_col Column name indicating whether the action was by
#'   "home" or "away".
#' @param team_name Name of the team to analyze (e.g., "Utah State").
#'
#' @return A data frame with referee, fouls_on_team, fouls_on_opponent, and
#'   fouls_ratio.


count_team_fouls <- function(data,
                             foul_col = "foul",
                             home_col = "home",
                             action_team_col = "action_team",
                             team_name) {
  data |>
    dplyr::mutate(is_home_team = .data[[home_col]] == team_name) |>
    dplyr::filter(.data[[foul_col]] == TRUE) |>
    dplyr::mutate(
      foul_on_team = (is_home_team & .data[[action_team_col]] == "home") |
        (!is_home_team & .data[[action_team_col]] == "away"),
      foul_on_opponent = (is_home_team & .data[[action_team_col]] == "away") |
        (!is_home_team & .data[[action_team_col]] == "home")
    ) |>
    dplyr::group_by(referee) |>
    dplyr::summarise(
      fouls_on_team = sum(foul_on_team, na.rm = TRUE),
      fouls_on_opponent = sum(foul_on_opponent, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      fouls_ratio = dplyr::if_else(fouls_on_opponent == 0, NA_real_,
        fouls_on_team / fouls_on_opponent
      )
    )
}
