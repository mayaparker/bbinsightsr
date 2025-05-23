% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_stats_for_segment.R
\name{calculate_stats_for_segment}
\alias{calculate_stats_for_segment}
\title{Summarize One Segment's Stat into a Single Row (Internal)}
\usage{
calculate_stats_for_segment(chunk, stat)
}
\arguments{
\item{chunk}{A data frame of all plays in a single segment. Must include
\code{game_id}, \code{date}, \code{home}, \code{away}, \code{segment_id}, and have \code{game_break}
and \code{game_break_label} on its final row.}

\item{stat}{A character string indicating which stat to summarize.
Options include:
\itemize{
\item \code{"points"}: Points scored, based on score difference.
\item \code{"fouls"}, \code{"assists"}, \code{"turnovers"}, \code{"steals"}
\item \code{"offensive_rebounds"}, \code{"defensive_rebounds"}, \code{"rebounds"}
\item \code{"fg_made"}, \code{"fg_attempts"}, \code{"3pt_made"}, \code{"3pt_attempts"}
}}
}
\value{
A one-row data frame containing:
\item{\code{game_id}, \code{date}, \code{home}, \code{away}, \code{segment_id}}{
Basic game identifiers.
}
\item{\code{game_break}, \code{game_break_label}}{
Break indicators and labels for plotting.
}
\item{\code{home_stat}, \code{away_stat}}{Calculated stat for each team.}
\item{\code{stat}}{The name of the stat that was computed.}
}
\description{
Given all the rows for one game segment, compute the chosen stat for both
teams and extract key metadata for plotting.
}
\details{
This helper function is intended for internal use only and is not exported.
}
\keyword{internal}
