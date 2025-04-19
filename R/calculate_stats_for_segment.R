#' Summarize One Segment's Stat into a Single Row (Internal)
#'
#' Given all the rows for one game segment, compute the chosen stat for both teams
#' and extract key metadata for plotting.
#'
#' This helper function is intended for internal use only and is not exported.
#'
#' @param chunk A data frame of all plays in a single segment. Must include `game_id`, `date`,
#'   `home`, `away`, `segment_id`, and have `game_break` and `game_break_label` on its final row.
#' @param stat A character string indicating which stat to summarize. Options include:
#'   \itemize{
#'     \item `"points"`: Points scored, based on score difference.
#'     \item `"fouls"`, `"assists"`, `"turnovers"`, `"steals"`
#'     \item `"offensive_rebounds"`, `"defensive_rebounds"`, `"rebounds"`
#'     \item `"fg_made"`, `"fg_attempts"`, `"3pt_made"`, `"3pt_attempts"`
#'   }
#'
#' @return A one-row data frame containing:
#'   \item{`game_id`, `date`, `home`, `away`, `segment_id`}{Basic game identifiers.}
#'   \item{`game_break`, `game_break_label`}{Break indicators and labels for plotting.}
#'   \item{`home_stat`, `away_stat`}{Calculated stat for each team.}
#'   \item{`stat`}{The name of the stat that was computed.}
#'
#' @keywords internal
calculate_stats_for_segment <- function(chunk, stat) {
  # 1) pull out invariant metadata
  game_id <- chunk$game_id[1]
  date    <- chunk$date[1]
  home    <- chunk$home[1]
  away    <- chunk$away[1]
  seg_id  <- chunk$segment_id[1]
  
  # 2) grab break info from the last row
  last_row <- chunk[nrow(chunk), ]
  game_break       <- last_row$game_break
  game_break_label <- last_row$game_break_label
  
  # 3) compute the two team stats
  vals <- switch(stat,
                 "points" = {
                   first_row <- chunk[1, ]
                   last_row2 <- chunk[nrow(chunk), ]
                   c(home = last_row2$home_score  - first_row$home_score,
                     away = last_row2$away_score  - first_row$away_score)
                 },
                 "fouls" = {
                   c(home = sum(chunk$foul & chunk$action_team == "home", na.rm=TRUE),
                     away = sum(chunk$foul & chunk$action_team == "away", na.rm=TRUE))
                 },
                 "assists" = {
                   c(home = sum(!is.na(chunk$assist) & chunk$action_team == "home", na.rm=TRUE),
                     away = sum(!is.na(chunk$assist) & chunk$action_team == "away", na.rm=TRUE))
                 },
                 "turnovers" = {
                   c(home = sum(grepl("turnover", tolower(chunk$description)) & chunk$action_team=="home", na.rm=TRUE),
                     away = sum(grepl("turnover", tolower(chunk$description)) & chunk$action_team=="away", na.rm=TRUE))
                 },
                 "steals" = {
                   c(home = sum(grepl("steal", tolower(chunk$description)) & chunk$action_team=="home", na.rm=TRUE),
                     away = sum(grepl("steal", tolower(chunk$description)) & chunk$action_team=="away", na.rm=TRUE))
                 },
                 "offensive_rebounds" = {
                   c(home = sum(grepl("offensive rebound", tolower(chunk$description)) & chunk$action_team=="home", na.rm=TRUE),
                     away = sum(grepl("offensive rebound", tolower(chunk$description)) & chunk$action_team=="away", na.rm=TRUE))
                 },
                 "defensive_rebounds" = {
                   c(home = sum(grepl("defensive rebound", tolower(chunk$description)) & chunk$action_team=="home", na.rm=TRUE),
                     away = sum(grepl("defensive rebound", tolower(chunk$description)) & chunk$action_team=="away", na.rm=TRUE))
                 },
                 "rebounds" = {
                   c(home = sum(grepl("rebound", tolower(chunk$description)) & chunk$action_team=="home", na.rm=TRUE),
                     away = sum(grepl("rebound", tolower(chunk$description)) & chunk$action_team=="away", na.rm=TRUE))
                 },
                 "fg_made" = {
                   c(home = sum(chunk$shot_outcome=="made" & !chunk$free_throw & chunk$action_team=="home", na.rm=TRUE),
                     away = sum(chunk$shot_outcome=="made" & !chunk$free_throw & chunk$action_team=="away", na.rm=TRUE))
                 },
                 "3pt_made" = {
                   c(home = sum(chunk$shot_outcome=="made" & chunk$three_pt & chunk$action_team=="home", na.rm=TRUE),
                     away = sum(chunk$shot_outcome=="made" & chunk$three_pt & chunk$action_team=="away", na.rm=TRUE))
                 },
                 "fg_attempts" = {
                   c(home = sum(!is.na(chunk$shot_outcome) & !chunk$free_throw & chunk$action_team=="home"),
                     away = sum(!is.na(chunk$shot_outcome) & !chunk$free_throw & chunk$action_team=="away"))
                 },
                 "3pt_attempts" = {
                   c(home = sum(!is.na(chunk$shot_outcome) & chunk$three_pt & chunk$action_team=="home"),
                     away = sum(!is.na(chunk$shot_outcome) & chunk$three_pt & chunk$action_team=="away"))
                 },
                 stop("Unknown stat: ", stat)
  )
  
  # 4) assemble one‐row summary
  data.frame(
    game_id          = game_id,
    date             = date,
    home             = home,
    away             = away,
    segment_id       = seg_id,
    game_break       = game_break,
    game_break_label = game_break_label,
    home_stat        = as.integer(vals["home"]),
    away_stat        = as.integer(vals["away"]),
    stat             = stat,
    stringsAsFactors = FALSE
  )
}
