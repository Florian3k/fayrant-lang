var arr = Array(1, 2, 3, 4);

for (var i = 0; i < arr.size(); i += 1) {
  print("i -> {arr.get(i)}");
}

arr.set(1, 7);
arr.push(5);

print("------");

for (var i = 0; i < arr.size(); i += 1) {
  print("i -> {arr.get(i)}");
}
print("pop -> {arr.pop()}");
print("pop -> {arr.pop()}");
print("pop -> {arr.pop()}");
