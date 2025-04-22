#' Select a Single Game Between Two Teams
#'
#' Filters a dataset of play-by-play data to return a single game between the
#' specified teams. If multiple games are found and no `game_date` is specified
#' or matched, the user will be prompted to select one.
#'
#' @param data A data frame containing play-by-play or game-level data,
#' including `home`, `away`, `date`, and `game_id` columns.
#' @param team The name of one team.
#' @param opponent The name of the opposing team.
#' @param game_date Optional. A specific game date (string or Date) to
#' automatically select a game if it exists.
#'
#' @return A data frame containing the filtered game data for the selected game.
#' @keywords internal
#'
#' @importFrom dplyr filter arrange distinct mutate
#' @importFrom utils flush.console
select_single_game <- function(data, team, opponent, game_date = NULL) {
  game_matches <- data %>%
    dplyr::filter((home == team & away == opponent) |
                    (home == opponent & away == team)) %>%
    dplyr::arrange(date, game_id)

  if (nrow(game_matches) == 0) {
    stop("No games found between those teams.")
  }

  unique_games <- game_matches %>%
    dplyr::distinct(game_id, date, home, away) %>%
    dplyr::arrange(date) %>%
    dplyr::mutate(date_label = format(as.Date(date), "%b %d, %Y"))

  # If game_date is specified
  if (!is.null(game_date)) {
    date_filtered <- unique_games %>%
      dplyr::filter(as.Date(date) == as.Date(game_date))

    if (nrow(date_filtered) == 1) {
      message(
        "Game automatically selected: ", date_filtered$home[1], " vs ",
        date_filtered$away[1],
        " on ", format(as.Date(date_filtered$date[1]), "%b %d, %Y")
      )
      return(game_matches %>% dplyr::filter(game_id ==
                                              date_filtered$game_id[1]))
    } else {
      message("No game found on ", as.character(game_date),
              " between these teams.")
      message("Available dates:")
      for (i in seq_len(nrow(unique_games))) {
        cat(i, ": ", unique_games$home[i], " vs ", unique_games$away[i],
          " - ", unique_games$date_label[i], "\n",
          sep = ""
        )
      }
    }
  }

  # Always prompt user if multiple games (and no valid game_date matched)
  cat("Multiple games found between these teams:\n")
  for (i in seq_len(nrow(unique_games))) {
    cat(i, ": ", unique_games$home[i], " vs ", unique_games$away[i],
      " - ", unique_games$date_label[i], "\n",
      sep = ""
    )
  }

  repeat {
    flush.console()
    selected_index <-
      as.integer(readline(prompt =
                            "Enter the number of the game you'd like to use: "))
    if (!is.na(selected_index) && selected_index >= 1 && selected_index <=
          nrow(unique_games)) {
      break
    }
    cat("Invalid selection. Please enter a number between 1 and ",
        nrow(unique_games), ".\n", sep = "")
  }

  selected_game_id <- unique_games$game_id[selected_index]
  selected_game <- game_matches %>% dplyr::filter(game_id == selected_game_id)

  message(
    "You selected: ", unique_games$home[selected_index], " vs ",
    unique_games$away[selected_index], " on ",
    unique_games$date_label[selected_index]
  )

  return(selected_game)
}
