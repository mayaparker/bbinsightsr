#'#' @import hms

#' Utah State University Basketball Play-by-Play Data
#'
#' A cleaned dataset containing play-by-play events for Utah State men's basketball
#' games from the past five seasons, scraped from ESPN. It includes information about
#' scores, fouls, referees, win probability, shot locations, and more for each play.
#' The data can be used for referee analysis, in-game trends, and outcome modeling.
#'
#' @format A data frame with 54,048 rows and 40 columns:
#' \describe{
#'   \item{game_id}{Unique game identifier}
#'   \item{date}{Date of the game}
#'   \item{home}{Name of the home team}
#'   \item{away}{Name of the away team}
#'   \item{play_id}{Sequential ID for each play}
#'   \item{half}{Half in which the play occurred (1 or 2)}
#'   \item{time_remaining_half}{Time remaining in the half (formatted as hms)}
#'   \item{secs_remaining}{Seconds remaining in the half}
#'   \item{secs_remaining_absolute}{Seconds remaining in the entire game}
#'   \item{description}{Text description of the play}
#'   \item{action_team}{Team responsible for the action ("home" or "away")}
#'   \item{home_score}{Home team score after the play}
#'   \item{away_score}{Away team score after the play}
#'   \item{score_diff}{Score differential at that point in the game}
#'   \item{play_length}{Length of the play in seconds}
#'   \item{scoring_play}{Logical, TRUE if the play resulted in points}
#'   \item{foul}{Logical, TRUE if the play was a foul}
#'   \item{win_prob}{Model-based win probability for the home team}
#'   \item{naive_win_prob}{Win probability based on a simpler model}
#'   \item{home_time_out_remaining}{Home team timeouts remaining}
#'   \item{away_time_out_remaining}{Away team timeouts remaining}
#'   \item{home_favored_by}{Pre-game point spread}
#'   \item{total_line}{Pre-game over/under line}
#'   \item{referees}{Slash-separated names of referees for the game}
#'   \item{arena_location}{City/state of the arena}
#'   \item{arena}{Name of the arena}
#'   \item{capacity}{Arena capacity (mostly NA)}
#'   \item{attendance}{Reported attendance for the game}
#'   \item{shot_x}{X-coordinate of shot attempt (if applicable)}
#'   \item{shot_y}{Y-coordinate of shot attempt (if applicable)}
#'   \item{shot_team}{Team that attempted the shot}
#'   \item{shot_outcome}{Outcome of the shot ("make" or "miss")}
#'   \item{shooter}{Player who attempted the shot}
#'   \item{assist}{Assisting player (if applicable)}
#'   \item{three_pt}{Indicator for a 3-point attempt}
#'   \item{free_throw}{Indicator for a free throw attempt}
#'   \item{possession_before}{Team with possession before the play}
#'   \item{possession_after}{Team with possession after the play}
#'   \item{wrong_time}{Logical, TRUE if timing of the play was incorrect}
#' }
#'
#' @source Scraped from ESPN via custom R scripts.
#'
#' @examples
#' data(usu_data)
#' head(usu_data)
"usu_data"

#' NCAA Team ID Table (from ncaahoopR)
#'
#' A lookup table of ESPN team IDs and URL fragments for use with the `ncaahoopR` package.
#'
#' @docType data
#' @format A data frame with 4 columns:
#' \describe{
#'   \item{team}{The name of the team to be supplied to functions in `ncaahoopR`}
#'   \item{id}{Team ID used in ESPN URLs}
#'   \item{link}{URL slug for the team on ESPN}
#'   \item{espn_abbrv}{Team abbreviation on ESPN (used in URLs)}
#' }
#'
#' @details
#' This table helps identify and correctly format ESPN play-by-play scraping requests.
#'
#' @source Extracted from the [`ncaahoopR`](https://github.com/lbenz730/ncaahoopR) package by Luke Benz.
#' @examples
#' data(ids)
#' head(ids)
"ids"

#' Team Name Conversion Dictionary (from ncaahoopR)
#'
#' A lookup table of team name formats across major NCAA basketball data sources.
#'
#' @docType data
#' @format A data frame with 9 columns:
#' \describe{
#'   \item{NCAA}{Team name as listed on the NCAA website}
#'   \item{ESPN}{Team name as listed in ESPN URLs}
#'   \item{ESPN_PBP}{Team name as listed on ESPN play-by-play logs}
#'   \item{Warren_Nolan}{Team name from WarrenNolan.com}
#'   \item{Trank}{Team name from barttorvik.com}
#'   \item{name_247}{Team name from 247Sports.com}
#'   \item{conference}{The team's conference}
#'   \item{sref_link}{Slug for the team on sports-reference.com}
#'   \item{sref_name}{Team name on sports-reference.com}
#' }
#'
#' @details
#' Useful for converting team names between different systems and data sources.
#'
#' @source Extracted from the [`ncaahoopR`](https://github.com/lbenz730/ncaahoopR) package by Luke Benz.
#' @examples
#' data(dict)
#' head(dict)
"dict"

#' NCAA Team Color Reference Table (from ncaahoopR)
#'
#' A dataset of NCAA team branding colors, including primary, secondary, and tertiary hex values.
#'
#' @docType data
#' @format A data frame with 11 columns:
#' \describe{
#'   \item{ncaa_name}{Team name as listed on the NCAA website}
#'   \item{espn_name}{Team name as listed in ESPN URLs}
#'   \item{primary_color}{Hex code for the team’s primary color}
#'   \item{secondary_color}{Hex code for the team’s secondary color}
#'   \item{tertiary_color}{Hex code for tertiary color, if available}
#'   \item{color_4}{Hex code for 4th color}
#'   \item{color_5}{Hex code for 5th color}
#'   \item{color_6}{Hex code for 6th color}
#'   \item{logo_url}{URL to the team’s logo}
#'   \item{color_3}{Alternate tertiary color code}
#'   \item{conference}{The team's conference}
#' }
#'
#' @details
#' Helpful for consistent and branded data visualizations.
#'
#' @source Extracted from the [`ncaahoopR`](https://github.com/lbenz730/ncaahoopR) package by Luke Benz.
#' @examples
#' data(ncaa_colors)
#' head(ncaa_colors)
"ncaa_colors"


