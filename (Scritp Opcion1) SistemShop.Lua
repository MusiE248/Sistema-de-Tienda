

----Este es un scritp y va enel ServerScriptService---

---Esta opcion 1 es la que hace que el jugador pueda comprar los Items sin limite------

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopFolder = workspace:WaitForChild("ShopItems")
local ToolsFolder = ServerStorage:WaitForChild("ToolsStorage")
local messageEvent = ReplicatedStorage:FindFirstChild("ShopMessageEvent")
if not messageEvent then
	messageEvent = Instance.new("RemoteEvent")
	messageEvent.Name = "ShopMessageEvent"
	messageEvent.Parent = ReplicatedStorage
end

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
	local toolName = string.gsub(model.Name, "Item", "")

	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if not coins then return end

	if coins.Value < cost then
		sendMessage(player, "❌ Ocupas " .. cost .. " Coins para comprar este objeto.")
		return
	end

	coins.Value = coins.Value - cost
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

