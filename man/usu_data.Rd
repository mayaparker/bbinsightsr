% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/usu_data.R
\docType{data}
\name{usu_data}
\alias{usu_data}
\title{#' @import hms
Utah State University Basketball Play-by-Play Data}
\format{
A data frame with 54,048 rows and 40 columns:
\describe{
\item{game_id}{Unique game identifier}
\item{date}{Date of the game}
\item{home}{Name of the home team}
\item{away}{Name of the away team}
\item{play_id}{Sequential ID for each play}
\item{half}{Half in which the play occurred (1 or 2)}
\item{time_remaining_half}{Time remaining in the half (formatted as hms)}
\item{secs_remaining}{Seconds remaining in the half}
\item{secs_remaining_absolute}{Seconds remaining in the entire game}
\item{description}{Text description of the play}
\item{action_team}{Team responsible for the action ("home" or "away")}
\item{home_score}{Home team score after the play}
\item{away_score}{Away team score after the play}
\item{score_diff}{Score differential at that point in the game}
\item{play_length}{Length of the play in seconds}
\item{scoring_play}{Logical, TRUE if the play resulted in points}
\item{foul}{Logical, TRUE if the play was a foul}
\item{win_prob}{Model-based win probability for the home team}
\item{naive_win_prob}{Win probability based on a simpler model}
\item{home_time_out_remaining}{Home team timeouts remaining}
\item{away_time_out_remaining}{Away team timeouts remaining}
\item{home_favored_by}{Pre-game point spread}
\item{total_line}{Pre-game over/under line}
\item{referees}{Slash-separated names of referees for the game}
\item{arena_location}{City/state of the arena}
\item{arena}{Name of the arena}
\item{capacity}{Arena capacity (mostly NA)}
\item{attendance}{Reported attendance for the game}
\item{shot_x}{X-coordinate of shot attempt (if applicable)}
\item{shot_y}{Y-coordinate of shot attempt (if applicable)}
\item{shot_team}{Team that attempted the shot}
\item{shot_outcome}{Outcome of the shot ("make" or "miss")}
\item{shooter}{Player who attempted the shot}
\item{assist}{Assisting player (if applicable)}
\item{three_pt}{Indicator for a 3-point attempt}
\item{free_throw}{Indicator for a free throw attempt}
\item{possession_before}{Team with possession before the play}
\item{possession_after}{Team with possession after the play}
\item{wrong_time}{Logical, TRUE if timing of the play was incorrect}
}
}
\source{
Scraped from ESPN via custom R scripts.
}
\usage{
usu_data
}
\description{
A cleaned dataset containing play-by-play events for Utah State men's
basketball games from the past five seasons, scraped from ESPN. It includes
information about scores, fouls, referees, win probability, shot locations,
and more for each play. The data can be used for referee analysis, in-game
trends, and outcome modeling.
}
\examples{
data(usu_data)
head(usu_data)
}
\keyword{datasets}
