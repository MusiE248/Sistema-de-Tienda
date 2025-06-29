

----Este es un scritp y va enel ServerScriptService---

---Esta opcion 2 es la que hace que el jugador pueda comprar Solo Una vez y ya no peudo comprar denuevo el Item------



local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local ShopFolder = workspace:WaitForChild("ShopItems")
local ToolsFolder = ServerStorage:WaitForChild("ToolsStorage")
local PurchasesDataStore = DataStoreService:GetDataStore("PlayerPurchases")

local messageEvent = Instance.new("RemoteEvent")
messageEvent.Name = "ShopMessageEvent"
messageEvent.Parent = ReplicatedStorage

local playerPurchases = {}

local function sendMessage(player, text)
	messageEvent:FireClient(player, text)
end

local function giveTool(player, toolName)
	local tool = ToolsFolder:FindFirstChild(toolName)
	if tool then
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			local clone = tool:Clone()
			clone.Parent = backpack
		end
	end
end

local function handlePurchase(prompt, player)
	local model = prompt.Parent.Parent
	local priceValue = model:FindFirstChild("Price")
	if not priceValue or not priceValue:IsA("IntValue") then return end

	local cost = priceValue.Value
	local itemName = model.Name
	local toolName = string.gsub(itemName, "Item", "")

	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if not coins then return end

	playerPurchases[player.UserId] = playerPurchases[player.UserId] or {}
	if playerPurchases[player.UserId][toolName] then
		sendMessage(player, "⚠️ Ya compraste este objeto.")
		return
	end

	if coins.Value < cost then
		sendMessage(player, "❌ Ocupas " .. cost .. " Coins para comprar este objeto.")
		return
	end

	coins.Value = coins.Value - cost
	playerPurchases[player.UserId][toolName] = true
	giveTool(player, toolName)
	sendMessage(player, "✅ ¡Compra exitosa!")
end

for _, item in pairs(ShopFolder:GetChildren()) do
	if item:IsA("Model") then
		local part = item:FindFirstChildWhichIsA("BasePart")
		if part then
			local prompt = part:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				prompt.Triggered:Connect(function(player)
					handlePurchase(prompt, player)
				end)
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	playerPurchases[player.UserId] = {}
	pcall(function()
		local data = PurchasesDataStore:GetAsync(player.UserId)
		if data and typeof(data) == "table" then
			for _, itemName in ipairs(data) do
				playerPurchases[player.UserId][itemName] = true
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local purchases = playerPurchases[player.UserId]
	if purchases then
		local purchaseList = {}
		for itemName, bought in pairs(purchases) do
			if bought then
				table.insert(purchaseList, itemName)
			end
		end

		pcall(function()
			PurchasesDataStore:SetAsync(player.UserId, purchaseList)
		end)
	end

	playerPurchases[player.UserId] = nil
end)
