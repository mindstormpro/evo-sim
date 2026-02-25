--made by Elio Anon, started jan 6, 2026 for CTMS magnet science fair
--why are you reading my code?

function love.load(arg) 
  if arg[#arg] == "-debug" then 
    require("mobdebug").start()
  end
  
  success = love.window.updateMode(0 ,0, {resizable = true})
end
--





local function makeSpeciesID(traits)
    return string.format("r%dg%db%d_stab%d_req%d_cd%d_mut%d",
        traits.color.r, traits.color.g, traits.color.b,
        traits.stability, traits.reqParts, traits.cooldown, traits.mutation
    )
end
--




local sim = {}


sim.buffer = 10
sim.width = love.graphics.getWidth() - sim.buffer
sim.hight = love.graphics.getHeight() - sim.buffer

sim.parts = 100 -- the total number of parts (helps create a max carrying capacity)
sim.lilGuys = {}






function sim.lilUpdate(self, dt)
  
  return false
end
--





function sim.lilDraw(self)
  
end
--




sim.minStats = { -- the min values for stats
  stability = 0.5,
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
    draw = sim.lilDraw,
    x = math.random(sim.buffer, sim.width),
    y = math.random(sim.buffer, sim.hight),
    species,
    traits = {
      color = {r = math.random(0, 255), g = math.random(0, 255), b = math.random(0, 255)},
      stability = math.random(sim.minStats.stability * sim.stepStats.stability[2], sim.maxStats.stability * sim.stepStats.stability[2]) / sim.stepStats.stability[1],
      reqParts = math.random(sim.minStats.reqParts * sim.stepStats.reqParts[2], sim.maxStats.reqParts * sim.stepStats.reqParts[2]) / sim.stepStats.reqParts[1],
      cooldown = math.random(sim.minStats.cooldown * sim.stepStats.cooldown[2], sim.maxStats.cooldown * sim.stepStats.cooldown[2]) / sim.stepStats.cooldown[1],
      mutation = math.random(sim.minStats.mutation * sim.stepStats.mutation[2], sim.maxStats.mutation * sim.stepStats.mutation[2]) / sim.stepStats.mutation[1]
    }
  }
  lilGuy.species = makeSpeciesID(lilGuy.traits)
  print(lilGuy.species)
  return lilGuy
end
--



math.randomseed(love.timer.getTime()) -- init late to give a semi-unpredictable outcome for the seed generator






for i = 1, 10 do 
  table.insert(sim.lilGuys, sim.makeLilGuy())
  print(sim.lilGuys[#sim.lilGuys].species)
end
--






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
--









function love.draw()
  for i = 1, #sim.lilGuys do
    sim.lilGuys[i]:draw()
  end
end