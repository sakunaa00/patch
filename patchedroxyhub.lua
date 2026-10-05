

RoxyHub_MultiEgg_DeliveryPlayer.lua
RoxyHub_MultiEgg…iveryPlayer.lua
 i tested this and the delivery feature did not work 


RoxyHub_MultiEgg_Draggable_V1_Safe.lua
RoxyHub_MultiEg…ble_V1_Safe.lua
 here is it

Done. I patched RoxyHub_MultiEgg_Draggable_V1_Safe.lua so the delivery system now:

Adds “Deliver Eggs To Player” to the existing Auto Farm section.

Automatically lists players currently in the server.

Keeps My Ranch as the default.

Uses the selected player's actual plot/Baseplate as the delivery destination.

Verifies that the basket actually becomes empty before declaring delivery successful.

Shows delivery failure instead of falsely continuing when the egg remains in the basket.

Prevents the selected player's name from becoming stale when they leave.

Keeps Auto-Hatch/Auto-Place/Auto-Unlock tied to your own ranch, so selecting another player doesn't accidentally run your plot automation on their ranch. 


Download the patched file
Download RoxyHub_MultiEgg_Draggable_V1_Safe_Patched.lua

The important part is that you don't need another egg-selection menu. Your existing Target Specific Egg remains the egg target; the new dropdown only determines whose ranch receives that egg.


RoxyHub_MultiEgg_Draggable_V1_Safe.lua
Code


Today 1:42 AM
its not displaying or detecting other players in the server

Fixed the player detection/display issue.

The dropdown now:

Loads all current players when the menu opens.

Uses the script's existing :Refresh() API for dynamic dropdowns.

Automatically updates when someone joins or leaves.

Keeps My Ranch as the default.

Handles the dropdown returning either a string or table.

Doesn't interfere with the draggable UI or the existing Target Specific Egg system.

Download the fixed RoxyHub_MultiEgg_Draggable_V1_Safe.lua

I also verified that the script is using Players:GetPlayers() and that the Players service is correctly initialized at the top of the file.


RoxyHub_MultiEgg_Draggable_V1_Safe.lua
Code


is it gonna detect other players now even though im the one who joined their server?

Yes. If you join someone else's Roblox server, the script should detect the other players in that same server.

The player list is based on:

Players:GetPlayers()
So it doesn't matter who created/joined the server. For example, if the server contains:

You — Necro mancer

PlayerA

PlayerB

PlayerC

the dropdown should show:

My Ranch

PlayerA

PlayerB

PlayerC

It also refreshes when another player joins or leaves.

One important distinction: detecting the player is separate from finding their ranch/plot. The new dropdown should detect them regardless of who joined first, but the delivery system still needs to correctly resolve that player's plot before the egg can actually be delivered there.


Library
/
RoxyHub_MultiEgg_Draggable_V1_Safe.lua



1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
local replicatedStorage = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local workspaceService = game:GetService("Workspace")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local httpService = game:GetService("HttpService")
local virtualUser = game:GetService("VirtualUser")
local virtualInputManager = game:GetService("VirtualInputManager")
_G.RoxyHubInstanceId = (_G.RoxyHubInstanceId or 0) + 1
local roxyHubInstanceId = _G.RoxyHubInstanceId

if _G.RoxyHubInstance and typeof(_G.RoxyHubInstance) == "table" and _G.RoxyHubInstance.Destroy then
  pcall(function() _G.RoxyHubInstance:Destroy() end)
end

if _G.RoxyHubConnections and type(_G.RoxyHubConnections) == "table" then
  for index, value in ipairs(_G.RoxyHubConnections) do
    local v1 = value
    pcall(function() v1:Disconnect() end)
  end
end

_G.RoxyHubConnections = {}

pcall(function()
  local rayfield = coreGui:FindFirstChild("Rayfield")

  if rayfield then
    rayfield:Destroy()
  end

  if gethui and gethui():FindFirstChild("RoxyHub_MobileToggle") then
    gethui().RoxyHub_MobileToggle:Destroy()
  end

  if coreGui:FindFirstChild("RoxyHub_MobileToggle") then
    coreGui.RoxyHub_MobileToggle:Destroy()
  end

  local localPlayer = players.LocalPlayer

  if localPlayer and localPlayer:FindFirstChild("PlayerGui")
    and localPlayer.PlayerGui:FindFirstChild("RoxyHub_MobileToggle") then
    localPlayer.PlayerGui.RoxyHub_MobileToggle:Destroy()
  end

  if localPlayer and localPlayer.Character then
    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = localPlayer.Character:FindFirstChild("Humanoid")

    if humanoidRootPart then
      local roxyFlightStabilizer = humanoidRootPart:FindFirstChild("RoxyFlightStabilizer")

      if roxyFlightStabilizer then
        roxyFlightStabilizer:Destroy()
      end

      humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
      humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end

    if humanoid then
      humanoid.PlatformStand = false
      humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
  end

  local renderedEggs = workspaceService:FindFirstChild("RenderedEggs")
