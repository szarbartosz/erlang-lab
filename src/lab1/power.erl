-module(power).

-export([power/2]).

power(_, 0) -> 1;
power(A, B) when B > 0 -> A * power(A, B - 1);
power(A, B) when B < 0 -> 1 / A * power(A, B + 1).