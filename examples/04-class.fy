class Example {
  constructor(a, b) {
    this.x = a;
    this.y = b;
  }

  func test(a, b) {
    return this.x * a + this.y * b;
  }
}

var ob = Example(2, 3);
ob.c = Example(4, 5);
ob.c.d = Example(4, 5);
ob.c.d.e = 9;
ob.c.d.e *= 2;
print("hello {ob.c.d.e}");
print(ob.test(5, 7));
