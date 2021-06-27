func factorial_rec(x) {
  if (x < 1) {
    return 1;
  }
  return x * factorial_rec(x - 1);
}

var x = #input();
if (x == null | x < 0) {
  print("Invalid number");
} else {
  print("Rec: {factorial_rec(x)}");
}
