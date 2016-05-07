
local cb = {}

local log = require 'log'

-- TODO: find a way to access lua_createtable in order to avoid triggering 
-- rehashes when initializing arrays. decide if this is important or necessary
-- TODO: include a submodule of pre-curried functions

-- library functions made local for efficiency
local min = math.min
local max = math.max
local floor = math.floor
local remove = table.remove
local insert = table.insert
local concat = table.concat
local unpack = unpack or table.unpack -- 5.1, 5.2, and 5.3 compatibility

-- push_(a, v): destructively append v to an array a
function cb.push_(a, v)
  return insert(a, v)
end

-- pop_(a): destructively remove the last element of an array a and 
-- return it
function cb.pop_(a)
  return remove(a)
end

-- shift_(a): destructively remove the first element of an array a and 
-- return it
function cb.shift_(a)
  return remove(a, 1)
end

-- unshift_(a, v): destructively insert v at the beginning of a
function cb.unshift_(a, v)
  return insert(a, 1, v)
end

-- map(f, a): apply a function f to every member of the array a (pure)
function cb.map(f, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local na = {}
  for i = 1, #a do
    na[i] = f(a[i])
  end
  return na
end

-- map_(f, a): destructively apply a function f to every member of the 
-- array a
function cb.map_(f, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  for i = 1, #a do
    a[i] = f(a[i])
  end
  return a
end

-- foldr(f, a0, a): reduce the array a from right to left using a0 as the 
-- starting value
function cb.foldr(f, a0, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local r = a0
  local len = #a
  for i = 1, len do
    r = f(a[len + 1 - i], r)
  end
  return r
end

-- foldl(f, a0, a): reduce the array a from left to right using a0 as the 
-- starting value
function cb.foldl(f, a0, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local r = a0
  for i = 1, #a do
    r = f(r, a[i])
  end
  return r
end

-- foldr1(f, a): reduce the array a from right to left
function cb.foldr1(f, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end 
  if a[1] == nil then 
    return nil, cb.errors.empty
  end
  local len = #a
  if len == 1 then return a[1] end
  local r = a[len]
  for i = 2, len do
    r = f(a[len + 1 - i], r)
  end
  return r
end

-- foldl1(f, a): reduce the array a from left to right
function cb.foldl1(f, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end 
  if a[1] == nil then 
    return nil, cb.errors.empty
  end
  local r = a[1]
  local len = #a
  if len == 1 then return r end
  for i = 2, len do
    r = f(r, a[i])
  end
  return r
end

-- filter(f, a): return an array containing all elements of an array a that 
-- are true under the function f(v)
function cb.filter(f, a)
  local function g(_, v) return f(v) end
  return cb.filteri(g, a)
end

-- filteri(f, a): similar to filter, except it uses a function of the 
-- form f(i, v)
function cb.filteri(f, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  local j = 1
  for i = 1, #a do
    if f(i, a[i]) then 
      r[j] = a[i]
      j = j + 1
    end
  end
  return r
end

-- filterk(f, a): similar to filter, except it only operates on a hash 
-- table with the function f(k, v)
function cb.filterk(f, t)
  if not cb.is_table(t) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  for k, v in pairs(t) do
    if f(k, v) then 
      r[k] = v
    end
  end
  return r
end

-- elem(e, a): return true if element e is in an array a and false otherwise
function cb.elem(e, a)
  if not cb.is_table(a) then return false end
  for i = 1, #a do
    if e == a[i] then return true end
  end
  return false
end

-- curry(f, n = 2): curry f for the first n arguments so that 
-- curry(f, n)(x1)(x2)(..)(xn, ...) = f(x1, x2, .., xn, ...).
function cb.curry(f, n)
  n = n or 2
  local function g(args, n)
    if n < 1 then
      return f(unpack(args))
    else
      local function h(...)
        cb.append_(args, { ... })
        return g(args, n - 1)
      end
      return h
    end
  end
  return g({}, n)
end

-- uncurry(f, n = 2): the inverse of curry(f, n), 
-- i.e. uncurry(curry(f, m), n) = f iff m = n. Results are unpredicatble 
-- when m ~= n.
function cb.uncurry(f, n)
  n = n or 2
  local function g(...)
    local args = { ... }
    local r = f
    local len = min(n, #args)
    for i = 1, len do
      r = r(args[i])
    end
    return r -- use up the rest of the arguments
  end
  return g
end

-- max(a): return the max of the elements of a
function cb.max(a)
  return cb.foldl1(max, a)
end

-- min(a): return the min of the elements of a
function cb.min(a)
  return cb.foldl1(min, a)
end

-- sum(a): return the sum of the elements of a
function cb.sum(a)
  local function f(x, y) return x + y end
  return cb.foldl(f, 0, a) -- an empty sum is by convention 0
end

-- product(a): return the product of the elements of a
function cb.product(a)
  local function f(x, y) return x * y end
  return cb.foldl(f, 1, a) -- an empty product is by convention 1
end

-- all(p, a): return true if p(a[i]) is true for every element a[i] of a
function cb.all(p, a)
  for i = 1, #a do
    if not p(a[i]) then return false end
  end
  return true
end

-- any(p, a): return true if p(a[i]) is true for any element a[i] of a
function cb.any(p, a)
  for i = 1, #a do
    if p(a[i]) then return true end
  end
  return false
end

-- none(p, a): return true if p(a[i]) is false for every element a[i] of a
function cb.none(p, a)
  return not cb.any(p, a)
end

-- id(v): return v
function cb.id(v) return v end

-- const(v): return a function that always returns v
function cb.const(v) 
  local function f(_) return v end
  return f
end

-- flip(f): return a function that takes its first two arguments in the 
-- reverse order of f
function cb.flip(f)
  local function g(a, b, ...)
    return f(b, a, ...)
  end
  return g
end

-- applyUntil(p, f, a): apply f to each element of a until p returns true
function cb.applyUntil(p, f, a)
  if cb.is_table(a) then
    local r = {}
    for i = 1, #a do
      if p(a[i]) then return r end
      r[i] = f(a[i])
    end
    return r
  else
    if p(a) then return a else return f(a) end
  end
end

-- append(a1, a2): return a1 appended by a2
function cb.append(a1, a2)
  if not cb.is_table(a1) or not cb.is_table(a2) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  local len1 = #a1
  local len2 = #a2
  for i = 1, len1 do
    r[i] = a1[i]
  end
  for i = 1, len2 do
    r[i + len1] = a2[i]
  end
  return r
end

-- appendn(...): append all of the arguments
function cb.appendn(...)
  local args = { ... }
  if not cb.all(cb.is_table, args) then 
    return nil, cb.errors.not_table
  end
  return cb.foldr(cb.append, {}, args)
end

-- append_(a1, a2): destructively append a1 by a2
function cb.append_(a1, a2)
  if not cb.is_table(a1) or not cb.is_table(a2) then 
    return nil, cb.errors.not_table
  end
  local len1 = #a1
  local len2 = #a2
  for i = 1, len2 do
    a1[i + len1] = a2[i]
  end
  return a1
end

-- appendn_(...): destructively append all of the arguments
function cb.appendn_(...)
  local args = { ... }
  if not cb.all(cb.is_table, args) then 
    return nil, cb.errors.not_table
  end
  return cb.foldr(cb.append_, {}, args)
end

-- head(a, n = 1): return the first n elements of a in an array. 
-- If n == 1, then return the first element
function cb.head(a, n)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  if not n then return a[1] end -- n defaults to 1
  local r = {}
  local len = min(#a, n)
  for i = 1, len do
    r[i] = a[i]
  end
  return r
end

-- last(a, n = 1): return the last n elements of a. 
-- If n == 1, then return the last element
function cb.last(a, n)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local len = #a
  if not n then return a[len] end -- n defaults to 1
  local r = {}
  local m = min(len, n)
  for i = 1, m  do
    r[i] = a[i + len - m]
  end
  return r
end

-- tail(a, n = 1): return the elements of a after skipping n
function cb.tail(a, n)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  n = n or 1
  local r = {}
  local len = #a
  if len <= n then return {} end
  for i = n + 1, len do
    r[i - n] = a[i]
  end
  return r
end

-- init(a): return all but the last element of a
function cb.init(a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  return cb.head(a, #a - 1)
end

-- reverse(a): reverses an array a
function cb.reverse(a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  local len = #a
  for i = 1, len do r[i] = nil end -- to ensure elements don't go into the hash
  local n = floor(len/2)
  for i = 1, n do
    r[i], r[len - i + 1] = a[len - i + 1], a[i]
  end
  if len % 2 == 1 then r[n + 1] = a[n + 1] end
  return r
end

-- reverse_(a): destructively reverses an array in place
function cb.reverse_(a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local len = #a
  for i = 1, floor(len/2) do
    a[i], a[len - i + 1] = a[len - i + 1], a[i]
  end
  return a
end

-- concat(as): concatenate all of the elements of as
function cb.concat(as)
  return cb.appendn(unpack(as))
end

-- scanl(f, a0, a): is similar to foldl, except it returns a list 
-- containing each of the intermediate steps
function cb.scanl(f, a0, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end 
  local r = { a0 }
  for i = 1, #a do
    r[i + 1] = f(r[i], a[i])
  end
  return r
end


-- scanl1(f, a): is similar to foldl1, except it returns a list 
-- containing each of the intermediate steps
function cb.scanl1(f, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end 
  local r = { a[1] }
  for i = 1, #a - 1 do
    r[i + 1] = f(r[i], a[i + 1])
  end
  return r
end

-- scanr(f, a0, a): is similar to foldr, except it returns a list 
-- containing each of the intermediate steps
function cb.scanr(f, a0, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end 
  local r = { a0 }
  local len = #a
  for i = 1, len do
    r[i + 1] = f(a[len + 1 - i], r[i])
  end
  return r
end

-- scanr1(f, a): is similar to foldr1, except it returns a list 
-- containing each of the intermediate steps
function cb.scanr1(f, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end 
  local len = #a
  local r = { a[len] }
  for i = 1, len - 1 do
    r[i + 1] = f(a[len - i], r[i])
  end
  return r
end

-- take(n, a): flip(head)
cb.take = cb.flip(cb.head)

-- drop(n, a): flip(tail)
cb.drop = cb.flip(cb.tail)

-- splitAt(n, a): return { take(n, a), drop(n, a) }
function cb.splitAt(n, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end 
  if n < 1 or #a < n then 
    return nil, cb.errors.outOfBounds
  end
  return { cb.take(n, a), cb.drop(n, a) }
end

-- takeWhile(p, a): return the longest prefix of a that all satisfy p
function cb.takeWhile(p, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  for i = 1, #a do
    if not p(a[i]) then return r end
    r[i] = a[i]
  end
  return r
end

-- dropWhile(p, a): return the elements remaining after takeWhile(p, a)
function cb.dropWhile(p, a)
  if not cb.is_table(a) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  local s
  for i = 1, #a do
    if not s and not p(a[i]) then s = i end
    if s then r[i - s + 1] = a[i] end
  end
  return r
end

-- span(p, a): return { takeWhile(p, a), dropWhile(p, a) }
function cb.span(p, a)
  return { cb.takeWhile(p, a), cb.dropWhile(p, a) }
end

-- zip(a, b): return an array of corresponding pairs of elements from 
-- a and b. If one array is short, then the remaining elements of the 
-- longer array are discarded
function cb.zip(a, b)
  if not cb.is_table(a) or not cb.is_table(b) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  for i = 1, min(#a, #b) do
    r[i] = { a[i], b[i] }
  end
  return r
end

-- zip3(a, b, c): similar to zip, except it takes three arrays instead of two
function cb.zip3(a, b, c)
  if not cb.is_table(a) or not cb.is_table(b) or not cb.is_table(c) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  for i = 1, min(#a, #b, #c) do
    r[i] = { a[i], b[i], c[i] }
  end
  return r
end

-- zipWith(f, a, b): return an array of the function f applied to 
-- corresponding pairs of elements from a and b. If one array is short, 
-- then the remaining elements of the longer array are discarded
function cb.zipWith(f, a, b)
  if not cb.is_table(a) or not cb.is_table(b) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  for i = 1, min(#a, #b) do
    r[i] = f(a[i], b[i])
  end
  return r
end

-- zipWith3(f, a, b, c): similar to zipWith, except it takes three arrays 
-- instead of two
function cb.zipWith3(f, a, b, c)
  if not cb.is_table(a) or not cb.is_table(b) or not cb.is_table(c) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  for i = 1, min(#a, #b, #c) do
    r[i] = f(a[i], b[i], c[i])
  end
  return r
end

-- unzip(ps): take an array of pairs and return an pair of arrays
function cb.unzip(ps)
  if not cb.is_table(ps) then 
    return nil, cb.errors.not_table
  end
  local r = { {}, {} }
  for i = 1, #ps do
    if not cb.is_table(ps[i]) then
      return nil, cb.errors.not_table
    end
    r[1][i] = ps[i][1]
    r[2][i] = ps[i][2]
  end
  return r
end

-- unzip3(ts): similar to unzip, except it takes an array of triples 
-- instead of pairs
function cb.unzip3(ts)
  if not cb.is_table(ts) then 
    return nil, cb.errors.not_table
  end
  local r = { {}, {}, {} }
  for i = 1, #ts do
    if not cb.is_table(ts[i]) then
      return nil, cb.errors.not_table
    end
    r[1][i] = ts[i][1]
    r[2][i] = ts[i][2]
    r[3][i] = ts[i][3]
  end
  return r
end

-- lines(s): return an array of all lines in s. Does not work register
-- \r characters.
function cb.lines(s)
  if not cb.is_string(s) then
    return nil, cb.errors.not_string
  end
  local r = {}
  local ri = 1
  local si = 1
  local prev = 1
  for si = 1, s:len() do
    if s:sub(si, si) == '\n' then
      r[ri] = s:sub(prev, si - 1)
      prev = si + 1
      ri = ri + 1
    end
  end
  r[ri] = s:sub(prev, -1)
  if r[ri] == '' then r[ri] = nil end -- following Haskell's example
  return r -- TODO: make sure that each line doesn't include the newline character
end

-- unlines(as): concatenate all of the strings in as, separated by a newline
function cb.unlines(as)
  return concat(as, '\n')
end

-- words(s): return an array of all words in s that are separated by 
-- whitespace
-- Credit to http://lua-users.org/wiki/StringRecipes
function cb.words(s)
  if not cb.is_string(s) then
    return nil, cb.errors.not_string
  end
  local r = {}
  local i = 1
  for word in s:gmatch("%S+") do
    r[i] = word
    i = i + 1
  end
  return r
end

-- unwords(as): concatenate all of the strings in as, separated by a space
function cb.unwords(as)
  return concat(as, ' ')
end

-- wrap(f, w): return bind(w, f), so that wrap(f, w)(...) = w(f, ...)
function cb.wrap(f, w)
  return cb.bind(w, f)
end

-- uniq(a): return an array containing all of a's unique values
function cb.uniq(a)
  if not cb.is_table(a) then return a end
  local r = {}
  local ri = 1
  for i = 1, #a do
    if not cb.elem(a[i], r) then
      r[ri] = a[i]
      ri = ri + 1
    end
  end
  return r
end

-- negate(p): return a function q such that q(v) = not p(v)
function cb.negate(p)
  local function q(v)
    return not p(v)
  end
  return q
end

-- bind(f, v): return a function g(...) = f(v, ...)
function cb.bind(f, v)
  local function g(...)
    return f(v, ...)
  end
  return g
end

-- bindn(f, ...): return a function g(...2) = f(v, ..., ...2)
function cb.bindn(f, ...)
  return cb.foldl(cb.bind, f, { ... })
end

-- result(m, o, ...): return o:m(...)
function cb.result(m, o, ...)
  return m(o, ...)
end

-- defaults(d, o): like defaults_, except it returns a new table
function cb.defaults(d, o)
  local r = {}
  for k, v in pairs(d) do
    r[k] = v
  end
  for k, v in pairs(o) do
    r[k] = v
  end
  return r
end

-- defaults_(d, o): for each key k in d, if o[k] == nil, then o[k] = d[k]. 
-- Return the resulting object (destructive)
function cb.defaults_(d, o)
  for k, v in pairs(d) do
    if o[k] == nil then
      o[k] = v
    end
  end
  return o
end

-- trycatch(f, errors, ?finally): wrap f in a function such that, when it is
-- called, if f returns nil for its first value, then the wrapper checks
-- errors using the second value returned for a function. If it finds one,
-- it calls it with the original arguments and returns its result. The
-- optional finally function is called after either of these happens.
function cb.trycatch(f, errors, finally)
  finally = finally or cb.id
  local function wrap(...)
    local res = { f(...) }
    if res[1] == nil then
      if res[2] and errors[res[2]] then
        local nres = { errors[res[2]](...) }
        finally()
        return unpack(nres)
      end
    end
    finally()
    return res[1]
  end
  return wrap
end

-- errors: a table of common error strings
cb.errors = {
  not_string = 'Not a string',
  not_table = 'Not a table',
  not_number = 'Not a number',
  not_bool = 'Not a bool',
  not_function = 'Not a function',
  not_callable = 'Not callable',
  immut = 'Can\'t modify an immutable table',
  outOfBounds = 'Variable is out of bounds',
  empty = 'Array is empty'
}

-- is_same(t1, t2): return true if t1 and t2 are 'essentially' equal, not
-- including functions that return the same things.
function cb.is_same(t1, t2)
  if not cb.is_table(t1) or not cb.is_table(t2) then
    return t1 == t2
  end
  for k, v in pairs(t1) do
    if not cb.is_same(v, t2[k]) then
      return false
    end
  end
  return cb.is_same(getmetatable(t1), getmetatable(t2))
end

-- pluck
-- shuffle
-- sort
-- sortBy
-- groupBy
-- indexBy
-- countBy

-- once(f): return a function that only returns a value the first time it 
-- is called
function cb.once(f)
  return cb.before(f, 1)
end

-- after(f, n = 1): return a function that only returns a value after the 
-- first n times it is called
function cb.after(f, n)
  n = n or 1
  local i = 1
  local function g(...)
    if i > n then
      return f(...)
    end
    i = i + 1
  end
  return g
end

-- before(f, n = 1): return a function that only returns a value before 
-- the first n times it is called
function cb.before(f, n)
  n = n or 1
  local i = 1
  local function g(...)
    if i <= n then
      i = i + 1
      return f(...)
    end
  end
  return g
end

-- compose(f, ...): return a function g(args) = f(f1(f2(..(fn(args))))) 
-- where { f1, f2, .., fn } = { ... }
function cb.compose(f, ...)
  local function _compose(a, b)
    local function g(...)
      return a(b(...))
    end
    return g
  end
  return cb.foldr1(_compose, { f, ... })
end

-- takei(it, n): return an iterator that returns only the first n values of it
cb.takei = cb.before

-- dropi(it, n): return an iterator that skips the first n values of it
cb.dropi = cb.after

-- iterate(f, x): return an iterator that applies f to the previous value in an endless loop
function cb.iterate(f, x)
  local prev = x
  local function it()
    local old = prev
    prev = f(prev)
    return old
  end
  return it
end

-- replicate(n, x): return an array containing x n times
function cb.replicate(n, x)
  return cb.iterlist(cb.takei(cb.const(x), n))
end

-- cycle(a): return an iterator that cycles through an array a in an endless loop
function cb.cycle(a)
  local len = #a
  local i = 0
  local function it()
    if i >= len then i = 0 end
    i = i + 1
    return a[i]
  end
  return it
end

-- takeWhilei(p, it): analagous to takeWhile, except takes an iterator
function cb.takeWhilei(p, it)
  local continue = true
  local v
  local function nit()
    if continue then
      v = it()
      continue = p(v)
      return v
    end
  end
  return nit
end

-- dropWhilei(p, it): analagous to dropWhile, except takes an iterator
function cb.dropWhilei(p, it)
  local drop = true
  local v
  local function nit()
    v = it()
    if drop then
      drop = p(v)
    else
      return v
    end
  end
  return nit
end

-- iterlist(it): return an array containing all of the values of the iterator it
function cb.iterlist(it)
  local r = {}
  local i = 1
  local v
  while true do
    v = it()
    if not v then return r end
    r[i] = v
    i = i + 1
  end
end

-- clone(o, ?_type): return an instance of o as a prototype
function cb.clone(o, _type)
  if not cb.is_table(o) then return o end
  local t = { _proto = o, _type = _type or o._type }
  setmetatable(t, { __index = o })
  return t
end

-- object:isa(t, o): return true if t descends from o
function cb.isa(t, o)
  local function getProtoIter(s) 
    local v = s
    return function()
      if v then 
        v = v._proto
        return v
      end
    end
  end
  
  if t == o then return true end
  
  for p in getProtoIter(t) do
    if p == o then return true end
  end

  return false
end

-- object: base prototype to inherit from
cb.object = { _type = 'object' }

-- object:clone(?_type): return an instance of object as a prototype
cb.object.clone = cb.clone

-- object:isa(o): return true if self descends from o
cb.object.isa = cb.isa

-- keys(t): return all of the non-integer keys of t
function cb.keys(t)
  if not cb.is_table(t) then 
    return nil, cb.errors.not_table
  end
  local r = {}
  local ri = 1
  for k, v in pairs(t) do
    if not cb.is_number(v) then
      r[ri] = k
      ri = ri + 1
    end
  end
  return r
end

-- allKeys(t): return all of the non-integer keys of t and its prototypes
function cb.allKeys(t)
  if not cb.is_table(t) then 
    return nil, cb.errors.not_table
  end
  local prev = t
  local function it() -- iterate across the prototypes
    local p = prev._proto
    prev = p
    return prev
  end
  return cb.keys(cb.foldr1(cb.defaults, cb.listiter(it)))
end

-- setKeys_(o, t): set o[k] to t[k] for each k in keys(t)
function cb.setKeys_(o, t)
  local ks = cb.keys(t)
  for k, v in pairs(ks) do
    o[k] = v
  end
  return o
end

-- values(t): return the values of all of the non-integer keys of t
function cb.values(t)
  -- TODO: make more efficient
  local function f(k) return t[k] end
  return cb.map(f, cb.keys(t))
end

-- allValues(t): return the values of all of the non-integer keys of t and 
-- its prototypes
function cb.allValues(t)
  -- TODO: make more efficient
  local function f(k) return t[k] end
  return cb.map(f, cb.allKeys(t))
end

-- mapObject(f, o): like map but includes the hashtable side

-- copy(t): return a deep copy of t
-- Credit to @tylerneylon
-- Source: https://gist.github.com/tylerneylon/81333721109155b2d244
function cb.copy(o, seen)
  -- Handle non-tables and previously-seen tables.
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  
  -- New table; mark it as seen an copy recursively.
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy3(k, s)] = copy3(v, s) end
  return res
end

-- shallowcopy(t): return a shallow copy of t
-- Credit to @MihailJP
-- Source: https://gist.github.com/MihailJP/3931841
function cb.shallowcopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do target[k] = v end
  setmetatable(target, meta)
  return target
end

-- immut(t): return a read-only link to t
function cb.immut(t)
  if not cb.is_table(t) then return t end
  local nt = { _immut = true, _orig = t }
  local function _fi(_, k) return cb.immut(t[k]) end
  local function _fni () return nil, cb.errors.immut end 
  setmetatable(nt, { 
    __index = _fi,
    __newindex = _fni
  })
  return nt
end

-- is_immut(t): return true if t was made immutable through immut
function cb.is_immut(t)
  return t._immut
end

-- fromimmut(t): return a mutable version of t
function cb.fromimmut(t)
  if not cb.is_table(t) then return t end
  if not t._immut then return t end
  return t._orig
end

-- is_empty(t): return true if t is empty
function cb.is_empty(t)
  return next(t) == nil
end

-- is_table(o): return true if o is a table
function cb.is_table(o)
  if type(o) == 'table' then return true end
  return false
end

-- is_string(o): return true if o is a string
function cb.is_string(o)
  if type(o) == 'string' then return true end
  return false
end

-- is_number(o): return true if o is a number
function cb.is_number(o)
  if type(o) == 'number' then return true end
  return false
end

return cb

-- References:
-- https://hackage.haskell.org/package/base-4.8.2.0/docs/Prelude.html
-- http://underscorejs.org
-- https://github.com/Yonaba/Moses
-- https://github.com/Suor/funcy
-- http://ramdajs.com/docs/
-- http://bolinfest.com/javascript/inheritance.php
-- http://clojure.github.io/clojure/clojure.walk-api.html
