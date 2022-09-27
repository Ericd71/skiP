repeat task.wait() until game:IsLoaded()

task.wait(5)

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ericd71/Rosemoc/main/Library.lua"))()

local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

local weaponData = require(game:GetService("ReplicatedStorage").WeaponData)
local combatData = game:GetService("ReplicatedStorage").CombatData

local windowname = _G.windowname

local meleeWeaponNames = {
    "Sword",
    "Club",
    "Longsword",
    "Axe",
    "Katana",
    "Spear",
    "Axe",
    "Knife",
    "Mallet",
    "Blade",
    "Gauntlets",
    "Lance",
    "Scythe",
    "Twin Blade",
    "Greatsword"
}

local rosemoc = {
    toggles = {
        killaura = false,
        mobesp = false,
        shortnumberstoggle = false,
        lockposition = false,
        cubitesp = false
    },
    vars = {
        killauradelay = 0.1,
        killaurarange = 25,
        mobesprange = 200,
        cubitesprange = 200
    }
}

local temptable = {
    version = "4.2.4",
    weaponm1name = nil,
    weaponname = nil,
    weapontype = nil,
    lockedposition = nil
}

local Config = {
    WindowName = "Rosemoc v" .. temptable.version .. " By RoseGold",
    Color = Color3.fromRGB(255, 105, 180),
    Keybind = Enum.KeyCode.Semicolon
}

for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
    if v:IsA("TextLabel") and string.find(v.Text, "Rosemoc v") then
        v.Parent.Parent:Destroy()
    end
end

local Window = library:CreateWindow(Config, game:GetService("CoreGui"))

local farmingtab = Window:CreateTab("Farming")

local farmingsection = farmingtab:CreateSection("Farming")

local killauratoggle = farmingsection:CreateToggle("Kill Aura", nil, function(State)
    rosemoc.toggles.killaura = State
end)
local killauradelayslider = farmingsection:CreateSlider("Kill Aura Delay (Seconds)", 0, 1, 0.1, false, function(Value)
    rosemoc.vars.killauradelay = Value
end)
local killaurarangeslider = farmingsection:CreateSlider("Kill Aura Range", 0, 100, 25, true, function(Value)
    rosemoc.vars.killaurarange = Value
end)

local rendersection = farmingtab:CreateSection("Render")

local mobesptoggle = rendersection:CreateToggle("Mob ESP", nil, function(State)
    rosemoc.toggles.mobesp = State
end)
local mobesprangeslider = rendersection:CreateSlider("Mob ESP Range", 0, 1000, 200, true, function(Value)
    rosemoc.vars.mobesprange = Value
end)
local cubitesptoggle = rendersection:CreateToggle("Cubit ESP", nil, function(State)
    rosemoc.toggles.cubitesp = State
end)
local cubitesprangetoggle = rendersection:CreateSlider("Cubit ESP Range", 0, 1000, 200, true, function(Value)
    rosemoc.toggles.cubitesprange = State
end)
local shortnumberstoggle = rendersection:CreateToggle("Short Numbers", nil, function(State)
    rosemoc.toggles.shortnumberstoggle = State
end)

local playersection = farmingtab:CreateSection("Player")

local lockpositiontoggle = playersection:CreateToggle("Lock Position", nil, function(State)
    rosemoc.toggles.lockposition = State
    temptable.lockedposition = player.Character.HumanoidRootPart.CFrame.p
end)

local function getm1name(weapon, _type)
    local weaponModule = require(combatData[_type])
    
    local Data = {
        Character = game.Players.LocalPlayer.Character,
        Stats = {AS = 1},
        Tools = {weapon},
        Anim = require(game.ReplicatedStorage.AnimationService),
    }
    
    for i,v in next, weaponModule(Data, weapon) do
        if v.LMB then
            return v.LMB[1]
        end
    end
end

local function isMeleeWeapon(weapon)
    if weaponData[weapon] and table.find(meleeWeaponNames, weaponData[weapon].Type) then
        return true
    end
end

local function DamageMob(mob)
    if mob and mob:FindFirstChild("Humanoid") and weaponm1name and mob.Humanoid.Health > 0 then
        player.Character.Combat.RemoteEvent:FireServer("Input", temptable.weaponname, math.random(), weaponm1name.."Event", mob.PrimaryPart)
    end
end

local function truncate(num)
    if not rosemoc.toggles.shortnumberstoggle then
        return num
    end

    num = num:gsub("K", "000"):gsub("M", "000000"):gsub("B", "000000000")
    
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

player.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

for i,v in next, player.Character.Equipment:GetChildren() do
    if isMeleeWeapon(v.Name) then
        temptable.weaponname, temptable.weapontype = v.Name, weaponData[v.Name].Type
        weaponm1name = getm1name(v, temptable.weapontype)
    end
end

player.Character.Equipment.ChildAdded:Connect(function(v)
    if isMeleeWeapon(v.Name) then
        temptable.weaponname, temptable.weapontype = v.Name, weaponData[v.Name].Type
        weaponm1name = getm1name(v, temptable.weapontype)
    end
end)

RunService.RenderStepped:Connect(function(step)
    if rosemoc.toggles.lockposition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and temptable.lockedposition then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(temptable.lockedposition)
        player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
end)

task.spawn(function()
    while task.wait(rosemoc.vars.killauradelay) do
        if rosemoc.toggles.killaura then
            for i,v in pairs(workspace.NPCs:GetChildren()) do
                if v.PrimaryPart and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 and (player.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude < rosemoc.vars.killaurarange then
                    DamageMob(v)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if rosemoc.toggles.mobesp then
            for i,v in pairs(game.Workspace.NPCs:GetChildren()) do
                if v.PrimaryPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not v.Name:find("Lv ") then return end
                    local mobname = v.Name:sub(0, v.Name:find("Lv ") - 2)
                    local moblevel = v.Name:sub(v.Name:find("Lv ") + 3, (v.Name:find("HP:") or #v.Name + 2) - 2)
                    local hps = v.Name:find("HP:") and ((v.Name:sub(v.Name:find("HP:") + 5, #v.Name - 1)):split("/")) or -1
                    local hp = -1
                    local maxhp = -1
                    if type(hps) == "table" then
                        hp, maxhp = unpack(hps) 
                    end
                    local hppercent = math.round(hp/maxhp*10000)/100
                    local billboardGui = v:FindFirstChildWhichIsA("BillboardGui")
                    if not billboardGui then
                        billboardGui = Instance.new("BillboardGui")
                        billboardGui.Adornee = v
                        billboardGui.ExtentsOffset = Vector3.new(0, 1, 0)
                        billboardGui.AlwaysOnTop = true
                        billboardGui.Size = UDim2.new(50, 0, 2, 0)
                        billboardGui.StudsOffset = Vector3.new(0, 0, 0)
                        billboardGui.MaxDistance = rosemoc.vars.mobesprange == 1000 and inf or rosemoc.vars.mobesprange
                        billboardGui.Parent = v
                        
                        local frame = Instance.new("Frame", billboardGui)
                        frame.BackgroundTransparency = 1
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        
                        local mobnametext = Instance.new("TextLabel", frame)
                        mobnametext.Name = "MobName"
                        mobnametext.Text = mobname
                        mobnametext.BackgroundTransparency = 1
                        mobnametext.Size = UDim2.new(1, 0, 1, 0)
                        mobnametext.Font = "SourceSansBold"
                        mobnametext.TextSize = 18
                        mobnametext.TextColor3 = Color3.fromRGB(255, 0, 0)
                        mobnametext.TextStrokeColor3 = Color3.fromRGB(127, 0, 0)
                        mobnametext.TextStrokeTransparency = 0
                        
                        local mobleveltext = Instance.new("TextLabel", frame)
                        mobleveltext.Name = "MobLevel"
                        mobleveltext.Text = "[Lv "..moblevel.."]"
                        mobleveltext.BackgroundTransparency = 1
                        mobleveltext.Size = UDim2.new(1, 0, 1, 0)
                        mobleveltext.Font = "SourceSansBold"
                        mobleveltext.TextSize = 18
                        mobleveltext.TextColor3 = Color3.fromRGB(255, 169, 0)
                        mobleveltext.TextStrokeColor3 = Color3.fromRGB(127, 85, 0)
                        mobleveltext.TextStrokeTransparency = 0
                        
                        local mobhptext = Instance.new("TextLabel", frame)
                        mobhptext.Name = "MobHP"
                        if hp == -1 then
                            mobhptext.Text = hppercent.."% HP"
                        else
                            mobhptext.Text = truncate(hp).."/"..truncate(maxhp).." HP ("..hppercent.."%)"
                        end
                        mobhptext.BackgroundTransparency = 1
                        mobhptext.Size = UDim2.new(1, 0, 1, 0)
                        mobhptext.Font = "SourceSansBold"
                        mobhptext.TextSize = 18
                        mobhptext.TextStrokeTransparency = 0
                        
                        local totalbound = mobnametext.TextBounds.X + mobleveltext.TextBounds.X
                        
                        mobnametext.Position = UDim2.new(0, -mobleveltext.TextBounds.X / 2 - 5, 0, -mobleveltext.TextBounds.Y / 2)
                        mobleveltext.Position = UDim2.new(0, totalbound / 2 - mobleveltext.TextBounds.X / 2 + 5, 0, -mobleveltext.TextBounds.Y / 2)
                        mobhptext.Position = UDim2.new(0, 0, 0, mobleveltext.TextBounds.Y / 2)
                        
                        local r = math.min(255, (1 - hppercent / 100) * 2 * 255)
                        local g = math.min(255, hppercent / 100 * 2 * 255)
                        
                        mobhptext.TextColor3 = Color3.fromRGB(r, g, 0)
                        mobhptext.TextStrokeColor3 = Color3.fromRGB(r/2, g/2, 0)
                    else
                        local mobnametext = billboardGui.Frame:FindFirstChild("MobName")
                        local mobleveltext = billboardGui.Frame:FindFirstChild("MobLevel")
                        local mobhptext = billboardGui.Frame:FindFirstChild("MobHP")
                        
                        billboardGui.MaxDistance = rosemoc.vars.mobesprange == 1000 and inf or rosemoc.vars.mobesprange
                        mobnametext.Text = mobname
                        mobleveltext.Text = "[Lv "..moblevel.."]"
                        if hp == -1 then
                            mobhptext.Text = hppercent.."% HP"
                        else
                            mobhptext.Text = truncate(hp).."/"..truncate(maxhp).." HP ("..hppercent.."%)"
                        end
                        
                        local r = math.min(255, (1 - hppercent / 100) * 2 * 255)
                        local g = math.min(255, hppercent / 100 * 2 * 255)
                        
                        mobhptext.TextColor3 = Color3.fromRGB(r, g, 0)
                        mobhptext.TextStrokeColor3 = Color3.fromRGB(r/2, g/2, 0)
                    end
                end
            end
        else
            if windowname == _G.windowname then
                for i,v in pairs(game.Workspace.NPCs:GetChildren()) do
                    local billboardGui = v:FindFirstChildWhichIsA("BillboardGui")
                    if billboardGui then
                        billboardGui:Destroy()
                    end
                end
            end
        end
        
        if rosemoc.toggles.cubitesp then
            for i,v in pairs(game.Workspace["Client Cubits"]:GetChildren()) do
                if v and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.round((player.Character.HumanoidRootPart.Position - v.Position).Magnitude * 100) / 100
                    local billboardGui = v:FindFirstChildWhichIsA("BillboardGui")
                    if not billboardGui then
                        billboardGui = Instance.new("BillboardGui")
                        billboardGui.Adornee = v
                        billboardGui.ExtentsOffset = Vector3.new(0, 1, 0)
                        billboardGui.AlwaysOnTop = true
                        billboardGui.Size = UDim2.new(50, 0, 2, 0)
                        billboardGui.StudsOffset = Vector3.new(0, 0, 0)
                        billboardGui.MaxDistance = rosemoc.vars.cubitesprange == 1000 and inf or rosemoc.vars.cubitesprange
                        billboardGui.Parent = v
                        
                        local frame = Instance.new("Frame", billboardGui)
                        frame.BackgroundTransparency = 1
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        
                        local distancetext = Instance.new("TextLabel", frame)
                        distancetext.Name = "Distance"
                        distancetext.Text = "Distance: "..dist
                        distancetext.BackgroundTransparency = 1
                        distancetext.Size = UDim2.new(1, 0, 1, 0)
                        distancetext.Font = "SourceSansBold"
                        distancetext.TextSize = 18
                        distancetext.TextColor3 = Color3.fromRGB(255, 0, 0)
                        distancetext.TextStrokeColor3 = Color3.fromRGB(127, 0, 0)
                        distancetext.TextStrokeTransparency = 0
                    else
                        billboardGui.MaxDistance = rosemoc.vars.cubitesprange == 1000 and inf or rosemoc.vars.cubitesprange
                        local distancetext = billboardGui.Frame:FindFirstChild("Distance")
                        distancetext.Text = "Distance: "..dist

                        local r = math.min(255, math.min(dist, 100) / 100 * 2 * 255)
                        local g = math.min(255, (1 - math.min(dist, 100) / 100) * 2 * 255)
                        
                        distancetext.TextColor3 = Color3.fromRGB(r, g, 0)
                        distancetext.TextStrokeColor3 = Color3.fromRGB(r/2, g/2, 0)
                    end
                end
            end
        else
            if windowname == _G.windowname then
                for i,v in pairs(game.Workspace["Client Cubits"]:GetChildren()) do
                    local billboardGui = v:FindFirstChildWhichIsA("BillboardGui")
                    if billboardGui then
                        billboardGui:Destroy()
                    end
                end
            end
        end
    end
end)
