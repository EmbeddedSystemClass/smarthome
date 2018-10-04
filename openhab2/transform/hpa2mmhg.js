(function(x) {
  if (x == "-" || x == "break") {
    return "Line break"
  }
  else {
    return (parseFloat(x) * 0.75006150504341).toFixed(1) + " mmHg"
  }
})(input);