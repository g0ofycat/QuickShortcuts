local ScriptEditorService = game:GetService("ScriptEditorService")

-- // Keyword Dictionary
local SNIPPETS = {
	["!hum"] = [[
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
]],

	["!ts"] = [[
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(
	1, -- Duration
	Enum.EasingStyle.Linear, -- // EasingStyle
	Enum.EasingDirection.InOut, -- // EasingDirection
	0, -- RepeatCount (0 for no repeat)
	false, -- // Reverses
	0 -- // Delay
)
local tween = TweenService:Create(part, tweenInfo, {Position = Vector3.new(10, 10, 10)})

tween:Play()
]],

	["!ray"] = [[
local origin = Vector3.new(0, 10, 0)
local direction = Vector3.new(0, -1, 0) -- Downward
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {} 

local raycastResult = workspace:Raycast(origin, direction, raycastParams)

if raycastResult then
    local hit = raycastResult.Instance
    local position = raycastResult.Position
    print("Hit:", hit, "Position:", position)
else
    print("No hit detected")
end
]],

	["!mouse"] = [[
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()

mouse.Button1Down:Connect(function()
	print(mouse.Hit.p)
end)
]],

	["!tool"] = [[
local tool = script.Parent

tool.Equipped:Connect(function()
	
end)

tool.Unequipped:Connect(function()
	
end)

tool.Activated:Connect(function()
	
end)
]],

	["!anim"] = [[
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://ANIMATION_ID_HERE"
local animator = character:FindFirstChildOfClass("Humanoid").Animator
local animTrack = humanoid:LoadAnimation(animation)

animTrack:Play()
]],

}

-- // Buffer recent Characters

local recentChars = ""

-- // Maximum buffer length

local MAX_BUFFER_LENGTH = 20

-- // Function to replace trigger words with their snippets

local function replaceTrigger(scriptDocument, snippet, endLine, endChar)
	local success, err = pcall(function()
		scriptDocument:EditTextAsync(snippet, endLine, 1, endLine, endChar + 1)
	end)

	if not success then
		warn("EditTextAsync failed:", err)
	end
end

-- // Check buffer for triggers

local function checkBufferForTriggers(scriptDocument, line, character)
	for trigger, snippet in pairs(SNIPPETS) do
		if recentChars:sub(-#trigger) == trigger then
			replaceTrigger(scriptDocument, snippet, line, character)
			recentChars = ""
			break
		end
	end
end

-- // Main text change handler

local function onTextChanged(scriptDocument, changes)
	for _, change in ipairs(changes) do
		if change.text and change.text ~= "" then
			recentChars = recentChars .. change.text
			if #recentChars > MAX_BUFFER_LENGTH then
				recentChars = recentChars:sub(-MAX_BUFFER_LENGTH)
			end
			checkBufferForTriggers(scriptDocument, change.range["end"].line, change.range["end"].character)
		end
	end
end

local connection = ScriptEditorService.TextDocumentDidChange:Connect(onTextChanged)

-- // Cleanup function

return function()
	if connection then
		connection:Disconnect()
	end
end
