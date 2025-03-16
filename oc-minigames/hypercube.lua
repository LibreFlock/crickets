local mq = require("minigamelib") -- renamed from miniqollib to minigamelib
local matmul = require("matmul")
local math = require("math")

function plot(vec, block)
  local pivot = mq.create_vector(69368,76,69438)
  local absolute = mq.relative_center(pivot,vec)
  print(absolute.x,absolute.y,absolute.z)
  mq.set_block(absolute.x,absolute.y,absolute.z,block)
end

function line(vec1,vec2,block)
  plot(vec1, block)
  local dx = math.abs(vec2.x-vec1.x)
  local dy = math.abs(vec2.y-vec1.y)
  local dz = math.abs(vec2.z-vec1.z)
  local as = mq.create_vector(0,0,0)
  if vec2.x > vec1.x then
    as.x = 1
  else
    as.x = -1
  end
  if vec2.y > vec1.y then
    as.y = 1
  else
    as.y = -1
  end
  if vec2.z > vec1.z then
    as.z = 1
  else
    as.z = -1
  end
  if dx >= dy and dx >= dz then
    local p1 = 2 * dy-dx
    loacl p2 = 2 * dz-dx
    while vec1.x ~= vec2.z do
      vec1.x = vec1.x + as.x
      if p1 >= 0 then
        vec1.y = vec1.y + as.y
        p1 = p1 - 2 * dx
      end
      if p2 >= 0 then
        vec1.z
end
plot(mq.create_vector(0,0,0),"stone")