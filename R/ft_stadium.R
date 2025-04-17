#' Analyze Free Throw Performance at a Home Team's Arena
#'
#' Summarizes and compares free throw performance by half for a specified home
#' team and their opponents in a particular arena. The function reports
#' free throw percentages for both the home and away teams across first and
#' second halves, and performs a t-test for the away team's performance by half.
#'
#' @param df A data frame of play-by-play data (e.g., from `ncaahoopR`) that
#' includes fields like `home`, `away`, `arena`, `free_throw`, `scoring_play`,
#' `half`, and `shot_team`.
#' @param home_team Character string specifying the name of the home team.
#' @param arena Character string specifying the name of the arena.
#'
#' @return A wide-format data frame (invisibly) with free throw percentages for
#' both home and away teams by half. The function prints a formatted summary
#' and a t-test comparing the away team’s first- and second-half free throw
#' percentages.
#'
#' @details If any team_type-by-half group has fewer than 15 observations, a
#' warning is issued indicating that the t-test may be unreliable for that
#' group.
#'
#' @examples
#' ft_stadium(
#'   df = usu_data,
#'   home_team = "Utah State",
#'   arena = "Dee Glen Smith Spectrum"
#' )
#'
#' @export
ft_stadium <- function(df, home_team, arena) {
  # Filter for all games where this team is the home team
  ft_data <- df %>%
    dplyr::filter(
      home == home_team,
      arena == arena,
      free_throw == TRUE,
      shot_team %in% c(home, away),
      half %in% c(1, 2)
    )

  if(nrow(ft_data) < 1){
    stop("No free throw data from given input. Make sure df is from ncaahoopr,",
         "and home_team, away_team, and arena are the correct corresponding",
         " home, away, and arena names in the data frame.")
  }

  # Add column identifying whether each shot is by home or away team
  ft_data <- ft_data %>%
    dplyr::mutate(
      team_type = dplyr::case_when(
        shot_team == home ~ "Home",
        shot_team == away ~ "Away"
      ),
      make_binary = ifelse(scoring_play == TRUE, 1, 0)
    )

  # Check sample sizes by team_type and half
  count_check <- ft_data %>%
    dplyr::group_by(team_type, half) %>%
    dplyr::summarise(n = dplyr::n(), .groups = "drop")

  under_min <- count_check %>% dplyr::filter(n < 15)

  if (nrow(under_min) > 0) {
    warning("Some team_type-half groups have fewer than 15 observations. ",
            "T-test results may not be reliable.\n\n",
            paste0(
              apply(under_min, 1, function(row) {
                paste0("- ", row["team_type"], ", Half ", row["half"], ": ",
                       row["n"], " observations")
              }),
              collapse = "\n"
            )
    )
  }

  # Summary FT% table
  summary <- ft_data %>%
    dplyr::group_by(team_type, half) %>%
    dplyr::summarise(
      attempts = dplyr::n(),
      made = sum(make_binary),
      ft_percentage = round(mean(make_binary) * 100, 2),
      .groups = "drop"
    )

  # Pivot summary table to wide format (safe rename)
  ft_wide <- summary %>%
    dplyr::select(team_type, half, ft_percentage) %>%
    tidyr::pivot_wider(
      names_from = half,
      values_from = ft_percentage,
      names_prefix = "Half_",
      values_fill = list(ft_percentage = 0)
    ) %>%
    dplyr::rename_with(
      .fn = ~ dplyr::recode(.x,
                            "Half_1" = "1st Half FT%",
                            "Half_2" = "2nd Half FT%"
      )
    )

  # Print summary
  print(glue::glue("Free Throw Summary: {home_team} (Home) vs All Opponents (Away)"))
  print(ft_wide)

  # Run t-test for away team (1st vs 2nd half)
  away_ft <- ft_data %>%
    dplyr::filter(team_type == "Away")

  if (length(unique(away_ft$half)) > 1) {
    t_test_result <- t.test(make_binary ~ half, data = away_ft)
    cat("\nT-test for Away Team FT% (1st vs 2nd Half):\n")
    print(t_test_result)
  } else {
    cat("\nT-test for Away Team could not be run (all free throws in same half).\n")
  }
}
