repeat task.wait(0.1) until game:IsLoaded()

getgenv().Star = "⭐"
getgenv().Danger = "⚠️"
getgenv().ExploitSpecific = "📜"

-- API CALLS

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ericd71/skiP/main/Library.lua"))()
getgenv().api = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ericd71/skiP/main/API.lua"))()
local bssapi = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ericd71/skiP/main/BSSAPI.lua"))()
local httpreq = (syn and syn.request) or http_request or (http and http.request) or request

if not isfolder("kocmoc") then makefolder("kocmoc") end
if not isfolder("kocmoc/premium") then makefolder("kocmoc/premium") end
if not isfolder("kocmoc/plantercache") then makefolder("kocmoc/plantercache") end

if isfile("rosemoc.txt") == false then
    httpreq({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = game:GetService("HttpService"):JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {code = "BeF364YJS5"},
            nonce = game:GetService("HttpService"):GenerateGUID(false)
        }),
        writefile("rosemoc.txt", "discord")
    })
end

-- Script temporary variables
local player = game.Players.LocalPlayer
local playerstatsevent = game:GetService("ReplicatedStorage").Events.RetrievePlayerStats
local playeractivescommand = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
local statstable = playerstatsevent:InvokeServer()
local monsterspawners = game.Workspace.MonsterSpawners
local NectarBlacklist = {}
local rarename

function rtsg()
    return playerstatsevent:InvokeServer()
end

function maskequip(mask)
    if rtsg()["EquippedAccessories"]["Hat"] == mask then return end
    game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer("Equip", {
        Mute = false,
        Type = mask,
        Category = "Accessory"
    })
end

function equiptool(tool)
    if rtsg()["EquippedCollector"] == tool then return end
    game.ReplicatedStorage.Events.ItemPackageEvent:InvokeServer("Equip", {
        Mute = true,
        Type = tool,
        Category = "Collector"
    })
end

local lasttouched = nil
local lastfieldpos = nil
local hi = false
local Items = require(game:GetService("ReplicatedStorage").EggTypes).GetTypes()
local v1 = require(game.ReplicatedStorage.ClientStatCache):Get()

repeat task.wait(0.1) until player.PlayerGui.ScreenGui:FindFirstChild("Menus")

local hives = game.Workspace.Honeycombs:GetChildren()
for i = #hives, 1, -1 do
    local hive = game.Workspace.Honeycombs:GetChildren()[i]
    if hive.Owner.Value == nil then
        game.ReplicatedStorage.Events.ClaimHive:FireServer(hive.HiveID.Value)
    end
end

-- Script tables
for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
    if v:IsA("TextLabel") and v.Text:find("Kocmoc v") then
        v.Parent.Parent:Destroy()
    end
end

getgenv().temptable = {
    version = "4.3.0",
    blackfield = "Sunflower Field",
    redfields = {},
    bluefields = {},
    whitefields = {},
    shouldiconvertballoonnow = false,
    balloondetected = false,
    puffshroomdetected = false,
    magnitude = 60,
    blacklist = {""},
    running = false,
    configname = "",
    tokenpath = game.Workspace.Collectibles,
    started = {
        vicious = false,
        mondo = false,
        windy = false,
        ant = false,
        monsters = false,
        crab = false
    },
    detected = {vicious = false, windy = false},
    tokensfarm = false,
    converting = false,
    consideringautoconverting = false,
    honeystart = 0,
    grib = nil,
    gribpos = CFrame.new(0, 0, 0),
    honeycurrent = statstable.Totals.Honey,
    dead = false,
    float = false,
    pepsigodmode = false,
    pepsiautodig = false,
    alpha = false,
    beta = false,
    myhiveis = false,
    invis = false,
    windy = nil,
    sprouts = {detected = false, coords},
    cache = {
        autofarm = false,
        killmondo = false,
        vicious = false,
        windy = false
    },
    allplanters = {},
    planters = {
        planter = {},
        cframe = {},
        activeplanters = {type = {}, id = {}}
    },
    monstertypes = {
        "Ladybug", "Rhino", "Spider", "Scorpion", "Mantis", "Werewolf"
    },
    ["stopapypa"] = function(path, part)
        local Closest
        for i, v in next, path:GetChildren() do
            if v.Name ~= "PlanterBulb" then
                if Closest == nil then
                    Closest = v.Soil
                else
                    if (part.Position - v.Soil.Position).magnitude <
                        (Closest.Position - part.Position).magnitude then
                        Closest = v.Soil
                    end
                end
            end
        end
        return Closest
    end,
    coconuts = {},
    crosshairs = {},
    bubbles = {},
    crosshair = false,
    coconut = false,
    act = 0,
    act2 = 0,
    ["touchedfunction"] = function(v)
        if lasttouched ~= v then
            if v.Parent.Name == "FlowerZones" then
                if v:FindFirstChild("ColorGroup") then
                    if tostring(v.ColorGroup.Value) == "Red" then
                        maskequip("Demon Mask")
                    elseif tostring(v.ColorGroup.Value) == "Blue" then
                        maskequip("Diamond Mask")
                    end
                else
                    maskequip("Gummy Mask")
                end
                lasttouched = v
            end
        end
    end,
    runningfor = 0,
    oldtool = rtsg()["EquippedCollector"],
    ["gacf"] = function(part, st)
        coordd = CFrame.new(part.Position.X, part.Position.Y + st, part.Position.Z)
        return coordd
    end,
    lookat = nil,
    currtool = rtsg()["EquippedCollector"],
    starttime = tick(),
    planting = false,
    crosshaircounter = 0,
    doingbubbles = false,
    doingcrosshairs = false,
    pollenpercentage = 0,
    lastmobkill = 0,
    usegumdropsforquest = false,
    lastgumdropuse = tick(),
    autox4glitter = isfile("kocmoc/plantercache/x4.file") and tonumber(readfile("kocmoc/plantercache/x4.file")) or 1
}
local planterst = {plantername = {}, planterid = {}}

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

for i, v in next, temptable.blacklist do
    if v == api.nickname then
        player:Kick("You're blacklisted! Get clapped!")
    end
end
if temptable.honeystart == 0 then temptable.honeystart = statstable.Totals.Honey end

for i, v in next, monsterspawners:GetDescendants() do
    if v.Name == "TimerAttachment" then v.Name = "Attachment" end
end
for i, v in next, monsterspawners:GetChildren() do
    if v.Name == "RoseBush" then
        v.Name = "ScorpionBush"
    elseif v.Name == "RoseBush2" then
        v.Name = "ScorpionBush2"
    end
end
for i, v in next, game.Workspace.FlowerZones:GetChildren() do
    if v:FindFirstChild("ColorGroup") then
        if v:FindFirstChild("ColorGroup").Value == "Red" then
            table.insert(temptable.redfields, v.Name)
        elseif v:FindFirstChild("ColorGroup").Value == "Blue" then
            table.insert(temptable.bluefields, v.Name)
        end
    else
        table.insert(temptable.whitefields, v.Name)
    end
end
local flowertable = {}
for _, z in next, game.Workspace.Flowers:GetChildren() do
    table.insert(flowertable, z.Position)
end
local masktable = {}
for _, v in next, game:GetService("ReplicatedStorage").Accessories:GetChildren() do
    if string.match(v.Name, "Mask") then table.insert(masktable, v.Name) end
end
local collectorstable = {}
for _, v in next, getupvalues(
                require(game:GetService("ReplicatedStorage").Collectors).Exists) do
    for e, r in next, v do table.insert(collectorstable, e) end
end
local fieldstable = {}
for _, v in next, game.Workspace.FlowerZones:GetChildren() do
    table.insert(fieldstable, v.Name)
end
local toystable = {}
for _, v in next, game.Workspace.Toys:GetChildren() do
    table.insert(toystable, v.Name)
end
local spawnerstable = {}
for _, v in next, monsterspawners:GetChildren() do
    table.insert(spawnerstable, v.Name)
end
local accesoriestable = {}
for _, v in next, game:GetService("ReplicatedStorage").Accessories:GetChildren() do
    if v.Name ~= "UpdateMeter" then table.insert(accesoriestable, v.Name) end
end
for i, v in pairs(getupvalues(require(game:GetService("ReplicatedStorage").PlanterTypes).GetTypes)) do
    for e, z in pairs(v) do 
        table.insert(temptable.allplanters, e)
    end
end
local donatableItemsTable = {}
local treatsTable = {}
for i, v in pairs(Items) do
    if v.DonatableToWindShrine == true then
        table.insert(donatableItemsTable, i)
    end
end
for i, v in pairs(Items) do if v.TreatValue then table.insert(treatsTable, i) end end
local buffTable = {
    ["Blue Extract"] = {b = false, DecalID = "2495936060"},
    ["Red Extract"] = {b = false, DecalID = "2495935291"},
    ["Oil"] = {b = false, DecalID = "2545746569"}, -- ?
    ["Enzymes"] = {b = false, DecalID = "2584584968"},
    ["Glue"] = {b = false, DecalID = "2504978518"},
    ["Glitter"] = {b = false, DecalID = "2542899798"},
    ["Tropical Drink"] = {b = false, DecalID = "3835877932"}
}
local AccessoryTypes = require(game:GetService("ReplicatedStorage").Accessories).GetTypes()
local MasksTable = {}
for i, v in pairs(AccessoryTypes) do
    if tostring(i):find("Mask") then
        if i ~= "Honey Mask" then table.insert(MasksTable, i) end
    end
end
local DropdownPlanterTable = {
    "Plastic Planter",
    "Candy Planter",
    "Red Clay Planter",
    "Blue Clay Planter",
    "Tacky Planter",
    "Pesticide Planter",
    "Petal Planter",
    "The Planter Of Plenty",
    "None"
}
local DropdownFieldsTable = deepcopy(fieldstable)
for i,v in pairs(DropdownFieldsTable) do
    if v == "Ant Field" then
        table.remove(DropdownFieldsTable, i)
    end
end
table.insert(DropdownFieldsTable, "None")

table.sort(fieldstable)
table.sort(accesoriestable)
table.sort(toystable)
table.sort(spawnerstable)
table.sort(masktable)
table.sort(temptable.allplanters)
table.sort(collectorstable)
table.sort(donatableItemsTable)
table.sort(buffTable)
table.sort(MasksTable)

-- float pad

local floatpad = Instance.new("Part", game.Workspace)
floatpad.CanCollide = false
floatpad.Anchored = true
floatpad.Transparency = 1
floatpad.Name = "FloatPad"

-- cococrab

local cocopad = Instance.new("Part", game.Workspace)
cocopad.Name = "Coconut Part"
cocopad.Anchored = true
cocopad.Transparency = 1
cocopad.Size = Vector3.new(10, 1, 10)
cocopad.Position = Vector3.new(-307.52117919922, 105.91863250732, 467.86791992188)

-- antfarm

local antpart = Instance.new("Part", workspace)
antpart.Name = "Ant Autofarm Part"
antpart.Position = Vector3.new(96, 47, 553)
antpart.Anchored = true
antpart.Size = Vector3.new(128, 1, 50)
antpart.Transparency = 1
antpart.CanCollide = false

-- config

getgenv().kocmoc = {
    rares = {},
    priority = {},
    bestfields = {
        red = "Pepper Patch",
        white = "Coconut Field",
        blue = "Stump Field"
    },
    blacklistedfields = {},
    killerkocmoc = {},
    bltokens = {},
    toggles = {
        autofarm = false,
        farmclosestleaf = false,
        farmbubbles = false,
        autodig = false,
        farmrares = false,
        rgbui = false,
        farmflower = false,
        farmfuzzy = false,
        farmcoco = false,
        farmflame = false,
        farmclouds = false,
        killmondo = false,
        killvicious = false,
        loopspeed = false,
        loopjump = false,
        autoquest = false,
        autoboosters = false,
        autodispense = false,
        clock = false,
        freeantpass = false,
        honeystorm = false,
        autodoquest = false,
        disableseperators = false,
        npctoggle = false,
        loopfarmspeed = false,
        mobquests = false,
        traincrab = false,
        avoidmobs = false,
        farmsprouts = false,
        enabletokenblacklisting = false,
        farmunderballoons = false,
        farmsnowflakes = false,
        collectgingerbreads = false,
        collectcrosshairs = false,
        farmpuffshrooms = false,
        tptonpc = false,
        donotfarmtokens = false,
        convertballoons = false,
        autostockings = false,
        autosamovar = false,
        autoonettart = false,
        autocandles = false,
        autofeast = false,
        autoplanters = false,
        autokillmobs = false,
        autoant = false,
        killwindy = false,
        godmode = false,
        disableconversion = false,
        autodonate = false,
        autouseconvertors = false,
        honeymaskconv = false,
        resetbeenergy = false,
        enablestatuspanel = false,
        autoequipmask = false,
        followplayer = false,
        buckobeequests = false,
        brownbearquests = false,
        rileybeequests = false,
        polarbearquests = false,
        blackbearquests = false,
        allquests = false,
        blacklistinvigorating = false,
        blacklistcomforting = false,
        blacklistmotivating = false,
        blacklistrefreshing = false,
        blacklistsatisfying = false,
        plasticplanter = false,
        candyplanter = false,
        redclayplanter = false,
        blueclayplanter = false,
        tackyplanter = false,
        pesticideplanter = false,
        petalplanter = false,
        shutdownkick = false,
        webhookupdates = false,
        webhookping = false,
        autoquesthoneybee = false,
        buyantpass = false,
        tweenteleport = false,
        docustomplanters = false,
        fastcrosshairs = false,
        smartmobkill = false,
        ["autouseBlue Extract"] = false,
        ["autouseRed Extract"] = false,
        ["autouseOil"] = false,
        ["autouseEnzymes"] = false,
        ["autouseGlue"] = false,
        ["autouseGlitter"] = false,
        ["autouseTropical Drink"] = false,
        usegumdropsforquest = false,
        autox4 = false,
        newtokencollection = false
    },
    vars = {
        field = "Ant Field",
        convertat = 100,
        farmspeed = 60,
        prefer = "Tokens",
        walkspeed = 70,
        jumppower = 70,
        npcprefer = "All Quests",
        farmtype = "Walk",
        monstertimer = 15,
        autodigmode = "Normal",
        donoItem = "Coconut",
        donoAmount = 25,
        selectedTreat = "Treat",
        selectedTreatAmount = 0,
        autouseMode = "Just Tickets",
        autoconvertWaitTime = 10,
        defmask = "Bubble",
        deftool = "Petal Wand",
        resettimer = 3,
        questcolorprefer = "Any NPC",
        playertofollow = "",
        convertballoonpercent = 50,
        planterharvestamount = 75,
        webhookurl = "",
        discordid = 0,
        webhooktimer = 60,
        customplanter11 = "",
        customplanter12 = "",
        customplanter13 = "",
        customplanter14 = "",
        customplanter15 = "",
        customplanter21 = "",
        customplanter22 = "",
        customplanter23 = "",
        customplanter24 = "",
        customplanter25 = "",
        customplanter31 = "",
        customplanter32 = "",
        customplanter33 = "",
        customplanter34 = "",
        customplanter35 = "",
        customplanterfield11 = "",
        customplanterfield12 = "",
        customplanterfield13 = "",
        customplanterfield14 = "",
        customplanterfield15 = "",
        customplanterfield21 = "",
        customplanterfield22 = "",
        customplanterfield23 = "",
        customplanterfield24 = "",
        customplanterfield25 = "",
        customplanterfield31 = "",
        customplanterfield32 = "",
        customplanterfield33 = "",
        customplanterfield34 = "",
        customplanterfield35 = "",
        customplanterdelay11 = 75,
        customplanterdelay12 = 75,
        customplanterdelay13 = 75,
        customplanterdelay14 = 75,
        customplanterdelay21 = 75,
        customplanterdelay22 = 75,
        customplanterdelay23 = 75,
        customplanterdelay24 = 75,
        customplanterdelay25 = 75,
        customplanterdelay31 = 75,
        customplanterdelay32 = 75,
        customplanterdelay33 = 75,
        customplanterdelay34 = 75,
        customplanterdelay35 = 75
    },
    dispensesettings = {
        blub = false,
        straw = false,
        treat = false,
        coconut = false,
        glue = false,
        rj = false,
        white = false,
        red = false,
        blue = false
    }
}

local defaultkocmoc = kocmoc

-- functions

local function addcommas(num)
    local str = tostring(num):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if str:sub(1,1) == "," then
        str = str:sub(2)
    end
    return str
end

local function truncatetime(sec)
    local second = tostring(sec%60)
    local minute = tostring(math.floor(sec / 60 - math.floor(sec / 3600) * 60))
    local hour = tostring(math.floor(sec / 3600))
    
    return (#hour == 1 and "0"..hour or hour)..":"..(#minute == 1 and "0"..minute or minute)..":"..(#second == 1 and "0"..second or second)
end

local function truncate(num)
    num = tonumber(math.round(num))
    if num <= 0 then
        return 0
    end
    local savenum = ""
    local i = 0
    local suff = ""
    local suffixes = {"k","M","B","T","qd","Qn","sx","Sp","O","N"}
    local length = math.floor(math.log10(num)+1)
    while num > 999 do
        i = i + 1
        suff = suffixes[i] or "???"
        num = num/1000
        savenum = (math.floor(num*100)/100)..suff
    end
    if i == 0 then
        return num
    end
    return savenum
end

local function disconnected(hook, discordid, reason)
    if not discordid then discordid = "0" end

    local timepassed = math.round(tick() - temptable.starttime)
    local honeygained = temptable.honeycurrent - temptable.honeystart

    local totalhoneystring = addcommas(temptable.honeycurrent).." ("..truncate(temptable.honeycurrent)..")"
    local honeygainedstring = addcommas(honeygained).." ("..truncate(honeygained)..")"
    local honeyperhourstring = addcommas(math.floor(honeygained / timepassed) * 3600).." ("..truncate(math.floor(honeygained / timepassed) * 3600)..") Honey"
    local uptimestring = truncatetime(timepassed)
    local data = {
        ["username"] = player.Name,
        ["avatar_url"] = "https://www.roblox.com/HeadShot-thumbnail/image?userId="..tostring(player.UserId).."&width=420&height=420&format=png",
        ["content"] = "<@"..tostring(discordid).."> "..(reason == "Server Timeout (Game Freeze)" and "Freeze" or "Kick"),
        ["embeds"] = {{
            ["title"] = "**Disconnect Detected**",
            --["description"] = "description",
            ["type"] = "rich",
            ["color"] = tonumber(0xfff802),
            ["fields"] = {
                {
                    ["name"] = "Reason:",
                    ["value"] = reason,
                    ["inline"] =  false
                },
                {
                    ["name"] = "Total Honey:",
                    ["value"] = totalhoneystring,
                    ["inline"] =  false
                },
                {
                    ["name"] = "Session Honey:",
                    ["value"] = honeygainedstring,
                    ["inline"] =  true
                },
                {
                    ["name"] = "Session Uptime:",
                    ["value"] = uptimestring,
                    ["inline"] =  true
                },
                {
                    ["name"] = "Session Honey Per Hour:",
                    ["value"] = honeyperhourstring,
                    ["inline"] =  true
                },
            },
            ["footer"] = {
                ["text"] = os.date("%x").." • "..os.date("%I")..":"..os.date("%M")..":"..os.date("%S").." "..os.date("%p")
            }
        }}
    }
    local headers = {
        ["content-Type"] = "application/json"
    }
    httpreq({Url = hook, Body = game:GetService("HttpService"):JSONEncode(data), Method = "POST", Headers = headers})
end

local function hourly(ping, hook, discordid)
    if not discordid then discordid = "0" end

    local timepassed = math.round(tick() - temptable.starttime)
    local honeygained = temptable.honeycurrent - temptable.honeystart

    local totalhoneystring = addcommas(temptable.honeycurrent).." ("..truncate(temptable.honeycurrent)..")"
    local honeygainedstring = addcommas(honeygained).." ("..truncate(honeygained)..")"
    local honeyperhourstring = addcommas(math.floor(honeygained / timepassed) * 3600).." ("..truncate(math.floor(honeygained / timepassed) * 3600)..") Honey"
    local uptimestring = truncatetime(timepassed)
    
    local data = {
        ["username"] = player.Name,
        ["avatar_url"] = "https://www.roblox.com/HeadShot-thumbnail/image?userId="..tostring(player.UserId).."&width=420&height=420&format=png",
        ["content"] = ping and "<@"..tostring(discordid).."> ".."Honey Update" or "Honey Update",
        ["embeds"] = {{
            ["title"] = "**Honey Update**",
            ["type"] = "rich",
            ["color"] = tonumber(0xfff802),
            ["fields"] = {
                {
                    ["name"] = "Total Honey:",
                    ["value"] = totalhoneystring,
                    ["inline"] =  false
                },
                {
                    ["name"] = "Session Honey:",
                    ["value"] = honeygainedstring,
                    ["inline"] =  true
                },
                {
                    ["name"] = "Session Uptime:",
                    ["value"] = uptimestring,
                    ["inline"] =  true
                },
                {
                    ["name"] = "Session Honey Per Hour:",
                    ["value"] = honeyperhourstring,
                    ["inline"] =  true
                },
            },
            ["footer"] = {
                ["text"] = os.date("%x").." • "..os.date("%I")..":"..os.date("%M")..":"..os.date("%S").." "..os.date("%p")
            }
        }}
    }
    local headers = {
        ["content-Type"] = "application/json"
    }
    httpreq({Url = hook, Body = game:GetService("HttpService"):JSONEncode(data), Method = "POST", Headers = headers})
end

local function findField(position)
    if not position then return nil end
    
    for _,v in pairs(game.Workspace.FlowerZones:GetChildren()) do
        local fieldPos = v.CFrame.p
        local fieldSize = v.Size + Vector3.new(0, 30, 0)
        if position.X > fieldPos.X - fieldSize.X/2 and position.X < fieldPos.X + fieldSize.X/2 then
            if position.Z > fieldPos.Z - fieldSize.Z/2 and position.Z < fieldPos.Z + fieldSize.Z/2 then
                if position.Y > fieldPos.Y - fieldSize.Y/2 and position.Y < fieldPos.Y + fieldSize.Y/2 then
                    return v
                end
            end
        end
    end
    
    return nil
end

function statsget()
    local StatCache = require(game.ReplicatedStorage.ClientStatCache)
    local stats = StatCache:Get()
    return stats
end
function farm(trying)
    if kocmoc.toggles.loopfarmspeed then
        player.Character.Humanoid.WalkSpeed = kocmoc.vars.farmspeed
    end
    api.humanoid():MoveTo(trying.Position)
    repeat 
        task.wait()
    until (trying.Position - api.humanoidrootpart().Position).magnitude <= 4 or not IsToken(trying) or not temptable.running
end

function disableall()
    if kocmoc.toggles.autofarm and not temptable.converting then
        temptable.cache.autofarm = true
        kocmoc.toggles.autofarm = false
    end
    if kocmoc.toggles.killmondo and not temptable.started.mondo then
        kocmoc.toggles.killmondo = false
        temptable.cache.killmondo = true
    end
    if kocmoc.toggles.killvicious and not temptable.started.vicious then
        kocmoc.toggles.killvicious = false
        temptable.cache.vicious = true
    end
    if kocmoc.toggles.killwindy and not temptable.started.windy then
        kocmoc.toggles.killwindy = false
        temptable.cache.windy = true
    end
end

function enableall()
    if temptable.cache.autofarm then
        kocmoc.toggles.autofarm = true
        temptable.cache.autofarm = false
    end
    if temptable.cache.killmondo then
        kocmoc.toggles.killmondo = true
        temptable.cache.killmondo = false
    end
    if temptable.cache.vicious then
        kocmoc.toggles.killvicious = true
        temptable.cache.vicious = false
    end
    if temptable.cache.windy then
        kocmoc.toggles.killwindy = true
        temptable.cache.windy = false
    end
end

function gettoken(v3, farmclosest)
    --if temptable.doingbubbles or temptable.doingcrosshairs then return end
    if not v3 then v3 = fieldposition end
    task.wait()
    if farmclosest then
        for i=0,10 do
            local closesttoken = {}
            for e, r in next, game.Workspace.Collectibles:GetChildren() do
                if r:FindFirstChild("farmed") then continue end
                itb = false
                if r:FindFirstChildOfClass("Decal") and kocmoc.toggles.enabletokenblacklisting then
                    if api.findvalue(kocmoc.bltokens, string.split(r:FindFirstChildOfClass("Decal").Texture, "rbxassetid://")[2]) then
                        itb = true
                    end
                end
                if not itb and findField(r.Position) == findField(api.humanoidrootpart().Position) then
                    if closesttoken.Distance then
                        if (r.Position - api.humanoidrootpart().Position).magnitude < closesttoken.Distance then
                            closesttoken = {Token = r, Distance = (r.Position - api.humanoidrootpart().Position).magnitude}
                        end
                    else
                        closesttoken = {Token = r, Distance = (r.Position - api.humanoidrootpart().Position).magnitude}
                    end
                end
            end
            if closesttoken.Token then
                farm(closesttoken.Token)
                local farmed = Instance.new("BoolValue", closesttoken.Token)
                farmed.Name = "farmed"
                task.spawn(function()
                    task.wait(1)
                    if closesttoken.Token and closesttoken.Token.Parent then
                        farmed.Parent = nil
                    end
                end)
            end
        end
    else
        for e, r in next, game.Workspace.Collectibles:GetChildren() do
            itb = false
            if r:FindFirstChildOfClass("Decal") and kocmoc.toggles.enabletokenblacklisting then
                if api.findvalue(kocmoc.bltokens, string.split(r:FindFirstChildOfClass("Decal").Texture, "rbxassetid://")[2]) then
                    itb = true
                end
            end
            if tonumber((r.Position - api.humanoidrootpart().Position).magnitude) <= temptable.magnitude / 1.4 and not itb and (v3 - r.Position).magnitude <= temptable.magnitude then
                farm(r)
            end
        end
    end
end

function makesprinklers(position, onlyonesprinkler)
    local sprinkler = rtsg().EquippedSprinkler
    local sprinklercount = 1
    local sprinklermodel = game.Workspace.Gadgets:FindFirstChild(sprinkler)

    if sprinkler == "The Supreme Saturator" then
        if sprinklermodel then
            if (sprinklermodel.Base.CFrame.p - position).magnitude > 32 then
                playeractivescommand:FireServer({["Name"] = "Sprinkler Builder"})
            end
        else
            playeractivescommand:FireServer({["Name"] = "Sprinkler Builder"})
        end
        return
    end
    
    if sprinkler == "Basic Sprinkler" or onlyonesprinkler then
        sprinklercount = 1
    elseif sprinkler == "Silver Soakers" then
        sprinklercount = 2
    elseif sprinkler == "Golden Gushers" then
        sprinklercount = 3
    elseif sprinkler == "Diamond Drenchers" then
        sprinklercount = 4
    end

    for i = 1, sprinklercount do
        if api.humanoid() then
            local k = api.humanoid().JumpPower
            if sprinklercount ~= 1 then
                api.humanoid().JumpPower = 70
                api.humanoid().Jump = true
                task.wait(.2)
            end
            playeractivescommand:FireServer({["Name"] = "Sprinkler Builder"})
            if sprinklercount ~= 1 then
                api.humanoid().JumpPower = k
                task.wait(1)
            end
        end
    end
end

function domob(place)
    if place:FindFirstChild("Territory") then
        local timestamp = tick()
        local secondstamp = tick()
        local monsterpart = place.Territory.Value

        if place.Name:match("Werewolf") then
            monsterpart = game:GetService("Workspace").Territories.WerewolfPlateau.w
        elseif place.Name:match("Mushroom") then
            monsterpart = game:GetService("Workspace").Territories.MushroomZone.Part
        end

        local point = Vector3.new((place.CFrame.p.X + monsterpart.CFrame.p.X) / 2, monsterpart.CFrame.p.Y, (place.CFrame.p.Z + monsterpart.CFrame.p.Z) / 2)

        if place:FindFirstChild("TimerLabel", true).Visible then
            return false
        end

        while not place:FindFirstChild("TimerLabel", true).Visible and tick() - timestamp < 25 do
            if tick() - secondstamp > 2 then
                api.humanoidrootpart().CFrame = CFrame.new(point + Vector3.new(0, 30, 0))
                api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
                task.wait(1)
                secondstamp = tick()
            end
            task.wait()
            api.humanoidrootpart().CFrame = CFrame.new(point)
            api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
        end

        if tick() - timestamp > 25 then
            return false
        end

        task.wait(1)
        for i = 1, 2 do
            gettoken(place.CFrame.p)
        end

        return true
    end
end

function killmobs()
    if kocmoc.toggles.smartmobkill then
        local monsternames = {
            "Mantis",
            "Scorpion",
            "Spider",
            "Werewol",
            "Rhino",
            "Ladybug"
        }
        
        local totalmonsters = {}

        for i, v in next, player.PlayerGui.ScreenGui.Menus.Children.Quests:GetDescendants() do
            if v.Name == "Description" and v.Parent and v.Parent.Parent then
                local text = v.Text
                for _,monstername in pairs(monsternames) do
                    local monsterindex = text:find(monstername)
                    if monsterindex and not text:find("Field") and text:find("/") then
                        local totalmonstercount = text:sub(text:find("/") + 1, #text)
                        local defeatedmonstercount = text:sub(text:find("\n"), text:find("/") - 1)
                        totalmonsters[monstername] = totalmonsters[monstername] and totalmonsters[monstername] + totalmonstercount - defeatedmonstercount or totalmonstercount - defeatedmonstercount
                    end
                end
            end
        end

        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("Rhino Bush")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Ladybug"] and totalmonsters["Ladybug"] > 0 then
            if domob(monsterspawners:FindFirstChild("Ladybug Bush")) then
                totalmonsters["Ladybug"] = totalmonsters["Ladybug"] - 1
            end
        end
        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("Rhino Cave 1")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("Rhino Cave 2")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("Rhino Cave 3")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Rhino"] and totalmonsters["Rhino"] > 0 then
            if domob(monsterspawners:FindFirstChild("PineappleBeetle")) then
                totalmonsters["Rhino"] = totalmonsters["Rhino"] - 1
            end
        end
        if totalmonsters["Mantis"] and totalmonsters["Mantis"] > 0 then
            if domob(monsterspawners:FindFirstChild("PineappleMantis1")) then
                totalmonsters["Mantis"] = totalmonsters["Mantis"] - 1
            end
        end
        if totalmonsters["Spider"] and totalmonsters["Spider"] > 0 then
            domob(monsterspawners:FindFirstChild("Spider Cave"))
        end
        if totalmonsters["Ladybug"] and totalmonsters["Ladybug"] > 0 then
            if domob(monsterspawners:FindFirstChild("MushroomBush")) then
                totalmonsters["Ladybug"] = totalmonsters["Ladybug"] - 1
            end
        end
        if totalmonsters["Ladybug"] and totalmonsters["Ladybug"] > 0 then
            domob(monsterspawners:FindFirstChild("Ladybug Bush 2"))
            domob(monsterspawners:FindFirstChild("Ladybug Bush 3"))
        end
        if totalmonsters["Scorpion"] and totalmonsters["Scorpion"] > 0 then
            domob(monsterspawners:FindFirstChild("ScorpionBush")) 
            domob(monsterspawners:FindFirstChild("ScorpionBush2"))
        end
        if totalmonsters["Werewol"] and totalmonsters["Werewol"] > 0 then
            domob(monsterspawners:FindFirstChild("WerewolfCave"))
        end
        if totalmonsters["Mantis"] and totalmonsters["Mantis"] > 0 then
            domob(monsterspawners:FindFirstChild("ForestMantis1"))
            domob(monsterspawners:FindFirstChild("ForestMantis2"))
        end
    else
        domob(monsterspawners:FindFirstChild("Rhino Bush")) -- Clover Field
        domob(monsterspawners:FindFirstChild("Ladybug Bush")) -- Clover Field
        domob(monsterspawners:FindFirstChild("Rhino Cave 1")) -- Blue Flower Field
        domob(monsterspawners:FindFirstChild("Rhino Cave 2")) -- Bamboo Field
        domob(monsterspawners:FindFirstChild("Rhino Cave 3")) -- Bamboo Field
        domob(monsterspawners:FindFirstChild("PineappleMantis1")) -- Pineapple Field
        domob(monsterspawners:FindFirstChild("PineappleBeetle")) -- Pineapple Field
        domob(monsterspawners:FindFirstChild("Spider Cave")) -- Spider Field
        domob(monsterspawners:FindFirstChild("MushroomBush")) -- Mushroom Field
        domob(monsterspawners:FindFirstChild("Ladybug Bush 2")) -- Strawberry Field
        domob(monsterspawners:FindFirstChild("Ladybug Bush 3")) -- Strawberry Field
        domob(monsterspawners:FindFirstChild("ScorpionBush")) -- Rose Field
        domob(monsterspawners:FindFirstChild("ScorpionBush2")) -- Rose Field
        domob(monsterspawners:FindFirstChild("WerewolfCave")) -- Werewolf
        domob(monsterspawners:FindFirstChild("ForestMantis1")) -- Pine Tree Field
        domob(monsterspawners:FindFirstChild("ForestMantis2")) -- Pine Tree Field
    end
end

function IsToken(token)
    if not token then return false end
    if not token.Parent then return false end
    if token then
        if token.Orientation.Z ~= 0 then return false end
        if token:FindFirstChild("FrontDecal") then
        else
            return false
        end
        if not token.Name == "C" then return false end
        if not token:IsA("Part") then return false end
        return true
    else
        return false
    end
end

function check(ok)
    if not ok then return false end
    if not ok.Parent then return false end
    return true
end

function getplanters()
    table.clear(planterst.plantername)
    table.clear(planterst.planterid)
    for i, v in pairs(debug.getupvalues(require(game:GetService("ReplicatedStorage").LocalPlanters).LoadPlanter)[4]) do
        if v.GrowthPercent == 1 and v.IsMine then
            table.insert(planterst.plantername, v.Type)
            table.insert(planterst.planterid, v.ActorID)
        end
    end
end

function getBuffTime(decalID)
    if not decalID then return 0 end
    
    for i,v in pairs(player.PlayerGui.ScreenGui:GetChildren()) do
        if v.Name == "TileGrid" then
            for j,k in pairs(v:GetChildren()) do
                if k:FindFirstChild("BG") and k.BG:FindFirstChild("Icon") then
                    if string.find(tostring(k.BG.Icon.Image), decalID) then
                        return k.BG.Bar.Size.Y.Scale
                    end
                end
            end
        end
    end

    return 0
end

function getBuffStack(decalID)
    if not decalID then return 0 end
    
    for i,v in pairs(player.PlayerGui.ScreenGui:GetChildren()) do
        if v.Name == "TileGrid" then
            for j,k in pairs(v:GetChildren()) do
                if k:FindFirstChild("BG") and k.BG:FindFirstChild("Icon") then
                    if string.find(tostring(k.BG.Icon.Image), decalID) then
                        local placeholder = k.BG.Text.Text:gsub("x", "")
                        return tonumber(placeholder) or 1
                    end
                end
            end
        end
    end

    return 0
end

function farmant()
    antpart.CanCollide = true
    temptable.started.ant = true
    local anttable = {left = true, right = false}
    temptable.oldtool = rtsg()["EquippedCollector"]
    if temptable.oldtool ~= "Tide Popper" then
        equiptool("Spark Staff")
    end
    local oldmask = rtsg()["EquippedAccessories"]["Hat"]
    maskequip("Demon Mask")
    game.ReplicatedStorage.Events.ToyEvent:FireServer("Ant Challenge")
    kocmoc.toggles.autodig = true
    local acl = CFrame.new(Vector3.new(127, 48, 547), Vector3.new(94, 51.8, 550))
    local acr = CFrame.new(Vector3.new(65, 48, 534), Vector3.new(94, 51.8, 550))
    task.wait(1)
    playeractivescommand:FireServer({
        ["Name"] = "Sprinkler Builder"
    })
    api.humanoidrootpart().CFrame = api.humanoidrootpart().CFrame + Vector3.new(0, 15, 0)
    local anttokendb = false
    task.wait(3)
    repeat
        task.wait()
        task.spawn(function()
            if not anttokendb then
                anttokendb = true
                local smallest = math.huge
                for _,token in pairs(workspace.Collectibles:GetChildren()) do
                    local decal = token:FindFirstChildOfClass("Decal")
                    if decal and decal.Texture then
                        if decal.Texture == "rbxassetid://1629547638" then
                            for _,monster in pairs(game.Workspace.Monsters:GetChildren()) do
                                if monster.Name:find("Ant") and monster:FindFirstChild("Head") then
                                    local dist = (monster.Head.CFrame.p - token.CFrame.p).magnitude
                                    if dist < smallest then
                                        smallest = dist
                                    end
                                end
                            end
                            
                            if player.Character:FindFirstChild("Humanoid") and smallest > 20 and smallest < 100 then
                                local save = api.humanoidrootpart().CFrame
                                api.humanoidrootpart().CFrame = CFrame.new(token.CFrame.p)
                                task.wait(0.5)
                                api.humanoidrootpart().CFrame = save
                                break
                            end
                        end
                    end
                end
                task.wait(1)
                anttokendb = false
            end
        end)
        for i, v in next, game.Workspace.Toys["Ant Challenge"].Obstacles:GetChildren() do
            if v:FindFirstChild("Root") then
                if (v.Root.Position - api.humanoidrootpart().Position).magnitude <= 40 and anttable.left then
                    api.humanoidrootpart().CFrame = acr
                    anttable.left = false
                    anttable.right = true
                    task.wait(0.5)
                elseif (v.Root.Position - api.humanoidrootpart().Position).magnitude <= 40 and anttable.right then
                    api.humanoidrootpart().CFrame = acl
                    anttable.left = true
                    anttable.right = false
                    task.wait(0.5)
                end
            end
        end
    until game.Workspace.Toys["Ant Challenge"].Busy.Value == false
    task.wait(1)
    if temptable.oldtool ~= "Tide Popper" then
        equiptool(temptable.oldtool)
    end
    maskequip(oldmask)
    temptable.started.ant = false
    antpart.CanCollide = false
end

function collectplanters()
    getplanters()
    for i, v in pairs(planterst.plantername) do
        if api.partwithnamepart(v, game.Workspace.Planters) and api.partwithnamepart(v, game.Workspace.Planters):FindFirstChild("Soil") then
            local soil = api.partwithnamepart(v, game.Workspace.Planters).Soil
            api.humanoidrootpart().CFrame = soil.CFrame
            game:GetService("ReplicatedStorage").Events.PlanterModelCollect:FireServer(planterst.planterid[i])
            task.wait(.5)
            playeractivescommand:FireServer({["Name"] = v .. " Planter"})
            for i = 1, 5 do gettoken(soil.Position) end
            task.wait(2)
        end
    end
end

function getprioritytokens()
    task.wait()
    if temptable.running == false then
        for e, r in next, game.Workspace.Collectibles:GetChildren() do
            if r:FindFirstChildOfClass("Decal") then
                local aaaaaaaa = string.split(r:FindFirstChildOfClass("Decal").Texture, "rbxassetid://")[2]
                if aaaaaaaa ~= nil and api.findvalue(kocmoc.priority, aaaaaaaa) then
                    if r.Name == player.Name and
                        not r:FindFirstChild("got it") or tonumber((r.Position - api.humanoidrootpart().Position).magnitude) <= temptable.magnitude / 1.4 and
                        not r:FindFirstChild("got it") then
                        farm(r)
                        local val = Instance.new("IntValue", r)
                        val.Name = "got it"
                        break
                    end
                end
            end
        end
    end
end

function gethiveballoon()
    for _,balloon in pairs(game.Workspace.Balloons.HiveBalloons:GetChildren()) do
        if balloon:FindFirstChild("BalloonRoot") then
            if balloon.BalloonRoot.CFrame.p.X == player.SpawnPos.Value.p.X then
                return true
            end
        end
    end
    return false
end

local function getfurthestballoon()
    local biggest = 0
    local saveloon = nil
    local balloons = game.Workspace:FindFirstChild("Balloons")
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if balloons and root then
        for _,balloon in pairs(balloons.FieldBalloons:GetChildren()) do
            local owner = balloon:FindFirstChild("PlayerName")
            if owner then
                if owner.Value == player.Name then
                    local text = balloon.BalloonBody.GuiAttach.Gui.Bar.TextLabel.Text
                    local bar = balloon.BalloonBody.GuiAttach.Gui.Bar.FillBar
                    if bar.Parent.BackgroundTransparency == 0 and fieldposition then
                        local dist = (root.CFrame.p - balloon.BalloonBody.Position).magnitude
                        if dist > biggest and dist < 100 then
                            biggest = dist
                            saveloon = balloon
                        end
                    end
                end
            end
        end
    end
    if saveloon and fieldposition then
        return Vector3.new(saveloon.BalloonBody.Position.X, fieldposition.Y, saveloon.BalloonBody.Position.Z)
    end
    return nil
end

function converthoney()
    task.wait(0)
    if temptable.converting then
        if player.PlayerGui.ScreenGui.ActivateButton.TextBox.Text ~= "Stop Making Honey" and player.PlayerGui.ScreenGui.ActivateButton.BackgroundColor3 ~= Color3.new(201, 39, 28) or (player.SpawnPos.Value.Position - api.humanoidrootpart().Position).magnitude > 13 then
            api.tween(1, player.SpawnPos.Value * CFrame.fromEulerAnglesXYZ(0, 110, 0) + Vector3.new(0, 0, 9))
            task.wait(.9)
            if player.PlayerGui.ScreenGui.ActivateButton.TextBox.Text ~= "Stop Making Honey" and player.PlayerGui.ScreenGui.ActivateButton.BackgroundColor3 ~= Color3.new(201, 39, 28) or (player.SpawnPos.Value.Position - api.humanoidrootpart().Position).magnitude > 13 then
                game:GetService("ReplicatedStorage").Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
            end
            task.wait(.1)
        end
    end
end

function closestleaf()
    for i, v in next, game.Workspace.Flowers:GetChildren() do
        if temptable.running == false and tonumber((v.Position - player.Character.HumanoidRootPart.Position).magnitude) < temptable.magnitude / 1.4 then
            farm(v)
            break
        end
    end
end

function getballoons()
    if temptable.doingbubbles or temptable.doingcrosshairs then return end
    for i, v in next, game.Workspace.Balloons.FieldBalloons:GetChildren() do
        if v:FindFirstChild("BalloonRoot") and v:FindFirstChild("PlayerName") then
            if v:FindFirstChild("PlayerName").Value == player.Name then
                if tonumber((v.BalloonRoot.Position - api.humanoidrootpart().Position).magnitude) < temptable.magnitude / 1.4 then
                    api.walkTo(v.BalloonRoot.Position)
                end
            end
        end
    end
end

function getpuff()
    local smallest = math.huge
    local closestPuffStem
    for _,puffshroom in pairs(game.Workspace.Happenings.Puffshrooms:GetChildren()) do
        local stem = puffshroom:FindFirstChild("Puffball Stem")
        if stem and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (api.humanoidrootpart().CFrame.p - stem.CFrame.p).magnitude
            if dist < smallest then
                smallest = dist
                closestPuffStem = stem
            end
        end
    end

    if closestPuffStem then
        api.walkTo(closestPuffStem.CFrame.p)
    end
end

function doautox4()
    if temptable.autox4glitter == 1 then
        writefile("kocmoc/plantercache/x4.file", "0")
    else
        writefile("kocmoc/plantercache/x4.file", "1")
    end
end

function getflower()
    flowerrrr = flowertable[math.random(#flowertable)]
    if tonumber((flowerrrr - api.humanoidrootpart().Position).magnitude) <= temptable.magnitude / 1.4 and
        tonumber((flowerrrr - fieldposition).magnitude) <= temptable.magnitude / 1.4 then
        if temptable.running == false then
            if kocmoc.toggles.loopfarmspeed then
                player.Character.Humanoid.WalkSpeed = kocmoc.vars.farmspeed
            end
            api.walkTo(flowerrrr)
        end
    end
end

function getcloud()
    if temptable.doingbubbles or temptable.doingcrosshairs then return end
    for i, v in next, game.Workspace.Clouds:GetChildren() do
        e = v:FindFirstChild("Plane")
        if e and tonumber((e.Position - api.humanoidrootpart().Position).magnitude) < temptable.magnitude / 1.4 then
            api.walkTo(e.Position)
        end
    end
end

function getfuzzy()
    pcall(function()
        for i, v in next, game.workspace.Particles:GetChildren() do
            if v.Name == "DustBunnyInstance" and temptable.running == false and
                tonumber((v.Plane.Position - api.humanoidrootpart().Position).magnitude) < temptable.magnitude /
                1.4 then
                if v:FindFirstChild("Plane") then
                    farm(v:FindFirstChild("Plane"))
                    break
                end
            end
        end
    end)
end

function getflame()
    for _,v in pairs(game.Workspace.PlayerFlames:GetChildren()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and v.PF.Color.Keypoints[1].Value.G == 0 and findField(v.Position) == findField(api.humanoidrootpart().Position) then
            api.humanoid():MoveTo(v.Position)
            repeat
                task.wait()
            until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or not temptable.running
            return
        end
    end
end

function avoidmob()
    for i, v in next, game.Workspace.Monsters:GetChildren() do
        if v:FindFirstChild("Head") then
            if (v.Head.Position - api.humanoidrootpart().Position).magnitude < 30 and api.humanoid():GetState() ~= Enum.HumanoidStateType.Freefall then
                player.Character.Humanoid.Jump = true
            end
        end
    end
end

function dobubbles()
    if kocmoc.toggles.farmpuffshrooms and game.Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model") then return end
    if temptable.started.ant or temptable.started.vicious or temptable.converting or temptable.planting then return end

    temptable.doingbubbles = true
    local savespeed = kocmoc.vars.walkspeed
    kocmoc.vars.walkspeed = kocmoc.vars.walkspeed * 1.75

    for _,v in pairs(game.Workspace.Particles:GetChildren()) do
        if string.find(v.Name, "Bubble") and v.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and getBuffTime("5101328809") > 0.2 and (v.Position - api.humanoidrootpart().Position).magnitude < temptable.magnitude * 0.9 then
            api.humanoid():MoveTo(v.Position)
            repeat
                task.wait()
            until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or not temptable.running
        end
    end

    temptable.doingbubbles = false
    kocmoc.vars.walkspeed = savespeed
end

function docrosshairs()
    if kocmoc.toggles.farmpuffshrooms and game.Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model") then return end
    if temptable.started.ant or temptable.started.vicious or temptable.converting or temptable.planting or temptable.started.monsters then return end

    local savespeed = kocmoc.vars.walkspeed

    for _,v in pairs(game.Workspace.Particles:GetChildren()) do
        if string.find(v.Name, "Crosshair") and v.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and v.BrickColor ~= BrickColor.new("Flint") then
            if kocmoc.toggles.fastcrosshairs then
                if (v.Position - api.humanoidrootpart().Position).magnitude > 200 then continue end
                if getBuffTime("8172818074") > 0.5 and getBuffStack("8172818074") > 9 and getBuffTime("5101329167") == 0 then
                    if v.BrickColor == BrickColor.new("Alder") then
                        task.wait(0.5)
                        local save_height = v.Position.y
                        repeat
                            task.wait()
                            api.humanoidrootpart().CFrame = CFrame.new(v.Position)
                        until not v or not v.Parent or v.Position.y ~= save_height
                    end
                else
                    if v.BrickColor == BrickColor.new("Red flip/flop") or v.BrickColor == BrickColor.new("Alder") then
                        repeat
                            api.humanoid():MoveTo(v.Position)
                            task.wait()
                        until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or v.BrickColor == BrickColor.new("Forest green") or v.BrickColor == BrickColor.new("Royal purple")
                    end
                end
            else
                if (v.Position - api.humanoidrootpart().Position).magnitude < temptable.magnitude * 0.9 then
                    temptable.doingcrosshairs = true
                    kocmoc.vars.walkspeed = savespeed * 1.75
                    api.humanoid():MoveTo(v.Position)
                    repeat
                        task.wait()
                    until (v.Position - api.humanoidrootpart().Position).magnitude <= 4 or not v or not v.Parent or v.BrickColor == BrickColor.new("Forest green") or v.BrickColor == BrickColor.new("Royal purple") or not temptable.running
                    kocmoc.vars.walkspeed = savespeed
                    temptable.doingcrosshairs = false
                end
            end
        end
    end
end

function makequests()
    for i, v in next, game.Workspace.NPCs:GetChildren() do
        if v.Name ~= "Ant Challenge Info" and v.Name ~= "Bubble Bee Man 2" and v.Name ~= "Wind Shrine" and v.Name ~= "Gummy Bear" and v.Name ~= "Honey Bee" then
            if v:FindFirstChild("Platform") then
                if v.Platform:FindFirstChild("AlertPos") then
                    if v.Platform.AlertPos:FindFirstChild("AlertGui") then
                        if v.Platform.AlertPos.AlertGui:FindFirstChild("ImageLabel") then
                            image = v.Platform.AlertPos.AlertGui.ImageLabel
                            button = player.PlayerGui.ScreenGui.ActivateButton.MouseButton1Click
                            if image.ImageTransparency == 0 then
                                if kocmoc.toggles.tptonpc then
                                    api.humanoidrootpart().CFrame = CFrame.new(
                                        v.Platform.Position.X,
                                        v.Platform.Position.Y + 3,
                                        v.Platform.Position.Z
                                    )
                                    task.wait(1)
                                else
                                    api.tween(2, CFrame.new(
                                        v.Platform.Position.X,
                                        v.Platform.Position.Y + 3,
                                        v.Platform.Position.Z
                                    ))
                                    task.wait(3)
                                end
                                for b, z in next, getconnections(button) do
                                    z.Function()
                                end
                                task.wait(8)
                                if image.ImageTransparency == 0 then
                                    for b, z in next, getconnections(button) do
                                        z.Function()
                                    end
                                end
                                task.wait(2)
                            end
                        end
                    end
                end
            end
        end
    end
end

getgenv().Tvk1 = {true, "💖"}

local function donateToShrine(item, qnt)
    print(qnt)
    local s, e = pcall(function()
        game:GetService("ReplicatedStorage").Events.WindShrineDonation:InvokeServer(item, qnt)
        task.wait(0.5)
        game.ReplicatedStorage.Events.WindShrineTrigger:FireServer()

        local UsePlatform = game.Workspace.NPCs["Wind Shrine"].Stage
        api.humanoidrootpart().CFrame = UsePlatform.CFrame + Vector3.new(0, 5, 0)

        for i = 1, 120 do
            task.wait(0.05)
            for i, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                if (v.Position - UsePlatform.Position).magnitude < 60 and
                    v.CFrame.YVector.Y == 1 then
                    api.humanoidrootpart().CFrame = v.CFrame
                end
            end
        end
    end)
    if not s then print(e) end
end

local function isWindshrineOnCooldown()
    local isOnCooldown = false
    local cooldown = 3600 - (require(game.ReplicatedStorage.OsTime)() - (require(game.ReplicatedStorage.StatTools).GetLastCooldownTime(v1, "WindShrine")))
    if cooldown > 0 then isOnCooldown = true end
    return isOnCooldown
end

local function getTimeSinceToyActivation(name)
    return require(game.ReplicatedStorage.OsTime)() - require(game.ReplicatedStorage.ClientStatCache):Get("ToyTimes")[name]
end

local function getTimeUntilToyAvailable(n)
    return workspace.Toys[n].Cooldown.Value - getTimeSinceToyActivation(n)
end

local function canToyBeUsed(toy)
    local timeleft = tostring(getTimeUntilToyAvailable(toy))
    local canbeUsed = false
    if string.find(timeleft, "-") then canbeUsed = true end
    return canbeUsed
end

function GetItemListWithValue()
    local StatCache = require(game.ReplicatedStorage.ClientStatCache)
    local data = StatCache.Get()
    return data.Eggs
end

local function useConvertors()
    local conv = {
        "Instant Converter", "Instant Converter B", "Instant Converter C"
    }

    local lastWithoutCooldown = nil

    for i, v in pairs(conv) do
        if canToyBeUsed(v) == true then lastWithoutCooldown = v end
    end
    local converted = false
    if lastWithoutCooldown ~= nil and
        string.find(kocmoc.vars.autouseMode, "Ticket") or
        string.find(kocmoc.vars.autouseMode, "All") then
        if converted == false then
            game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer(
                lastWithoutCooldown)
            converted = true
        end
    end
    if GetItemListWithValue()["Snowflake"] > 0 and
        string.find(kocmoc.vars.autouseMode, "Snowflak") or
        string.find(kocmoc.vars.autouseMode, "All") then
        playeractivescommand:FireServer({["Name"] = "Snowflake"})
    end
    if GetItemListWithValue()["Coconut"] > 0 and
        string.find(kocmoc.vars.autouseMode, "Coconut") or
        string.find(kocmoc.vars.autouseMode, "All") then
        playeractivescommand:FireServer({["Name"] = "Coconut"})
    end
end

local function fetchBuffTable(stats)
    local stTab = {}
    if player then
        if player.PlayerGui then
            if player.PlayerGui.ScreenGui then
                for i, v in pairs(player.PlayerGui.ScreenGui:GetChildren()) do
                    if v.Name == "TileGrid" then
                        for p, l in pairs(v:GetChildren()) do
                            if l:FindFirstChild("BG") then
                                if l:FindFirstChild("BG"):FindFirstChild("Icon") then
                                    local ic = l:FindFirstChild("BG"):FindFirstChild("Icon")
                                    for field, fdata in pairs(stats) do
                                        if fdata["DecalID"] ~= nil then
                                            if string.find(ic.Image, fdata["DecalID"]) then
                                                if ic.Parent:FindFirstChild("Text") then
                                                    if ic.Parent:FindFirstChild("Text").Text == "" then
                                                        stTab[field] = 1
                                                    else
                                                        local thing = ""
                                                        thing = string.gsub(ic.Parent:FindFirstChild("Text").Text, "x", "")
                                                        stTab[field] = tonumber(thing + 1)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return stTab
end

local fullPlanterData = {
    ["Red Clay"] = {
        NectarTypes = {Invigorating = 1.2, Satisfying = 1.2},
        GrowthFields = {
            ["Pepper Patch"] = 1.25,
            ["Rose Field"] = 1.25,
            ["Strawberry Field"] = 1.25,
            ["Mushroom Field"] = 1.25
        }
    },
    --[[
    Plenty = {
        NectarTypes = {
            Satisfying = 1.5,
            Comforting = 1.5,
            Invigorating = 1.5,
            Refreshing = 1.5,
            Motivating = 1.5
        },
        GrowthFields = {
            ["Mountain Top Field"] = 1.5,
            ["Coconut Field"] = 1.5,
            ["Pepper Patch"] = 1.5,
            ["Stump Field"] = 1.5
        }
    },
    Festive = {
        NectarTypes = {
            Satisfying = 3,
            Comforting = 3,
            Invigorating = 3,
            Refreshing = 3,
            Motivating = 3
        },
        GrowthFields = { }
    },
    Paper = {
        NectarTypes = {
            Satisfying = 0.75,
            Comforting = 0.75,
            Invigorating = 0.75,
            Refreshing = 0.75,
            Motivating = 0.75
        },
        GrowthFields = {}
    },
    ]]
    Tacky = {
        NectarTypes = {Satisfying = 1.25, Comforting = 1.25},
        GrowthFields = {
            ["Sunflower Field"] = 1.25,
            ["Mushroom Field"] = 1.25,
            ["Dandelion Field"] = 1.25,
            ["Clover Field"] = 1.25,
            ["Blue Flower Field"] = 1.25
        }
    },
    Candy = {
        NectarTypes = {Motivating = 1.2},
        GrowthFields = {
            ["Coconut Field"] = 1.25,
            ["Strawberry Field"] = 1.25,
            ["Pineapple Patch"] = 1.25
        }
    },
    Hydroponic = {
        NectarTypes = {Refreshing = 1.4, Comforting = 1.4},
        GrowthFields = {
            ["Blue Flower Field"] = 1.5,
            ["Pine Tree Forest"] = 1.5,
            ["Stump Field"] = 1.5,
            ["Bamboo Field"] = 1.5
        }
    },
    Plastic = {
        NectarTypes = {
            Refreshing = 1,
            Invigorating = 1,
            Comforting = 1,
            Satisfying = 1,
            Motivating = 1
        },
        GrowthFields = {}
    },
    Petal = {
        NectarTypes = {Satisfying = 1.5, Comforting = 1.5},
        GrowthFields = {
            ["Sunflower Field"] = 1.5,
            ["Dandelion Field"] = 1.5,
            ["Spider Field"] = 1.5,
            ["Pineapple Patch"] = 1.5,
            ["Coconut Field"] = 1.5
        }
    },
    ["Heat-Treated"] = {
        NectarTypes = {Invigorating = 1.4, Motivating = 1.4},
        GrowthFields = {
            ["Pepper Patch"] = 1.5,
            ["Rose Field"] = 1.5,
            ["Strawberry Field"] = 1.5,
            ["Mushroom Field"] = 1.5
        }
    },
    ["Blue Clay"] = {
        NectarTypes = {Refreshing = 1.2, Comforting = 1.2},
        GrowthFields = {
            ["Blue Flower Field"] = 1.25,
            ["Pine Tree Forest"] = 1.25,
            ["Stump Field"] = 1.25,
            ["Bamboo Field"] = 1.25
        }
    },
    Pesticide = {
        NectarTypes = {Motivating = 1.3, Satisfying = 1.3},
        GrowthFields = {
            ["Strawberry Field"] = 1.3,
            ["Spider Field"] = 1.3,
            ["Bamboo Field"] = 1.3
        }
    }
}

local planterData = deepcopy(fullPlanterData)

local nectarData = {
    Refreshing = {"Blue Flower Field", "Strawberry Field", "Coconut Field"},
    Invigorating = {"Clover Field", "Cactus Field", "Mountain Top Field", "Pepper Patch"},
    Comforting = {"Dandelion Field", "Bamboo Field", "Pine Tree Forest"},
    Motivating = {"Mushroom Field", "Spider Field", "Stump Field", "Rose Field"},
    Satisfying = {"Sunflower Field", "Pineapple Patch", "Pumpkin Patch"}
}

function GetPlanterData(name)
    local concaccon = require(game:GetService("ReplicatedStorage").LocalPlanters)
    local concacbo = concaccon.LoadPlanter
    local PlanterTable = debug.getupvalues(concacbo)[4]
    local tttttt = nil
    for k, v in pairs(PlanterTable) do
        if v.PotModel and v.IsMine == true and string.find(v.PotModel.Name, name) then 
            tttttt = v
        end
    end
    return tttttt
end

local fullnectardata = require(game:GetService("ReplicatedStorage").NectarTypes).GetTypes()

function fetchNectarsData()

    local ndata = {
        Refreshing = "none",
        Invigorating = "none",
        Comforting = "none",
        Motivating = "none",
        Satisfying = "none"
    }

    if game:GetService("Players").LocalPlayer then
        if game:GetService("Players").LocalPlayer.PlayerGui then
            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui then
                for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui:GetChildren()) do
                    if v.Name == "TileGrid" then
                        for p, l in pairs(v:GetChildren()) do
                            for k, e in pairs(fullnectardata) do
                                if l:FindFirstChild("BG") then
                                    if l:FindFirstChild("BG"):FindFirstChild("Icon") then
                                        if l:FindFirstChild("BG"):FindFirstChild("Icon").ImageColor3 == e.Color then
                                            local Xsize = l:FindFirstChild("BG").Bar.AbsoluteSize.X
                                            local Ysize = l:FindFirstChild("BG").Bar.AbsoluteSize.Y
                                            local percentage = (Ysize / Xsize) * 100
                                            ndata[k] = percentage
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return ndata
end

function isBlacklisted(nectartype, blacklist)
    local bl = false
    for i, v in pairs(blacklist) do
        if v == nectartype then
            bl = true
        end
    end
    for i, v in pairs(NectarBlacklist) do
        if v == nectartype then
            bl = true
        end
    end
    return bl
end

function calculateLeastNectar(blacklist)
    local leastNectar = nil
    local tempLeastValue = 999

    local nectarData = fetchNectarsData()
    for i, v in pairs(nectarData) do
        if not isBlacklisted(i, blacklist) then
            if v == "none" or v == nil then
                leastNectar = i
                tempLeastValue = 0
            else
                if v <= tempLeastValue then
                    tempLeastValue = v
                    leastNectar = i
                end
            end
        end
    end
    return leastNectar
end

function GetItemListWithValue()
    local StatCache = require(game.ReplicatedStorage.ClientStatCache)
    local data = StatCache.Get()
    return data.Eggs
end

function fetchBestMatch(nectartype, field)
    local bestPlanter = nil
    local bestNectarMult = 0
    local bestFieldGrowthRate = 0
    for i, v in pairs(planterData) do
        if GetItemListWithValue()[i .. "Planter"] then
            if GetItemListWithValue()[i .. "Planter"] >= 1 then
                if v.GrowthFields[field] ~= nil then
                    if v.GrowthFields[field] > bestFieldGrowthRate then
                        bestFieldGrowthRate = v.GrowthFields[field]
                        bestPlanter = i
                    end
                end
            end
        end
    end
    for i, v in pairs(planterData) do
        if GetItemListWithValue()[i .. "Planter"] then
            if GetItemListWithValue()[i .. "Planter"] >= 1 then
                if v.NectarTypes[nectartype] ~= nil then
                    if v.NectarTypes[nectartype] > bestNectarMult then
                        local totalNectarFieldGrowthMult = 0
                        if v["GrowthFields"][field] ~= nil then
                            totalNectarFieldGrowthMult = totalNectarFieldGrowthMult + (v["GrowthFields"][field])
                        end
                        bestNectarMult = (v.NectarTypes[nectartype] + totalNectarFieldGrowthMult)
                        bestPlanter = i
                    end
                end
            end
        end
    end
    return bestPlanter
end

function getPlanterLocation(plnt)
    local resultingField = "None"
    local lowestMag = math.huge
    for i, v in pairs(game:GetService("Workspace").FlowerZones:GetChildren()) do
        if (v.Position - plnt.Position).magnitude < lowestMag then
            lowestMag = (v.Position - plnt.Position).magnitude
            resultingField = v.Name
        end
    end
    return resultingField
end

function isFieldOccupied(field)
    local isOccupied = false
    local concaccon = require(game:GetService("ReplicatedStorage").LocalPlanters)
    local concacbo = concaccon.LoadPlanter
    local PlanterTable = debug.getupvalues(concacbo)[4]

    for k, v in pairs(PlanterTable) do
        if v.PotModel and v.PotModel.Parent and v.PotModel.PrimaryPart then
            if getPlanterLocation(v.PotModel.PrimaryPart) == field then
                isOccupied = true
            end
        end
    end
    return isOccupied
end

function fetchAllPlanters()
    local p = {}
    local concaccon = require(game:GetService("ReplicatedStorage").LocalPlanters)
    local concacbo = concaccon.LoadPlanter
    local PlanterTable = debug.getupvalues(concacbo)[4]

    for k, v in pairs(PlanterTable) do
        if v.PotModel and v.PotModel.Parent and v.IsMine == true then
            p[k] = v
        end
    end
    return p
end

function isNectarPending(nectartype)
    local planterz = fetchAllPlanters()
    local isPending = false
    for i, v in pairs(planterz) do
        local location = getPlanterLocation(v.PotModel.PrimaryPart)
        if location then
            local conftype = getNectarFromField(location)
            if conftype then
                if conftype == nectartype then
                    isPending = true
                end
            end
        end
    end
    return isPending
end

function fetchBestFieldWithNectar(nectar)
    local bestField = "None"
    local nectarFields = nectarData[nectar]
    local fieldPlaceholderValue = ""

    repeat
        task.wait(0.01)
        local randomField = nectarFields[math.random(1, #nectarFields)]
        if randomField then
            fieldPlaceholderValue = randomField
        end
    until not isFieldOccupied(fieldPlaceholderValue)

    bestField = fieldPlaceholderValue

    return bestField
end

function checkIfPlanterExists(pNum)
    local exists = false
    local stuffs = fetchAllPlanters()
    if stuffs ~= {} then
        for i, v in pairs(stuffs) do
            if v["ActorID"] == pNum then
                exists = true
            end
        end
    end
    return exists
end

function collectSpecificPlanter(prt, id)
    if prt then
        if player.Character then
            if player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character:FindFirstChild("HumanoidRootPart").CFrame = prt.CFrame
                task.wait(0.1)
                game:GetService("ReplicatedStorage").Events.PlanterModelCollect:FireServer(id)
            end
        end
    end
end

function RequestCollectPlanter(planter)
    if planter.PotModel and planter.PotModel.Parent and planter.ActorID then
        repeat
            task.wait(0.7)
            collectSpecificPlanter(planter.PotModel.PrimaryPart, planter.ActorID)
        until not checkIfPlanterExists(planter.ActorID)
    end
end

function RequestCollectPlanters(planterTable)
    task.spawn(function()
        local plantersToCollect = {}
        if planterTable then
            for i, v in pairs(planterTable) do
                if v["GrowthPercent"] ~= nil then
                    if kocmoc.vars.planterharvestamount then
                        if v["GrowthPercent"] >= (kocmoc.vars.planterharvestamount / 100) then
                            table.insert(plantersToCollect, {
                                ["PM"] = v["PotModel"].PrimaryPart,
                                ["AID"] = v["ActorID"]
                            })
                        end
                    else
                        if v["GrowthPercent"] >= (75 / 100) then
                            table.insert(plantersToCollect, {
                                ["PM"] = v["PotModel"].PrimaryPart,
                                ["AID"] = v["ActorID"]
                            })
                        end
                    end
                end
            end
        end
        if plantersToCollect ~= {} then
            for i, v in pairs(plantersToCollect) do
                repeat
                    task.wait(0.7)
                    collectSpecificPlanter(v["PM"], v["AID"])
                until checkIfPlanterExists(v["AID"]) == false
            end
        end
    end)
end

function PlantPlanter(name, field)
    if field and name then
        local specField = game:GetService("Workspace").FlowerZones:FindFirstChild(field)
        if specField ~= nil then
            temptable.planting = true
            local attempts = 0
            repeat
                task.wait(0.1)
                if player.Character then
                    if player.Character:FindFirstChild("HumanoidRootPart") then
                        for i=0,50 do
                            player.Character.HumanoidRootPart.CFrame = specField.CFrame
                            task.wait()
                        end
                        if name == "The Planter Of Plenty" then
                            playeractivescommand:FireServer({["Name"] = name})
                        else
                            playeractivescommand:FireServer({["Name"] = name .. " Planter"})
                        end
                    end
                    attempts = attempts + 1
                end
            until GetPlanterData(name) ~= nil or attempts == 15
            temptable.planting = false
        end
    end
end

function getNectarFromField(field)
    local foundnectar = nil
    for i, v in pairs(nectarData) do
        for k, p in pairs(v) do
            if p == field then
                foundnectar = i
            end
        end
    end
    return foundnectar
end

function fetchNectarBlacklist()
    local nblacklist = {}
    for i, v in pairs(nectarData) do
        if isNectarPending(i) == true then
            table.insert(nblacklist, i)
        end
    end
    return nblacklist
end

function formatString(Planter, Field, Nectar)
    return "You should plant a " .. Planter .. " Planter in the " .. Field .. " to get " .. Nectar .. " Nectar."
end

local Config = {
    WindowName = "Rosemoc v" .. temptable.version .. " Re-Remastered By RoseGold",
    Color = Color3.fromRGB(39, 133, 11),
    Keybind = Enum.KeyCode.Semicolon
}
local Window = library:CreateWindow(Config, game:GetService("CoreGui"))

local guiElements = {
    toggles = {},
    vars = {},
    bestfields = {},
    dispensesettings = {}
}

local hometab = Window:CreateTab("Home")
local farmtab = Window:CreateTab("Farming")
local combtab = Window:CreateTab("Combat")
local itemstab = Window:CreateTab("Items")
local plantertab = Window:CreateTab("Planters")
local misctab = Window:CreateTab("Misc")
local setttab = Window:CreateTab("Settings")
local premiumtab = Window:CreateTab("Premium")

local loadingInfo = hometab:CreateSection("Startup")
local loadingFunctions = loadingInfo:CreateLabel("Loading Functions..")
task.wait(1)
loadingFunctions:UpdateText("Loaded Functions")
local loadingBackend = loadingInfo:CreateLabel("Loading Backend..")

loadingBackend:UpdateText("Loaded Backend")
local loadingUI = loadingInfo:CreateLabel("Loading UI..")

local information = hometab:CreateSection("Information")
information:CreateLabel("Welcome, " .. api.nickname .. "!")
information:CreateLabel("Script version: " .. temptable.version)
information:CreateLabel(Danger.." - Not Safe Function")
information:CreateLabel("⚙ - Configurable Function")
information:CreateLabel("📜 - May be exploit specific")
information:CreateLabel("v4 by RoseGold#5441")
information:CreateLabel("Script by Boxking776")
information:CreateLabel("Originally by weuz_ and mrdevl")
local gainedhoneylabel = information:CreateLabel("Gained Honey: 0")
local uptimelabel = information:CreateLabel("Uptime: 0")
information:CreateButton("Discord Invite", function()
    setclipboard("https://discord.gg/kTNMzbxUuZ")
end)
information:CreateButton("Donation", function()
    setclipboard("https://www.paypal.com/paypalme/GHubPay")
end)
guiElements["toggles"]["enablestatuspanel"] = information:CreateToggle("Status Panel", true, function(bool)
    kocmoc.toggles.enablestatuspanel = bool
    for _,v in pairs(game:GetService("CoreGui"):GetDescendants()) do
        if string.find(v.Name, "Mob Panel") or
            string.find(v.Name, "Utility Panel") then
            v.Visible = bool
        end
    end
end)
local farmo = farmtab:CreateSection("Farming")
local fielddropdown = farmo:CreateDropdown("Field", fieldstable, function(String)
    kocmoc.vars.field = String
end)
fielddropdown:SetOption(fieldstable[1])
guiElements["vars"]["field"] = fielddropdown
local convertatslider = farmo:CreateSlider("Convert At", 0, 100, 100, false, function(Value) kocmoc.vars.convertat = Value end)
guiElements["vars"]["convertat"] = convertatslider
local autofarmtoggle = farmo:CreateToggle("Autofarm [⚙]", nil, function(State)
    kocmoc.toggles.autofarm = State
end)
guiElements["toggles"]["autofarm"] = autofarmtoggle
autofarmtoggle:CreateKeybind("U", function(Key) end)
guiElements["toggles"]["autodig"] = farmo:CreateToggle("Autodig", nil, function(State)
    kocmoc.toggles.autodig = State
end)
guiElements["vars"]["autodigmode"] = farmo:CreateDropdown("Autodig Mode", {"Normal", "Collector Steal"}, function(Option) kocmoc.vars.autodigmode = Option end)

local contt = farmtab:CreateSection("Container Tools")
guiElements["toggles"]["disableconversion"] = contt:CreateToggle("Don't Convert Pollen", nil, function(State)
    kocmoc.toggles.disableconversion = State
end)
guiElements["toggles"]["autouseconvertors"] = contt:CreateToggle("Auto Bag Reduction", nil, function(Boole)
    kocmoc.toggles.autouseconvertors = Boole
end)
guiElements["vars"]["autouseMode"] = contt:CreateDropdown("Bag Reduction Mode", {
    "Ticket Converters", "Just Snowflakes", "Just Coconuts",
    "Snowflakes and Coconuts", "Tickets and Snowflakes", "Tickets and Coconuts",
    "All"
}, function(Select) kocmoc.vars.autouseMode = Select end)
guiElements["vars"]["autoconvertWaitTime"] = contt:CreateSlider("Reduction Confirmation Time", 3, 20, 10, false, function(state)
    kocmoc.vars.autoconvertWaitTime = tonumber(state)
end)

guiElements["toggles"]["autosprinkler"] = farmo:CreateToggle("Auto Sprinkler", nil, function(State) kocmoc.toggles.autosprinkler = State end)
guiElements["toggles"]["farmbubbles"] = farmo:CreateToggle("Farm Bubbles", nil, function(State) kocmoc.toggles.farmbubbles = State end)
guiElements["toggles"]["farmflame"] = farmo:CreateToggle("Farm Flames", nil, function(State) kocmoc.toggles.farmflame = State end)
guiElements["toggles"]["farmcoco"] = farmo:CreateToggle("Farm Coconuts & Shower", nil, function(State) kocmoc.toggles.farmcoco = State end)
guiElements["toggles"]["collectcrosshairs"] = farmo:CreateToggle("Farm Precise Crosshairs", nil, function(State) kocmoc.toggles.collectcrosshairs = State end)
guiElements["toggles"]["fastcrosshairs"] = farmo:CreateToggle("Smart Precise Crosshairs ["..Danger.."]", nil, function(State) kocmoc.toggles.fastcrosshairs = State end)
guiElements["toggles"]["farmfuzzy"] = farmo:CreateToggle("Farm Fuzzy Bombs", nil, function(State) kocmoc.toggles.farmfuzzy = State end)
guiElements["toggles"]["farmunderballoons"] = farmo:CreateToggle("Farm Under Balloons", nil, function(State) kocmoc.toggles.farmunderballoons = State end)
guiElements["toggles"]["farmclouds"] = farmo:CreateToggle("Farm Under Clouds", nil, function(State) kocmoc.toggles.farmclouds = State end)
farmo:CreateLabel("")
guiElements["toggles"]["honeymaskconv"] = farmo:CreateToggle("Auto Honey Mask", nil, function(bool) kocmoc.toggles.honeymaskconv = bool end)
guiElements["vars"]["defmask"] = farmo:CreateDropdown("Default Mask", MasksTable, function(val) kocmoc.vars.defmask = val end)
guiElements["vars"]["deftool"] = farmo:CreateDropdown("Default Tool", collectorstable, function(val) kocmoc.vars.deftool = val end)
guiElements["toggles"]["autoequipmask"] = farmo:CreateToggle("Equip Mask Based on Field", nil, function(bool) kocmoc.toggles.autoequipmask = bool end)
guiElements["toggles"]["followplayer"] = farmo:CreateToggle("Follow Player", nil, function(bool)
    kocmoc.toggles.followplayer = bool
end)
guiElements["vars"]["playertofollow"] = farmo:CreateTextBox("Player to Follow", "player name", false, function(Value)
    kocmoc.vars.playertofollow = Value
end)
-- farmo:CreateToggle("Farm Closest Leaves", nil, function(State) kocmoc.toggles.farmclosestleaf = State end)

local farmt = farmtab:CreateSection("Farming")
guiElements["toggles"]["autodispense"] = farmt:CreateToggle("Auto Dispenser [⚙]", nil, function(State) kocmoc.toggles.autodispense = State end)
guiElements["toggles"]["autoboosters"] = farmt:CreateToggle("Auto Field Boosters [⚙]", nil, function(State) kocmoc.toggles.autoboosters = State end)
guiElements["toggles"]["clock"] = farmt:CreateToggle("Auto Wealth Clock", nil, function(State) kocmoc.toggles.clock = State end)
-- BEESMAS MARKER farmt:CreateToggle("Auto Gingerbread Bears", nil, function(State) kocmoc.toggles.collectgingerbreads = State end)
-- BEESMAS MARKER farmt:CreateToggle("Auto Samovar", nil, function(State) kocmoc.toggles.autosamovar = State end)
-- BEESMAS MARKER farmt:CreateToggle("Auto Stockings", nil, function(State) kocmoc.toggles.autostockings = State end)
-- BEESMAS MARKER farmt:CreateToggle("Auto Honey Candles", nil, function(State) kocmoc.toggles.autocandles = State end)
-- BEESMAS MARKER farmt:CreateToggle("Auto Beesmas Feast", nil, function(State) kocmoc.toggles.autofeast = State end)
-- BEESMAS MARKER farmt:CreateToggle("Auto Onett's Lid Art", nil, function(State) kocmoc.toggles.autoonettart = State end)
guiElements["toggles"]["freeantpass"] = farmt:CreateToggle("Auto Free Antpasses", nil, function(State) kocmoc.toggles.freeantpass = State end)
guiElements["toggles"]["farmsprouts"] = farmt:CreateToggle("Farm Sprouts", nil, function(State) kocmoc.toggles.farmsprouts = State end)
guiElements["toggles"]["farmpuffshrooms"] = farmt:CreateToggle("Farm Puffshrooms", nil, function(State) kocmoc.toggles.farmpuffshrooms = State end)
-- BEESMAS MARKER farmt:CreateToggle("Farm Snowflakes ["..Danger.."]", nil, function(State) kocmoc.toggles.farmsnowflakes = State end)
guiElements["toggles"]["farmrares"] = farmt:CreateToggle("Teleport To Rares ["..Danger.."]", nil, function(State) kocmoc.toggles.farmrares = State end)
guiElements["toggles"]["autoquest"] = farmt:CreateToggle("Auto Accept/Confirm Quests [⚙]", nil, function(State) kocmoc.toggles.autoquest = State end)
guiElements["toggles"]["autodoquest"] = farmt:CreateToggle("Auto Do Quests [⚙]", nil, function(State) kocmoc.toggles.autodoquest = State end)
guiElements["toggles"]["honeystorm"] = farmt:CreateToggle("Auto Honeystorm", nil, function(State) kocmoc.toggles.honeystorm = State end)
farmt:CreateLabel(" ")
guiElements["toggles"]["resetbeenergy"] = farmt:CreateToggle("Reset Bee Energy after X Conversions", nil, function(bool)
    kocmoc.toggles.resetbeenergy = bool
end)
guiElements["vars"]["resettimer"] = farmt:CreateTextBox("Conversion Amount", "default = 3", true, function(Value)
    kocmoc.vars.resettimer = tonumber(Value)
end)

local plantersection = plantertab:CreateSection("Automatic Planters & Nectars")
guiElements["toggles"]["autoplanters"] = plantersection:CreateToggle("Auto Planters", nil, function(State) kocmoc.toggles.autoplanters = State end)
guiElements["toggles"]["blacklistinvigorating"] = plantersection:CreateToggle("Blacklist Invigorating", nil, function(State) kocmoc.toggles.blacklistinvigorating = State end)
guiElements["toggles"]["blacklistcomforting"] = plantersection:CreateToggle("Blacklist Comforting", nil, function(State) kocmoc.toggles.blacklistcomforting = State end)
guiElements["toggles"]["blacklistmotivating"] = plantersection:CreateToggle("Blacklist Motivating", nil, function(State) kocmoc.toggles.blacklistmotivating = State end)
guiElements["toggles"]["blacklistrefreshing"] = plantersection:CreateToggle("Blacklist Refreshing", nil, function(State) kocmoc.toggles.blacklistrefreshing = State end)
guiElements["toggles"]["blacklistsatisfying"] = plantersection:CreateToggle("Blacklist Satisfying", nil, function(State) kocmoc.toggles.blacklistsatisfying = State end)
guiElements["vars"]["planterharvestamount"] = plantersection:CreateSlider("Planter Harvest Percentage", 0, 100, 75, false, function(Value)
    kocmoc.vars.planterharvestamount = Value
end)
guiElements["toggles"]["plasticplanter"] = plantersection:CreateToggle("Blacklist Plastic Planter", nil, function(State) kocmoc.toggles.plasticplanter = State end)
guiElements["toggles"]["candyplanter"] = plantersection:CreateToggle("Blacklist Candy Planter", nil, function(State) kocmoc.toggles.candyplanter = State end)
guiElements["toggles"]["redclayplanter"] = plantersection:CreateToggle("Blacklist Red Clay Planter", nil, function(State) kocmoc.toggles.redclayplanter = State end)
guiElements["toggles"]["blueclayplanter"] = plantersection:CreateToggle("Blacklist Blue Clay Planter", nil, function(State) kocmoc.toggles.blueclayplanter = State end)
guiElements["toggles"]["tackyplanter"] = plantersection:CreateToggle("Blacklist Tacky Planter", nil, function(State) kocmoc.toggles.tackyplanter = State end)
guiElements["toggles"]["pesticideplanter"] = plantersection:CreateToggle("Blacklist Pesticide Planter", nil, function(State) kocmoc.toggles.pesticideplanter = State end)
guiElements["toggles"]["petalplanter"] = plantersection:CreateToggle("Blacklist Petal Planter", nil, function(State) kocmoc.toggles.petalplanter = State end)

local customplanterssection = plantertab:CreateSection("Custom Planters")
customplanterssection:CreateLabel("Turning this on will disable auto planters!")
customplanterssection:CreateLabel("["..Danger.."] You should know what you are")
customplanterssection:CreateLabel("doing before turning this on! ["..Danger.."]")
guiElements["toggles"]["docustomplanters"] = customplanterssection:CreateToggle("Custom Planters", nil, function(State) kocmoc.toggles.docustomplanters = State end)

local customplanter1section = plantertab:CreateSection("Custom Planter 1")
guiElements["vars"]["customplanterfield11"] = customplanter1section:CreateDropdown("Field 1", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield11 = Option
end)
guiElements["vars"]["customplanter11"] = customplanter1section:CreateDropdown("Field 1 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter11 = Option
end)
guiElements["vars"]["customplanterdelay11"] = customplanter1section:CreateSlider("Field 1 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay11 = Value
end)
guiElements["vars"]["customplanterfield12"] = customplanter1section:CreateDropdown("Field 2", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield12 = Option
end)
guiElements["vars"]["customplanter12"] = customplanter1section:CreateDropdown("Field 2 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter12 = Option
end)
guiElements["vars"]["customplanterdelay12"] = customplanter1section:CreateSlider("Field 2 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay12 = Value
end)
guiElements["vars"]["customplanterfield13"] = customplanter1section:CreateDropdown("Field 3", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield13 = Option
end)
guiElements["vars"]["customplanter13"] = customplanter1section:CreateDropdown("Field 3 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter13 = Option
end)
guiElements["vars"]["customplanterdelay13"] = customplanter1section:CreateSlider("Field 3 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay13 = Value
end)
guiElements["vars"]["customplanterfield14"] = customplanter1section:CreateDropdown("Field 4", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield14 = Option
end)
guiElements["vars"]["customplanter14"] = customplanter1section:CreateDropdown("Field 4 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter14 = Option
end)
guiElements["vars"]["customplanterdelay14"] = customplanter1section:CreateSlider("Field 4 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay14 = Value
end)
guiElements["vars"]["customplanterfield15"] = customplanter1section:CreateDropdown("Field 5", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield15 = Option
end)
guiElements["vars"]["customplanter15"] = customplanter1section:CreateDropdown("Field 5 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter15 = Option
end)
guiElements["vars"]["customplanterdelay15"] = customplanter1section:CreateSlider("Field 5 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay15 = Value
end)

local customplanter2section = plantertab:CreateSection("Custom Planter 2")
guiElements["vars"]["customplanterfield21"] = customplanter2section:CreateDropdown("Field 1", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield21 = Option
end)
guiElements["vars"]["customplanter21"] = customplanter2section:CreateDropdown("Field 1 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter21 = Option
end)
guiElements["vars"]["customplanterdelay21"] = customplanter2section:CreateSlider("Field 1 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay21 = Value
end)
guiElements["vars"]["customplanterfield22"] = customplanter2section:CreateDropdown("Field 2", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield22 = Option
end)
guiElements["vars"]["customplanter22"] = customplanter2section:CreateDropdown("Field 2 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter22 = Option
end)
guiElements["vars"]["customplanterdelay22"] = customplanter2section:CreateSlider("Field 2 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay22 = Value
end)
guiElements["vars"]["customplanterfield23"] = customplanter2section:CreateDropdown("Field 3", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield23 = Option
end)
guiElements["vars"]["customplanter23"] = customplanter2section:CreateDropdown("Field 3 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter23 = Option
end)
guiElements["vars"]["customplanterdelay23"] = customplanter2section:CreateSlider("Field 3 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay23 = Value
end)
guiElements["vars"]["customplanterfield24"] = customplanter2section:CreateDropdown("Field 4", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield24 = Option
end)
guiElements["vars"]["customplanter24"] = customplanter2section:CreateDropdown("Field 4 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter24 = Option
end)
guiElements["vars"]["customplanterdelay24"] = customplanter2section:CreateSlider("Field 4 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay24 = Value
end)
guiElements["vars"]["customplanterfield25"] = customplanter2section:CreateDropdown("Field 5", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield25 = Option
end)
guiElements["vars"]["customplanter25"] = customplanter2section:CreateDropdown("Field 5 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter25 = Option
end)
guiElements["vars"]["customplanterdelay25"] = customplanter2section:CreateSlider("Field 5 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay25 = Value
end)

local customplanter3section = plantertab:CreateSection("Custom Planter 3")
guiElements["vars"]["customplanterfield31"] = customplanter3section:CreateDropdown("Field 1 Field", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield31 = Option
end)
guiElements["vars"]["customplanter31"] = customplanter3section:CreateDropdown("Field 1 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter31 = Option
end)
guiElements["vars"]["customplanterdelay31"] = customplanter3section:CreateSlider("Field 1 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay31 = Value
end)
guiElements["vars"]["customplanterfield32"] = customplanter3section:CreateDropdown("Field 2 Field", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield32 = Option
end)
guiElements["vars"]["customplanter32"] = customplanter3section:CreateDropdown("Field 2 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter32 = Option
end)
guiElements["vars"]["customplanterdelay32"] = customplanter3section:CreateSlider("Field 2 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay32 = Value
end)
guiElements["vars"]["customplanterfield33"] = customplanter3section:CreateDropdown("Field 3 Field", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield33 = Option
end)
guiElements["vars"]["customplanter33"] = customplanter3section:CreateDropdown("Field 3 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter33 = Option
end)
guiElements["vars"]["customplanterdelay33"] = customplanter3section:CreateSlider("Field 3 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay33 = Value
end)
guiElements["vars"]["customplanterfield34"] = customplanter3section:CreateDropdown("Field 4 Field", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield34 = Option
end)
guiElements["vars"]["customplanter34"] = customplanter3section:CreateDropdown("Field 4 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter34 = Option
end)
guiElements["vars"]["customplanterdelay34"] = customplanter3section:CreateSlider("Field 4 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay34 = Value
end)
guiElements["vars"]["customplanterfield35"] = customplanter3section:CreateDropdown("Field 5 Field", DropdownFieldsTable, function(Option)
    kocmoc.vars.customplanterfield35 = Option
end)
guiElements["vars"]["customplanter35"] = customplanter3section:CreateDropdown("Field 5 Planter Type", DropdownPlanterTable, function(Option)
    kocmoc.vars.customplanter35 = Option
end)
guiElements["vars"]["customplanterdelay35"] = customplanter3section:CreateSlider("Field 5 Harvest %", 0, 100, 75, false, function(Value)
    kocmoc.vars.customplanterdelay35 = Value
end)

local mobkill = combtab:CreateSection("Combat")
mobkill:CreateToggle("Train Crab", nil, function(State)
    kocmoc.toggles.traincrab = State
    if State then
        api.humanoidrootpart().CFrame = CFrame.new(-307.52117919922, 107.91863250732, 467.86791992188)
    end
end)
mobkill:CreateToggle("Train Snail", nil, function(State)
    kocmoc.toggles.trainsnail = State
    local fd = game.Workspace.FlowerZones["Stump Field"]
    if State then
        api.humanoidrootpart().CFrame = CFrame.new(
            fd.Position.X,
            fd.Position.Y - 20,
            fd.Position.Z
        )
    else
        api.humanoidrootpart().CFrame = CFrame.new(
            fd.Position.X,
            fd.Position.Y + 2,
            fd.Position.Z
        )
    end
end)
guiElements["toggles"]["killmondo"] = mobkill:CreateToggle("Kill Mondo", nil, function(State) kocmoc.toggles.killmondo = State end)
guiElements["toggles"]["killvicious"] = mobkill:CreateToggle("Kill Vicious", nil, function(State) kocmoc.toggles.killvicious = State end)
guiElements["toggles"]["killwindy"] = mobkill:CreateToggle("Kill Windy", nil, function(State) kocmoc.toggles.killwindy = State end)
local autokillmobstoggle = mobkill:CreateToggle("Auto Kill Mobs", nil, function(State) kocmoc.toggles.autokillmobs = State end)
autokillmobstoggle:AddToolTip("Kills mobs after x pollen converting")
guiElements["toggles"]["autokillmobs"] = autokillmobstoggle
guiElements["toggles"]["avoidmobs"] = mobkill:CreateToggle("Avoid Mobs", nil, function(State) kocmoc.toggles.avoidmobs = State end)
local autoanttoggle = mobkill:CreateToggle("Auto Ant", nil, function(State) kocmoc.toggles.autoant = State end)
autoanttoggle:AddToolTip("You Need Spark Stuff 😋; Goes to Ant Challenge after pollen converting")
guiElements["toggles"]["autoant"] = autoanttoggle

local serverhopkill = combtab:CreateSection("Serverhopping Combat")
serverhopkill:CreateButton("Vicious Bee Serverhopper ["..Danger.."]["..ExploitSpecific.."]", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ericd71/skiP/main/viciousbeeserverhop.lua"))()
end):AddToolTip("Serverhops for rouge vicious bees")
serverhopkill:CreateLabel("")
serverhopkill:CreateLabel("["..Danger.."] These functions will unload the UI")
serverhopkill:CreateLabel("")

local amks = combtab:CreateSection("Auto Kill Mobs Settings")
guiElements["vars"]["monstertimer"] = amks:CreateTextBox("Reset Mob Timer Minutes", "default = 15", true, function(Value)
    if tonumber(Value) then
        kocmoc.vars.monstertimer = tonumber(Value)
    end
end)
amks:CreateButton("Kill Mobs", function()
    temptable.started.monsters = true
    killmobs()
    temptable.started.monsters = false
end)

local wayp = misctab:CreateSection("Waypoints")
wayp:CreateDropdown("Field Teleports", fieldstable, function(Option)
    api.humanoidrootpart().CFrame = game.Workspace.FlowerZones:FindFirstChild(Option).CFrame
end)
wayp:CreateDropdown("Monster Teleports", spawnerstable, function(Option)
    local d = monsterspawners:FindFirstChild(Option)
    api.humanoidrootpart().CFrame = CFrame.new(
        d.Position.X,
        d.Position.Y + 3,
        d.Position.Z
    )
end)
wayp:CreateDropdown("Toys Teleports", toystable, function(Option)
    d = game.Workspace.Toys:FindFirstChild(Option).Platform
    api.humanoidrootpart().CFrame = CFrame.new(
        d.Position.X,
        d.Position.Y + 3,
        d.Position.Z
    )
end)
wayp:CreateButton("Teleport to hive", function()
    api.humanoidrootpart().CFrame =
        player.SpawnPos.Value
end)

local useitems = itemstab:CreateSection("Use Items")

useitems:CreateButton("Use All Buffs ["..Danger.."]", function()
    for i, v in pairs(buffTable) do
        playeractivescommand:FireServer({["Name"] = i})
    end
end)
useitems:CreateLabel("")

for i, v in pairs(buffTable) do
    useitems:CreateButton("Use " .. i, function()
        playeractivescommand:FireServer({["Name"] = i})
    end)
    guiElements["vars"]["autouse"..i] = useitems:CreateToggle("Auto Use " .. i, nil, function(bool)
        buffTable[i].b = bool
        kocmoc.vars["autouse"..i] = bool
    end)
end

local miscc = misctab:CreateSection("Misc")
miscc:CreateButton("Ant Challenge Semi-Godmode", function()
    api.tween(1, CFrame.new(93.4228, 32.3983, 553.128))
    task.wait(1)
    game.ReplicatedStorage.Events.ToyEvent:FireServer("Ant Challenge")
    api.humanoidrootpart().Position = Vector3.new(93.4228, 42.3983, 553.128)
    task.wait(2)
    player.Character.Humanoid.Name = 1
    local l = player.Character["1"]:Clone()
    l.Parent = player.Character
    l.Name = "Humanoid"
    task.wait()
    player.Character["1"]:Destroy()
    api.tween(1, CFrame.new(93.4228, 32.3983, 553.128))
    task.wait(8)
    api.tween(1, CFrame.new(93.4228, 32.3983, 553.128))
end)
local wstoggle = miscc:CreateToggle("Walk Speed", nil, function(State)
    kocmoc.toggles.loopspeed = State
end)
wstoggle:CreateKeybind("K", function(Key) end)
guiElements["toggles"]["loopspeed"] = wstoggle
local jptoggle = miscc:CreateToggle("Jump Power", nil, function(State)
    kocmoc.toggles.loopjump = State
end)
jptoggle:CreateKeybind("L", function(Key) end)
guiElements["toggles"]["loopjump"] = jptoggle
guiElements["toggles"]["godmode"] = miscc:CreateToggle("Godmode", nil, function(State)
    kocmoc.toggles.godmode = State
    bssapi:Godmode(State)
end)
local misco = misctab:CreateSection("Other")
misco:CreateDropdown("Equip Accesories", accesoriestable, function(Option)
    local ohString1 = "Equip"
    local ohTable2 = {
        ["Mute"] = false,
        ["Type"] = Option,
        ["Category"] = "Accessory"
    }
    game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(ohString1, ohTable2)
end)
misco:CreateDropdown("Equip Masks", masktable, function(Option)
    maskequip(Option)
end)
misco:CreateDropdown("Equip Collectors", collectorstable, function(Option)
    equiptool(Option)
end)
misco:CreateDropdown("Generate Amulet", {
    "Supreme Star Amulet", "Diamond Star Amulet", "Gold Star Amulet",
    "Silver Star Amulet", "Bronze Star Amulet", "Moon Amulet"
}, function(Option)
    game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer(Option .. " Generator")
end)
misco:CreateButton("Export Stats Table ["..ExploitSpecific.."]", function()
    local StatCache = require(game.ReplicatedStorage.ClientStatCache)
    writefile("Stats_" .. api.nickname .. ".json", StatCache:Encode())
end)

if string.find(string.upper(identifyexecutor()), "SYN") or string.find(string.upper(identifyexecutor()), "SCRIP") then
    local visu = misctab:CreateSection("Visual")
    local alertText = "☢️ A nuke is incoming! ☢️"
    local alertDesign = "Purple"
    local function pushAlert()
        local alerts = require(game:GetService("ReplicatedStorage").AlertBoxes)
        local chat = function(...) alerts:Push(...) end
        chat(alertText, nil, alertDesign)
    end
    visu:CreateButton("Spawn Coconut ["..ExploitSpecific.."]", function()
        syn.secure_call(function()
            require(game.ReplicatedStorage.LocalFX.FallingCoconut)({
                Pos = player.Character.Humanoid.RootPart.CFrame.p,
                Dur = 0.6,
                Radius = 16,
                Delay = 1.5,
                Friendly = true
            })
        end, player.PlayerScripts.ClientInit)
    end)
    visu:CreateButton("Spawn Hostile Coconut ["..ExploitSpecific.."]", function()
        syn.secure_call(function()
            require(game.ReplicatedStorage.LocalFX.FallingCoconut)({
                Pos = player.Character.Humanoid.RootPart.CFrame.p,
                Dur = 0.6,
                Radius = 16,
                Delay = 1.5,
                Friendly = false
            })
        end, player.PlayerScripts.ClientInit)
    end)
    visu:CreateButton("Spawn Mythic Meteor ["..ExploitSpecific.."]", function()
        syn.secure_call(function()
            require(game.ReplicatedStorage.LocalFX.MythicMeteor)({
                Pos = player.Character.Humanoid.RootPart.CFrame.p,
                Dur = 0.6,
                Radius = 16,
                Delay = 1.5,
                Friendly = true
            })
        end, player.PlayerScripts.ClientInit)
    end)
    visu:CreateButton("Spawn Jelly Bean ["..ExploitSpecific.."]", function()
        local jellybeans = {
            "Navy", "Blue", "Spoiled", "Merigold", "Teal", "Periwinkle", "Pink",
            "Slate", "White", "Black", "Green", "Brown", "Yellow", "Maroon",
            "Red"
        }
        syn.secure_call(function()
            require(game.ReplicatedStorage.LocalFX.JellyBeanToss)({
                Start = player.Character.Humanoid.RootPart.CFrame.p,
                Type = jellybeans[math.random(1, #jellybeans)],
                End = (player.Character.Humanoid.RootPart.CFrame * CFrame.new(0, 0, -35)).p + Vector3.new(math.random(1, 20), 0, math.random(1, 20))
            })
        end, player.PlayerScripts.ClientInit)
    end)
    visu:CreateButton("Spawn Puffshroom Spores ["..ExploitSpecific.."]", function()
        task.spawn(function()
            syn.secure_call(function()
                local field = game.Workspace.FlowerZones:GetChildren()[math.random(1, #game.Workspace.FlowerZones:GetChildren())]
                local pos = field.CFrame.p
                require(game.ReplicatedStorage.LocalFX.PuffshroomSporeThrow)({
                    Start = api.humanoidrootpart().CFrame.p,
                    End = pos
                })
            end, player.PlayerScripts.ClientInit)
            task.wait(10)
            workspace.Particles:FindFirstChild("SporeCloud"):Destroy()
        end)
    end)
    visu:CreateButton("Spawn Party Popper ["..ExploitSpecific.."]", function()
        syn.secure_call(function()
            require(game:GetService("ReplicatedStorage").LocalFX.PartyPopper)({
                Pos = player.Character.Humanoid.RootPart.CFrame.p
            })
        end, player.PlayerScripts.ClientInit)
    end)
    visu:CreateButton("Spawn Flame ["..ExploitSpecific.."]", function()
        syn.secure_call(function()
            require(game.ReplicatedStorage.LocalFX.LocalFlames).AddFlame(
                player.Character.Humanoid.RootPart.CFrame.p,
                10,
                1,
                player.UserId,
                false
            )
        end, player.PlayerScripts.ClientInit)
    end)
    visu:CreateButton("Spawn Dark Flame ["..ExploitSpecific.."]", function()
        syn.secure_call(function()
            require(game.ReplicatedStorage.LocalFX.LocalFlames).AddFlame(
                player.Character.Humanoid.RootPart.CFrame.p,
                10,
                1,
                player.UserId,
                true
            )
        end, player.PlayerScripts.ClientInit)
    end)
    local booolholder = false
    visu:CreateToggle("Flame Walk ["..ExploitSpecific.."]", nil, function(boool)
        if boool == true then
            booolholder = true
            repeat
                task.wait(0.1)
                syn.secure_call(function()
                    require(game.ReplicatedStorage.LocalFX.LocalFlames).AddFlame(
                        player.Character.Humanoid.RootPart.CFrame.p,
                        10,
                        1,
                        player.UserId,
                        false
                    )
                end, player.PlayerScripts.ClientInit)
            until booolholder == false
        else
            booolholder = false
        end
    end)
    visu:CreateToggle("Dark Flame Walk ["..ExploitSpecific.."]", nil, function(boool)
        if boool == true then
            booolholder = true
            repeat
                task.wait(0.1)
                syn.secure_call(function()
                    require(game.ReplicatedStorage.LocalFX.LocalFlames).AddFlame(
                        player.Character.Humanoid.RootPart.CFrame.p,
                        10,
                        1,
                        player.UserId,
                        true
                    )
                end, player.PlayerScripts.ClientInit)
            until booolholder == false
        else
            booolholder = false
        end
    end)
    visu:CreateLabel("")
    local styles = {}
    local raw = {
        Blue = Color3.fromRGB(50, 131, 255),
        ChaChing = Color3.fromRGB(50, 131, 255),
        Green = Color3.fromRGB(27, 119, 43),
        Red = Color3.fromRGB(201, 39, 28),
        White = Color3.fromRGB(140, 140, 140),
        Yellow = Color3.fromRGB(218, 216, 31),
        Gold = Color3.fromRGB(254, 200, 9),
        Pink = Color3.fromRGB(242, 129, 255),
        Teal = Color3.fromRGB(33, 255, 171),
        Purple = Color3.fromRGB(125, 97, 232),
        TaDah = Color3.fromRGB(254, 200, 9),
        Festive = Color3.fromRGB(197, 0, 15),
        Festive2 = Color3.fromRGB(197, 0, 15),
        Badge = Color3.fromRGB(254, 200, 9),
        Robo = Color3.fromRGB(34, 255, 64),
        EggHunt = Color3.fromRGB(236, 227, 158),
        Vicious = Color3.fromRGB(0, 1, 5),
        Brown = Color3.fromRGB(82, 51, 43)
    }
    local alertDesign2 = "ChaChing"
    for i, v in pairs(raw) do table.insert(styles, i) end
    visu:CreateDropdown("Notification Style", styles,function(dd) alertDesign2 = dd end)
    visu:CreateTextBox("Text ["..ExploitSpecific.."]", "ex. Hello World", false, function(tx)
        alertText = tx
        alertDesign = alertDesign2
        syn.secure_call(pushAlert, player.PlayerScripts.AlertBoxes)
    end)

    visu:CreateLabel("")
    local destroym = true
    visu:CreateToggle("Destroy Map", true, function(State) destroym = State end)
    local nukeDuration = 10
    local nukePosition = Vector3.new(-26.202560424804688, 0.657240390777588, 172.31759643554688)
    local spoof = player.PlayerScripts.AlertBoxes
    function Nuke()
        require(game.ReplicatedStorage.LocalFX.MythicMeteor)({
            Pos = nukePosition,
            Dur = nukeDuration,
            Radius = 50,
            Delay = 1
        })
    end
    function DustCloud()
        require(game.ReplicatedStorage.LocalFX.OrbExplode)({
            Color = Color3.new(0.313726, 0.313726, 0.941176),
            Radius = 600,
            Dur = 15,
            Pos = nukePosition
        })
    end
    visu:CreateButton("Spawn Nuke ["..ExploitSpecific.."]", function()
        alertText = "☢️ A nuke is incoming! ☢️"
        syn.secure_call(pushAlert, spoof)
        alertText = "☢️ Get somewhere high! ☢️"
        task.wait(1.5)
        task.spawn(function()
            local Humanoid = player.Character.Humanoid
            for i = 1, 950 do
                local x = math.random(-100, 100) / 100
                local y = math.random(-100, 100) / 100
                local z = math.random(-100, 100) / 100
                Humanoid.CameraOffset = Vector3.new(x, y, z)
                task.wait(0.01)
            end
        end)
        syn.secure_call(pushAlert, spoof)
        task.wait(10)
        task.spawn(function()
            syn.secure_call(Nuke, player.PlayerScripts.ClientInit)
        end)
        task.wait(nukeDuration)
        task.spawn(function()
            syn.secure_call(DustCloud, player.PlayerScripts.ClientInit)
        end)
        task.wait(1)
        local Orb = game.Workspace.Particles:FindFirstChild("Orb")
        if Orb then Orb.CanCollide = true end
        if destroym == true then
            repeat
                task.wait(3)
                for i, v in pairs(Orb:GetTouchingParts()) do
                    if v.Anchored == true then
                        v.Anchored = false
                    end
                    v:BreakJoints()
                    v.Position = v.Position + Vector3.new(0, 0, 2)
                end
            until Orb == nil
        end
    end)
end

local webhooksection = misctab:CreateSection("External")
guiElements["toggles"]["shutdownkick"] = webhooksection:CreateToggle("Shutdown on Kick", nil, function(State)
    kocmoc.toggles.shutdownkick = State
end)
guiElements["toggles"]["webhookupdates"] = webhooksection:CreateToggle("Send Webhook Updates", nil, function(State)
    kocmoc.toggles.webhookupdates = State
end)
guiElements["vars"]["webhookurl"] = webhooksection:CreateTextBox("Webhook URL", "Discord webhook URL", false, function(Value)
    if Value and string.find(Value, "https://") then
        kocmoc.vars.webhookurl = Value
    else
        api.notify("Rosemoc " .. temptable.version, "Invalid URL!", 2)
    end
end)
guiElements["vars"]["webhooktimer"] = webhooksection:CreateSlider("Minutes Between Updates", 1, 60, 60, false, function(Value)
    kocmoc.vars.webhooktimer = Value
end)
guiElements["toggles"]["webhookping"] = webhooksection:CreateToggle("Ping on Honey Update", nil, function(State)
    kocmoc.toggles.webhookping = State
end)
guiElements["vars"]["discordid"] = webhooksection:CreateTextBox("Discord ID", "", false, function(Value)
    if tonumber(Value) then
        kocmoc.vars.discordid = Value
    else
        api.notify("Rosemoc " .. temptable.version, "Invalid ID!", 2)
    end
end)

local autofeed = itemstab:CreateSection("Auto Feed")

local function feedAllBees(treat, amt)
    for L = 1, 5 do
        for U = 1, 10 do
            game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(L, U, treat, amt)
        end
    end
end

guiElements["vars"]["selectedTreat"] = autofeed:CreateDropdown("Select Treat", treatsTable, function(option)
    kocmoc.vars.selectedTreat = option
end)
guiElements["vars"]["selectedTreatAmount"] = autofeed:CreateTextBox("Treat Amount", "10", false, function(Value)
    kocmoc.vars.selectedTreatAmount = tonumber(Value)
end)
autofeed:CreateButton("Feed All Bees", function()
    feedAllBees(kocmoc.vars.selectedTreat, kocmoc.vars.selectedTreatAmount)
end)

local windShrine = itemstab:CreateSection("Wind Shrine")
guiElements["vars"]["donoItem"] = windShrine:CreateDropdown("Select Item", donatableItemsTable, function(Option)
    kocmoc.vars.donoItem = Option
end)
guiElements["vars"]["donoAmount"] = windShrine:CreateTextBox("Item Quantity", "10", false, function(Value)
    kocmoc.vars.donoAmount = tonumber(Value)
end)
windShrine:CreateButton("Donate", function()
    donateToShrine(kocmoc.vars.donoItem, kocmoc.vars.donoAmount)
    print(kocmoc.vars.donoAmount)
end)
guiElements["toggles"]["autodonate"] = windShrine:CreateToggle("Auto Donate", nil, function(selection)
    kocmoc.toggles.autodonate = selection
end)

local farmsettings = setttab:CreateSection("Autofarm Settings")
guiElements["vars"]["farmspeed"] = farmsettings:CreateTextBox("Autofarming Walkspeed", "Default Value = 60", true, function(Value)
    kocmoc.vars.farmspeed = Value
end)
guiElements["toggles"]["loopfarmspeed"] = farmsettings:CreateToggle("^ Loop Speed On Autofarming", nil, function(State)
    kocmoc.toggles.loopfarmspeed = State
end)
guiElements["toggles"]["farmflower"] = farmsettings:CreateToggle("Don't Walk In Field", nil, function(State)
    kocmoc.toggles.farmflower = State
end)
guiElements["toggles"]["convertballoons"] = farmsettings:CreateToggle("Convert Hive Balloon", nil, function(State)
    kocmoc.toggles.convertballoons = State
end)
local balloonPercentSlider = farmsettings:CreateSlider("Balloon Blessing % To Convert At", 0, 100, 50, false, function(Value)
    kocmoc.vars.convertballoonpercent = Value
end)
balloonPercentSlider:AddToolTip("0% = Always convert balloon when converting bag")
guiElements["vars"]["convertballoonpercent"] = balloonPercentSlider
guiElements["toggles"]["donotfarmtokens"] = farmsettings:CreateToggle("Don't Farm Tokens", nil, function(State)
    kocmoc.toggles.donotfarmtokens = State
end)
guiElements["toggles"]["enabletokenblacklisting"] = farmsettings:CreateToggle("Enable Token Blacklisting", nil, function(State)
    kocmoc.toggles.enabletokenblacklisting = State
end)
guiElements["vars"]["walkspeed"] = farmsettings:CreateSlider("Walk Speed", 0, 120, 70, false, function(Value)
    kocmoc.vars.walkspeed = Value
end)
guiElements["vars"]["jumppower"] = farmsettings:CreateSlider("Jump Power", 0, 120, 70, false, function(Value)
    kocmoc.vars.jumppower = Value
end)
guiElements["toggles"]["autox4"] = farmsettings:CreateToggle("Auto x4 Field Boost", nil, function(State)
    kocmoc.toggles.autox4 = State
end)
guiElements["toggles"]["newtokencollection"] = farmsettings:CreateToggle("New Token Collection", nil, function(State)
    kocmoc.toggles.newtokencollection = State
end)
local raresettings = setttab:CreateSection("Tokens Settings")
raresettings:CreateTextBox("Asset ID", "rbxassetid", false, function(Value)
    rarename = Value
end)
raresettings:CreateButton("Add Token To Rares List", function()
    table.insert(kocmoc.rares, rarename)
    game:GetService("CoreGui"):FindFirstChild(_G.windowname).Main:FindFirstChild("Rares List Dropdown", true):Destroy()
    raresettings:CreateDropdown("Rares List", kocmoc.rares, function(Option) end)
end)
raresettings:CreateButton("Remove Token From Rares List", function()
    table.remove(kocmoc.rares, api.tablefind(kocmoc.rares, rarename))
    game:GetService("CoreGui"):FindFirstChild(_G.windowname).Main:FindFirstChild(
        "Rares List Dropdown", true):Destroy()
    raresettings:CreateDropdown("Rares List", kocmoc.rares, function(Option) end)
end)
raresettings:CreateButton("Add Token To Blacklist", function()
    table.insert(kocmoc.bltokens, rarename)
    game:GetService("CoreGui"):FindFirstChild(_G.windowname).Main:FindFirstChild(
        "Tokens Blacklist Dropdown", true):Destroy()
    raresettings:CreateDropdown("Tokens Blacklist", kocmoc.bltokens,
                                function(Option) end)
end)
raresettings:CreateButton("Remove Token From Blacklist", function()
    table.remove(kocmoc.bltokens, api.tablefind(kocmoc.bltokens, rarename))
    game:GetService("CoreGui"):FindFirstChild(_G.windowname).Main:FindFirstChild(
        "Tokens Blacklist Dropdown", true):Destroy()
    raresettings:CreateDropdown("Tokens Blacklist", kocmoc.bltokens,
                                function(Option) end)
end)
raresettings:CreateDropdown("Tokens Blacklist", kocmoc.bltokens,
                            function(Option) end)
raresettings:CreateDropdown("Rares List", kocmoc.rares, function(Option) end)
raresettings:CreateButton("Copy Token List Link", function()
    api.notify("Rosemoc " .. temptable.version, "Copied link to clipboard!", 2)
    setclipboard("https://pastebin.com/raw/wtHBD3ij")
end)
local dispsettings = setttab:CreateSection("Auto Dispenser & Auto Boosters Settings")
guiElements["dispensesettings"]["rj"] = dispsettings:CreateToggle("Royal Jelly Dispenser", nil, function(State)
    kocmoc.dispensesettings.rj = not kocmoc.dispensesettings.rj
end)
guiElements["dispensesettings"]["blub"] = dispsettings:CreateToggle("Blueberry Dispenser", nil, function(State)
    kocmoc.dispensesettings.blub = not kocmoc.dispensesettings.blub
end)
guiElements["dispensesettings"]["straw"] = dispsettings:CreateToggle("Strawberry Dispenser", nil, function(State)
    kocmoc.dispensesettings.straw = not kocmoc.dispensesettings.straw
end)
guiElements["dispensesettings"]["treat"] = dispsettings:CreateToggle("Treat Dispenser", nil, function(State)
    kocmoc.dispensesettings.treat = not kocmoc.dispensesettings.treat
end)
guiElements["dispensesettings"]["coconut"] = dispsettings:CreateToggle("Coconut Dispenser", nil, function(State)
    kocmoc.dispensesettings.coconut = not kocmoc.dispensesettings.coconut
end)
guiElements["dispensesettings"]["glue"] = dispsettings:CreateToggle("Glue Dispenser", nil, function(State)
    kocmoc.dispensesettings.glue = not kocmoc.dispensesettings.glue
end)
guiElements["dispensesettings"]["white"] = dispsettings:CreateToggle("Mountain Top Booster", nil, function(State)
    kocmoc.dispensesettings.white = not kocmoc.dispensesettings.white
end)
guiElements["dispensesettings"]["blue"] = dispsettings:CreateToggle("Blue Field Booster", nil, function(State)
    kocmoc.dispensesettings.blue = not kocmoc.dispensesettings.blue
end)
guiElements["dispensesettings"]["red"] = dispsettings:CreateToggle("Red Field Booster", nil, function(State)
    kocmoc.dispensesettings.red = not kocmoc.dispensesettings.red
end)
local guisettings = setttab:CreateSection("GUI Settings")
local uitoggle = guisettings:CreateToggle("UI Toggle", nil, function(State)
    Window:Toggle(State)
end)
uitoggle:CreateKeybind(tostring(Config.Keybind):gsub("Enum.KeyCode.", ""),
                       function(Key) Config.Keybind = Enum.KeyCode[Key] end)
uitoggle:SetState(true)
local UIColorPicker = guisettings:CreateColorpicker("UI Color", function(Color) Window:ChangeColor(Color) end)
repeat 
    task.wait()
until UIColorPicker:GetObject() and UIColorPicker:GetObject():FindFirstChild("Color")
UIColorPicker:GetObject().Color.BackgroundColor3 = Config.Color
local themes = guisettings:CreateDropdown("Image", {
    "Default", "Hearts", "Abstract", "Hexagon", "Circles", "Lace With Flowers", "Floral"
}, function(Name)
    if Name == "Default" then
        Window:SetBackground("2151741365")
    elseif Name == "Hearts" then
        Window:SetBackground("6073763717")
    elseif Name == "Abstract" then
        Window:SetBackground("6073743871")
    elseif Name == "Hexagon" then
        Window:SetBackground("6073628839")
    elseif Name == "Circles" then
        Window:SetBackground("6071579801")
    elseif Name == "Lace With Flowers" then
        Window:SetBackground("6071575925")
    elseif Name == "Floral" then
        Window:SetBackground("5553946656")
    end
end)
themes:SetOption("Default")
local kocmocs = setttab:CreateSection("Configs")
kocmocs:CreateTextBox("Config Name", "ex: stumpconfig", false, function(Value) temptable.configname = Value end)
kocmocs:CreateButton("Load Config", function()
    if not isfile("kocmoc/BSS_" .. temptable.configname .. ".json") then
        api.notify("Rosemoc " .. temptable.version, "No such config file!", 2)
    else
        kocmoc = game:service("HttpService"):JSONDecode(readfile("kocmoc/BSS_" .. temptable.configname .. ".json"))
        for i,v in pairs(guiElements) do
            for j,k in pairs(v) do
                local obj = k:GetObject()
                local lastCharacters = obj.Name:reverse():sub(0, obj.Name:reverse():find(" ")):reverse()
                if kocmoc[i][j] then
                    if lastCharacters == " Dropdown" then
                        obj.Container.Value.Text = kocmoc[i][j]
                    elseif lastCharacters == " Slider" then
                        task.spawn(function()
                            local Tween = game:GetService("TweenService"):Create(
                                obj.Slider.Bar,
                                TweenInfo.new(1),
                                {Size = UDim2.new((tonumber(kocmoc[i][j]) - k:GetMin()) / (k:GetMax() - k:GetMin()), 0, 1, 0)}
                            )
                            Tween:Play()
                            local startStamp = tick()
                            local startValue = tonumber(obj.Value.PlaceholderText)
                            while tick() - startStamp < 1 do
                                task.wait()
                                local partial = tick() - startStamp
                                local value = (startValue + ((tonumber(kocmoc[i][j]) - startValue) * partial))
                                obj.Value.PlaceholderText = math.round(value * 100) / 100
                            end
                            obj.Value.PlaceholderText = tonumber(kocmoc[i][j])
                        end)
                    elseif lastCharacters == " Toggle" then
                        obj.Toggle.BackgroundColor3 = kocmoc[i][j] and Config.Color or Color3.fromRGB(50,50,50)
                    elseif lastCharacters == " TextBox" then
                        obj.Background.Input.Text = kocmoc[i][j]
                    end
                end
            end
        end
    end
end)
kocmocs:CreateButton("Save Config", function()
    writefile("kocmoc/BSS_" .. temptable.configname .. ".json", game:service("HttpService"):JSONEncode(kocmoc))
end)
kocmocs:CreateButton("Reset Config", function() kocmoc = defaultkocmoc end)
local fieldsettings = setttab:CreateSection("Fields Settings")
guiElements["bestfields"]["white"] = fieldsettings:CreateDropdown("Best White Field", temptable.whitefields, function(Option)
    kocmoc.bestfields.white = Option
end)
guiElements["bestfields"]["red"] = fieldsettings:CreateDropdown("Best Red Field", temptable.redfields, function(Option)
    kocmoc.bestfields.red = Option
end)
guiElements["bestfields"]["blue"] = fieldsettings:CreateDropdown("Best Blue Field", temptable.bluefields, function(Option)
    kocmoc.bestfields.blue = Option
end)
fieldsettings:CreateDropdown("Field", fieldstable, function(Option) temptable.blackfield = Option end)
fieldsettings:CreateButton("Add Field To Blacklist", function()
    table.insert(kocmoc.blacklistedfields, temptable.blackfield)
    game:GetService("CoreGui"):FindFirstChild(_G.windowname).Main:FindFirstChild("Blacklisted Fields Dropdown", true):Destroy()
    fieldsettings:CreateDropdown("Blacklisted Fields", kocmoc.blacklistedfields, function(Option) end)
end)
fieldsettings:CreateButton("Remove Field From Blacklist", function()
    table.remove(kocmoc.blacklistedfields, api.tablefind(kocmoc.blacklistedfields, temptable.blackfield))
    game:GetService("CoreGui"):FindFirstChild(_G.windowname).Main:FindFirstChild("Blacklisted Fields Dropdown", true):Destroy()
    fieldsettings:CreateDropdown("Blacklisted Fields", kocmoc.blacklistedfields, function(Option) end)
end)
fieldsettings:CreateDropdown("Blacklisted Fields", kocmoc.blacklistedfields, function(Option) end)
local aqs = setttab:CreateSection("Auto Quest Settings")

guiElements["toggles"]["allquests"] = aqs:CreateToggle("Non-Repeatable Quests", nil, function(State) kocmoc.toggles.allquests = State end)
guiElements["toggles"]["buckobeequests"] = aqs:CreateToggle("Bucko Bee Quests", nil, function(State) kocmoc.toggles.buckobeequests = State end)
guiElements["toggles"]["rileybeequests"] = aqs:CreateToggle("Riley Bee Quests", nil, function(State) kocmoc.toggles.rileybeequests = State end)
guiElements["toggles"]["blackbearquests"] = aqs:CreateToggle("Black Bear Quests", nil, function(State) kocmoc.toggles.blackbearquests = State end)
guiElements["toggles"]["brownbearquests"] = aqs:CreateToggle("Brown Bear Quests", nil, function(State) kocmoc.toggles.brownbearquests = State end)
guiElements["toggles"]["polarbearquests"] = aqs:CreateToggle("Polar Bear Quests", nil, function(State) kocmoc.toggles.polarbearquests = State end)

guiElements["vars"]["questcolorprefer"] = aqs:CreateDropdown("Only Farm Ants From NPC", {
    "Any NPC", "Bucko Bee", "Riley Bee"
}, function(Option) 
    kocmoc.vars.questcolorprefer = Option
end)
guiElements["toggles"]["tptonpc"] = aqs:CreateToggle("Teleport To NPC", nil, function(State) kocmoc.toggles.tptonpc = State end)
guiElements["toggles"]["autoquesthoneybee"] = aqs:CreateToggle("Include Honey Bee Quests", nil, function(State) kocmoc.toggles.autoquesthoneybee = State end)
guiElements["toggles"]["buyantpass"] = aqs:CreateToggle("Buy Ant Pass When Needed", nil, function(State) kocmoc.toggles.buyantpass = State end)
guiElements["toggles"]["smartmobkill"] = aqs:CreateToggle("Modify Mob Kill To Match Quests", nil, function(State) kocmoc.toggles.smartmobkill = State end)
guiElements["toggles"]["usegumdropsforquest"] = aqs:CreateToggle("Use Gumdrops For Goo Quests", nil, function(State) kocmoc.toggles.usegumdropsforquest = State end)


local pts = setttab:CreateSection("Autofarm Priority Tokens")
pts:CreateTextBox("Asset ID", "rbxassetid", false, function(Value) rarename = Value end)
pts:CreateButton("Add Token To Priority List", function()
    table.insert(kocmoc.priority, rarename)
    game:GetService("CoreGui"):FindFirstChild(_G.windowname).Main:FindFirstChild("Priority List Dropdown", true):Destroy()
    pts:CreateDropdown("Priority List", kocmoc.priority, function(Option) end)
end)
pts:CreateButton("Remove Token From Priority List", function()
    table.remove(kocmoc.priority, api.tablefind(kocmoc.priority, rarename))
    game:GetService("CoreGui"):FindFirstChild(_G.windowname).Main:FindFirstChild("Priority List Dropdown", true):Destroy()
    pts:CreateDropdown("Priority List", kocmoc.priority, function(Option) end)
end)
pts:CreateDropdown("Priority List", kocmoc.priority, function(Option) end)

local buysection = premiumtab:CreateSection("Buy")
buysection:CreateLabel("Support the developer of Kocmoc v3!")
buysection:CreateButton("Copy Shirt Link", function()
    api.notify("Rosemoc " .. temptable.version, "Copied link to clipboard!", 2)
    setclipboard("https://www.roblox.com/catalog/8958348861/Kocmoc-Honey-Bee-Design")
end)
buysection:CreateLabel("Without them this project")
buysection:CreateLabel("wouldn't be possible")

local miscsection = premiumtab:CreateSection("Misc")
miscsection:CreateLabel("Kocmoc Premium includes:")
miscsection:CreateLabel("Glider Speed Modifier [" .. getgenv().Star .. "]")
miscsection:CreateLabel("Glider Float Exploit [" .. getgenv().Star .. "]")

local autofarmingsection = premiumtab:CreateSection("Auto Farming")
autofarmingsection:CreateLabel("Kocmoc Premium includes:")
autofarmingsection:CreateLabel("Windy Bee Server Hopper [" .. getgenv().Star .. "]")
autofarmingsection:CreateLabel("Smart Bubble Bloat [" .. getgenv().Star .. "]")

local autojellysection = premiumtab:CreateSection("Auto Jelly")
autojellysection:CreateLabel("Kocmoc Premium includes:")
autojellysection:CreateLabel("Auto Jelly [" .. getgenv().Star .. "]")
autojellysection:CreateLabel("Incredibly intricate yet simple to use")
autojellysection:CreateLabel("to get you the perfect hive!")

local autonectarsection = premiumtab:CreateSection("Auto Nectar")
autonectarsection:CreateLabel("Kocmoc Premium includes:")
autonectarsection:CreateLabel("Auto Nectar [" .. getgenv().Star .. "]")

local webhooksection = premiumtab:CreateSection("Webhook")
webhooksection:CreateLabel("Kocmoc Premium includes:")
webhooksection:CreateLabel("Enable Webhook [" .. getgenv().Star .. "]")
webhooksection:CreateLabel("The perfect way to track your exact")
webhooksection:CreateLabel("progress even from your mobile device!")

loadingUI:UpdateText("Loaded UI")
local loadingLoops = loadingInfo:CreateLabel("Loading Loops..")
-- script

local honeytoggleouyfyt = false
task.spawn(function()
    while task.wait(1) do
        if kocmoc.toggles.honeymaskconv then
            if temptable.converting then
                if not honeytoggleouyfyt then
                    honeytoggleouyfyt = true
                    maskequip("Honey Mask")
                end
            else
                if honeytoggleouyfyt then
                    honeytoggleouyfyt = false
                    maskequip(kocmoc.vars.defmask)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        local buffs = fetchBuffTable(buffTable)
        for i, v in pairs(buffTable) do
            buffTable[i].b = kocmoc.vars["autouse"..i]
            if v["b"] then
                local inuse = false
                for k, p in pairs(buffs) do
                    if k == i then inuse = true end
                end
                if not inuse then
                    playeractivescommand:FireServer({["Name"] = i})
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if kocmoc.toggles.autofarm then
            if kocmoc.toggles.farmbubbles then 
                dobubbles()
            end
            if kocmoc.toggles.collectcrosshairs then 
                docrosshairs()
            end
            if kocmoc.toggles.farmfuzzy then
                getfuzzy()
            end
        end
    end
end)

game.Workspace.Particles.ChildAdded:Connect(function(v)
    if (v:IsA("Part") or v:IsA("MeshPart")) and not temptable.started.ant and not temptable.started.vicious and kocmoc.toggles.autofarm and not temptable.converting and not temptable.planting then
        if v.Name == "WarningDisk" and kocmoc.toggles.farmcoco then
            task.wait(0.5)
            if v.BrickColor == BrickColor.new("Lime green") then
                task.wait(1.25)
                if (v.Position - api.humanoidrootpart().Position).magnitude > 100 then return end
                if temptable.lookat then
                    api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
                    api.humanoidrootpart().CFrame = CFrame.new(v.CFrame.p, temptable.lookat)
                    task.wait()
                    api.humanoidrootpart().CFrame = CFrame.new(v.CFrame.p, temptable.lookat)
                else
                    api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
                    api.humanoidrootpart().CFrame = CFrame.new(v.CFrame.p)
                    task.wait()
                    api.humanoidrootpart().CFrame = CFrame.new(v.CFrame.p)
                end
            end
        elseif v.Name == "Crosshair" and kocmoc.toggles.collectcrosshairs then
            local timestamp = Instance.new("NumberValue", v)
            timestamp.Name = "timestamp"
            timestamp.Value = tick()
        elseif string.find(v.Name, "Bubble") and getBuffTime("5101328809") > 0.2 and kocmoc.toggles.farmbubbles then
            if not kocmoc.toggles.farmpuffshrooms or (kocmoc.toggles.farmpuffshrooms and not game.Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model")) then
                if (v.Position - api.humanoidrootpart().Position).magnitude > 100 then return end
                table.insert(temptable.bubbles, v)
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        temptable.magnitude = 50
        if player.Character:FindFirstChild("ProgressLabel", true) then
            local pollenprglbl = player.Character:FindFirstChild("ProgressLabel", true)
            local maxpollen = tonumber(pollenprglbl.Text:match("%d+$"))
            local pollencount = player.CoreStats.Pollen.Value
            temptable.pollenpercentage = pollencount / maxpollen * 100
            fieldselected = game.Workspace.FlowerZones[kocmoc.vars.field]

            if kocmoc.toggles.autouseconvertors then
                if tonumber(temptable.pollenpercentage) >= (kocmoc.vars.convertat - (kocmoc.vars.autoconvertWaitTime)) then
                    if not temptable.consideringautoconverting then
                        temptable.consideringautoconverting = true
                        task.spawn(function()
                            task.wait(kocmoc.vars.autoconvertWaitTime)
                            if tonumber(temptable.pollenpercentage) >= (kocmoc.vars.convertat - (kocmoc.vars.autoconvertWaitTime)) then
                                useConvertors()
                            end
                            temptable.consideringautoconverting = false
                        end)
                    end
                end
            end

            if kocmoc.toggles.autofarm then
                temptable.usegumdropsforquest = false
                if kocmoc.toggles.autodoquest and player.PlayerGui.ScreenGui.Menus.Children.Quests.Content:FindFirstChild("Frame") then
                    for i, v in next, player.PlayerGui.ScreenGui.Menus.Children.Quests:GetDescendants() do
                        if v.Name == "Description" and v.Parent and v.Parent.Parent then
                            local text = v.Text
                            local questName = v.Parent.Parent.TitleBar.Text
                            local pollentypes = {
                                "White Pollen", "Red Pollen", "Blue Pollen", "Blue Flowers", "Red Flowers", "White Flowers"
                            }
                            if (kocmoc.toggles.buckobeequests and questName:find("Bucko Bee")) or (kocmoc.toggles.rileybeequests and questName:find("Riley Bee")) or (kocmoc.toggles.polarbearquests and questName:find("Polar Bear")) or (kocmoc.toggles.brownbearquests and questName:find("Brown Bear")) or (kocmoc.toggles.blackbearquests and questName:find("Black Bear")) or (kocmoc.toggles.allquests and not questName:find("Bear:") and not questName:find("Bee:")) then
                                if not string.find(v.Text, "Puffshroom") then
                                    if text:find(" Goo ") then
                                        temptable.usegumdropsforquest = true
                                    end
                                    if api.returnvalue(fieldstable, text) and not string.find(v.Text, "Complete!") and not api.findvalue(kocmoc.blacklistedfields, api.returnvalue(fieldstable, text)) then
                                        d = api.returnvalue(fieldstable, text)
                                        fieldselected = game.Workspace.FlowerZones[d]
                                        break
                                    elseif api.returnvalue(pollentypes, text) and not string.find(v.Text, "Complete!") then
                                        d = api.returnvalue(pollentypes, text)
                                        if d == "Blue Flowers" or d == "Blue Pollen" then
                                            fieldselected = game.Workspace.FlowerZones[kocmoc.bestfields.blue]
                                            break
                                        elseif d == "White Flowers" or d == "White Pollen" then
                                            fieldselected = game.Workspace.FlowerZones[kocmoc.bestfields.white]
                                            break
                                        elseif d == "Red Flowers" or d == "Red Pollen" then
                                            fieldselected = game.Workspace.FlowerZones[kocmoc.bestfields.red]
                                            break
                                        end
                                    elseif questName:find("Bee") and string.find(text, "Feed") and not string.find(text, "Complete!") and not v:FindFirstChild("done") then
                                        local amount, kind = unpack((text:sub(6, text:find("to")-2)):split(" "))
                                        if amount and kind then
                                            if kind == "Blueberries" then
                                                game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(5, 3, "Blueberry", amount, false)
                                            elseif kind == "Strawberries" then
                                                game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(5, 3, "Strawberry", amount, false)
                                            end                                            
                                            local done = Instance.new("BoolValue", v)
                                            done.Name = "done"
                                            break
                                        end
                                    elseif string.find(text, "Ants.") and not string.find(text, "Complete!") then
                                        if rtsg().Eggs.AntPass == 0 and kocmoc.toggles.buyantpass then
                                            game.ReplicatedStorage.Events.ToyEvent:FireServer("Ant Pass Dispenser")
                                            task.wait(0.5)
                                        end
                                        if not game.Workspace.Toys["Ant Challenge"].Busy.Value and rtsg().Eggs.AntPass > 0 then
                                            if kocmoc.vars.questcolorprefer == "Any NPC" then
                                                farmant()
                                            else
                                                if questName:find(kocmoc.vars.questcolorprefer) then
                                                    farmant()
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if i == #player.PlayerGui.ScreenGui.Menus.Children.Quests:GetDescendants() then
                            if kocmoc.toggles.followplayer then
                                local playerToFollow = game.Players:FindFirstChild(kocmoc.vars.playertofollow)
                                if playerToFollow and playerToFollow.Character and playerToFollow.Character:FindFirstChild("HumanoidRootPart") then
                                    fieldselected = findField(playerToFollow.Character.HumanoidRootPart.CFrame.p)
                                    if not fieldselected or tostring(fieldselected) == "Ant Field" then
                                        fieldselected = game.Workspace.FlowerZones[kocmoc.vars.field]
                                    end
                                end
                            else
                                fieldselected = game.Workspace.FlowerZones[kocmoc.vars.field]
                            end
                        end
                    end
                else
                    if kocmoc.toggles.followplayer then
                        local playerToFollow = game.Players:FindFirstChild(kocmoc.vars.playertofollow)
                        if playerToFollow and playerToFollow.Character and playerToFollow.Character:FindFirstChild("HumanoidRootPart") then
                            fieldselected = findField(playerToFollow.Character.HumanoidRootPart.CFrame.p)
                            if not fieldselected then
                                fieldselected = game.Workspace.FlowerZones[kocmoc.vars.field]
                            end
                        end
                    else
                        fieldselected = game.Workspace.FlowerZones[kocmoc.vars.field]
                    end
                end
                local colorGroup = fieldselected:FindFirstChild("ColorGroup")
                if kocmoc.toggles.autoequipmask then 
                    if colorGroup then
                        if colorGroup.Value == "Red" then
                            maskequip("Demon Mask")
                        elseif colorGroup and colorGroup.Value == "Blue" then
                            maskequip("Diamond Mask")
                        else
                            maskequip("Gummy Mask")
                        end
                    end
                end

                local onlyonesprinkler = false

                fieldpos = CFrame.new(
                    fieldselected.Position.X,
                    fieldselected.Position.Y + 3,
                    fieldselected.Position.Z
                )
                fieldposition = fieldselected.Position
                if temptable.sprouts.detected and temptable.sprouts.coords and kocmoc.toggles.farmsprouts then
                    onlyonesprinkler = true
                    fieldposition = temptable.sprouts.coords.Position
                    fieldpos = temptable.sprouts.coords
                end
                if kocmoc.toggles.farmpuffshrooms and game.Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model") then
                    local mythics = {}
                    local legendaries = {}
                    local epics = {}
                    local rares = {}
                    local commons = {}

                    local function isPuffInField(stem)
                        if stem and player.Character:FindFirstChild("HumanoidRootPart") then
                            return findField(stem.CFrame.p) == findField(api.humanoidrootpart().CFrame.p)
                        end
                        return false
                    end

                    for _,puffshroom in pairs(game.Workspace.Happenings.Puffshrooms:GetChildren()) do
                        local stem = puffshroom:FindFirstChild("Puffball Stem")
                        if stem then
                            if string.find(puffshroom.Name, "Mythic") then
                                table.insert(mythics, {stem, isPuffInField(stem)})
                            elseif string.find(puffshroom.Name, "Legendary") then
                                table.insert(legendaries, {stem, isPuffInField(stem)})
                            elseif string.find(puffshroom.Name, "Epic") then
                                table.insert(epics, {stem, isPuffInField(stem)})
                            elseif string.find(puffshroom.Name, "Rare") then
                                table.insert(rares, {stem, isPuffInField(stem)})
                            else
                                table.insert(commons, {stem, isPuffInField(stem)})
                            end
                        end
                    end

                    if #mythics ~= 0 then
                        for _,v in pairs(mythics) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                        end
                        for _,v in pairs(mythics) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                            end
                        end
                    elseif #legendaries ~= 0 then
                        for _,v in pairs(legendaries) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                        end
                        for _,v in pairs(legendaries) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                            end
                        end
                    elseif #epics ~= 0 then
                        for _,v in pairs(epics) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                        end
                        for _,v in pairs(epics) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                            end
                        end
                    elseif #rares ~= 0 then
                        for _,v in pairs(rares) do
                            local stem, infield = unpack(v)
                            fieldpos = stem.CFrame
                        end
                        for _,v in pairs(rares) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                            end
                        end
                    elseif #commons ~= 0 then
                        fieldpos = api.getbiggestmodel(game.Workspace.Happenings.Puffshrooms):FindFirstChild("Puffball Stem").CFrame
                        for _,v in pairs(commons) do
                            local stem, infield = unpack(v)
                            if infield then
                                fieldpos = stem.CFrame
                            end
                        end
                    end

                    fieldposition = fieldpos.Position
                    temptable.magnitude = 35
                    onlyonesprinkler = true

                    fieldselected = findField(fieldposition)
                    if fieldselected then
                        local colorGroup = fieldselected:FindFirstChild("ColorGroup")
                        if kocmoc.toggles.autoequipmask then 
                            if colorGroup then
                                if colorGroup.Value == "Red" then
                                    maskequip("Demon Mask")
                                elseif colorGroup and colorGroup.Value == "Blue" then
                                    maskequip("Diamond Mask")
                                else
                                    maskequip("Gummy Mask")
                                end
                            end
                        end
                    end
                end
                
                if kocmoc.toggles.convertballoons and not temptable.planting and not temptable.started.vicious and kocmoc.vars.convertballoonpercent and gethiveballoon() and getBuffTime("8083443467") < tonumber(kocmoc.vars.convertballoonpercent) / 100 then
                    temptable.tokensfarm = false
                    api.tween(2, player.SpawnPos.Value * CFrame.fromEulerAnglesXYZ(0, 110, 0) + Vector3.new(0, 0, 9))
                    task.wait(2)
                    api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
                    api.tween(0.1, player.SpawnPos.Value * CFrame.fromEulerAnglesXYZ(0, 110, 0) + Vector3.new(0, 0, 9))
                    temptable.converting = true
                    repeat converthoney() until player.CoreStats.Pollen.Value == 0
                    if kocmoc.toggles.convertballoons and gethiveballoon() then
                        task.wait(6)
                        repeat
                            task.wait()
                            converthoney()
                        until gethiveballoon() == false or not kocmoc.toggles.convertballoons
                    end
                    temptable.converting = false
                    temptable.act = temptable.act + 1
                    task.wait(6)
                    if kocmoc.toggles.autoant and not game.Workspace.Toys["Ant Challenge"].Busy.Value and rtsg().Eggs.AntPass > 0 then
                        farmant()
                    end
                    if kocmoc.toggles.autoquest then
                        makequests()
                    end
                    if kocmoc.toggles.autokillmobs then
                        if tick() - temptable.lastmobkill >= kocmoc.vars.monstertimer * 60 then
                            temptable.lastmobkill = tick()
                            temptable.started.monsters = true
                            temptable.act = 0
                            killmobs()
                            temptable.started.monsters = false
                        end
                    end
                    if kocmoc.vars.resetbeenergy then
                        if temptable.act2 >= kocmoc.vars.resettimer then
                            temptable.started.monsters = true
                            temptable.act2 = 0
                            repeat 
                                task.wait()
                            until player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
                            player.Character:BreakJoints()
                            task.wait(6.5)
                            repeat 
                                task.wait()
                            until player.Character
                            player.Character:BreakJoints()
                            task.wait(6.5)
                            repeat
                                task.wait()
                            until player.Character
                            temptable.started.monsters = false
                        end
                    end
                end
                if tonumber(temptable.pollenpercentage) < tonumber(kocmoc.vars.convertat) or kocmoc.toggles.disableconversion and not temptable.planting then
                    if not temptable.tokensfarm then
                        api.tween(2, fieldpos)
                        task.wait(2)
                        temptable.tokensfarm = true
                        if kocmoc.toggles.autosprinkler then
                            makesprinklers(fieldposition, onlyonesprinkler)
                            task.wait(0.5)
                            playeractivescommand:FireServer({["Name"] = "Sprinkler Builder"})
                        end
                    else
                        if not game.Workspace.MonsterSpawners.CoconutCrab.Attachment.TimerGui.TimerLabel.Visible and not temptable.started.vicious and not temptable.started.monsters and not temptable.started.windy and findField(fieldposition).Name == "Coconut Field" then
                            maskequip("Demon Mask")
                            temptable.started.crab = true
                            while not game.Workspace.MonsterSpawners.CoconutCrab.Attachment.TimerGui.TimerLabel.Visible and not temptable.started.vicious and not temptable.started.monsters and not temptable.started.windy and findField(fieldposition).Name == "Coconut Field" do
                                task.wait()
                                if api.humanoidrootpart() then
                                    api.humanoidrootpart().CFrame = CFrame.new(-307.52117919922, 110.11863250732, 467.86791992188)
                                end
                            end
                        end
                        temptable.started.crab = false
                        if kocmoc.toggles.killmondo then
                            while kocmoc.toggles.killmondo and game.Workspace.Monsters:FindFirstChild("Mondo Chick (Lvl 8)") and not temptable.started.vicious and not temptable.started.monsters do
                                temptable.started.mondo = true
                                while game.Workspace.Monsters:FindFirstChild("Mondo Chick (Lvl 8)") do
                                    disableall()
                                    game.Workspace.Map.Ground.HighBlock.CanCollide = false
                                    mondopition = game.Workspace.Monsters["Mondo Chick (Lvl 8)"].Head.Position
                                    api.tween(1, CFrame.new(
                                        mondopition.x,
                                        mondopition.y - 60,
                                        mondopition.z)
                                    )
                                    task.wait(1)
                                    temptable.float = true
                                end
                                task.wait(.5)
                                game.Workspace.Map.Ground.HighBlock.CanCollide = true
                                temptable.float = false
                                api.tween(.5, CFrame.new(73.2, 176.35, -167))
                                task.wait(1)
                                for i = 0, 50 do
                                    gettoken(CFrame.new(73.2, 176.35, -167).Position)
                                end
                                enableall()
                                api.tween(2, fieldpos)
                                temptable.started.mondo = false
                            end
                        end
                        if lastfieldpos ~= fieldpos then
                            task.wait(0.5)
                            gettoken()
                        end
                        if (fieldposition - api.humanoidrootpart().Position).magnitude > temptable.magnitude and findField(api.humanoidrootpart().CFrame.p) ~= findField(fieldposition) and not temptable.planting and not temptable.doingcrosshairs and not temptable.doingbubbles then
                            api.tween(0.1, fieldpos)
                            task.spawn(function()
                                task.wait(0.5)
                                if kocmoc.toggles.autosprinkler then
                                    makesprinklers(fieldposition, onlyonesprinkler)
                                end
                            end)
                        end
                        getprioritytokens()
                        if kocmoc.toggles.farmflame then 
                            getflame()
                        end
                        if kocmoc.toggles.avoidmobs then
                            avoidmob()
                        end
                        if kocmoc.toggles.farmclosestleaf then
                            closestleaf()
                        end
                        if kocmoc.toggles.farmclouds then
                            getcloud()
                        end
                        if kocmoc.toggles.farmunderballoons then
                            getballoons()
                        end
                        if not kocmoc.toggles.donotfarmtokens then
                            gettoken(nil, kocmoc.toggles.newtokencollection)
                        end
                        if not kocmoc.toggles.farmflower then
                            getflower()
                        end
                        if kocmoc.toggles.farmpuffshrooms and game.Workspace.Happenings.Puffshrooms:FindFirstChildOfClass("Model") then
                            getpuff()
                        end
                        if kocmoc.toggles.autox4 then
                            doautox4()
                        end
                        if temptable.usegumdropsforquest and kocmoc.toggles.usegumdropsforquest and tick() - temptable.lastgumdropuse > 3 then
                            temptable.lastgumdropuse = tick()
                            playeractivescommand:FireServer({["Name"] = "Gumdrops"})
                        end
                    end
                elseif tonumber(temptable.pollenpercentage) >= tonumber(kocmoc.vars.convertat) and not temptable.started.vicious and not temptable.planting then
                    if not kocmoc.toggles.disableconversion then
                        temptable.tokensfarm = false
                        api.tween(2, player.SpawnPos.Value * CFrame.fromEulerAnglesXYZ(0, 110, 0) + Vector3.new(0, 0, 9))
                        task.wait(2)
                        api.humanoidrootpart().Velocity = Vector3.new(0, 0, 0)
                        api.tween(0.1, player.SpawnPos.Value * CFrame.fromEulerAnglesXYZ(0, 110, 0) + Vector3.new(0, 0, 9))
                        temptable.converting = true
                        repeat converthoney() until player.CoreStats.Pollen.Value == 0
                        if kocmoc.toggles.convertballoons and kocmoc.vars.convertballoonpercent == 0 and gethiveballoon() then
                            task.wait(6)
                            repeat
                                task.wait()
                                converthoney()
                            until gethiveballoon() == false or not kocmoc.toggles.convertballoons
                        end
                        equiptool(kocmoc.vars.deftool)
                        temptable.converting = false
                        temptable.act = temptable.act + 1
                        task.wait(6)
                        if kocmoc.toggles.autoant and not game.Workspace.Toys["Ant Challenge"].Busy.Value and rtsg().Eggs.AntPass > 0 then
                            farmant()
                        end
                        if kocmoc.toggles.autoquest then
                            makequests()
                        end
                        if kocmoc.toggles.autokillmobs then
                            if tick() - temptable.lastmobkill >= kocmoc.vars.monstertimer * 60 then
                                temptable.lastmobkill = tick()
                                temptable.started.monsters = true
                                temptable.act = 0
                                killmobs()
                                temptable.started.monsters = false
                            end
                        end
                        if kocmoc.vars.resetbeenergy then
                            if temptable.act2 >= kocmoc.vars.resettimer then
                                temptable.started.monsters = true
                                temptable.act2 = 0
                                repeat 
                                    task.wait()
                                until player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
                                player.Character:BreakJoints()
                                task.wait(6.5)
                                repeat 
                                    task.wait()
                                until player.Character
                                player.Character:BreakJoints()
                                task.wait(6.5)
                                repeat
                                    task.wait()
                                until player.Character
                                temptable.started.monsters = false
                            end
                        end
                    end
                end
                lastfieldpos = fieldpos
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if kocmoc.toggles.killvicious and temptable.detected.vicious and not temptable.converting and not temptable.started.monsters and not game.Workspace.Toys["Ant Challenge"].Busy.Value then
            temptable.started.vicious = true
            disableall()
            local vichumanoid = api.humanoidrootpart()
            for i, v in next, game.workspace.Particles:GetChildren() do
                for x in string.gmatch(v.Name, "Vicious") do
                    if string.find(v.Name, "Vicious") then
                        api.tween(1, CFrame.new(v.Position.x, v.Position.y, v.Position.z))
                        task.wait(1)
                        api.tween(0.5, CFrame.new(v.Position.x, v.Position.y, v.Position.z))
                        task.wait(.5)
                    end
                end
            end
            for i, v in next, game.workspace.Particles:GetChildren() do
                for x in string.gmatch(v.Name, "Vicious") do
                    while kocmoc.toggles.killvicious and
                        temptable.detected.vicious do
                        task.wait()
                        if string.find(v.Name, "Vicious") then
                            for i = 1, 4 do
                                temptable.float = true
                                vichumanoid.CFrame =
                                    CFrame.new(v.Position.x + 10, v.Position.y,
                                               v.Position.z)
                                task.wait(.3)
                            end
                        end
                    end
                end
            end
            enableall()
            task.wait(1)
            temptable.float = false
            temptable.started.vicious = false
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if kocmoc.toggles.killwindy and temptable.detected.windy and not temptable.converting and not temptable.started.vicious and not temptable.started.mondo and not temptable.started.monsters and not game.Workspace.Toys["Ant Challenge"].Busy.Value then
            temptable.started.windy = true
            local windytokendb = false
            local windytokentp = false
            local wlvl = ""
            local aw = false
            local awb = false -- some variable for autowindy, yk?
            disableall()
            local oldmask = rtsg()["EquippedAccessories"]["Hat"]
            maskequip("Demon Mask")
            while kocmoc.toggles.killwindy and temptable.detected.windy do
                if not aw then
                    for i, v in pairs(workspace.Monsters:GetChildren()) do
                        if string.find(v.Name, "Windy") then
                            wlvl = v.Name
                            aw = true -- we found windy!
                        end
                    end
                end
                if aw then
                    for i, v in pairs(workspace.Monsters:GetChildren()) do
                        if string.find(v.Name, "Windy") then
                            if v.Name ~= wlvl then
                                temptable.float = false
                                task.wait(2)
                                api.humanoidrootpart().CFrame = temptable.gacf(temptable.windy, 5)
                                task.wait(2)
                                for i = 1, 3 do
                                    gettoken(api.humanoidrootpart().Position)
                                end -- collect tokens :yessir:
                                wlvl = v.Name
                            end
                        end
                    end
                end
                if not awb then
                    api.tween(1, temptable.gacf(temptable.windy, 5))
                    task.wait(2)
                    api.tween(1, temptable.gacf(temptable.windy, 5))
                    task.wait(2)
                    awb = true
                end
                if awb and temptable.windy and temptable.windy.Name == "Windy" then
                    task.spawn(function()
                        if not windytokendb then
                            for _,token in pairs(workspace.Collectibles:GetChildren()) do
                                decal = token:FindFirstChildOfClass("Decal")
                                if decal and decal.Texture == "rbxassetid://1629547638" and api.humanoidrootpart() then
                                    windytokendb = true
                                    windytokentp = true
                                    task.wait()
                                    for i=0,20 do
                                        api.humanoidrootpart().CFrame = token.CFrame
                                        task.wait()
                                    end
                                    windytokentp = false
                                    task.wait(3)
                                    windytokendb = false
                                    break
                                end
                            end
                        end
                    end)
                    if not windytokentp and api.humanoidrootpart() then
                        api.humanoidrootpart().CFrame = temptable.gacf(temptable.windy, 25)
                        temptable.float = true
                    end
                    task.wait()
                end
            end
            maskequip(oldmask)
            enableall()
            temptable.float = false
            temptable.started.windy = false
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if kocmoc.toggles.autodig then
            if player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local clickEvent = tool:FindFirstChild("ClickEvent", true)
                    if clickEvent then
                        clickEvent:FireServer()
                    end
                end
                if kocmoc.vars.autodigmode == "Collector Steal" then
                    local onnet = game.Workspace.NPCs.Onett.Onett["Porcelain Dipper"]:FindFirstChild("ClickEvent")
                    if onnet then
                        task.wait()
                        onnet:FireServer()
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if kocmoc.toggles.traincrab and api.humanoidrootpart() then
            api.humanoidrootpart().CFrame = CFrame.new(-307.52117919922, 110.11863250732, 467.86791992188)
        end
        if kocmoc.toggles.trainsnail and api.humanoidrootpart() then
            local fd = game.Workspace.FlowerZones["Stump Field"]
            api.humanoidrootpart().CFrame = CFrame.new(
                fd.Position.X,
                fd.Position.Y - 20,
                fd.Position.Z
            )
        end
        if kocmoc.toggles.farmrares and not temptable.started.crab and not temptable.started.ant then
            for k, v in next, game.workspace.Collectibles:GetChildren() do
                if v.CFrame.YVector.Y == 1 then
                    if v.Transparency == 0 then
                        decal = v:FindFirstChildOfClass("Decal")
                        for e, r in next, kocmoc.rares do
                            if decal.Texture == r or decal.Texture == "rbxassetid://" .. r then
                                api.humanoidrootpart().CFrame = v.CFrame
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

game.Workspace.Particles.Folder2.ChildAdded:Connect(function(child)
    if child.Name == "Sprout" then
        temptable.sprouts.detected = true
        temptable.sprouts.coords = child.CFrame
    end
end)
game.Workspace.Particles.Folder2.ChildRemoved:Connect(function(child)
    if child.Name == "Sprout" then
        task.wait(30)
        temptable.sprouts.detected = false
        temptable.sprouts.coords = ""
    end
end)

Workspace.Particles.ChildAdded:Connect(function(instance)
    if string.find(instance.Name, "Vicious") then
        temptable.detected.vicious = true
    end
end)
Workspace.Particles.ChildRemoved:Connect(function(instance)
    if string.find(instance.Name, "Vicious") then
        temptable.detected.vicious = false
    end
end)
game.Workspace.NPCBees.ChildAdded:Connect(function(v)
    if v.Name == "Windy" then
        task.wait(3)
        temptable.windy = v
        temptable.detected.windy = true
    end
end)
game.Workspace.NPCBees.ChildRemoved:Connect(function(v)
    if v.Name == "Windy" then
        task.wait(3)
        temptable.windy = nil
        temptable.detected.windy = false
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if not temptable.converting then
            if kocmoc.toggles.autosamovar then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Samovar")
                platformm = game.Workspace.Toys.Samovar.Platform
                for i, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                    if (v.Position - platformm.Position).magnitude < 25 and
                        v.CFrame.YVector.Y == 1 then
                        api.humanoidrootpart().CFrame = v.CFrame
                    end
                end
            end
            if kocmoc.toggles.autostockings then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Stockings")
                platformm = game.Workspace.Toys.Stockings.Platform
                for i, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                    if (v.Position - platformm.Position).magnitude < 25 and
                        v.CFrame.YVector.Y == 1 then
                        api.humanoidrootpart().CFrame = v.CFrame
                    end
                end
            end
            if kocmoc.toggles.autoonettart then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Onett's Lid Art")
                platformm = game.Workspace.Toys["Onett's Lid Art"]
                                .Platform
                for i, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                    if (v.Position - platformm.Position).magnitude < 25 and
                        v.CFrame.YVector.Y == 1 then
                        api.humanoidrootpart().CFrame = v.CFrame
                    end
                end
            end
            if kocmoc.toggles.autocandles then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Honeyday Candles")
                platformm = game.Workspace.Toys["Honeyday Candles"].Platform
                for i, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                    if (v.Position - platformm.Position).magnitude < 25 and
                        v.CFrame.YVector.Y == 1 then
                        api.humanoidrootpart().CFrame = v.CFrame
                    end
                end
            end
            if kocmoc.toggles.autofeast then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer(
                    "Beesmas Feast")
                platformm = game.Workspace.Toys["Beesmas Feast"]
                                .Platform
                for i, v in pairs(game.Workspace.Collectibles:GetChildren()) do
                    if (v.Position - platformm.Position).magnitude < 25 and
                        v.CFrame.YVector.Y == 1 then
                        api.humanoidrootpart().CFrame = v.CFrame
                    end
                end
            end
            if kocmoc.toggles.autodonate then
                if isWindshrineOnCooldown() == false then
                    donateToShrine(kocmoc.vars.donoItem, kocmoc.vars.donoAmount)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        temptable.runningfor = temptable.runningfor + 1
        temptable.honeycurrent = statsget().Totals.Honey
        if kocmoc.toggles.honeystorm then
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Honeystorm")
        end
        if kocmoc.toggles.collectgingerbreads then
            game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Gingerbread House")
        end
        if kocmoc.toggles.autodispense then
            if kocmoc.dispensesettings.rj then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Free Royal Jelly Dispenser")
            end
            if kocmoc.dispensesettings.blub then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Blueberry Dispenser")
            end
            if kocmoc.dispensesettings.straw then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Strawberry Dispenser")
            end
            if kocmoc.dispensesettings.treat then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Treat Dispenser")
            end
            if kocmoc.dispensesettings.coconut then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Coconut Dispenser")
            end
            if kocmoc.dispensesettings.glue then
                game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Glue Dispenser")
            end
        end
        if kocmoc.toggles.autoboosters then
            if kocmoc.dispensesettings.white then
                game.ReplicatedStorage.Events.ToyEvent:FireServer("Field Booster")
            end
            if kocmoc.dispensesettings.red then
                game.ReplicatedStorage.Events.ToyEvent:FireServer("Red Field Booster")
            end
            if kocmoc.dispensesettings.blue then
                game.ReplicatedStorage.Events.ToyEvent:FireServer("Blue Field Booster")
            end
        end
        if kocmoc.toggles.clock then
            game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Wealth Clock")
        end
        if kocmoc.toggles.freeantpass then
            game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer("Free Ant Pass Dispenser")
        end
        if kocmoc.toggles.autoquest then
            local completeQuest = game.ReplicatedStorage.Events.CompleteQuestFromPool
            completeQuest:FireServer("Polar Bear")
            completeQuest:FireServer("Brown Bear 2")
            completeQuest:FireServer("Black Bear 2")
            completeQuest:FireServer("Bucko Bee")
            completeQuest:FireServer("Riley Bee")
            if kocmoc.toggles.autoquesthoneybee then
                completeQuest:FireServer("Honey Bee")
            end
            task.wait(1)
            local getQuest = game.ReplicatedStorage.Events.GiveQuestFromPool
            getQuest:FireServer("Polar Bear")
            getQuest:FireServer("Brown Bear 2")
            getQuest:FireServer("Black Bear 2")
            getQuest:FireServer("Bucko Bee")
            getQuest:FireServer("Riley Bee")
            if kocmoc.toggles.autoquesthoneybee then
                completeQuest:FireServer("Honey Bee")
            end
        end
        gainedhoneylabel:UpdateText("Gained Honey: " .. api.suffixstring(temptable.honeycurrent - temptable.honeystart))
        uptimelabel:UpdateText("Uptime: " .. truncatetime(math.round(tick() - temptable.starttime)))
    end
end)

game:GetService("RunService").Heartbeat:connect(function()
    if kocmoc.toggles.autoquest and player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("ScreenGui") and player.PlayerGui.ScreenGui:FindFirstChild("NPC") and player.PlayerGui.ScreenGui.NPC.Visible then
        firesignal(player.PlayerGui.ScreenGui.NPC.ButtonOverlay.MouseButton1Click)
    end
    if kocmoc.toggles.loopspeed and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = kocmoc.vars.walkspeed
    end
    if kocmoc.toggles.loopjump and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = kocmoc.vars.jumppower
    end
end)

game:GetService("RunService").Heartbeat:connect(function()
    for _, v in next, player.PlayerGui.ScreenGui:WaitForChild("MinigameLayer"):GetChildren() do
        for _, q in next, v:WaitForChild("GuiGrid"):GetDescendants() do
            if q.Name == "ObjContent" or q.Name == "ObjImage" then
                q.Visible = true
            end
        end
    end
end)

game:GetService("RunService").Heartbeat:connect(function()
    if temptable.float and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.BodyTypeScale.Value = 0
        floatpad.CanCollide = true
        floatpad.CFrame = CFrame.new(
            api.humanoidrootpart().Position.X,
            api.humanoidrootpart().Position.Y - 3.75,
            api.humanoidrootpart().Position.Z
        )
        task.wait(0)
    else
        floatpad.CanCollide = false
    end
end)

local vu = game:GetService("VirtualUser")
player.Idled:connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    while task.wait() do
        if kocmoc.toggles.farmsnowflakes then
            task.wait(3)
            for i, v in next, temptable.tokenpath:GetChildren() do
                if v:FindFirstChildOfClass("Decal") and
                    v:FindFirstChildOfClass("Decal").Texture ==
                    "rbxassetid://6087969886" and v.Transparency == 0 then
                    api.humanoidrootpart().CFrame =
                        CFrame.new(v.Position.X, v.Position.Y + 3, v.Position.Z)
                    break
                end
            end
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if kocmoc.toggles.autofarm then
            temptable.dead = true
            kocmoc.toggles.autofarm = false
            temptable.converting = false
            temptable.farmtoken = false
        end
        if temptable.dead then
            task.wait(25)
            temptable.dead = false
            kocmoc.toggles.autofarm = true
            temptable.converting = false
            temptable.tokensfarm = true
        end
    end)
end)

for _, v in next, game.workspace.Collectibles:GetChildren() do
    if string.find(v.Name, "") then v:Destroy() end
end

task.spawn(function()
    while task.wait() do
        if player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = api.humanoidrootpart().Position
            task.wait(0.00001)
            local currentSpeed = (pos - api.humanoidrootpart().Position).magnitude
            if currentSpeed > 0 then
                temptable.running = true
            else
                temptable.running = false
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        temptable.currtool = rtsg()["EquippedCollector"]
    end
end)

task.spawn(function()
    while task.wait() do
        local torso = player.Character:FindFirstChild("UpperTorso")
        
        if temptable.currtool == "Tide Popper" then
            temptable.lookat = getfurthestballoon() or fieldposition
        elseif temptable.currtool == "Petal Wand" then
            temptable.lookat = fieldposition
        elseif temptable.currtool == "Dark Scythe" then
            temptable.lookat = fieldposition
            for i,v in pairs(game.Workspace.PlayerFlames:GetChildren()) do
                if v:FindFirstChild("PF") and v.PF.Color.Keypoints[1].Value.G ~= 0 and (v.Position - torso.Position).magnitude < 20 then
                    temptable.lookat = v.Position
                end
            end
        end
        
        if not temptable.started.ant and not temptable.started.vicious and kocmoc.toggles.autofarm and not temptable.converting then
            if torso then
                local bodygyro = torso:FindFirstChildOfClass("BodyGyro")

                if not bodygyro then
                    bodygyro = Instance.new("BodyGyro")
                    bodygyro.D = 10
                    bodygyro.P = 5000
                    bodygyro.MaxTorque = Vector3.new(0, 0, 0)
                    bodygyro.Parent = torso
                end
                
                if bodygyro then
                    if fieldposition and temptable.lookat then
                        bodygyro.CFrame = CFrame.new(torso.CFrame.p, temptable.lookat)
                        bodygyro.MaxTorque = Vector3.new(0, math.huge, 0)
                        bodygyro.D = 10
                        bodygyro.P = 5000
                    elseif bodygyro then
                        bodygyro:Destroy()
                    end
                end
            end
        else
            if torso then
                local bodygyro = torso:FindFirstChildOfClass("BodyGyro")
                if bodygyro then
                    bodygyro:Destroy()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        for i,v in pairs(game.Workspace.Planters:GetChildren()) do
            if v.Name == "PlanterBulb" then
                local attach = v:FindFirstChild("Gui Attach")
                if attach then
                    local gui = attach:FindFirstChild("Planter Gui")
                    if gui then
                        gui.MaxDistance = 1e5
                        gui.Size = UDim2.new(150, 0, 50, 0)
                        
                        local text = gui.Bar.TextLabel
                        if text then
                            text.Size = UDim2.new(0.9, 0, 1, 0)
                            text.Position = UDim2.new(0.05, 0, 0, 0)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if kocmoc.toggles.docustomplanters then
            local plantercycles = {
                {
                    {Planter = kocmoc.vars.customplanter11, Field = kocmoc.vars.customplanterfield11, Percent = kocmoc.vars.customplanterdelay11},
                    {Planter = kocmoc.vars.customplanter12, Field = kocmoc.vars.customplanterfield12, Percent = kocmoc.vars.customplanterdelay12},
                    {Planter = kocmoc.vars.customplanter13, Field = kocmoc.vars.customplanterfield13, Percent = kocmoc.vars.customplanterdelay13},
                    {Planter = kocmoc.vars.customplanter14, Field = kocmoc.vars.customplanterfield14, Percent = kocmoc.vars.customplanterdelay14},
                    {Planter = kocmoc.vars.customplanter15, Field = kocmoc.vars.customplanterfield15, Percent = kocmoc.vars.customplanterdelay15}
                },
                {
                    {Planter = kocmoc.vars.customplanter21, Field = kocmoc.vars.customplanterfield21, Percent = kocmoc.vars.customplanterdelay21},
                    {Planter = kocmoc.vars.customplanter22, Field = kocmoc.vars.customplanterfield22, Percent = kocmoc.vars.customplanterdelay22},
                    {Planter = kocmoc.vars.customplanter23, Field = kocmoc.vars.customplanterfield23, Percent = kocmoc.vars.customplanterdelay23},
                    {Planter = kocmoc.vars.customplanter24, Field = kocmoc.vars.customplanterfield24, Percent = kocmoc.vars.customplanterdelay24},
                    {Planter = kocmoc.vars.customplanter25, Field = kocmoc.vars.customplanterfield25, Percent = kocmoc.vars.customplanterdelay25}
                },
                {
                    {Planter = kocmoc.vars.customplanter31, Field = kocmoc.vars.customplanterfield31, Percent = kocmoc.vars.customplanterdelay31},
                    {Planter = kocmoc.vars.customplanter32, Field = kocmoc.vars.customplanterfield32, Percent = kocmoc.vars.customplanterdelay32},
                    {Planter = kocmoc.vars.customplanter33, Field = kocmoc.vars.customplanterfield33, Percent = kocmoc.vars.customplanterdelay33},
                    {Planter = kocmoc.vars.customplanter34, Field = kocmoc.vars.customplanterfield34, Percent = kocmoc.vars.customplanterdelay34},
                    {Planter = kocmoc.vars.customplanter35, Field = kocmoc.vars.customplanterfield35, Percent = kocmoc.vars.customplanterdelay35}
                }
            }

            local steps = {
                5, 5, 5
            }

            for i,cycle in pairs(plantercycles) do
                for j,step in pairs(cycle) do
                    if not step.Planter or not step.Planter:find("Planter") then
                        steps[i] = steps[i] - 1
                    elseif not step.Field or (not step.Field:find("Field") and not step.Field:find("Patch") and not step.Field:find("Forest")) then
                        steps[i] = steps[i] - 1
                    end
                end
            end

            for i=1,3 do
                if not isfile("kocmoc/plantercache/cycle"..i.."cache.file") then
                    for _,planter in pairs(fetchAllPlanters()) do
                        RequestCollectPlanter(planter)
                    end
                    writefile("kocmoc/plantercache/cycle"..i.."cache.file", "1")
                end
            end

            if not temptable.started.ant and kocmoc.toggles.autofarm and not temptable.converting and not temptable.started.monsters then
                for i,cycle in pairs(plantercycles) do
                    if steps[i] == 0 then continue end
                    local planted = false
                    local currentstep = isfile("kocmoc/plantercache/cycle"..i.."cache.file") and tonumber(readfile("kocmoc/plantercache/cycle"..i.."cache.file")) or 1
                    currentstep = (currentstep - 1) % steps[i] + 1
                    for j,step in pairs(cycle) do
                        if step.Percent and step.Planter and step.Planter:find("Planter") and step.Field and (step.Field:find("Field") or step.Field:find("Patch") or step.Field:find("Forest")) then
                            for _,planter in pairs(fetchAllPlanters()) do
                                if planter.PotModel and planter.PotModel.Parent and planter.PotModel.PrimaryPart then
                                    if planter.GrowthPercent > step.Percent / 100 then
                                        if planter.PotModel.Name == step.Planter and getPlanterLocation(planter.PotModel.PrimaryPart) == step.Field then
                                            RequestCollectPlanter(planter)
                                        end
                                    else
                                        if planter.PotModel.Name == step.Planter and getPlanterLocation(planter.PotModel.PrimaryPart) == step.Field then
                                            planted = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if not planted and cycle[currentstep].Planter and #fetchAllPlanters() < 3 then
                        local planter = cycle[currentstep].Planter
                        if planter == "The Planter Of Plenty" and GetItemListWithValue()["PlentyPlanter"] and GetItemListWithValue()["PlentyPlanter"] > 0 then
                            PlantPlanter(planter, cycle[currentstep].Field)
                            writefile("kocmoc/plantercache/cycle"..i.."cache.file", tostring((currentstep - 1) % steps[i] + 2))
                        else
                            if GetItemListWithValue()[planter:gsub(" Planter", "") .. "Planter"] and GetItemListWithValue()[planter:gsub(" Planter", "") .. "Planter"] > 0 then
                                PlantPlanter(planter:gsub(" Planter", ""), cycle[currentstep].Field)
                                writefile("kocmoc/plantercache/cycle"..i.."cache.file", tostring((currentstep - 1) % steps[i] + 2))
                            end
                        end
                    end
                end
            end
        else
            NectarBlacklist["Invigorating"] = kocmoc.toggles.blacklistinvigorating and "Invigorating" or nil
            NectarBlacklist["Comforting"] = kocmoc.toggles.blacklistcomforting and "Comforting" or nil
            NectarBlacklist["Motivating"] = kocmoc.toggles.blacklistmotivating and "Motivating" or nil
            NectarBlacklist["Refreshing"] = kocmoc.toggles.blacklistrefreshing and "Refreshing" or nil
            NectarBlacklist["Satisfying"] = kocmoc.toggles.blacklistsatisfying and "Satisfying" or nil

            planterData["Plastic"] = not kocmoc.toggles.plasticplanter and fullPlanterData["Plastic"] or nil
            planterData["Candy"] = not kocmoc.toggles.candyplanter and fullPlanterData["Candy"] or nil
            planterData["Red Clay"] = not kocmoc.toggles.redclayplanter and fullPlanterData["Red Clay"] or nil
            planterData["Blue Clay"] = not kocmoc.toggles.blueclayplanter and fullPlanterData["Blue Clay"] or nil
            planterData["Tacky"] = not kocmoc.toggles.tackyplanter and fullPlanterData["Tacky"] or nil
            planterData["Pesticide"] = not kocmoc.toggles.pesticideplanter and fullPlanterData["Pesticide"] or nil
            planterData["Petal"] = not kocmoc.toggles.petalplanter and fullPlanterData["Petal"] or nil

            if kocmoc.toggles.autoplanters and not temptable.started.ant and kocmoc.toggles.autofarm and not temptable.converting then
                RequestCollectPlanters(fetchAllPlanters())
                if #fetchAllPlanters() < 3 then
                    local LeastNectar = calculateLeastNectar(fetchNectarBlacklist())
                    local Field = fetchBestFieldWithNectar(LeastNectar)
                    local Planter = fetchBestMatch(LeastNectar, Field)
                    if LeastNectar and Field and Planter then
                        print(formatString(Planter, Field, LeastNectar))
                        PlantPlanter(Planter, Field)
                    end
                end
            end
        end
    end
end)

loadingLoops:UpdateText("Loaded Loops")

local function getMonsterName(name)
    local newName = nil
    local keywords = {
        ["Mushroom"] = "Ladybug",
        ["Rhino"] = "Rhino Beetle",
        ["Spider"] = "Spider",
        ["Ladybug"] = "Ladybug",
        ["Scorpion"] = "Scorpion",
        ["Mantis"] = "Mantis",
        ["Beetle"] = "Rhino Beetle",
        ["Tunnel"] = "Tunnel Bear",
        ["Coco"] = "Coconut Crab",
        ["King"] = "King Beetle",
        ["Stump"] = "Stump Snail",
        ["Were"] = "Werewolf"
    }
    for i, v in pairs(keywords) do
        if string.find(string.upper(name), string.upper(i)) then
            newName = v
            break
        end
    end
    if newName == nil then newName = name end
    return newName
end

local function getNearestField(part)
    local resultingFieldPos
    local lowestMag = math.huge
    for i, v in pairs(game.Workspace.FlowerZones:GetChildren()) do
        if (v.Position - part.Position).magnitude < lowestMag then
            lowestMag = (v.Position - part.Position).magnitude
            resultingFieldPos = v.Position
        end
    end
    if lowestMag > 100 then
        resultingFieldPos = part.Position + Vector3.new(0, 0, 10)
    end
    if string.find(part.Name, "Tunnel") then
        resultingFieldPos = part.Position + Vector3.new(20, -70, 0)
    end
    return resultingFieldPos
end

local function fetchVisualMonsterString(v)
    local mobText = nil
    if v:FindFirstChild("Attachment") then
        if v.Attachment:FindFirstChild("TimerGui") then
            if v.Attachment.TimerGui:FindFirstChild("TimerLabel") then
                if v.Attachment.TimerGui.TimerLabel.Visible then
                    local splitTimer = string.split(v.Attachment.TimerGui.TimerLabel.Text, " ")
                    if splitTimer[3] ~= nil then
                        mobText = getMonsterName(v.Name) .. ": " .. splitTimer[3]
                    elseif splitTimer[2] ~= nil then
                        mobText = getMonsterName(v.Name) .. ": " .. splitTimer[2]
                    else
                        mobText = getMonsterName(v.Name) .. ": " .. splitTimer[1]
                    end
                else
                    mobText = getMonsterName(v.Name) .. ": Ready"
                end
            end
        end
    end
    return mobText
end

local function getToyCooldown(toy)
    local c = require(game.ReplicatedStorage.ClientStatCache):Get()
    local name = toy
    local t = workspace.OsTime.Value - c.ToyTimes[name]
    local cooldown = workspace.Toys[name].Cooldown.Value
    local u = cooldown - t
    local canBeUsed = false
    if string.find(tostring(u), "-") then canBeUsed = true end
    return u, canBeUsed
end


game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
        if kocmoc.vars.webhookurl ~= "" and httpreq then
            task.wait(1)
            disconnected(kocmoc.vars.webhookurl, kocmoc.vars.discordid, child.MessageArea.ErrorFrame.ErrorMessage.Text)
        end
        if kocmoc.toggles.shutdownkick then
            game:Shutdown()
        end
    end
end)

task.spawn(function()
    local timestamp = tick()
    while task.wait(15) do
        local timeout = false
        task.spawn(function()
            timeout = true
            task.wait(15)
            if timeout then
                if kocmoc.vars.webhookurl ~= "" and httpreq then
                    disconnected(kocmoc.vars.webhookurl, kocmoc.vars.discordid, "Server Timeout (Game Freeze)")
                end
                if kocmoc.toggles.shutdownkick then
                    game:Shutdown()
                end
            end
        end)
        local timestamp = tick()
        local statstable = playerstatsevent:InvokeServer()
        while task.wait() do
            if timeout then
                timeout = false
                break
            end
        end
    end
end)

task.spawn(function()
    local timestamp = tick()
    while task.wait(0.1) do
        if tick() - timestamp > kocmoc.vars.webhooktimer * 60 then
            if httpreq and kocmoc.vars.webhookurl ~= "" and kocmoc.toggles.webhookupdates then
                hourly(kocmoc.toggles.webhookping, kocmoc.vars.webhookurl, kocmoc.vars.discordid)
            end
            timestamp = tick()
        end
    end
end)

task.spawn(function()
    pcall(function()
        loadingInfo:CreateLabel("")
        loadingInfo:CreateLabel("Script loaded!")
        task.wait(2)
        pcall(function()
            for i, v in pairs(game.CoreGui:GetDescendants()) do
                if v.Name == "Startup Section" then
                    v.Parent.Parent.RightSide["Information Section"].Parent = v.Parent
                    v:Destroy()
                end
            end
        end)
        local panel = hometab:CreateSection("Mob Panel")
        local statusTable = {}
        for i, v in pairs(monsterspawners:GetChildren()) do
            if not string.find(v.Name, "CaveMonster") then
                local mobText = nil
                mobText = fetchVisualMonsterString(v)
                if mobText ~= nil then
                    local mob = panel:CreateButton(mobText, function()
                        api.tween(1, CFrame.new(getNearestField(v)))
                    end)
                    table.insert(statusTable, {mob, v})
                end
            end
        end
        local mob2 = panel:CreateButton("Mondo Chick: 00:00", function()
            api.tween(1,
                      game.Workspace.FlowerZones["Mountain Top Field"]
                          .CFrame)
        end)
        local panel2 = hometab:CreateSection("Utility Panel")
        local windUpd = panel2:CreateButton("Wind Shrine: 00:00", function()
            api.tween(1,
                      CFrame.new(
                          game.Workspace.NPCs["Wind Shrine"]
                              .Circle.Position + Vector3.new(0, 5, 0)))
        end)
        local rfbUpd = panel2:CreateButton("Red Field Booster: 00:00",
                                           function()
            api.tween(1,
                      CFrame.new(
                          game.Workspace.Toys["Red Field Booster"]
                              .Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local bfbUpd = panel2:CreateButton("Blue Field Booster: 00:00",
                                           function()
            api.tween(1,
                      CFrame.new(
                          game.Workspace.Toys["Blue Field Booster"]
                              .Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local wfbUpd = panel2:CreateButton("White Field Booster: 00:00",
                                           function()
            api.tween(1, CFrame.new(
                          game.Workspace.Toys["Field Booster"]
                              .Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local cocoDispUpd = panel2:CreateButton("Coconut Dispenser: 00:00",
                                                function()
            api.tween(1,
                      CFrame.new(
                          game.Workspace.Toys["Coconut Dispenser"]
                              .Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local ic1 = panel2:CreateButton("Instant Converter A: 00:00", function()
            api.tween(1,
                      CFrame.new(
                          game.Workspace.Toys["Instant Converter"]
                              .Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local ic2 = panel2:CreateButton("Instant Converter B: 00:00", function()
            api.tween(1,
                      CFrame.new(
                          game.Workspace.Toys["Instant Converter B"]
                              .Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local ic3 = panel2:CreateButton("Instant Converter C: 00:00", function()
            api.tween(1,
                      CFrame.new(
                          game.Workspace.Toys["Instant Converter C"]
                              .Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local wcUpd = panel2:CreateButton("Wealth Clock: 00:00", function()
            api.tween(1, CFrame.new(
                          game.Workspace.Toys["Wealth Clock"]
                              .Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local mmsUpd = panel2:CreateButton("Mythic Meteor Shower: 00:00", function()
            api.tween(1, CFrame.new( game.Workspace.Toys["Mythic Meteor Shower"].Platform.Position + Vector3.new(0, 5, 0)))
        end)
        local utilities = {
            ["Red Field Booster"] = rfbUpd,
            ["Blue Field Booster"] = bfbUpd,
            ["Field Booster"] = wfbUpd,
            ["Coconut Dispenser"] = cocoDispUpd,
            ["Instant Converter"] = ic1,
            ["Instant Converter B"] = ic2,
            ["Instant Converter C"] = ic3,
            ["Wealth Clock"] = wcUpd,
            ["Mythic Meteor Shower"] = mmsUpd
        }
        while task.wait(1) do
            if kocmoc.toggles.enablestatuspanel then
                for i, v in pairs(statusTable) do
                    if v[1] and v[2] then
                        v[1]:UpdateText(fetchVisualMonsterString(v[2]))
                    end
                end
                if workspace:FindFirstChild("Clock") then
                    if workspace.Clock:FindFirstChild("SurfaceGui") then
                        if workspace.Clock.SurfaceGui:FindFirstChild("TextLabel") then
                            if workspace.Clock.SurfaceGui:FindFirstChild("TextLabel").Text == "! ! !" then
                                mob2:UpdateText("Mondo Chick: Ready")
                            else
                                mob2:UpdateText("Mondo Chick: " .. string.gsub(string.gsub(workspace.Clock.SurfaceGui:FindFirstChild("TextLabel").Text, "\n", ""), "Mondo Chick:", ""))
                            end
                        end
                    end
                end
                local cooldown = require(game.ReplicatedStorage.TimeString)(
                                     3600 -
                                         (require(game.ReplicatedStorage.OsTime)() -
                                             (require(
                                                 game.ReplicatedStorage
                                                     .StatTools).GetLastCooldownTime(
                                                 v1, "WindShrine") or 0)))
                if cooldown == "" then
                    windUpd:UpdateText("Wind Shrine: Ready")
                else
                    windUpd:UpdateText("Wind Shrine: " .. cooldown)
                end
                for i, v in pairs(utilities) do
                    local cooldown, isUsable = getToyCooldown(i)
                    if cooldown ~= nil and isUsable ~= nil then
                        if isUsable then
                            v:UpdateText(i .. ": Ready")
                        else
                            v:UpdateText(i .. ": " .. require(game.ReplicatedStorage.TimeString)(cooldown))
                        end
                    end
                end
            end
        end
    end)
end)

if _G.autoload then
    if isfile("kocmoc/BSS_" .. _G.autoload .. ".json") then
        kocmoc = game:service("HttpService"):JSONDecode(readfile("kocmoc/BSS_" .. _G.autoload .. ".json"))
        for i,v in pairs(guiElements) do
            for j,k in pairs(v) do
                local obj = k:GetObject()
                local lastCharacters = obj.Name:reverse():sub(0, obj.Name:reverse():find(" ")):reverse()
                if kocmoc[i][j] then
                    if lastCharacters == " Dropdown" then
                        obj.Container.Value.Text = kocmoc[i][j]
                    elseif lastCharacters == " Slider" then
                        task.spawn(function()
                            local Tween = game:GetService("TweenService"):Create(
                                obj.Slider.Bar,
                                TweenInfo.new(1),
                                {Size = UDim2.new((tonumber(kocmoc[i][j]) - k:GetMin()) / (k:GetMax() - k:GetMin()), 0, 1, 0)}
                            )
                            Tween:Play()
                            local startStamp = tick()
                            local startValue = tonumber(obj.Value.PlaceholderText)
                            while tick() - startStamp < 1 do
                                task.wait()
                                local partial = tick() - startStamp
                                local value = (startValue + ((tonumber(kocmoc[i][j]) - startValue) * partial))
                                obj.Value.PlaceholderText = math.round(value * 100) / 100
                            end
                            obj.Value.PlaceholderText = tonumber(kocmoc[i][j])
                        end)
                    elseif lastCharacters == " Toggle" then
                        obj.Toggle.BackgroundColor3 = kocmoc[i][j] and Config.Color or Color3.fromRGB(50,50,50)
                    elseif lastCharacters == " TextBox" then
                        obj.Background.Input.Text = kocmoc[i][j]
                    end
                end
            end
        end
    else
        api.notify("Rosemoc " .. temptable.version, "No such config file!", 2)
    end

    local menuTabs = player.PlayerGui.ScreenGui.Menus.ChildTabs
    local set_thread_identity = syn and syn.set_thread_identity or setthreadcontext or setidentity

    if not set_thread_identity then
        api.notify("Rosemoc " .. temptable.version, "your exploit only partially supports autoload!", 2)
    else
        for _,v in pairs(menuTabs:GetChildren()) do
            if v:FindFirstChild("Icon") and v.Icon.Image == "rbxassetid://1436835355" then
                set_thread_identity(2)
                firesignal(v.MouseButton1Click)
                set_thread_identity(7)
            end
        end
    end
end

for _, part in next, workspace:FindFirstChild("FieldDecos"):GetDescendants() do
    if part:IsA("BasePart") then
        part.CanCollide = false
        part.Transparency = part.Transparency < 0.5 and 0.5 or part.Transparency
        task.wait()
    end
end
for _, part in next, workspace:FindFirstChild("Decorations"):GetDescendants() do
    if part:IsA("BasePart") and
        (part.Parent.Name == "Bush" or part.Parent.Name == "Blue Flower") then
        part.CanCollide = false
        part.Transparency = part.Transparency < 0.5 and 0.5 or part.Transparency
        task.wait()
    end
end
for i, v in next, workspace.Decorations.Misc:GetDescendants() do
    if v.Parent.Name == "Mushroom" then
        v.CanCollide = false
        v.Transparency = 0.5
    end
end
