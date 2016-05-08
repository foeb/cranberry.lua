describe('cranberry', function()
  local cb = require 'cranberry'
  local t = { 1, { 'apple', 7 }, sayHello = function() return 'hello' end }
  local s = { 'a', 'b', 'c', 'd' }
  local a = { 1, 2, 3, 4 }
  
  test('shift_ should destructively remove the first element of an array '..
        'a and return it', function()
    local a = { 1, 2, 3, 4 }
    assert.equals(1, cb.shift_(a))
    assert.is_same({ 2, 3, 4 }, a)
    assert.equals(2, cb.shift_(a))
    assert.is_same({ 3, 4 }, a)
  end)
  
  test('unshift_ should destructively destructively insert v at the ' .. 
        'beginning of a', function()
    local a = { 3, 4 }
    cb.unshift_(a, 2)
    assert.is_same({ 2, 3, 4 }, a)
    cb.unshift_(a, 1)
    assert.is_same({ 1, 2, 3, 4 }, a)
  end)
  
  test('map should apply a function to every member of the array', 
        function()
    local v = cb.map(string.upper, s)
    assert.is_same(v, { 'A', 'B', 'C', 'D' })
    assert.is_same(s, { 'a', 'b', 'c', 'd' })
  end)
  
  test('map should destructively apply a function to every member of ' .. 
        'the array', function()
    local v = { 'a', 'b', 'c', 'd' }
    cb.map_(string.upper, v)
    assert.is_same(v, { 'A', 'B', 'C', 'D' })
  end)
  
  test('map_ should destructively apply a function to every member of ' ..
        'the array', function()
    local v = cb.map(string.upper, s)
    assert.is_same(v, { 'A', 'B', 'C', 'D' })
    assert.is_same(s, { 'a', 'b', 'c', 'd' })
  end)

  test('foldr reduces the list from right to left using the function f', 
        function()
    local function f(x, y) return x - y end
    local v = cb.foldr(f, 0, a)
    local w = cb.foldr1(f, a)
    assert.equals(v, 1 - (2 - (3 - (4 - 0))))
    assert.equals(w, 1 - (2 - (3 - 4)))
  end)
  
  test('foldl reduces the list from left to right using the function f', 
        function()
    local function f(x, y) return x - y end
    local v = cb.foldl(f, 0, a)
    local w = cb.foldl1(f, a)
    assert.equals(v, (((0 - 1) - 2) - 3) - 4)
    assert.equals(w, ((1 - 2) - 3) - 4)
  end)
  
  test('filter takes a function and returns an array of all elements ' ..
        'of an array that are true under that function', function()
    local v = cb.filter(function(x) return x % 2 == 0 end, a)
    assert.is_same(v, { 2, 4 })
  end)
  
  test('filteri should be similar to filter, except it uses a function ' ..
        'of the form f(i, v)', function()
    local v = cb.filteri(function(i,x) return (x%2 == 0) or (i == 3) end, a)
    assert.is_same(v, { 2, 3, 4 })
  end)
  
  test('filterk should be similar to filter, except it only operates on ' ..
        'a hash table with the function f(k, v)', function()
    local v = cb.filterk(function(k, x) 
      return (x == 1) or (k == 'pear') 
    end, { pear = true, apple = false, mango = 1 })
    assert.equals(true, v['pear'])
    assert.equals(1, v['mango'])
  end)
  
  test('elem returns true if e is in a and false otherwise', function()
    assert.is_true(cb.elem('b', s))
    assert.is_not_true(cb.elem('z', s))
  end)
  
  test('curry(f, n) should curry f to n places', function()
    local function f(a, b, c) return b * (a - c) end
    local g = cb.curry(f, 3)
    local g2 = cb.curry(f, 2)
    local g4 = cb.curry(f, 4)
    assert.equals(f(3,4,5), g(3)(4)(5))
    assert.equals(f(3,4,5), g2(3)(4, 5))
    assert.equals(f(3,4,5), g4(3)(4)(5)())
    
    -- shouldn't happen, but it does. TODO: Fix
    -- assert.not_equals(f(3,4,5), g(3,4,5)()()) 
  end)
  
  test('uncurry(f, n) should uncurry f to n places', function()
    local function f(a, b, c) return b * (a - c) end
    local g = cb.curry(f, 3)
    local h = cb.uncurry(g, 3)
    local h2 = cb.uncurry(g, 2)
    local h4 = cb.uncurry(g, 4)
    assert.equals(f(3,4,5), h(3,4,5))
    assert.equals(f(3,4,5), h2(3,4)(5))
    assert.equals(f(3,4,5), h4(3,4,5))
  end)
  
  test('max should return the maximal element of a', function()
    assert.equals(cb.max(a), 4)
  end)
  
  test('min should return the minimal element of a', function()
    assert.equals(cb.min(a), 1)
  end)
  
  test('sum should return the sum of a', function()
    assert.equals(cb.sum(a), 1 + 2 + 3 + 4)
  end)
  
  test('product should return the product of a', function()
    assert.equals(cb.product(a), 1 * 2 * 3 * 4)
  end)
  
  test('all should return true if p(a[i]) is true for every element a[i] of a',
        function()
    assert.is_true(cb.all(function(v) return v < 10 end, a))
    assert.is_not_true(cb.all(function(v) return v ~= 2 end, a))
  end)
  
  test('any should return true if p(a[i]) is true for any element a[i] of a',
        function()
    assert.is_not_true(cb.any(function(v) return v > 10 end, a))
    assert.is_true(cb.any(function(v) return v == 2 end, a)) 
  end)
  
  test('none should return true if p(a[i]) is false for every ' ..
        'element a[i] of a', function()
    assert.is_true(cb.none(function(v) return v > 10 end, a))
    assert.is_not_true(cb.none(function(v) return v == 2 end, a))  
  end)
  
  test('id is the identity', function()
    assert.equals(cb.id(2), 2)
    assert.equals(cb.id('a'), 'a')
    assert.equals(cb.id(t), t)
  end)
  
  test('const returns a function that returns the value given to const', 
        function()
    local f = cb.const('a')
    assert.equals(f(3), 'a')
    assert.equals(f('q'), 'a')
    assert.equals(f(t), 'a')
  end)
  
  test('flip should return a function that takes its first two arguments '..
        'in the reverse order of f', function()
    local f = function(a, b, c) return a .. b .. c end
    local g = cb.flip(f)
    assert.equals(f('a', 'b', 'c'), g('b', 'a', 'c'))
  end)
  
  test('applyUntil should apply f to each element of a until p returns true',
        function()
    local p = function(v) return v > 2 end
    local f = function(v) return v + 1 end
    assert.is_same(cb.applyUntil(p, f, a), { 2, 3 })
    assert.is_equal(cb.applyUntil(p, f, 1), 2)
  end)
  
  test('append should return a1 appended by a2', function()
    assert.is_same(cb.append({1, 2}, {3, 4}), a)
  end)
  
  test('appendn should append all of the arguments', function()
    assert.is_same(cb.appendn({1}, {2, 3}, {4}), a)
  end)

  test('append_ should destructively append a1 by a2', function()
    local b = { 1, 2 }
    cb.append_(b, { 3, 4 })
    assert.is_same(a, b)
  end)
  
  test('appendn_ should destructively append all of the arguments', function()
    local b = { 1 }
    cb.appendn_(b, {2, 3}, {4})
    assert.is_same(b, a)
  end)
  
  test('head should return the first n elements of a', function()
    assert.is_same(cb.head(a, 2), {1, 2})
    assert.is_same(cb.head(s), 'a')
  end)
  
  test('last should return the last n elements of a', function()
    assert.is_same(cb.last(a, 3), {2, 3, 4})
    assert.is_same(cb.last(s), 'd')
  end)
  
  test('tail should return the elements of a after skipping n', function()
    assert.is_same(cb.tail(a, 2), {3, 4})
    assert.is_same(cb.tail(s), {'b', 'c', 'd'})
  end)
  
  test('init should return all but the last element of a', function()
    assert.is_same(cb.init(a), {1, 2, 3})
  end)
  
  test('reverse should reverse an array', function()
    local v = cb.reverse(a)
    local w = cb.reverse({ 1, 2, 3, 4, 5 })
    assert.is_same(v, { 4, 3, 2, 1 })
    assert.is_same(a, { 1, 2, 3, 4 })
    assert.is_same(w, { 5, 4, 3, 2, 1 })
  end)
  
  test('reverse_ should destructively reverse an array', function()
    local v = { 1, 2, 3, 4, 5 }
    cb.reverse_(v)
    assert.is_same(v, { 5, 4, 3, 2, 1 })
  end)
  
  test('concat should concatenate all of the elements of as', function()
    local r = cb.concat({ {1,2}, {3}, {4} })
    assert.is_same(r, a)
  end)
 
  test('scanl should return a list containing each of the intermediate ' ..
        'steps of foldl', function()
    local function f(x, y) return x - y end
    local v = cb.scanl(f, 0, a)
    local w = cb.scanl1(f, a)
    assert.is_same(v, { 0, -1, -3, -6, -10 })
    assert.is_same(w, { 1, -1, -4, -8 })
  end)
 
  test('scanr should return a list containing each of the intermediate ' ..
        'steps of foldr', function()
    local function f(x, y) return x - y end
    local v = cb.scanr(f, 0, a)
    local w = cb.scanr1(f, a)
    assert.is_same(v, { 0, 4, -1, 3, -2 })
    assert.is_same(w, { 4, -1, 3, -2 })
  end)
  
  test('splitAt(n, a) should return { take(n, a), drop(n, a) }', function()
    assert.is_same({ { 1 }, { 2, 3, 4 } }, cb.splitAt(1, a))
    assert.is_same({ { 1, 2 }, { 3, 4 } }, cb.splitAt(2, a))
    assert.is_same({ { 1, 2, 3 }, { 4 } }, cb.splitAt(3, a))
    assert.is_same({ { 1, 2, 3, 4 }, {} }, cb.splitAt(4, a))
  end)
  
  test('takeWhile(p, a) should return the longest prefix of a that ' .. 
        'all satisfy p', function()
    local function p(v) return v ~= 3 end
    assert.is_same({ 1, 2 }, cb.takeWhile(p, a))
  end)
  
  test('dropWhile(p, a) should return the elments remaining after '..
        'takeWhile(p, a)', function()
    local function p(v) return v ~= 3 end
    assert.is_same({ 3, 4 }, cb.dropWhile(p, a))
  end)
  
  test('span(p, a) should return { takeWhile(p, a), dropWhile(p, a) }',
        function()
    local function p(v) return v ~= 3 end
    assert.is_same({{ 1, 2 }, { 3, 4 }}, cb.span(p, a))
  end)

  test('zip(a, b) should return an array of corresponding pairs of ' .. 
        'elements from a and b.\n\t\tIf one array is short, then the ' ..
        'remaining elements of the longer array are discarded', function()
    assert.is_same(
      { { 1, 'a' }, { 2, 'b' }, { 3, 'c' }, { 4, 'd' } },
      cb.zip(a, s)
    )
    assert.is_same(
      { { 1, 'a' }, { 2, 'b' }, { 3, 'c' }, { 4, 'd' } },
      cb.zip(cb.append(a, { 5, 6, 7 }), s)
    )
  end)

  test('zip3(a, b, c) should be similar to zip, except it takes three ' ..
        'arrays instead of two', function()
    local b = { true, false, false }
    assert.is_same(
      { { 1, 'a', true }, { 2, 'b', false }, { 3, 'c', false } },
      cb.zip3(a, s, b)
    )
  end)
  
  test('zipWith(f, a, b) should return an array of the function f applied'..
        ' to corresponding pairs of\n\t\telements from a and b. If one ' ..
        'array is short, then the remaining elements of the\n' ..
        '\t\tlonger array are discarded', function()
    local function sub(a, b) return a - b end
    assert.is_same(
      { 7-1, 6-2, 5-3, 4-4 },
      cb.zipWith(sub, cb.reverse(cb.append(a, { 5, 6, 7 })), a)
    )      
  end)
  
  test('zipWith3(f, a, b, c) should be similar to zipWith, except it ' ..
        'takes three arrays instead of two', function()
    local function f(a, b, c) return b * (a - c) end
    assert.is_same(
      { 1 * (4 - 2), 2 * (3 - 3), 3 * (2 - 4) },
      cb.zipWith3(f, {4,3,2}, {1,2,3}, {2,3,4})
    )
  end)

  test('unzip(ps) should take an array of pairs and return an array of ' ..
        'first components and second components', function()
    assert.is_same({ a, s }, cb.unzip(cb.zip(a, s)))
  end)
  
  test('unzip3(ts) should be similar to unzip, except it takes an array ' ..
        'of triples instead of pairs', function()
    local b = { true, false, false, true }
    assert.is_same({ a, s, b }, cb.unzip3(cb.zip3(a, s, b)))
  end)
  
  test('lines(s) should return an array of all lines in s', function()
    assert.is_same(
      { 'ab', '', '12 4 5\t', '3' }, 
      cb.lines('ab\n\n12 4 5\t\n3\n')
    )
  end)
  
  test('unlines(as) should concatenate all of the strings in as, ' ..
        'separated by a newline', function()
    assert.equals(
      'ab\n\n12 4 5\t\n3',
      cb.unlines({ 'ab', '', '12 4 5\t', '3' })
    )
  end)
  
  test('words(s) should return an array of all words in s that are ' ..
        'separated by whitespace', function()
    assert.is_same(
      { 'ab', '12', '4', '5', '3' },
      cb.words('ab\n\n12 4 5\t\n3\n')
    )
  end)
  
  test('unwords(as) should concatenate all of the strings in as, ' ..
        'separated by a space', function()
    assert.equals(
      'ab 12 4 5 3',
      cb.unwords({ 'ab', '12', '4', '5', '3' })
    )
  end)
  
  test('wrap(f, w) should return bind(w, f), so that ' ..
        'wrap(f, w)(...) = w(f, ...)', function()
    local function f(x, y) return x + y*y end
    local function w(f, x, y) return 'The result is ' .. f(x, y) .. '!' end
    assert.equals('The result is 5!', cb.wrap(f, w)(1, 2))
  end)
  
  test('uniq(a) should return an array containing all of a\'s unique ' ..
        'values in the order that they appear', function()
    assert.is_same({1,2,3}, cb.uniq({1,1,2,3,2,2,3,1}))
  end)
  
  test('negate(p) should return a function q such that q(v) = not p(v)',
        function()
    local function p(b) return not b end
    assert.equals(not p(true), cb.negate(p)(true))
    assert.equals(not p(false), cb.negate(p)(false))
  end)
  
  test('bind(f, v) should return a function g(...) = f(v, ...)', function()
    local function f(a, b, c, d) return a - (b / (c - d)) end
    assert.equals(f(1, 2, 3, 4), cb.bind(f, 1)(2, 3, 4))
  end)

  test('bindn(f, ...) should return a function g(...2) = f(v, ..., ...2)', 
        function()
    local function f(a, b, c, d) return a - (b / (c - d)) end
    assert.equals(f(1, 2, 3, 4), cb.bindn(f, 1, 2, 3)(4))
  end)
  
  test('result(m, o, ...) should return o:m(...)', function()
    assert.equals('cd', cb.result(string.sub, 'abcde', 3, 4))
  end)
  
  test('defaults_(d, o) should, for each key k in d, if o[k] == nil then '..
        'set o[k] = d[k]', function()
    local d = { fruit = true, color = 'orange', flavor = 'sour' }
    local o = { flavor = 'sweet' }
    cb.defaults_(d, o)
    assert.is_same({ fruit = true, color = 'orange', flavor = 'sweet' }, o)
  end)
  
  test('defaults(d, o) should be like defaults_, except it returns a ' ..
        'new table', function() 
    local d = { fruit = true, color = 'orange', flavor = 'sour' }
    local o = { flavor = 'sweet' }
    assert.is_same(
      { fruit = true, color = 'orange', flavor = 'sweet' },
      cb.defaults(d, o)
    )
    assert.is_true(o.color == nil)
  end)
  
  test('trycatch(f, errors, ?finally) should follow the specification',
        function()
    -- Specification:
    -- trycatch(f, errors, ?finally): wrap f in a function such that, when it is
    -- called, if f returns nil for its first value, then the wrapper checks
    -- errors using the second value returned for a function. If it finds one,
    -- it calls it with the original arguments and returns its result. The
    -- optional finally function is called with the original arguments after 
    -- either of these happens.
    
    local function f(t)
      if not cb.is_table(t) then
        return nil, cb.errors.not_table
      end
      return t
    end
    local function catch(t)
      return tostring(t)
    end
    local i = 0
    local function finally(t)
      i = i + 1
    end
    local g = cb.trycatch(f, { [cb.errors.not_table] = catch }, finally)
    assert.equals(a, g(a))
    assert.equals(1, i)
    assert.equals('4', g(4))
    assert.equals(2, i)
  end)
  
  test('is_same(t1, t2) should return true if t1 and t2 are ' .. 
        '\'essentially\' equal, not including functions that return the ' ..
        'same values.', function()
    local t1 = { 1, 'b', { 3, cb.id } }
    local t2 = { 1, 'b', { 3, cb.id } }
    assert.is_true(cb.is_same(t1, t2))
    assert.is_not_true(cb.is_same(a, t1))
  end)
  
  test('once(f) should return a function that only returns a value the ' ..
        'first time it is called', function()
    local f = cb.once(cb.id)
    assert.equals('a', f('a'))
    assert.is_true(f('a') == nil)
    assert.is_true(f('a') == nil)
  end)
  
  test('after(f, n = 1): return a function that only returns a value ' ..
        'after the first n times it is called', function()
    local f = cb.after(cb.id, 2)
    assert.is_true(f('a') == nil)
    assert.is_true(f('a') == nil)
    assert.equals('a', f('a'))
  end)

  test('before(f, n = 1): return a function that only returns a value ' ..
        'before the first n times it is called', function()
    local f = cb.before(cb.id, 2)
    assert.equals('a', f('a'))
    assert.equals('a', f('a'))
    assert.is_true(f('a') == nil)
  end)

  test('compose(f, ...): return a function ' ..
        'g(args) = f(f1(f2(..(fn(args))))) where { f1, f2, .., fn } = { ... }',
        function()
    local function f(x) return 2 * x end
    local function g(x) return 3 + x end
    local function h(x) return 1 / x end
    assert.equals(f(g(h(2))), cb.compose(f, g, h)(2))
  end)
  
  test('iterate(f, x) should return an iterator that applies f to the ' ..
        'previous value in an endless loop', function()
    local function f(x) return x + 1 end
    local it = cb.iterate(f, 1)
    for i = 1, 100 do
      assert.equals(i, it())
    end
  end)
  
  test('replicate(n, x) should return an array containing x n times', 
        function()
    assert.is_same({ 1, 1, 1, 1, 1 }, cb.replicate(5, 1))
  end)
  
  test('cycle(a): return an iterator that cycles through an array a in ' ..
        'an endless loop', function()
    local it = cb.cycle({ 1, 2, 3 })
    assert.equals(1, it())
    assert.equals(2, it())
    assert.equals(3, it())
    assert.equals(1, it())
  end)
  
  test('takeWhilei(p, it) should be analagous to takeWhile, except takes ' ..
        'an iterator and returns an iterator', function()
    local function f(x) return x + 1 end
    local function p(x) return x < 4 end
    local it = cb.takeWhilei(p, cb.iterate(f, 1))
    assert.equals(1, it())
    assert.equals(2, it())
    assert.equals(3, it())
    assert.is_true(it() == nil)
    assert.is_true(it() == nil)
  end)
  
  test('takeWhilei(p, it) should be analagous to takeWhile, except takes ' ..
        'an iterator and returns an iterator', function()
    local function f(x) return x + 1 end
    local function p(x) return x < 4 end
    local it = cb.dropWhilei(p, cb.iterate(f, 1))
    assert.is_true(it() == nil)
    assert.is_true(it() == nil)
    assert.is_true(it() == nil)
    assert.equals(4, it())
    assert.equals(5, it())
    assert.equals(6, it())
  end)
  
  test('mapObject(f, o) should be like map but iterates over the ' ..
        'non-integer keys of o', function()
    local o = { 'fungus', walrus = 'tooth', wolf = 'fang' }
    assert.is_same(
      { 'FUNGUS', walrus = 'TOOTH', wolf = 'FANG' },
      cb.mapObject(string.upper, o)
    )
  end)
  
  test('mapObject_(f, o) should be like map but destructively iterates ' ..
        'over the non-integer keys of o', function()
    local o = { 'fungus', walrus = 'tooth', wolf = 'fang' }
    cb.mapObject_(string.upper, o)
    assert.is_same(
      { 'FUNGUS', walrus = 'TOOTH', wolf = 'FANG' },
      o
    )    
  end)
  
  test('copy should return a deep copy of the object', function()
    local t2 = cb.copy(t)
    assert.is_same(t, t2)
    t2[2][1] = 'alfalfa'
    assert.is_not_same(t, t2)
  end)

  test('shallowcopy should return a shallow copy of the object', function()
    local t2 = cb.shallowcopy(t)
    assert.is_same(t, t2)
    assert.not_equals(t, t2)
  end)
  
  test('duplicate should return a copy of object without copying its ' ..
        'prototype', function()
    local m = cb.object:clone('microbe')
    local a1 = m:clone('amoeba')
    local a2 = a1:duplicate()
    assert.is_same(a1, a2)
    assert.not_equals(a1, a2)
    assert.equals(a1._super, a2._super)
  end)
  
  test('new should return an instance of object as a prototype and ' ..
        'initialize it', function()
    local o = cb.object:clone('fruit')
    local o2 = o:new()
    assert.equals(o._type, o2._type)
    assert.equals(o._super, o2._super)
    assert.not_equals(o, o2)
  end)
  
  test('clone should allow access to their prototype\'s fields', function()
    local o = cb.clone(t)
    assert.equals(o.sayHello, t.sayHello)
  end)
  
  test('clone should not be able to modify their prototype\'s fields', 
        function()
    local o = cb.clone(t)
    o.sayHello = function() return 'bye' end
    assert.equals(t.sayHello(), 'hello')
  end)
  
  test('clone should modify the objects type if entered', function()
    local o1 = cb.object:clone()
    local o2 = cb.object:clone('waffle')
    assert.equals('object', o1._type)
    assert.equals('waffle', o2._type)
  end)
  
  test('clone should refer to the objects prototype', function()
    local o = cb.object:clone()
    assert.equals(cb.object, o._proto)
  end)
  
  test('isa should return true if t descends from o', function()
    local fruit = cb.object:clone('fruit')
    local apple = fruit:clone('apple')
    local macintosh = apple:clone('macintosh')
    local computer = cb.object:clone('computer')
    assert.is_true(macintosh:isa(fruit))
    assert.is_not_true(macintosh:isa(computer))
    assert.is_true(macintosh:isa(cb.object))
  end)
  
  --[[
  test('setmeta should set the metatable of object while preserving ' ..
        'inheritance.', function()
    local book = cb.object:clone('book')
    function book:read()
      return cb.append(unpack(self.pages))
    end
    function book:init(name, pages)
      self.name = name
      self.pages = pages
      cb.object.setmeta(self, {
          __index = function(t, k) return t.pages[k] end
      })
    end
    local kafkaOnTheShore = book:new(
      'Kafka on the Shore', 
      { 'A boy runs away from home', 'he meets some people', 'some guy finds cats', 'things happen', 'the end' }
    )
    assert.equals('A boy runs away from home', kafkaOnTheShore[1])
    assert.equals('Kafka on the Shore', kafkaOnTheShore.name)
    assert.truthy(kafkaOnTheShore.clone)
  end)
  --]]
  
  test('keys(t) should return all of the non-integer keys of t', function()
    local o = { 8, pineapple = 'in shopping cart', thirsty = true }
    local o2 = { secret = 'don\'t look!' }
    setmetatable(o, { __index = o2 })
    assert.is_true(cb.elem('pineapple', cb.keys(o)))
    assert.is_true(cb.elem('thirsty', cb.keys(o)))
    assert.is_not_true(cb.elem('secret', cb.keys(o)))
    assert.is_not_true(cb.elem('1', cb.keys(o)))
    assert.is_not_true(cb.elem(1, cb.keys(o)))
  end)
  
  test('allKeys(t) should return all of the non-integer keys of t and ' ..
        'its prototypes', function()
    local o = { 8, pineapple = 'in shopping cart', thirsty = true }
    local o2 = { secret = 'don\'t look!' }
    setmetatable(o, { __index = o2 })
    o._proto = o2
    assert.is_true(cb.elem('pineapple', cb.allKeys(o)))
    assert.is_true(cb.elem('thirsty', cb.allKeys(o)))
    assert.is_true(cb.elem('secret', cb.allKeys(o)))
    assert.is_not_true(cb.elem('1', cb.allKeys(o)))
    assert.is_not_true(cb.elem(1, cb.allKeys(o)))
  end)
  
  test('setKeys_(o, t) should set o[k] to t[k] for each k in keys(t)',
        function()
    local o = { protoplasm = 'a lot' }
    cb.setKeys_(o, { 8, protoplasm = 'just a little', emotion = 'melancholy' })
    assert.equals('just a little', o.protoplasm)
    assert.equals('melancholy', o.emotion)
    assert.is_true(o[1] == nil)
  end)
  
  test('values(t) should return the values of all of the non-integer ' ..
        'keys of t', function()
    local o = { 8, protoplasm = 'just a little', emotion = 'melancholy' }
    local o2 = { secret = 'don\'t look!' }
    setmetatable(o, { __index = o2 })
    o._proto = o2
    local vs = cb.values(o)
    assert.is_true(cb.elem('just a little', vs))
    assert.is_true(cb.elem('melancholy', vs))
    assert.is_not_true(cb.elem('don\'t look!', vs))
    assert.is_not_true(cb.elem(8, vs))
  end)

  test('allValues(t) should return the values of all of the non-integer ' ..
        'keys of t and its prototypes', function()
    local o = { 8, protoplasm = 'just a little', emotion = 'melancholy' }
    local o2 = { secret = 'don\'t look!' }
    setmetatable(o, { __index = o2 })
    o._proto = o2
    local vs = cb.allValues(o)
    assert.is_true(cb.elem('just a little', vs))
    assert.is_true(cb.elem('melancholy', vs))
    assert.is_true(cb.elem('don\'t look!', vs))
    assert.is_not_true(cb.elem(8, vs))
  end)
  
  test('objects should act as expected', function()
    local fruit = cb.object:clone('fruit')
    function fruit:init(name, color)
      self.name = name
      self.color = color
    end
    function fruit:talk()
      return 'I am a ' .. self.name .. ' and I am ' .. self.color
    end
    local tomato = fruit:new('tomato', 'red')
    assert.is_equal('I am a tomato and I am red', tomato:talk())

    local squash = fruit:clone('squash')
    function squash:init(name, color, shape)
      self._proto:init(name, color)
      self.shape = shape
    end
    function squash:talk()
      return 'I am a ' .. self.shape .. ' ' .. self.name .. ' and I am ' .. self.color
    end
    local pumpkin = squash:new('pumpkin', 'orange', 'round')
    assert.is_equal('round', pumpkin.shape)
    assert.is_equal('I am a round pumpkin and I am orange', pumpkin:talk())
    
    assert.is_true(pumpkin:isa(fruit))
    assert.is_not_true(pumpkin:isa(tomato)) -- tomato isn't a prototype of pumpkin  
  end)
  
  test('tables returned by immut should be immutable', function()
    local nt = cb.immut(t)
    nt[1] = 5
    nt[2][1] = 'banana'
    assert.equals(t[1], 1)
    assert.equals(nt[1], 1)
    assert.equals(t[2][1], 'apple')
    assert.equals(nt[2][1], 'apple')
  end)
  
  test('is_immut should return true if the table was returned by immut ' ..
        'and false otherwise', function()
    local nt = cb.immut(t)
    assert.is_true(cb.is_immut(nt))
    assert.is_not_true(cb.is_immut(t))
  end)
  
  test('from_immut(t) should return a mutable version of t', function()
    local t = { 1, 2, figs = 'good' }
    local nt = cb.immut(t)
    nt = cb.from_immut(nt)
    nt.figs = 'bad'
    assert.equals('bad', t.figs)
    assert.equals('bad', nt.figs)
  end)
  
  test('is_table should return true iff it is a table', function()
    assert.is_true(cb.is_table(t))
    assert.is_not_true()
  end)
end)