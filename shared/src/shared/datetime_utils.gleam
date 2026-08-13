import gleam/int
import gleam/string
import gleam/time/calendar

pub fn month_to_int(month: calendar.Month) -> Int {
  case month {
    calendar.January -> 1
    calendar.February -> 2
    calendar.March -> 3
    calendar.April -> 4
    calendar.May -> 5
    calendar.June -> 6
    calendar.July -> 7
    calendar.August -> 8
    calendar.September -> 9
    calendar.October -> 10
    calendar.November -> 11
    calendar.December -> 12
  }
}

pub fn int_to_month(n: Int) -> Result(calendar.Month, Nil) {
  case n {
    1 -> Ok(calendar.January)
    2 -> Ok(calendar.February)
    3 -> Ok(calendar.March)
    4 -> Ok(calendar.April)
    5 -> Ok(calendar.May)
    6 -> Ok(calendar.June)
    7 -> Ok(calendar.July)
    8 -> Ok(calendar.August)
    9 -> Ok(calendar.September)
    10 -> Ok(calendar.October)
    11 -> Ok(calendar.November)
    12 -> Ok(calendar.December)
    _ -> Error(Nil)
  }
}

pub fn format_int_with_padding(n: Int, width: Int) -> String {
  n
  |> int.to_string
  |> string.pad_start(to: width, with: "0")
}

pub fn date_to_string(date: calendar.Date) -> String {
  format_int_with_padding(date.year, 4)
  <> "-"
  <> format_int_with_padding(month_to_int(date.month), 2)
  <> "-"
  <> format_int_with_padding(date.day, 2)
}

pub fn time_to_string(time: calendar.TimeOfDay) -> String {
  format_int_with_padding(time.hours, 2)
  <> ":"
  <> format_int_with_padding(time.minutes, 2)
  <> ":"
  <> format_int_with_padding(time.seconds, 2)
}

pub fn string_to_date(str: String) -> Result(calendar.Date, Nil) {
  case string.split(str, "-") {
    [year_str, month_str, day_str] -> {
      case int.parse(year_str), int.parse(month_str), int.parse(day_str) {
        Ok(year), Ok(month_int), Ok(day) -> {
          case int_to_month(month_int) {
            Ok(month) -> Ok(calendar.Date(year, month, day))
            Error(Nil) -> Error(Nil)
          }
        }
        _, _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

pub fn string_to_time(str: String) -> Result(calendar.TimeOfDay, Nil) {
  case string.split(str, ":") {
    [hours_str, minutes_str, seconds_str] -> {
      case int.parse(hours_str), int.parse(minutes_str), int.parse(seconds_str) {
        Ok(hours), Ok(minutes), Ok(seconds) -> {
          case
            hours >= 0
            && hours < 24
            && minutes >= 0
            && minutes < 60
            && seconds >= 0
            && seconds < 60
          {
            True -> Ok(calendar.TimeOfDay(hours, minutes, seconds, 0))
            False -> Error(Nil)
          }
        }
        _, _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}
