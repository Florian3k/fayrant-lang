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
print(ob.test(5, 7));
