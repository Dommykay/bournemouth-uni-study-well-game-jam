
---@class colour.lua
---@overload fun(r: number, g: number, b: number, a: number): Colour.lua
local module = {
  _version = "vector.lua v2019.14.12",
  _description = "a simple vector library for Lua based on the PVector class from processing",
  _url = "https://github.com/themousery/vector.lua",
  _license = [[
    Copyright (c) 2018 themousery

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]]
}

-- create the module
---@class Colour.lua
---@operator add: Vector.lua
---@operator sub: Vector.lua
---@operator mul: Vector.lua
---@operator div: Vector.lua
---@operator unm: Vector.lua
local colour = {}
colour.__index = colour

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then rand = love.math.random end

--- makes a new colour
---@param r number?
---@param g number?
---@param b number?
---@param a number?
---@return Colour.lua
local function new(r,g,b,a)
  return setmetatable({r=r or 0,g=g or 0,b=b or 0,a=a or 0}, colour)
end

--[[ NOT NEEDED
--- makes a new vector from an angle
---@param theta number
---@return Vector.lua
local function fromAngle(theta)
  return new(math.cos(theta), -math.sin(theta))
end
]]--

--[[ NOT NEEDED
--- makes a vector with a random direction
---@return Vector.lua
local function random()
  return fromAngle(rand() * math.pi*2)
end
]]--


--- check if an object is a colour
---@param t any
---@return boolean
local function iscolour(t)
  return getmetatable(t) == colour
end

--- set the values of the colour to something new
---@param r number
---@param g number
---@param b number
---@param a number
---@overload fun(self: Colour.lua, vec: Colour.lua): self
---@return self
function colour:set(r,g,b,a)
---@diagnostic disable-next-line: undefined-field
  if iscolour(r) then self.r, self.g, self.b, self.a = r.r, r.g, r.b, r.a; return self end
  self.r, self.g, self.b, self.a = r or self.r, g or self.g, b or self.b, a or self.a
  return self
end

--- replace the values of a colour with the values of another colour
---@param c Colour.lua
---@return self
function colour:replace(c)
  assert(iscolour(c), "replace: wrong argument type: (expected <colour>, got "..type(c)..")")
  self.r, self.g, self.b, self.a = c.r, c.g, c.b, c.a
  return self
end

--- returns a copy of a colour
---@return Colour.lua
function colour:clone()
  return new(self.r, self.g, self.b, self.a)
end

--- get the magnitude of a colour
---@return number
function colour:getmag()
  return math.sqrt(self.r^2 + self.g^2 + self.b^2 + self.a^2)
end

--- get the magnitude squared of a colour
---@return number
function colour:magSq()
  return self.r^2 + self.g^2 + self.b^2 + self.a^2
end

--- set the magnitude of a colour
---@return self
function colour:setmag(mag)
  assert(self:getmag() ~= 0, "Cannot set magnitude when direction is ambiguous")
  self:norm()
  local c = self * mag
  self:replace(c)
  return self
end

--- meta function to make colours negative
--- ex: (negative) -colour(5,6,5,6) is the same as colour(-5,-6,-5,-6)
---@param c Colour.lua
---@return Colour.lua
function colour.__unm(c)
  return new(-c.r, -c.g, -c.b, -c.a)
end

--- meta function to add colours together
--- ex: (colour(5,6,5,6) + colour(6,5,6,5)) is the same as vector(11,11,11,11)
---@param a Colour.lua
---@param b Colour.lua
---@return Colour.lua
function colour.__add(a,b)
  assert(iscolour(a) and iscolour(b), "add: wrong argument types: (expected <colour> and <colour>)")
  return new(a.r+b.r, a.g+b.g, a.b+b.b, a.a+b.a)
end

--- meta function to subtract colours
---@param a Colour.lua
---@param b Colour.lua
---@return Colour.lua
function colour.__sub(a,b)
  assert(iscolour(a) and iscolour(b), "sub: wrong argument types: (expected <colour> and <colour>)")
  return new(a.r-b.r, a.g-b.g, a.b-b.b, a.a-b.a)
end

--- meta function to multiply colours
---@param a Colour.lua | number
---@param b Colour.lua | number
---@return Colour.lua
function colour.__mul(a,b)
  if type(a) == 'number' then
    return new(a * b.r, a * b.g, a * b.b, a * b.a)
  elseif type(b) == 'number' then
    return new(a.r * b, a.g * b, a.b * b, a.a * b)
  else
    assert(iscolour(a) and iscolour(b),  "mul: wrong argument types: (expected <vector> or <number>)")
    return new(a.r*b.r, a.g*b.g, a.b*b.b, a.a*b.a)
  end
end

--- meta function to divide colours
---@param a Colour.lua | number
---@param b Colour.lua | number
---@return Colour.lua
function colour.__div(a,b)
  assert(iscolour(a) and type(b) == "number", "div: wrong argument types (expected <colour> and <number>)")
  return new(a.r/b, a.g/b, a.b/b, a.a/b)
end

--- meta function to check if colours have the same values
---@param a Colour.lua
---@param b Colour.lua
---@return boolean
function colour.__eq(a,b)
  assert(iscolour(a) and iscolour(b), "eq: wrong argument types (expected <vector> and <vector>)")
  return a.r==b.r and a.g==b.g and a.b==b.b and a.a==b.a
end

--- meta function to change how colours appear as string
--- ex: print(colour(2,8)) - this prints '(2,8)'
---@return string
function colour:__tostring()
  return "("..self.r..", "..self.g..", "..self.b..", "..self.a..")"
end

--- get the distance between two colours
---@param a Colour.lua
---@param b Colour.lua
---@return number
function colour.dist(a,b)
  assert(iscolour(a) and iscolour(b), "dist: wrong argument types (expected <vector> and <vector>)")
  return math.sqrt((a.r-b.r)^2 + (a.g-b.g)^2 + (a.b-b.b)^2 + (a.a-b.a)^2)
end

--- return the dot product of the colours
---@param c Colour.lua
---@return number
function colour:dot(c)
  assert(iscolour(c), "dot: wrong argument type (expected <vector>)")
  return self.r * c.r + self.g * c.g + self.b * c.b + self.a * c.a
end

--- normalize the colours (give it a magnitude of 1)
---@return Colour.lua
function colour:norm()
  local m = self:getmag()
  if m~=0 then
    self:replace(self / m)
  end
  return self
end

--- limit the colours to a certain amount
---@param max number
---@return Vector.lua
function colour:limit(max)
  assert(type(max) == 'number', "limit: wrong argument type (expected <number>)")
  local mSq = self:magSq()
  if mSq > max^2 then
    self:setmag(max)
  end
  return self
end

--- Clamp each axis between max and min's corresponding axis
---@param min Colour.lua
---@param max Colour.lua
---@return Colour.lua
function colour:clamp(min, max)
  assert(iscolour(min) and iscolour(max), "clamp: wrong argument type (expected <vector>) and <vector>")
  local r = math.min( math.max( self.r, min.r ), max.r )
  local g = math.min( math.max( self.g, min.g ), max.g )
  local b = math.min( math.max( self.b, min.b ), max.b )
  local a = math.min( math.max( self.a, min.a ), max.a )
  self:set(r,g,b,a)
  return self
end

--[[ NOT NEEDED
--- get the heading (direction) of a vector
---@return number
function vector:heading()
  return -math.atan2(self.y, self.x)
end

--- rotate a vector clockwise by a certain number of radians
---@param theta number
---@return Vector.lua
function vector:rotate(theta)
  local s = math.sin(theta)
  local c = math.cos(theta)
  local v = new(
                (c * self.x) + (s * self.y),
                -(s * self.x) + (c * self.y))
  self:replace(v)
  return self
end
]]--

--- CUSTOM FUNCTION ADDED BY Dommykay, Floors both numbers in the colours
---@return Colour.lua
function colour:floor()
  local r, g, b, a = self:unpack()
  r, g, b, a = math.floor(r), math.floor(g), math.floor(b), math.floor(a)
  self:set(a,b)
  return self
end

--- return r, g, b and a of colours as a regular array
---@return { [1]: number, [2]: number, [3]: number, [4]: number}
function colour:array()
  return {self.r, self.g, self.b, self.a}
end

-- return r, g, b and a of colours, unpacked from table
---@return number, number, number, number
function colour:unpack()
  return self.r, self.g, self.b, self.a
end


-- pack up and return module
module.new = new
module.iscolour = iscolour
return setmetatable(module --[[@as table]], {__call = function(_,...) return new(...) end}) --[[@as colour.lua]]
