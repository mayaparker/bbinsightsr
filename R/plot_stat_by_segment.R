#' Plot a Team Statistic by Game Segment (Internal)
#'
#' Creates a bar plot showing the values of a selected stat for both teams across game segments.
#' Automatically uses team colors and abbreviates game break labels using a dictionary and color lookup tables.
#'
#' This function is intended for internal use and is not exported.
#'
#' @param summary_data A data frame produced by `summarize_segmented_data()`, containing
#'   game segment IDs, labels, and stat values (`home_stat`, `away_stat`) for both teams.
#'
#' @return A ggplot2 object showing the stat values across game segments, color-coded by team.
#'
#' @keywords internal
#'
#' @importFrom dplyr filter select mutate if_else
#' @importFrom tibble deframe
#' @importFrom tidyr pivot_longer
#' @importFrom ggplot2 ggplot aes geom_col scale_fill_manual geom_vline
#'   scale_y_continuous labs theme_bw theme element_text element_blank
#'   position_dodge2 margin
#' @importFrom stringr str_replace_all
#' @importFrom tools toTitleCase
#' @importFrom stats setNames
#' @importFrom utils tail
plot_stat_by_segment <- function(summary_data) {
  # 1. Pull out team names from the summary
  home_team <- unique(summary_data$home)[1]
  away_team <- unique(summary_data$away)[1]
  teams <- c(home_team, away_team)

  # 2. Lookup home team colors (fallback to stripped match if needed)
  home_colors <- ncaa_colors %>% filter(espn_name == home_team)

  if (nrow(home_colors) == 0) {
    fallback_name <- ncaa_colors %>%
      mutate(stripped_name = gsub("[[:punct:][:space:]]", "", espn_name)) %>%
      filter(stripped_name == gsub("[[:punct:][:space:]]", "", home_team))

    if (nrow(fallback_name) > 0) {
      home_colors <- fallback_name
      home_team <- fallback_name$espn_name[1] # update to canonical name
      teams[1] <- home_team
    }
  }

  # 3. Build ESPN_PBP → abbreviation lookup
  abbrv_lookup <- dict %>%
    filter(ESPN_PBP %in% teams) %>%
    select(ESPN_PBP, ESPN) %>%
    deframe()

  # 4. Replace team names in game_break_label with abbreviations
  summary_data <- summary_data %>%
    mutate(game_break_label = stringr::str_replace_all(game_break_label, abbrv_lookup)) %>%
    mutate(game_break_label = gsub("Official TV Timeout", "TV Timeout", game_break_label, fixed = TRUE))

  # 5. Identify stat we're plotting
  stat_name <- unique(summary_data$stat)[1]

  # 6. Pivot to long format
  plot_df <- summary_data %>%
    select(segment_id, segment_label = game_break_label, home, away, home_stat, away_stat) %>%
    pivot_longer(c(home_stat, away_stat), names_to = "side", values_to = "value") %>%
    mutate(
      team = if_else(side == "home_stat", home, away),
      team = factor(team, levels = teams),
      segment_label = factor(segment_label, levels = unique(segment_label))
    )

  # 7. Assign team colors
  team_colors <- c(
    setNames(home_colors$primary_color, home_team),
    setNames(home_colors$secondary_color, away_team)
  )

  # Replace white bars with gray fallback
  team_colors <- ifelse(toupper(team_colors) == "#FFFFFF", "#A2AAAD", team_colors)
  names(team_colors) <- c(home_team, away_team)

  # 8. Final plot
  n_segments <- length(levels(plot_df$segment_label))
  vlines <- seq(1.5, n_segments - 0.5, by = 1)
  max_y <- ceiling(max(plot_df$value, na.rm = TRUE))
  max_y_adj <- ifelse(max_y %% 2 == 1, max_y + 1, max_y)

  ggplot(plot_df, aes(x = segment_label, y = value, fill = team)) +
    geom_col(
      position  = position_dodge2(preserve = "single", padding = 0),
      width     = 0.8,
      colour    = "grey30",
      linewidth = 0.3
    ) +
    scale_fill_manual(
      name   = NULL,
      values = team_colors,
      labels = teams
    ) +
    geom_vline(
      xintercept = vlines,
      linetype   = "dashed",
      color      = "grey60",
      linewidth  = 0.5
    ) +
    scale_y_continuous(
      name   = tools::toTitleCase(stat_name),
      breaks = seq(0, max_y_adj, by = 2),
      limits = c(0, max_y_adj)
    ) +
    labs(x = "Game Segment") +
    theme_bw(base_size = 14) +
    theme(
      legend.position = "top",
      axis.text.x = element_text(
        angle  = 45,
        hjust  = 1,
        margin = margin(t = 8, l = 10)
      )
    )
}
