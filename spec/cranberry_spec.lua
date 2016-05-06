describe('cranberry', function()
  local cb = require 'cranberry'
  local t = { 1, { 'apple', 7 }, sayHello = function() return 'hello' end }
  local s = { 'a', 'b', 'c', 'd' }
  local a = { 1, 2, 3, 4 }
  
  test('map should apply a function to every member of the array', function()
    local v = cb.map(string.upper, s)
    assert.is_same(v, { 'A', 'B', 'C', 'D' })
    assert.is_same(s, { 'a', 'b', 'c', 'd' })
  end)

  test('foldr reduces the list from right to left using the function f', function()
    local function f(x, y) return x - y end
    local v = cb.foldr(f, 0, a)
    local w = cb.foldr1(f, a)
    assert.equals(v, 1 - (2 - (3 - (4 - 0))))
    assert.equals(w, 1 - (2 - (3 - 4)))
  end)
  
  test('foldl reduces the list from left to right using the function f', function()
    local function f(x, y) return x - y end
    local v = cb.foldl(f, 0, a)
    local w = cb.foldl1(f, a)
    assert.equals(v, (((0 - 1) - 2) - 3) - 4)
    assert.equals(w, ((1 - 2) - 3) - 4)
  end)
  
  test('filter takes a function and returns an array of all elements of an array that are true under that function', function()
    local v = cb.filter(function(x) return x % 2 == 0 end, a)
    assert.is_same(v, { 2, 4 })
  end)
  
  test('elem returns true if e is in a and false otherwise', function()
    assert.is_true(cb.elem('b', s))
    assert.is_not_true(cb.elem('z', s))
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
  
  test('all should return true if p(a[i]) is true for every element a[i] of a', function()
    assert.is_true(cb.all(function(v) return v < 10 end, a))
    assert.is_not_true(cb.all(function(v) return v ~= 2 end, a))
  end)
  
  test('any should return true if p(a[i]) is true for any element a[i] of a', function()
    assert.is_not_true(cb.any(function(v) return v > 10 end, a))
    assert.is_true(cb.any(function(v) return v == 2 end, a)) 
  end)
  
  test('none should return true if p(a[i]) is false for every element a[i] of a', function()
    assert.is_true(cb.none(function(v) return v > 10 end, a))
    assert.is_not_true(cb.none(function(v) return v == 2 end, a))  
  end)
  
  test('id is the identity', function()
    assert.equals(cb.id(2), 2)
    assert.equals(cb.id('a'), 'a')
    assert.equals(cb.id(t), t)
  end)
  
  test('const returns a function that returns the value given to const', function()
    local f = cb.const('a')
    assert.equals(f(3), 'a')
    assert.equals(f('q'), 'a')
    assert.equals(f(t), 'a')
  end)
  
  test('flip should return a function that takes its first two arguments in the reverse order of f', function()
    local f = function(a, b, c) return a .. b .. c end
    local g = cb.flip(f)
    assert.equals(f('a', 'b', 'c'), g('b', 'a', 'c'))
  end)
  
  test('applyUntil should apply f to each element of a until p returns true', function()
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
    assert.is_same(v, { 4, 3, 2, 1 })
    assert.is_same(a, { 1, 2, 3, 4 })
  end)
  
  test('concat should concatenate all of the elements of as', function()
    local r = cb.concat({ {1,2}, {3}, {4} })
    assert.is_same(r, a)
  end)
 
  test('scanl should return a list containing each of the intermediate steps of foldl', function()
    local function f(x, y) return x - y end
    local v = cb.scanl(f, 0, a)
    local w = cb.scanl1(f, a)
    assert.is_same(v, { 0, -1, -3, -6, -10 })
    assert.is_same(w, { 1, -1, -4, -8 })
  end)
 
  test('scanr should return a list containing each of the intermediate steps of foldr', function()
    local function f(x, y) return x - y end
    local v = cb.scanr(f, 0, a)
    local w = cb.scanr1(f, a)
    assert.is_same(v, { 0, 4, -1, 3, -2 })
    assert.is_same(w, { 4, -1, 3, -2 })
  end)
  
  --- Objects
  
  test('clone should allow access to their prototype\'s fields', function()
    local o = cb.clone(t)
    assert.equals(o.sayHello, t.sayHello)
  end)
  
  test('clone should not be able to modify their prototype\'s fields', function()
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
  
  test('is_immut should return true if the table was returned by immut and false otherwise', function()
    local nt = cb.immut(t)
    assert.is_true(cb.is_immut(nt))
    assert.is_not_true(cb.is_immut(t))
  end)
end)