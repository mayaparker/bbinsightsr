#' Plot Game Trends by Segment
#'
#' Plots a selected statistic (e.g., points, fouls, turnovers) for a single game between two teams,
#' segmented by timeouts, halves, or a user-specified number of breaks.
#'
#' @param games A data frame of play-by-play data for one or more games.
#' @param home_team A string giving the home team's full name.
#' @param away_team A string giving the away team's full name.
#' @param game_break A string indicating the segmentation method. One of `"timeout"`, `"half"`, or `"num_breaks"`.
#' @param stat The statistic to plot. One of:
#'   \code{"points"}, \code{"fouls"}, \code{"assists"}, \code{"shots_made"},
#'   \code{"shots_total"}, \code{"threes_made"}, \code{"threes_total"},
#'   \code{"turnovers"}, \code{"steals"}, \code{"offensive_rebounds"},
#'   \code{"defensive_rebounds"}, \code{"rebounds"},
#'   \code{"fg_made"}, \code{"3pt_made"}, \code{"fg_attempts"}, \code{"3pt_attempts"}.
#' @param num_breaks (Optional) Integer. Required only if `game_break = "num_breaks"`. Specifies how many evenly spaced segments to create.
#' @param game_date (Optional) A string (format: `"YYYY-MM-DD"`) to identify a specific game when multiple matchups exist between the teams.
#'
#' @return A \link[ggplot2]{ggplot} object showing the chosen stat by segment.
#'
#' @export
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
    game_date  = NULL
) {
  game_break <- match.arg(game_break)
  stat       <- match.arg(stat)

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
