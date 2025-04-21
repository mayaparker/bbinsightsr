utils::globalVariables(c(
  ".", "%>%", "home", "away", "referee", "game_id", "foul",
  "foul_on_team", "foul_on_opponent", "shot_team", "half",
  "scoring_play", "make_binary", "ft_percentage", "team_type",
  "foul_type", "count", "fouls_called", "games_worked",
  "fouls_on_team", "fouls_on_opponent", "fouls_per_game",
  "fouls_ratio", "is_home_team", "reorder", "RefereesList",
  "n", "Half_1", "Half_2"
))


#' Plot Referee Summary Statistics
#'
#' This function creates and displays three visualizations for referee stats:
#' fouls per game, fouls on team vs opponent, and the foul ratio. Designed to work
#' directly with the output of `refstats()`.
#'
#' @param ref_stats A data frame created by `refstats()` containing referee summary statistics.
#' @param top_n Number of top referees to include in each plot.
#' @param team_label A string to label your team in the chart title (e.g., "Utah State").
#'
#' @return A combined plot displaying all three referee charts using patchwork.
#' @export
#'
#' @examples
#' data(usu_data)
#' stats <- refstats(usu_data, team_name = "Utah State")
#' plot_refstats(stats, team_label = "Utah State")
plot_refstats <- function(ref_stats, top_n = 5, team_label = "Team") {
  p1 <- plot_fouls(ref_stats, top_n)
  p2 <- plot_team_fouls(ref_stats, top_n)
  p3 <- plot_team_foul_ratio(ref_stats, top_n)

  patchwork::wrap_plots(p1, p2, p3, ncol = 1) +
    patchwork::plot_annotation(title = paste("Referee Summary Plots -", team_label))
}


#' Plot total fouls per game by referee
#'
#' Helper function that visualizes the top referees by average fouls called per game.
#'
#' @param foul_stats A data frame generated from `refstats()`.
#' @param top_n Number of top referees to display in the plot.
#'
#' @return A ggplot object.

plot_fouls <- function(foul_stats, top_n = 5) {
  foul_stats |>
    dplyr::slice_max(fouls_per_game, n = top_n) |>
    ggplot2::ggplot(ggplot2::aes(x = reorder(referee, fouls_per_game), y = fouls_per_game)) +
    ggplot2::geom_col(fill = "steelblue") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = paste("Top", top_n, "Referees by Fouls per Game"),
      x = "Referee",
      y = "Fouls per Game"
    ) +
    ggplot2::theme_minimal()
}

#' Plot team vs opponent foul counts
#'
#' Helper function to generate a bar chart comparing fouls called on the team vs. opponent
#' for each referee.
#'
#' @param ref_stats A data frame generated from `refstats()`.
#' @param top_n Number of top referees to include based on total foul counts.
#'
#' @return A ggplot object.

plot_team_fouls <- function(ref_stats, top_n = 5) {
  ref_stats |>
    dplyr::select(referee, fouls_on_team, fouls_on_opponent) |>
    dplyr::slice_max(fouls_on_team + fouls_on_opponent, n = top_n) |>
    tidyr::pivot_longer(
      cols = c(fouls_on_team, fouls_on_opponent),
      names_to = "foul_type", values_to = "count"
    ) |>
    ggplot2::ggplot(ggplot2::aes(x = reorder(referee, count), y = count, fill = foul_type)) +
    ggplot2::geom_col(position = "dodge") +
    ggplot2::coord_flip() +
    ggplot2::scale_fill_manual(
      values = c("fouls_on_team" = "steelblue", "fouls_on_opponent" = "firebrick"),
      labels = c("On Opponent", "On Team")
    ) +
    ggplot2::labs(
      title = paste("Fouls Called: Team vs Opponent (Top", top_n, "Refs)"),
      x = "Referee",
      y = "Fouls",
      fill = "Foul Type"
    ) +
    ggplot2::theme_minimal()
}

#' Plot foul ratio by referee
#'
#' Helper function to visualize the ratio of fouls called on the team versus the opponent.
#'
#' @param ref_stats A data frame generated from `refstats()`.
#' @param top_n Number of top referees to display by foul ratio.
#'
#' @return A ggplot object.

plot_team_foul_ratio <- function(ref_stats, top_n = 5) {
  ref_stats |>
    dplyr::filter(!is.na(fouls_ratio)) |>
    dplyr::slice_max(fouls_ratio, n = top_n) |>
    ggplot2::ggplot(ggplot2::aes(x = reorder(referee, fouls_ratio), y = fouls_ratio)) +
    ggplot2::geom_col(fill = "darkorange") +
    ggplot2::geom_hline(yintercept = 1, linetype = "dashed", color = "gray40") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      title = paste("Foul Ratio (Team / Opponent) - Top", top_n),
      x = "Referee",
      y = "Foul Ratio"
    ) +
    ggplot2::theme_minimal()
}
