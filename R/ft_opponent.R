#' Analyze Free Throw Performance by Half
#'
#' Analyzes and summarizes free throw performance for both teams (home and
#' away) between two specific teams in a specific arena. The function provides
#' a summary table of free throw percentages by half, checks if groups have
#' sufficient sample sizes, and performs t-tests comparing first- and
#' second-half free throw accuracy for each team.
#'
#' @param df A data frame of play-by-play data (e.g., from `ncaahoopR`) that
#' includes fields like `home`, `away`, `arena`, `free_throw`, `scoring_play`,
#' `half`, and `shot_team`.
#' @param home_team Character string specifying the name of the home team.
#' @param away_team Character string specifying the name of the away team.
#' @param arena Character string specifying the name of the arena.
#'
#' @importFrom magrittr %>%
#' @importFrom stats t.test
#' @importFrom dplyr filter mutate group_by summarise case_when

#' @return A wide-format data frame (invisibly) with first- and second-half
#' free throw percentages for each team. The function prints a formatted
#' summary and the results of t-tests for within-team half comparisons.
#'
#' @details If any of the four shot_team-by-half combinations have fewer than
#' 15 observations, a warning is issued noting which groups may produce
#' unreliable t-test results.
#'
#' @examples
#' ft_opponent(
#'   df = usu_data,
#'   home_team = "Utah State",
#'   away_team = "Boise St",
#'   arena = "Dee Glen Smith Spectrum"
#' )
#'
#' @export
ft_opponent <- function(df, home_team, away_team, arena) {
  # Filter for relevant games and FTs
  ft_data <- df %>%
    dplyr::filter(
      home == home_team,
      away == away_team,
      arena == arena,
      free_throw == TRUE,
      shot_team %in% c(home_team, away_team),
      half %in% c(1, 2)
    ) %>%
    dplyr::mutate(
      make_binary = ifelse(scoring_play == TRUE, 1, 0)
    )

  if(nrow(ft_data) < 1){
    stop("No free throw data from given input. Make sure df is play
         by play data from ncaahoopr,",
         "and home_team, away_team, and arena are the correct corresponding",
         " home, away, and arena names in the data frame.")
  }

  # Count observations by team and half
  count_check <- ft_data %>%
    dplyr::group_by(shot_team, half) %>%
    dplyr::summarise(n = dplyr::n(), .groups = "drop")

  # Check if any group has <15 obs
  under_min <- count_check %>% dplyr::filter(n < 15)

  if (nrow(under_min) > 0) {
    warning("Some shot_team-half groups have fewer than 15 observations. ",
            "T-test results may not be reliable.\n\n",
            paste0(
              apply(under_min, 1, function(row) {
                paste0("- ", row["shot_team"], ", Half ", row["half"], ": ",
                       row["n"], " observations")
              }),
              collapse = "\n"
            )
    )
  }

  # Summary table
  summary <- ft_data %>%
    dplyr::group_by(shot_team, half) %>%
    dplyr::summarise(
      attempts = dplyr::n(),
      made = sum(make_binary),
      ft_percentage = round(mean(make_binary) * 100, 2),
      .groups = "drop"
    )

  # Pivot FT% to wide format
  ft_wide <- summary %>%
    dplyr::select(shot_team, half, ft_percentage) %>%
    tidyr::pivot_wider(
      names_from = half,
      values_from = ft_percentage,
      names_prefix = "Half_",
      values_fill = 0
    ) %>%
    dplyr::rename(
      `1st Half FT%` = Half_1,
      `2nd Half FT%` = Half_2
    )

  # Print summary
  print(glue::glue("Free Throw Summary: {home_team} vs {away_team}"))
  print(ft_wide)

  # Run t-tests for each team
  for (team in c(home_team, away_team)) {
    team_ft <- ft_data %>% dplyr::filter(shot_team == team)

    if (length(unique(team_ft$half)) > 1) {
      t_test <- t.test(make_binary ~ half, data = team_ft)
      cat("\nT-test for", team, "(1st vs 2nd Half FT%):\n")
      print(t_test)
    } else {
      cat("\nT-test for", team, "could not be run (all free throws in same half).\n")
    }
  }

  invisible(ft_wide)
}
