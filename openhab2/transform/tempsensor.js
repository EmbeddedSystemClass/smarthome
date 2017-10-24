(function(x) {
  if (x == "-" || x == "break") {
    return "Line break"
  }
  else {
    return x + " \xB0C";
  }
})(input);