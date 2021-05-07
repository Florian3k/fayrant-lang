func factorial_iter(x) {
  if (x < 1) {
    return 1;
  }
  var res = 1;
  while (x > 1) {
    res *= x;
    x -= 1;
  }
  return res;
}

func factorial_rec(x) {
  if (x < 1) {
    return 1;
  }
  return x * factorial_rec(x - 1);
}

var x = #input();
if (x == null | x < 1) {
  print("Invalid number");
  return;
}
print("Iter: {factorial_iter(x)}")
print("Rec: {factorial_rec(x)}")
