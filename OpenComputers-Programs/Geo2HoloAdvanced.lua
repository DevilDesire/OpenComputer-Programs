-- Chunks need to be active!!
local component = require("component")
local holos = {}
local geos = {}
local holoGeo = 9

holos[1] = "04f92fd9-4277-4a54-bdd6-938be39d34b0"
holos[2] = "a483fe19-6be7-43e9-91b9-057ab4d12f25"
holos[3] = "79d0d3fb-2e76-43cf-b170-3243680ba213"
holos[4] = "432871f8-1461-4185-bab9-9fc090a6b346"
holos[5] = "e02e6472-7bac-463d-9aa5-3c1c244a3dc9"
holos[6] = "658d15e9-3f49-44bb-8c4e-8ffd91310d89"
holos[7] = "b56a697c-5d05-4c5a-aa2a-ac3c117e785b"
holos[8] = "ca65b0da-212d-4b95-a388-b5814534fc5c"
holos[9] = "0aaec845-3562-4ff1-911f-4182429654d3"

geos[1] = "ad301dc8-13df-47de-8246-c64bb5e21deb"
geos[2] = "e456e521-dae5-4ca3-a8b8-10fd7353a3fd"
geos[3] = "3f686ff9-d23f-478c-80eb-cbed703dd051"
geos[4] = "f8b83c62-4d23-4dbf-a480-e10ec3da65fd"
geos[5] = "60c583c1-5f1e-478f-89d2-67921e36186e"
geos[6] = "f7781c79-75c3-45a7-9596-80f051eee4cd"
geos[7] = "70197c6e-5e4c-47e9-a6fd-158655fd7892"
geos[8] = ""
geos[9] = ""

if not component.isAvailable("geolyzer") then
  io.stderr:write("This program requires a Geolyzer to run.\n")
  return
end
if not component.isAvailable("hologram") then
  io.stderr:write("This program requires a Hologram Projector to run.\n")
  return
end


local sx, sz = 48, 48
local ox, oz = -24, -24
local starty, stopy = -5

local function validateY(value, min, max, default)
  value = tonumber(value) or default
  if value < min or value > max then
    io.stderr:write("invalid y coordinate, must be in [" .. min .. ", " .. max .. "]\n")
    os.exit(1)
  end
  return value
end

local function getHolos()
	local holograms = component.list("hologram")
	for address, componentType in holograms do
		print(address)
		table.insert(holos, address)
	end
end

local function getGeos()
	local geolyzers = component.list("geolyzer")
	for address, componentType in geolyzers do
		print(address)
		table.insert(geos, address)
	end
end

local args = {...}

local function validateAll()
	do
	  starty = validateY(args[1], -32, 31, starty)
	  stopy = validateY(args[2], starty, starty + 32, math.min(starty + 32, 31))
	end
end

local function PrintError(compType, number)
	print(compType .. "not found! Index " .. number .. "\nMaybe chunks not active")
end

local function printAllGeos()
	for address in pairs(holos) do
		print(address)
	end
end

local function printAllHolos()
	for address in pairs(holos) do
		print(address)
	end

end

local function main()
	printAllHolos()
	for index=1, holoGeo, 1 do
		break
		local geoAddress = geos[index]
		local holoAddress = holos[index]
		
		local geo = component.proxy(geoAddress)
		local holo = component.proxy(holoAddress)
		validateAll()
		
		if geo ~= nil then 
			if holo ~= nil then
				holo.clear()
				print("Setze holo Scale auf 0.33")
				os.sleep(1)
				holo.setScale(0.33)
				os.sleep(1)
				print("holo scale gesetzt")
				print("Holo Scale = " .. holo.getScale())
				for x=ox,sx+ox do
				  for z=oz,sz+oz do
					local hx, hz = 1 + x - ox, 1 + z - oz
					local column = component.geolyzer.scan(x, z, false)
					for y=1,1+stopy-starty do
					  local color = 0
					  if column then
						local hardness = column[y + starty + 32]
						if hardness == 0 or not hardness then
						  color = 0
						elseif hardness < 3 then
						  color = 2
						elseif hardness < 100 then
						  color = 1
						else
						  color = 3
						end
					  end
					  if component.hologram.maxDepth() > 1 then
						component.hologram.set(hx, y, hz, color)
					  else
						component.hologram.set(hx, y, hz, math.min(color, 1))
					  end
					end
					os.sleep(0)
				  end
				end
			else
				PrintError("hologram", index)
			end
		else
			PrintError("geolyzer", index)
		end
		
		geoAddress = nil
		holoAddress = nil
		geo = nil
		holo = nil
	end
end

main()