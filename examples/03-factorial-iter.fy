func factorial_iter(x) {
  if (x < 1) {
    return 1;
  }
  var res = 1;
  for (; x > 1; x -= 1) {
    res *= x;
  }
  return res;
}

var x = #input();
if (x == null | x < 0) {
  print("Invalid number");
} else {
  print("Iter: {factorial_iter(x)}");
}
