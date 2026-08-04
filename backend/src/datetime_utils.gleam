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
