export function fetch_workouts(on_success, on_error) {
  fetch('/api/workouts')
    .then(res => {
      if (!res.ok) {
        throw new Error('HTTP error! Status: ' + res.status);
      }
      return res.text();
    })
    .then(text => on_success(text))
    .catch(err => on_error(err.message || String(err)));
}
