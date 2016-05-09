# cranberry.lua

__Cranberry__ is a Lua library that aims to make functional programming easier by providing a set of useful and frequently needed functions, inspired by the Haskell Prelude and Underscore.js. 

__Note: cranberry.lua is a *very* new project and it is very likely that it will change drastically in the near future. Don't use it for any projects in the meantime.__

## Usage

Drop cranberry.lua into your source directory and require it.

```
local u = require 'cranberry'

-- create a function that multiplies its input by two and then adds one
local f = u.compose(u.inc, u.bind(u.op.mul, 2))
print(f(2))
-- 5

-- use this function to iteratively create a list
local a = u.map(f, u.iterlist(u.takei(5, u.iterate(f, 0))))
u.each(print, a)
-- 1
-- 3
-- 7
-- 15
-- 31

-- add up all of the values
local v = u.foldr(u.op.add, 0, a) -- or you can do u.sum(a)
print(v)
-- 57
```

## Tests

This project uses busted for its unit tests. To run the the tests, install busted and call `busted` in the main folder.

## Manifest

Cranberry currently contains these functions:

### Arrays
- `push_(a, v)`
- `pop_(a)`
- `shift_(a)`
- `unshift_(a, v)`
- `map(f, a)`
- `map_(f, a)`
- `each(f, a)`
- `foldr(f, a0, a)`
- `foldr1(f, a)`
- `foldl(f, a0, a)`
- `foldl1(f, a)`
- `filter(f, a)`
- `elem(e, a)`
- `max(a)`
- `min(a)`
- `sum(a)`
- `product(a)`
- `all(p, a)`
- `any(p, a)`
- `none(p, a)`
- `applyUntil(p, f, a)`
- `append(...)`
- `append_(...)`
- `head(a, n = 1)`
- `last(a, n = 1)`
- `tail(a, n = 1)`
- `init(a)`
- `reverse(a)`
- `reverse_(a)`
- `concat(as)`
- `scanr(f, a0, a)`
- `scanr1(f, a)`
- `scanl(f, a0, a)`
- `scanl1(f, a)`
- `take(n, a)`
- `drop(n, a)`
- `splitAt(n, a)`
- `takeWhile(p, a)`
- `dropWhile(p, a)`
- `span(p, a)`
- `zip(a, b)`
- `zip3(a, b, c)`
- `zipWith(f, a, b)`
- `zipWith3(f, a, b, c)`
- `unzip(ps)`
- `unzip3(ts)`
- `lines(s)`
- `unlines(as)`
- `words(s)`
- `unwords(as)`
- `shuffle(a)`
- `shuffle_(a)`
- `merge(a, b, comp = op.lt)`
- `mergesort(a, comp = op.lt)`
- `sort(a, comp = op.lt)`
- `sort_(a, comp = op.lt)`
- `sortBy(a, f, comp = op.lt)`
- `groupBy(a, f)`
- `countBy(a, f)`
- `replicate(n, x)`
 
### Functions
- `id(v)`
- `const(v)`
- `flip(f)`
- `curry(f, n = 2)`
- `uncurry(f, n = 2)`
- `wrap(f, w)`
- `uniq(a)`
- `negate(p)`
- `bind(f, v)`
- `bindn(f, ...)`
- `once(f)`
- `after(f, n)`
- `before(f, n)`
- `compose(f, ...)`
- `inc(i)`
- `dec(i)`
- `trycatch(f, errors, finally)`
- `errors`
- `op.add(a, b)`
- `op.sub(a, b)`
- `op.mul(a, b)`
- `op.div(a, b)`
- `op.mod(a, b)`
- `op.unm(a)`
- `op.concat(a, b)`
- `op.len(a)`
- `op.eq(a, b)`
- `op.neq(a, b)`
- `op.lt(a, b)`
- `op.gt(a, b)`
- `op.le(a, b)`
- `op.ge(a, b)`
- `op.opAnd(a, b)`
- `op.opOr(a, b)`
- `op.opNot(a, b)`
- `op.newtable(...)`
- `op.funcall(f, ...)`
- `op.index(t, k)`
- `op.newindex(t, k, v)`
 
### Iterators
- `takei(n, it)`
- `dropi(n, it)`
- `iterate(f, x)`
- `cycle(a)`
- `takeWhilei(p, it)`
- `dropWhilei(p, it)`
- `iterlist(it)`
 
### Tables
- `copy(t)`
- `shallowcopy(t)`
- `immut(t)`
- `is_immut(t)`
- `from_immut(t)`
- `is_same(t1, t2)`
- `pluck(t, k)`
- `keys(t)`
- `allKeys(t)`
- `setKeys_(o, t)`
- `values(t)`
- `allValues(t)`
- `defaults_(d, t)`
- `mapObject(f, t)`
- `mapObject_(f, t)`
- `filterObject(f, t)`
 
### Objects
- `object:duplicate()`
- `object:new(...)`
- `object:init()`
- `object:clone(_type = self._type)`
- `object:isa(o)`
- `result(m, o, ...)`
- `is_empty(t)`
- `is_table(o)`
- `is_string(o)`
- `is_number(o)`
- `is_function(o)`
- `is_boolean(o)`
- `is_nil(o)`
- `is_userdata(o)`
- `is_thread(o)`
 

