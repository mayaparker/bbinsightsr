% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/usu_data.R
\docType{data}
\name{ids}
\alias{ids}
\title{NCAA Team ID Table (from ncaahoopR)}
\format{
A data frame with 4 columns:
\describe{
\item{team}{The name of the team to be supplied to functions in
\code{ncaahoopR}}
\item{id}{Team ID used in ESPN URLs}
\item{link}{URL slug for the team on ESPN}
\item{espn_abbrv}{Team abbreviation on ESPN (used in URLs)}
}
}
\source{
Extracted from
the \href{https://github.com/lbenz730/ncaahoopR}{\code{ncaahoopR}} package by
Luke Benz.
}
\usage{
ids
}
\description{
A lookup table of ESPN team IDs and URL fragments for use with the
\code{ncaahoopR} package.
}
\details{
This table helps identify and correctly format ESPN play-by-play scraping
requests.
}
\examples{
data(ids)
head(ids)
}
\keyword{datasets}
