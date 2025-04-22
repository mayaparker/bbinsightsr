#' Assign Game Segments Based on Break Type (Internal)
#'
#' Splits a single game's play-by-play data into sequential segments based on a
#' selected break type. Adds a `segment_id` to each row and marks
#' `game_break = TRUE` for key break events (e.g., timeouts, halftime, end of
#' game). Appends `game_break_label` with a consistent time.
#'
#' @param game_data A data frame containing play-by-play data for a single
#'   game. Must include `play_id`, `description`, `half`, and
#'   `secs_remaining_absolute` columns.
#' @param segment_by A character string indicating how to segment the game.
#'   One of:
#'   \itemize{
#'     \item `"half"`: Breaks the game into halves or OT periods.
#'     \item `"timeout"`: Uses coach/official timeouts or "end" descriptions to
#'       define breaks.
#'     \item `"num_breaks"`: Splits the game evenly into a given number of
#'       breaks.
#'   }
#' @param num_breaks Integer (optional). Required if
#'   `segment_by = "num_breaks"`.
#'
#' @return A modified version of `game_data` with columns:
#'   \item{`segment_id`}{An integer indicating segment assignment.}
#'   \item{`game_break`}{Logical TRUE/FALSE indicator for break rows.}
#'   \item{`game_break_label`}{Label showing break and formatted time (MM:SS).}
#'
#' @importFrom dplyr group_by slice_min ungroup
#' @importFrom hms as_hms
#' @keywords internal
assign_game_breaks <- function(game_data, segment_by = c("half", "timeout",
                                                         "num_breaks"),
                               num_breaks = NULL) {
  segment_by <- match.arg(segment_by)
  game_data  <- game_data[order(game_data$play_id), ]
  game_data$time_remaining_half <- hms::as_hms(game_data$time_remaining_half)

  game_data$segment_id       <- NA_integer_
  game_data$game_break       <- FALSE
  game_data$game_break_label <- NA_character_

  # --- Formatter to strip trailing :00 from hms ---
  format_mmss <- function(x) {
    t_str <- as.character(hms::as_hms(x))
    substr(t_str, 1, 5)
  }

  if (segment_by == "timeout") {
    is_break <- grepl("\\btimeout\\b|\\bend\\b",
                      tolower(game_data$description)) &
      !is.na(game_data$play_id)
    candidates <- game_data[is_break, ]

    home_team <- unique(game_data$home)[1]
    away_team <- unique(game_data$away)[1]
    candidates$priority <- 4L

    eo_game <- grepl("end of game", tolower(candidates$description))
    candidates$priority[eo_game] <- 1L

    coach_to <- grepl("timeout", tolower(candidates$description)) &
      (grepl(home_team, candidates$description, ignore.case = TRUE) |
         grepl(away_team, candidates$description, ignore.case = TRUE))
    candidates$priority[coach_to] <- pmin(candidates$priority[coach_to], 2L)

    eo_half <- grepl("end of [0-9]+(st|nd|th) half",
                     tolower(candidates$description))
    candidates$priority[eo_half] <- pmin(candidates$priority[eo_half], 3L)

    selected <- dplyr::group_by(candidates, secs_remaining_absolute) |>
      dplyr::slice_min(priority, with_ties = FALSE) |>
      dplyr::ungroup()

    break_idxs <- which(game_data$play_id %in% selected$play_id)

    seg_id <- integer(nrow(game_data))
    cur_seg <- 1L
    last_index <- 1L

    for (i in break_idxs) {
      seg_id[last_index:(i - 1)] <- cur_seg
      seg_id[i] <- cur_seg
      game_data$game_break[i] <- TRUE
      game_data$game_break_label[i] <- paste0(
        trimws(game_data$description[i]), " (",
        format_mmss(game_data$time_remaining_half[i]), ")"
      )

      cur_seg <- cur_seg + 1L
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
      game_data$game_break_label[last] <- paste0(game_data$description[last], "
                    (", format_mmss(game_data$time_remaining_half[last]), ")")
    }

  } else if (segment_by == "num_breaks" && !is.null(num_breaks)) {
    total_time <- max(game_data$secs_remaining_absolute, na.rm = TRUE)
    cuts <- seq(total_time, 0, length.out = num_breaks + 1)

    game_data$segment_id <- cut(game_data$secs_remaining_absolute,
                                breaks = cuts,
                                include.lowest = TRUE,
                                labels = FALSE)

    for (s in unique(game_data$segment_id)) {
      rows <- which(game_data$segment_id == s)
      last <- tail(rows, 1)
      game_data$game_break[last] <- TRUE
      game_data$game_break_label[last] <- paste0(game_data$description[last], "
                  (", format_mmss(game_data$time_remaining_half[last]), ")")
    }

  } else {
    stop("Invalid segment_by type or missing num_breaks for 'num_breaks'.")
  }

  return(game_data)
}
