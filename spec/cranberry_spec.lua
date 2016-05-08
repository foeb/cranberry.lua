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
    assert.is_same(
      { fruit = true, color = 'orange', flavor = 'sweet' },
      cb.defaults_(d, o)
    )
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
  
  test('new should return a copy of the object', function()
    local o = cb.object:clone('fruit')
    local o2 = o:new()
    assert.equals(o._type, o2._type)
    assert.equals(o._super, o2._super)
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
  
  test('is_table should return true iff it is a table', function()
    assert.is_true(cb.is_table(t))
    assert.is_not_true()
  end)
end)