
behaviour("MoonGravity")
local acy
local timer
-- gravityScale = -0.55f
local enabled = false
local hasPressed = false
local scriptvar
local onlyForBots = false
local AntiFall = false
function MoonGravity:Start()
	acy = self
	-- Run when behaviour is created
	print("[ZG]--MoonGravity by Chryses --")
	print("<color=#10e33a>Press Y to enable and disable Moon Gravity</color>")
	print("<color=#10e33a>Press P to enable and AntiFall</color>")
end
function MoonGravity:Awake()
	scriptvar = self.script 
end

function MoonGravity:Update()
	if acy ~= self then
		return
	end
	if AntiFall == true then
		
		Player.actor.balance = 9999
	end

	if Input.GetKeyDown(KeyCode.P) then
		
		AntiFall = not AntiFall
		if AntiFall == true then
			Overlay.ShowMessage("<color=#0ff526>Enabled AntiFall</color>")
		else
			Overlay.ShowMessage("<color=red>Disabled AntiFall</color>")
		end
	end

	if Input.GetKeyDown(KeyCode.Y) then
		
		if enabled == false then
			print("<color=green>Enabled Moon Gravity</color>")
			Overlay.ShowMessage("<color=green>Enabled Moon Gravity</color>")
            Physics.gravity = Vector3(0,-1.65,0)
            enabled = true
		else
			Overlay.ShowMessage("<color=red>Disabled Moon Gravity</color>")
            print("<color=red>Disabled Moon Gravity</color>")
            Physics.gravity = Vector3(0,-9.81,0)
            enabled = false

        end
	end



	
		--	gravityForce = gravityForce + 0.5
end
