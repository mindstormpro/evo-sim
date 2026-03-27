--made by Elio Anon, started jan 6, 2026 for CTMS magnet science fair
--why are you reading my code?

function love.load(arg) 
  if arg[#arg] == "-debug" then 
    require("mobdebug").start()
  end
  
  success = love.window.updateMode(0 ,0, {resizable = true})
end
--


local sim = {}


sim.buffer = 10
sim.width = love.graphics.getWidth() - sim.buffer
sim.hight = love.graphics.getHeight() - sim.buffer

sim.parts = 100 -- the total number of parts (helps create a max carrying capacity)
sim.lilGuys = {}
sim.speciesCount = {}
sim.species = {}




local function deepCopy(orig)
  local copy = {}
  for k, v in pairs(orig) do
    if type(v) == "table" then
      copy[k] = deepCopy(v)  -- recurse for nested tables
    else
      copy[k] = v
    end
  end
  return copy
end

local function makeSpeciesID(traits)
    return string.format("r%dg%db%d_stab%d_req%d_cd%d_mut%d",
        traits.color.r, traits.color.g, traits.color.b,
        traits.stability, traits.reqParts, traits.cooldown, traits.mutation
    )
end


function sim.evolveLilGuy(oldLilGuy)
  local lilGuy = deepCopy(oldLilGuy)
  
  local traits = lilGuy.traits
  traits.color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)}
  traits.stability = traits.stability + (math.random(-10, 10) / 10)
  traits.reqParts   = traits.reqParts + math.random(-1, 1)
  traits.cooldown   = traits.cooldown + (math.random(-10, 10) / 10)
  traits.mutation   = traits.mutation + (math.random(-10, 10) / 10)
  lilGuy.traits = traits
  lilGuy.currCooldown = 0
  lilGuy.currDir = math.random(1, 360)
  lilGuy.species = makeSpeciesID(traits)

  if sim.speciesCount[lilGuy.species] then
    sim.speciesCount[lilGuy.species] = sim.speciesCount[lilGuy.species] + 1
  else
    table.insert(sim.species, lilGuy.species)
    sim.speciesCount[lilGuy.species] = 1
  end

  table.insert(sim.lilGuys, lilGuy)
end


--







function sim.lilUpdate(self, dt)
  
  
  if math.random(1, 100000) / 1000 < dt * self.traits.stability * 0.15 then
    print("dying!")
    return true
  end
  if self.currCooldown >= 0.1 then
    self.currCooldown = self.currCooldown - dt
  else 
    if sim.parts >= self.traits.reqParts then
      sim.parts = sim.parts - self.traits.reqParts
      if math.random(1, 100000) / 100000 < dt * (self.traits.mutation / 5) then
        print("i'm evolving!")
        sim.evolveLilGuy(self)
      else
        print("i'm cloning!")
        local child = deepCopy(self)
        child.currCooldown = self.traits.cooldown
        sim.speciesCount[self.species] = (sim.speciesCount[self.species] or 0) + 1
        table.insert(sim.lilGuys, child)
      end
      self.currCooldown = self.traits.cooldown
    end
  end
  
  
  return false
end
--


--




sim.minStats = { -- the min values for stats
  stability = 1,
  reqParts = 5,
  cooldown = 3,
  mutation = 1
}
--

sim.maxStats = { -- the max values for stats
  stability = 50,
  reqParts = 20,
  cooldown = 20,
  mutation = 100
}
--

sim.stepStats = { -- the steps (EX: 0.1, 1, ect...) in the form of {step, 1/step}
  stability = {0.1, 10},
  reqParts = {1, 1},
  cooldown = {0.1, 10},
  mutation = {0.1, 10}
}
--




function sim.makeLilGuy()
  local lilGuy = {
    update = sim.lilUpdate,
    currCooldown = 0,
    currDir = math.random(1, 360),
    x = math.random(sim.buffer, sim.width),
    y = math.random(sim.buffer, sim.hight),
    species,
    traits = {
      color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)},
      stability = math.random(sim.minStats.stability * sim.stepStats.stability[2], sim.maxStats.stability * sim.stepStats.stability[2]) * sim.stepStats.stability[1],
      reqParts = math.random(sim.minStats.reqParts * sim.stepStats.reqParts[2], sim.maxStats.reqParts * sim.stepStats.reqParts[2]) * sim.stepStats.reqParts[1],
      cooldown = math.random(sim.minStats.cooldown * sim.stepStats.cooldown[2], sim.maxStats.cooldown * sim.stepStats.cooldown[2]) * sim.stepStats.cooldown[1],
      mutation = math.random(sim.minStats.mutation * sim.stepStats.mutation[2], sim.maxStats.mutation * sim.stepStats.mutation[2]) * sim.stepStats.mutation[1]
    }
  }
  lilGuy.species = makeSpeciesID(lilGuy.traits)
  if sim.speciesCount[lilGuy.species] then
    sim.speciesCount[lilGuy.species] = sim.speciesCount[lilGuy.species] + 1
  else
    table.insert(sim.species, lilGuy.species)
    sim.speciesCount[lilGuy.species] = 1
  end
  print(lilGuy.species)
  
  lilGuy.currCooldown = lilGuy.traits.cooldown
  print(lilGuy.traits.mutation)
  return lilGuy
end
--



math.randomseed(love.timer.getTime()) -- init late to give a semi-unpredictable outcome for the seed generator






for i = 1, 10 do 
  table.insert(sim.lilGuys, sim.makeLilGuy())
end
--






function love.update(dt)
  sim.parts = math.min(sim.parts + (10 * dt), 100) -- add part regen
  
  for i = #sim.lilGuys, 1, -1 do
    if sim.lilGuys[i]:update(dt) then
      if (sim.speciesCount[sim.lilGuys[i].species] or 0) > 1 then
        sim.speciesCount[sim.lilGuys[i].species] = sim.speciesCount[sim.lilGuys[i].species] - 1
      else
        sim.speciesCount[sim.lilGuys[i].species] = nil
      end
      table.remove(sim.lilGuys, i)
      print("removed 1 lilGuy")
    end
  end
  for i = #sim.species, 1, -1 do
    if sim.speciesCount[sim.species[i]] == nil then
      table.remove(sim.species, i)
    end
  end
end
--



print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)
print(math.random(1, 100000) / 1000 < 0.01 * 60)

local width, height

local padding = 60

local r, g, b
local s

function love.draw()
  width, height = love.graphics.getDimensions()
  
  
  love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
  love.graphics.rectangle("line", padding, padding, 300, height - ( 2 * padding), 20, 20, 25 )
  
  for i = 1, #sim.species do 
    s = sim.species[i]
    r, g, b = s:match("r(%d+)g(%d+)b(%d+)")
    love.graphics.setColor(love.math.colorFromBytes(r, g, b))
    love.graphics.circle("fill", padding + 20, padding + (i * 25), 4)
  end
end