import datetime_utils
import gleam/time/calendar

pub fn format_int_with_padding_test() {
  let assert "05" = datetime_utils.format_int_with_padding(5, 2)
  let assert "2026" = datetime_utils.format_int_with_padding(2026, 4)
  let assert "12" = datetime_utils.format_int_with_padding(12, 2)
  let assert "000" = datetime_utils.format_int_with_padding(0, 3)
}

pub fn date_to_string_test() {
  let assert "2026-08-03" =
    datetime_utils.date_to_string(calendar.Date(2026, calendar.August, 3))
  let assert "2025-12-19" =
    datetime_utils.date_to_string(calendar.Date(2025, calendar.December, 19))
  let assert "2024-01-01" =
    datetime_utils.date_to_string(calendar.Date(2024, calendar.January, 1))
}

pub fn time_to_string_test() {
  let assert "17:08:47" =
    datetime_utils.time_to_string(calendar.TimeOfDay(17, 8, 47, 0))
  let assert "09:05:00" =
    datetime_utils.time_to_string(calendar.TimeOfDay(9, 5, 0, 100))
}
