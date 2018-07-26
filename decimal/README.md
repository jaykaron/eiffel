# Decimal

decimal: includes BIG_INTEGER, RATIONAL and DECIMAL. The ECF file is currently: Eiffel18.07

# To Do
At the moment all the tests succeed but the clases and their tests are a hodpodge and the design needs to be seriuosly refactored. Testing needs to be more comprehensive and better organized. 

Note that in general BIG_INTEGER should not depend on RATIONAL which should not depend on DECIMAL. But this need not be strict when it comes to division. 

* Remove all dependencies on VALUE. Convert from big integers and rational to DECIMAL where this can be done. 
* Current comments in tests are too long so ESPEC output is too wide. Use sub_comment.
* Clean up design and do comprehensive testing of large numbers as well as all operations. 

## DECIMAL

This class is a wrapper for gobo decimal, see
[Gobo Decimal](https://www.gobosoft.com/eiffel/gobo/math/decimal/index.html). Finite numbers can be represented by a triad [sign, coefficient, exponent]
that fully represent a number. 

* [0, 2708, -2] represents 27.08;
* [1, 1289, 0] represents -1289.

Special numbers are:

* *Infinity*: a value whose magnitude is infinitely large. It may be positive or negative.
* quiet *NaN*: Undefined result ("Not a Number"), which shall not raise an Invalid operation signal.
* signaling NaN:  Undefined result, which shall raise an Invalid operation signal.

Gobo decimal supports +, -, *, /, //, \\, but not sqquare root exponent etc. that we have addeed and needs to be tested. 

### What needs to be done
* Clean up the design
* We need to support default precision and rounding, but also allow for higher precision and different rounding. See {DECIMAL_TEST1}`t2` for how this can be done. 
* Revisit the need for exceptions where there is division by zero
* Add support for all Gobo decimal operations 
* Constructors: from INTEGER\_64, REAL\_64, from string using Gobo's parse routine, BIG_INTEGER and RATIONAL. Convert back to these where possible. 
* Write significant tests using the old tests from VALUE as well. 

## RATIONAL
* Clean up the design
* A lot more testing

## BIG_INTEGER

* Clean up the design
* Integer divsion is very slow as we inherited from VALUE which wwas not intended for integers. 
* See [big integer js calculator](http://www.javascripter.net/math/calculators/100digitbigintcalculator.htm)