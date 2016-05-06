
local cb = {}

-- map
-- map_
-- foldr
-- foldl
-- filter
-- filteri
-- filterk
-- contains/elem
-- curry
-- uncurry
-- max
-- min
-- sum
-- product
-- id
-- const
-- flip
-- until
-- append
-- append_
-- head
-- last
-- tail
-- init
-- reverse
-- reverse_
-- any
-- all
-- concat
-- scanl
-- scanr
-- take
-- take_
-- drop
-- splitAt
-- takeWhile
-- dropWhile
-- span
-- break
-- lookup
-- zip
-- zip3
-- zipWith
-- zipWith3
-- unzip
-- unzip3
-- lines
-- unlines
-- words
-- unwords
-- wrap
-- bind
-- result
-- defaults


-- takei (for iterators)
-- dropi (for iterators)
-- iterate
-- repeat
-- replicate
-- cycle
-- takeWhilei
-- dropWhilei
-- iterList (iterator to list)

--- Objects

-- clone: return an instance of o as a prototype
function cb.clone(o)
  local t = { _proto = o }
  setmetatable(t, { __index = o })
  return o
end

-- immut: return a read-only link to t
function cb.immut(t)
  local nt = { _immut = true }
  setmetatable(nt, { __index = t, __newindex = function() return end })
  return nt
end

-- is_immut: return true if t was made immutable through immut
function cb.is_immut(t)
  return t._immut
end

return cb