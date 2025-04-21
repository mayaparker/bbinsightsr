#' Summarize a Segmented Game into One Tidy Table of Stats
#'
#' Takes a play-by-play data frame that has been run through
#' `assign_game_breaks()`, splits it into segments, computes a stat for each
#' segment and team, and returns
#' the ready-to-plot summary.
#'
#' This function is intended for internal use only and is not exported.
#'
#' @param segmented_game A data frame of a single game's play-by-play data,
#'   with columns `segment_id`, `game_break`, and `game_break_label`
#'   as added by `assign_game_breaks()`.
#' @param stat A character string indicating which stat to compute. Options
#'   include:
#'   \itemize{
#'     \item `"points"`, `"fouls"`, `"assists"`, `"turnovers"`, `"steals"`
#'     \item `"offensive_rebounds"`, `"defensive_rebounds"`, `"rebounds"`
#'     \item `"fg_made"`, `"3pt_made"`, `"fg_attempts"`, `"3pt_attempts"`
#'   }
#'
#' @return A data frame with one row per segment, containing:
#'   \item{`game_id`, `date`, `home`, `away`}{Basic game identifiers.}
#'   \item{`segment_id`, `game_break`, `game_break_label`}{
#'     Segment and label info.
#'   }
#'   \item{`home_stat`, `away_stat`}{Values of the chosen stat for each team.}
#'   \item{`stat`}{The name of the stat that was computed.}
#'
#' @keywords internal
summarize_segmented_data <- function(segmented_game, stat = "points") {
  # split into list of chunks
  chunks <- split(segmented_game, segmented_game$segment_id)

  # for each chunk, compute home/away stat
  stats_list <- lapply(chunks, calculate_stats_for_segment, stat = stat)

  # bind back together
  summary_df <- do.call(rbind, stats_list)
  rownames(summary_df) <- NULL

  return(summary_df)
}
