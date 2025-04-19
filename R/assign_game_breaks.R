#' Assign Game Segments Based on Break Type (Internal)
#'
#' Splits a single game's play-by-play data into sequential segments based on a selected break type.
#' Adds a `segment_id` to each row of the game and marks the appropriate rows as `game_break = TRUE`
#' to identify key game breaks (e.g., timeouts, halves, or custom intervals).
#'
#' This helper function is intended for internal use only and is not exported.
#'
#' @param game_data A data frame containing play-by-play data for a single game. Must include `play_id`, `description`, `half`, and `secs_remaining_absolute` columns.
#' @param segment_by A character string indicating how to segment the game. Options include:
#'   \itemize{
#'     \item `"half"`: Breaks the game into 20-minute halves (plus OT if present).
#'     \item `"timeout"`: Uses timeouts or "end" descriptions to define breaks.
#'     \item `"num_breaks"`: Splits the game evenly into a specified number of breaks.
#'   }
#' @param num_breaks An integer specifying how many breaks to create (required if `segment_by = "num_breaks"`).
#'
#' @return A modified version of the input data frame, including:
#'   \item{`segment_id`}{An integer indicating which segment each row belongs to.}
#'   \item{`game_break`}{Logical; `TRUE` if the row marks a break between segments.}
#'   \item{`game_break_label`}{A string combining the break description and timestamp.}
#'
#' @keywords internal
#'
#' @importFrom dplyr group_by slice_min ungroup
assign_game_breaks <- function(game_data, segment_by = c("half", "timeout", "num_breaks"), num_breaks = NULL) {
  segment_by <- match.arg(segment_by)

  # Ensure plays are in correct order
  game_data <- game_data[order(game_data$play_id), ]

  # Initialize
  game_data$segment_id       <- NA_integer_
  game_data$game_break       <- FALSE
  game_data$game_break_label <- NA_character_

  if (segment_by == "timeout") {
    # 1) identify all candidate breaks
    is_break <- grepl("\\btimeout\\b|\\bend\\b", tolower(game_data$description)) & !is.na(game_data$play_id)
    candidates  <- game_data[is_break, ]

    # 2) assign priorities
    home_team <- unique(game_data$home)[1]
    away_team <- unique(game_data$away)[1]

    candidates$priority <- 4L

    eo_game <- grepl("end of game", tolower(candidates$description))
    candidates$priority[eo_game] <- 1L

    coach_to <- grepl("timeout", tolower(candidates$description)) &
      (grepl(home_team, candidates$description, ignore.case=TRUE) |
         grepl(away_team, candidates$description, ignore.case=TRUE))
    candidates$priority[coach_to] <- pmin(candidates$priority[coach_to], 2L)

    eo_half <- grepl("end of [0-9]+(st|nd|th) half", tolower(candidates$description))
    candidates$priority[eo_half] <- pmin(candidates$priority[eo_half], 3L)

    # 3) from each second, keep only the top‐priority row
    selected <- dplyr::group_by(candidates, secs_remaining_absolute) %>%
      dplyr::slice_min(priority, with_ties = FALSE) %>%
      dplyr::ungroup()

    break_idxs <- which(game_data$play_id %in% selected$play_id)

    seg_id     <- integer(nrow(game_data))
    cur_seg    <- 1L
    last_index <- 1L

    for (i in break_idxs) {
      seg_id[last_index:(i-1)] <- cur_seg
      seg_id[i]                <- cur_seg
      game_data$game_break[i]  <- TRUE
      game_data$game_break_label[i] <-
        paste0(game_data$description[i], " (", game_data$time_remaining_half[i], ")")

      cur_seg    <- cur_seg + 1L
      last_index <- i + 1L
    }
    if (last_index <= nrow(game_data)) {
      seg_id[last_index:nrow(game_data)] <- cur_seg
    }
    game_data$segment_id <- seg_id

  } else if (segment_by == "half") {
    game_data$segment_id <- game_data$half

    for (h in unique(game_data$segment_id)) {
      rows <- which(game_data$segment_id == h)
      last <- tail(rows, 1)
      game_data$game_break[last] <- TRUE
      game_data$game_break_label[last] <-
        paste0(game_data$description[last], " (", game_data$time_remaining_half[last], ")")
    }

  } else if (segment_by == "num_breaks" && !is.null(num_breaks)) {
    total_time <- max(game_data$secs_remaining_absolute, na.rm = TRUE)
    cuts       <- seq(total_time, 0, length.out = num_breaks + 1)
    game_data$segment_id <- cut(game_data$secs_remaining_absolute,
                                breaks = cuts,
                                include.lowest = TRUE,
                                labels = FALSE)

    for (s in unique(game_data$segment_id)) {
      rows <- which(game_data$segment_id == s)
      last <- tail(rows, 1)
      game_data$game_break[last] <- TRUE
      game_data$game_break_label[last] <-
        paste0(game_data$description[last], " (", game_data$time_remaining_half[last], ")")
    }

  } else {
    stop("Invalid segment_by type or missing num_breaks for 'num_breaks'.")
  }

  return(game_data)
}
