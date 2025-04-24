utils::globalVariables("dictionary")
#' Plot Game Trends by Segment
#'
#' Plots a selected statistic (e.g., points, fouls, turnovers) for a single game
#'  between two teams, segmented by timeouts, halves, or a user-specified number
#'   of breaks.
#'
#' @param games A data frame of play-by-play data for one or more games.
#' @param home_team A string giving the home team's full name.
#'   Must match a name in the `dictionary` dataset
#'   (columns: NCAA, ESPN, ESPN_PBP, short_name).
#' @param away_team A string giving the away team's full name.
#'   Must match a name in the `dictionary` dataset
#'   (columns: NCAA, ESPN, ESPN_PBP, short_name).
#' @param game_break A string indicating the segmentation method. One of
#'   `"timeout"`, `"half"`, or `"num_breaks"`.
#' @param stat The statistic to plot. One of:
#'   \code{"points"}, \code{"fouls"}, \code{"assists"}, \code{"shots_made"},
#'   \code{"shots_total"}, \code{"threes_made"}, \code{"threes_total"},
#'   \code{"turnovers"}, \code{"steals"}, \code{"offensive_rebounds"},
#'   \code{"defensive_rebounds"}, \code{"rebounds"},
#'   \code{"fg_made"}, \code{"3pt_made"}, \code{"fg_attempts"},
#'   \code{"3pt_attempts"}.
#' @param num_breaks (Optional) Integer. Required only if
#'   `game_break = "num_breaks"`. Specifies how many evenly spaced segments to
#'   create.
#' @param game_date (Optional) A string (format: `"YYYY-MM-DD"`) to identify a
#'   specific game when multiple matchups exist between the teams.
#'
#' @return A \link[ggplot2]{ggplot} object showing the chosen stat by segment.
#'
#' @importFrom tools toTitleCase
#' @importFrom ggplot2 ggtitle
#'
#' @examples
#' # Example 1: Plot with specific game date
#' plot_game_trends(
#'   games      = usu_data,
#'   home_team  = "Utah State",
#'   away_team  = "Wyoming",
#'   game_break = "timeout",
#'   stat       = "points",
#'   game_date  = "2023-01-10"
#' )
#'
#' # Example 2: Plot without date (user selects game if multiple exist)
#' \dontrun{
#' plot_game_trends(
#'   games      = usu_data,
#'   home_team  = "Utah State",
#'   away_team  = "Nevada",
#'   game_break = "half",
#'   stat       = "rebounds"
#' )
#' }
#'
#' @export
plot_game_trends <- function(
    games,
    home_team,
    away_team,
    game_break = c("timeout", "half", "num_breaks"),
    stat = c(
      "points", "fouls", "assists", "shots_made", "shots_total",
      "threes_made", "threes_total", "turnovers", "steals",
      "offensive_rebounds", "defensive_rebounds", "rebounds",
      "fg_made", "3pt_made", "fg_attempts", "3pt_attempts"
    ),
    num_breaks = NULL,
    game_date = NULL) {
  game_break <- match.arg(game_break)
  stat <- match.arg(stat)

  # Helper to map input to official ESPN name
  resolve_team_name <- function(input_name) {
    match_row <- dictionary[
      apply(dictionary, 1, function(row) input_name %in% row),
    ]
    if (nrow(match_row) == 0) {
      stop(
        glue::glue(
          "Team '{input_name}' not recognized. Please use a known name from one
          of these columns in `dictionary`:\n",
          "  - NCAA\n  - ESPN\n  - ESPN_PBP\n  - short_name\n\n",
          "You can run `View(dictionary)` to explore valid team names."
        )
      )
    }
    match_row$ESPN[1]
  }

  # Resolve input team names to ESPN standard
  home_team <- resolve_team_name(home_team)
  away_team <- resolve_team_name(away_team)

  # Normalize team names in the dataset by replacing any match with ESPN name
  for (col in c("home", "away", "action_team", "shot_team",
                "possession_before", "possession_after")) {
    if (col %in% colnames(games)) {
      for (i in seq_len(nrow(dictionary))) {
        row_vals <- unlist(dictionary[i, c("NCAA", "ESPN", "ESPN_PBP", "short_name")])
        espn_name <- dictionary$ESPN[i]
        games[[col]][games[[col]] %in% row_vals] <- espn_name
      }
    }
  }



  selected_game <- select_single_game(
    data      = games,
    team      = home_team,
    opponent  = away_team,
    game_date = game_date
  )

  segmented_game <- assign_game_breaks(
    game_data  = selected_game,
    segment_by = game_break,
    num_breaks = num_breaks
  )

  summary_data <- summarize_segmented_data(
    segmented_game = segmented_game,
    stat           = stat
  )

  break_label <- if (game_break == "num_breaks" && !is.null(num_breaks)) {
    paste0(num_breaks, " Time Segments")
  } else {
    tools::toTitleCase(game_break)
  }

  game_day <- unique(selected_game$date)
  if (length(game_day) > 1) game_day <- game_day[1]

  title_text <- paste0(
    tools::toTitleCase(stat), " by ", break_label, " for ",
    home_team, " vs ", away_team,
    " on ", format(as.Date(game_day), "%B %d, %Y")
  )

  plot_stat_by_segment(summary_data) +
    ggplot2::ggtitle(title_text)
}
