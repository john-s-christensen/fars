#' @title
#' Import .csv flat files
#'
#' @description
#' This function imports a .csv file. The parameter \code{filename} is meant to
#' be passed a string from the function \code{make_filename()}. This function is
#' used within the \code{fars_read_years()} function.
#'
#' @details This function first checks to make sure the file exists, and then,
#' if it does exist, uses \code{readr::read_csv()} to import the file, suppressing
#' import messages and the progress bar in the process.  Finally, it uses
#' \code{dplyr::tbl_df()} to convert the imported file to be a tibble data frame.
#'
#' @param filename A character string giving the name of the .csv file to be
#' imported.
#'
#' @return This function returns a tibble.
#'
#' @note if a .csv file matching the \code{filename} you supply does not exist,
#' the function will stop execution with message
#' "file \code{filename} does not exist."
#'
#' @examples
#' fars_read("accident_2015.csv.bz2")
#'
#' @export
fars_read <- function(filename) {
  #if(!file.exists(paste0("extdata/",filename)))
   # stop("file '", filename, "' does not exist")
  data <- suppressMessages({
    #readr::read_csv(paste0("data/",filename), progress = FALSE) # I want to try using system.file
    #in read_csv. How would you call the internal data without using read_csv??
    #readr::read_csv(filename, progress = FALSE)
    readr::read_csv(system.file("extdata", filename, package = "fars"), progress = FALSE)
  })
  #data <- filename
  dplyr::tbl_df(data)
}

#' @title
#' Create a file name.
#'
#' @description
#' This function returns a string, which is meant to be passed to the
#' \code{filename} argument of the \code{fars_read()} function.
#'
#' @details
#' This function takes a year as an argument, coerces that year to be an
#' integer and then uses the \code{sprintf} function to concatenate the \code{year}
#' argument into "accident_\code{year}.csv.bz2"
#'
#' @param year A integer giving the year of a .csv file.
#'
#' @return This function returns a character string.
#'
#' @examples
#' make_filename(2015)
#'
#' @export
make_filename <- function(year) {
  year <- as.integer(year)
  sprintf("accident_%d.csv.bz2", year)
}

#' @title
#' Select the month and year columns from the files whose years you specify.
#'
#' @description
#' This function is used inside of the \code{fars_summarize_years()} function
#' and input for the \code{years} argument comes from the \code{years} argument
#' of the \code{fars_summarize_years()} function.
#'
#' @details
#' This function takes a vector of years as input and uses \code{lapply()} to
#' make a filename for each year, read in that file as a tibble and select the
#' month and year columns in that tibble.
#'
#' @param years A vector of years for the files you're interested in.
#'
#' @return This function returns a list, with each element of the list being a
#' tibble for each year in the vector of years specified in argument \code{years}.
#' Each tibble in the list contains two columns, "MONTH" and "year".
#'
#' @note if even one of the years in the vector passed to argument \code{years}
#' does not exist (if there is no file for that year), no results, only an error
#' message, will be returned; "invalid year: 2017" for example.
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' fars_read_years(c(2013, 2014, 2015))
#'
#' @export
fars_read_years <- function(years) {
  # To avoid "no visible binding for global variable" note in R Check CMD:
  MONTH <- NULL
  lapply(years, function(year) {
    file <- make_filename(year)
    tryCatch({
      dat <- fars_read(file)
      dplyr::mutate(dat, year = year) %>%
        dplyr::select(MONTH, year)
    }, error = function(e) {
      warning("invalid year: ", year)
      return(NULL)
    })
  })
}

#' @title
#' Display a count of the number of fatalities per month and year.
#'
#' @description
#' This function counts the number of traffic fatalities per month/year for the
#' vector of years specified in argument \code{years}.
#'
#' @details
#' This function makes use of the \code{fars_read_years()} function, which in
#' turn makes use of \code{fars_read()} which uses \code{make_filename()}. First,
#' the list of tibbles returned by \code{fars_read_years()} is unioned and then
#' grouped by year and month. Then \code{dplyr::summarize()} is used to count
#' the number of fatalities in each year/month group. Finally, \code{tidyr::spread}
#' pivots the counts so that they're visually appealing for printing.
#'
#' @inheritParams fars_read_years
#'
#' @return This function returns a tibble.
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' fars_summarize_years(c(2013, 2014, 2015))
#'
#' @export
fars_summarize_years <- function(years) {
  # To avoid "no visible binding for global variable" note in R Check CMD:
  year <- MONTH <- n <- NULL

  dat_list <- fars_read_years(years)
  dplyr::bind_rows(dat_list) %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
}

#' @title
#' Map fatalities within a state for a given year.
#'
#' @description
#' This function plots a map showing where traffic fatalitites occurred in a state,
#' specified by argument \code{state.num}, for a given year, specified by argument
#' \code{year}.
#'
#' @param state.num an integer specifying which state you want to see traffic
#' fatalities for.
#' @param year a four digit integer representing the year you want to see traffic
#' fatalities for.
#'
#' @details
#' This function uses \code{make_filename()} and \code{fars_read()} to read in the
#' .csv that corresponds with parameter \code{year}. Parameter \code{state.num} is
#' coerced to be an integer and checked for valid existence.
#' Logitudes of greater than 900 and latitudes of greater than 90 coerced into NAs.
#' \code{maps::map()} is used to create the map. \code{graphics::points()} is
#' used to plot traffic fatalities on the map.
#'
#' @return This function returns a map plot of the state fatalities in a year.
#'
#' @note
#' If you supply an invalid \code{state.num} to this function, you'll receive error
#' message: "invalid STATE number: ". If there are no traffic fatalities for the
#' state and year, you'll receive a message: "no accidents to plot".
#' Because this function coerces longitudes greater than 900 and latitudes
#' greater than 90 to NA, you could receive a message saying, "nothing to draw:
#' all regions out of bounds". \code{fars_map_state(2, 2013)} for example will
#' return this message.
#'
#' @examples
#' fars_map_state(48, 2015)
#'
#' @export
fars_map_state <- function(state.num, year) {
  filename <- make_filename(year)
  data <- fars_read(filename)
  state.num <- as.integer(state.num)

  # To avoid "no visible binding for global variable" note in R Check CMD:
  STATE <- NULL

  if(!(state.num %in% unique(data$STATE)))
    stop("invalid STATE number: ", state.num)
  data.sub <- dplyr::filter(data, STATE == state.num)
  if(nrow(data.sub) == 0L) {
    message("no accidents to plot")
    return(invisible(NULL))
  }
  is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
  is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
  with(data.sub, {
    maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
              xlim = range(LONGITUD, na.rm = TRUE))
    graphics::points(LONGITUD, LATITUDE, pch = 46)
  })
}
