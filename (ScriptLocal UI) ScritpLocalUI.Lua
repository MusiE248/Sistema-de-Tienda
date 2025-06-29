
---Este scripLocal va dentor del ""ShopUI""-----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local messageEvent = ReplicatedStorage:WaitForChild("ShopMessageEvent")

local gui = player:WaitForChild("PlayerGui"):WaitForChild("ShopUI")
local label = gui:WaitForChild("MessageLabel")

messageEvent.OnClientEvent:Connect(function(msg)
	label.Text = msg
	label.Visible = true
	task.wait(3)
	label.Visible = false
end)
