% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/usu_data.R
\docType{data}
\name{ncaa_colors}
\alias{ncaa_colors}
\title{NCAA Team Color Reference Table (from ncaahoopR)}
\format{
A data frame with 11 columns:
\describe{
\item{ncaa_name}{Team name as listed on the NCAA website}
\item{espn_name}{Team name as listed in ESPN URLs}
\item{primary_color}{Hex code for the team’s primary color}
\item{secondary_color}{Hex code for the team’s secondary color}
\item{tertiary_color}{Hex code for tertiary color, if available}
\item{color_4}{Hex code for 4th color}
\item{color_5}{Hex code for 5th color}
\item{color_6}{Hex code for 6th color}
\item{logo_url}{URL to the team’s logo}
\item{color_3}{Alternate tertiary color code}
\item{conference}{The team's conference}
}
}
\source{
Extracted from the
\href{https://github.com/lbenz730/ncaahoopR}{\code{ncaahoopR}} package by Luke Benz.
}
\usage{
ncaa_colors
}
\description{
A dataset of NCAA team branding colors, including primary, secondary,
and tertiary hex values.
}
\details{
Helpful for consistent and branded data visualizations.
}
\examples{
data(ncaa_colors)
head(ncaa_colors)
}
\keyword{datasets}
