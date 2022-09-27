print("loaded kickdetector")
local doneloading = false

task.spawn(function()
    while not doneloading do
        task.wait()
        local robloxPromptGui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if robloxPromptGui then
            local promptOverlay = robloxPromptGui:FindFirstChild("promptOverlay")
            if promptOverlay then
                local errorPrompt = promptOverlay:FindFirstChild("ErrorPrompt")
                if errorPrompt and errorPrompt:FindFirstChild('MessageArea') and errorPrompt.MessageArea:FindFirstChild("ErrorFrame") then
                    game:Shutdown()
                end
            end
        end
    end
end)

repeat task.wait(0.1) until game:IsLoaded()
repeat task.wait(0.1) until game.Players.LocalPlayer
repeat task.wait(0.1) until game.Players.LocalPlayer:FindFirstChild("PlayerGui")
repeat task.wait(0.1) until game.Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
repeat task.wait(0.1) until game.Players.LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("Menus")

print("Game was properly loaded, so now the main Rosemoc file will handle any disconnections")

local doneloading = true
