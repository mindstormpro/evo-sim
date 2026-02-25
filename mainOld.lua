--made by Elio Anon, started jan 6, 2026 for CTMS magnet science fair
--why are you reading my code?

function love.load(arg) 
  if arg[#arg] == "-debug" then 
    require("mobdebug").start()
  end
  success = love.window.updateMode(0 ,0, {resizable = true})
end



local sim = {}
local speed = 100

sim.buffer = 10
sim.width = love.graphics.getWidth() * 1.5 - sim.buffer
sim.hight = love.graphics.getHeight() * 1.5 - sim.buffer

sim.parts = 100 -- the total number of parts (helps create a max carrying capacity)
sim.lilGuys = {}

function sim.lilUpdate(self, dt)
  print(self.currDir)
  if math.random(1, 1000000) / 10000 <= self.traits.stability * dt then
    return true --return death flag
  end
  
  if math.random(1, 1000000) / 10000 <= self.traits.stability * dt and self.currCooldown <= 1 then
    local evo = {
      update = sim.lilUpdate,
      currCooldown = 0,
      color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)},
      draw = sim.lilDraw,
      currDir = math.random(1, 360),
      x = self.x,
      y = self.y,
      traits = {
        stability = self.traits.stability + (math.random(-10, 10) / 10),
        reqParts = self.traits.reqParts + math.random(-1, 1),
        cooldown = 15,
        mutation = 10
      }
    }
    sim.lilGuys[#sim.lilGuys + 1] = evo
    self.currCooldown = self.traits.cooldown + self.traits.reqParts
  end
  
  
  if not self.currDir == nil then
    local tempX, tempY = speed * math.cos(self.currDir) * dt, speed * math.sin(self.currDir) * dt
    if self.x + tempX > 2500 or self.x + tempX < 100 or tempY + self.y > 1600 or tempY + self.y < 100 then
      self.currDir = math.random(1, 360)
    else
      self.x = self.x + tempX
      self.y = self.y + tempY
    end
  else
    self.curDir = math.random(1, 360)
  end
  
  return false
end

function sim.lilDraw(self)
  love.graphics.setColor(love.math.colorFromBytes(self.color.r, self.color.g, self.color.b))
  love.graphics.circle("fill", self.x, self.y, 50)
end

sim.MMStats = { -- the min and max values for stats to prevent things from getting too perfect 
  stability = 0.5,
  reqParts = 5,
  cooldown = 5,
  mutation = 1
} -- These will most likely change over time as seen fit

function sim.makeLilGuy()
  local lilGuy = {
    update = sim.lilUpdate,
    color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)},
    currCooldown = 0,
    currDir = math.random(1, 360),
    draw = sim.lilDraw,
    x = math.random(sim.buffer, sim.width),
    y = math.random(sim.buffer, sim.hight),
    traits = {
      stability = 5,
      reqParts = 10,
      cooldown = 15,
      mutation = 10
    }
  }

  return lilGuy
end

math.randomseed(love.timer.getTime()) -- init late to give a semi-unpredictable outcome for the seed generator

for i = 1, 100 do 
  table.insert(sim.lilGuys, sim.makeLilGuy())
end


function love.update(dt)
  local d = 0
  for i = 1, #sim.lilGuys do
    if sim.lilGuys[i - d]:update(dt) then
      table.remove(sim.lilGuys, i - d)
      d = d + 1
      print("removed 1 lilGuy")
    end
  end
end

function love.draw()
  for i = 1, #sim.lilGuys do
    sim.lilGuys[i]:draw()
  end
end
