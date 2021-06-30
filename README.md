# Fayrant-lang
### Simple, interpreted, dynamically-typed programming language

Authors:
- Mikołaj Fornal [@Florian3k](https://github.com/Florian3k)
- Paweł Karaś [@Ph0enixKM](https://github.com/Ph0enixKM)
- Maciej Witkowski [@MaciejWitkowskiDev](https://github.com/MaciejWitkowskiDev)

## Basic syntax

```=
~ this is comment

~ variable declaration
var something;
var something2 = 123;

~ simple types
something = null;

something = true;
something = false;

something = 1234;           ~ all numbers are 64-bit floating point (double)
something = 3.14159;
something = 0b100001011001; ~ binary literal
something = 0xDeadC0de;     ~ hexadecimal literal

something = "simple string";
something = "string with \n \t \\ \" \{ \} escapes";
something = "string with unicode escapes \u{65} \u{0x41}";
something = "string with interpolation { 2 + 3 + something2 }";
something = "string { "with { "nested" } interpolation" }";

~ unary and binary operators
something = !something;
something = -something;
something = @1234;    ~ conversion to string
something = #"1234";  ~ conversion to number

~ arithmetic
something = 1 + 2 - 3;
something = 1 * 2 + 3 / 4;
something = 4 \ 3;      ~ same as 3 / 4;
something = 2 ^ 3 ^ 4;  ~ exponentiation
something = 5 % 3;

~ comparison
something = 2 < 3;
something = 2 > 3;
something = 2 <= 3;
something = 2 >= 3;

something = 2 == 3;
something = 2 != 3;
something = "asd" == "def";
something = "asd" == 3;
something = "asd" == null;

something = "Hello " ++ "world!";  ~ string concatenation

~ logical
something = true & false;
something = true | false;

~ assignment operators
something = 1;
something += 2;
something -= 3;
something *= 4;
something /= 5;
something \= 6;
something %= 7;
something ^= 8;
something &= true;
something |= false;
something ++= "asdf";

~ basic io
something = input();  ~ returns string
print(something);     ~ prints anything

~ control flow

if (something > 5) {
  print("hello");
}

if (something == 7) {
  print("seven");
} else {
  print("not seven");
}

while (something > 0) {
  something -= 1;
}

for (var i = 0; i < 3; i += 1) {
  print(i);
}

while (true) {
  if (true) {
    break;
  }
}

for (var i = 0; i < 3; i += 1) {
  if (i == 2) {
    continue;
  }
  print(i);
}
```

### Functions example
```=
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
print("Iter: {factorial_iter(x)}");
print("Rec: {factorial_rec(x)}");
```

### Class example
```=
class Vec2d {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }

  func plus(other) {
    return Vec2d(this.x + other.x, this.y + other.y);
  }
  
  func norm() {
    return (this.x ^ 2 + this.y ^ 2) ^ 0.5;
  }
  
  func str() {
    return "Vec[{this.x},{this.y}]";
  } 
}

var v1 = Vec2d(3, 4);
var v2 = Vec2d(4, 5);
var v3 = v1.plus(v2);

print("{v1.str()} + {v2.str()} = {v2.str()}")
```

## FAQ:

### Why Fayrant name?
It's a tribute to this outstanding beverage

![](https://i.imgur.com/7Ni6osS.png)
