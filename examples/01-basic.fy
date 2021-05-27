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