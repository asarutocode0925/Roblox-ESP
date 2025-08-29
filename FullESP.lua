-- FullESP.lua
-- 固定サイズESP + 名前(黒) + 体力バー + 最大距離200

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 最大表示距離
local MAX_DISTANCE = 200

-- 固定サイズ
local BOX_WIDTH = 40
local BOX_HEIGHT = 70

-- ESP生成関数
local function createESP(player)
    if player == LocalPlayer then return end

    -- 四角枠
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Color = Color3.fromRGB(255, 0, 0) -- 赤枠
    Box.Filled = false
    Box.Visible = false

    -- 名前表示
    local Name = Drawing.new("Text")
    Name.Size = 12
    Name.Center = true
    Name.Outline = true
    Name.Color = Color3.fromRGB(0, 0, 0) -- 黒
    Name.Visible = false

    -- 体力バー背景
    local HealthBG = Drawing.new("Square")
    HealthBG.Thickness = 1
    HealthBG.Filled = true
    HealthBG.Color = Color3.fromRGB(0, 0, 0)
    HealthBG.Visible = false

    -- 体力バー本体
    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = true
    HealthBar.Visible = false

    -- 毎フレーム更新処理
    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local distance = (hrp.Position - Camera.CFrame.Position).Magnitude

            if distance <= MAX_DISTANCE then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    -- 四角枠
                    Box.Size = Vector2.new(BOX_WIDTH, BOX_HEIGHT)
                    Box.Position = Vector2.new(pos.X - BOX_WIDTH / 2, pos.Y - BOX_HEIGHT / 2)
                    Box.Visible = true

                    -- 名前
                    Name.Text = player.Name
                    Name.Position = Vector2.new(pos.X, pos.Y - BOX_HEIGHT / 2 - 14)
                    Name.Visible = true

                    -- 体力バー計算
                    local health = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)

                    -- 体力バー背景
                    HealthBG.Size = Vector2.new(4, BOX_HEIGHT)
                    HealthBG.Position = Vector2.new(Box.Position.X - 6, Box.Position.Y)
                    HealthBG.Visible = true

                    -- 体力バー本体（赤→緑）
                    HealthBar.Size = Vector2.new(4, BOX_HEIGHT * health)
                    HealthBar.Position = Vector2.new(Box.Position.X - 6, Box.Position.Y + (BOX_HEIGHT * (1 - health)))
                    HealthBar.Color = Color3.fromRGB((1 - health) * 255, health * 255, 0)
                    HealthBar.Visible = true
                else
                    Box.Visible = false
                    Name.Visible = false
                    HealthBG.Visible = false
                    HealthBar.Visible = false
                end
            else
                Box.Visible = false
                Name.Visible = false
                HealthBG.Visible = false
                HealthBar.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            HealthBG.Visible = false
            HealthBar.Visible = false
        end
    end)
end

-- 既存プレイヤーにESPを生成
for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end

-- 新規参加プレイヤーにESPを生成
Players.PlayerAdded:Connect(function(p)
    createESP(p)
end)
