-- Example of cranberry's utilities for prototypal OOP
-- Reasons for using prototypes: 
-- * Changes to the object instantly propagate to its children.
-- * There's no magic--objects are just tables with their __index pointing to their prototype.
-- * In the same spirit as above, they're simple and easy to extend.
--
-- Objects and prototypes aren't capitalized because they are the same thing--there are no classes.

local fruit = u.object:clone('fruit')

function fruit:init(name, color)
  self.name = name
  self.color = color
end

function fruit:talk()
  return 'I am a ' .. self.name .. ' and I am ' .. self.color
end

local tomato = fruit:new('tomato', 'red')
assert('I am a tomato and I am red' == tomato:talk())


local squash = fruit:clone('squash')

function squash:init(name, color, shape)
  self._proto:init(name, color)
  self.shape = shape
end

function squash:talk()
  return 'I am a ' .. self.shape .. ' ' .. self.name .. ' and I am ' .. self.color
end

local pumpkin = squash:new('pumpkin', 'orange', 'round')
assert('round' == pumpkin.shape)
assert('I am a round pumpkin and I am orange', pumpkin:talk())

assert(pumpkin:isa(fruit))
assert(not pumpkin:isa(tomato)) -- tomato isn't a prototype of pumpkin