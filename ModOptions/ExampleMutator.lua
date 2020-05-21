-- Register the behaviour
behaviour("InfiniteThings")
local actor
local weapon
local AntiFall
local InfiniteHealth
local isInfiniteHealth
local isInfiniteVehicleHealth
local isFlying
local NoRecoil
local canvasit
local behaviourModOptions -- MOD OPTIONS
function InfiniteThings:Start()
	-- Run when behaviour is created
	self.canvasit = self.targets.canvasit -- chance the target of canvasit to your own canvas!
	
	self.weapon = Player.actor.activeWeapon
	local tih = self.targets.toggleInfiniteHealth.GetComponent(Toggle)
	local tia = self.targets.toggleInfiniteAmmo.GetComponent(Toggle)
	local tvh = self.targets.toggleVehicleHealth.GetComponent(Toggle)
	local tNF = self.targets.toggleAntiFall.GetComponent(Toggle)
	local tNR = self.targets.toggleNoRecoil.GetComponent(Toggle)
	
self.canvasit.gameObject.SetActive(false) -- Disable your canvas so it doesn't show up all the time
	self.script.StartCoroutine("AddOption") -- MOD OPTIONS
end
function InfiniteThings:AddOption() -- MOD OPTIONS
coroutine.yield(WaitForSeconds(0.1)) -- To ensure that the ModOptions Mutator is loaded first
local mutatorOptions = GameObject.Find("ModOptionsScript(Clone)") -- Find the ModOptionsScript GameObject
if mutatorOptions == nil then 
	print("ModOptionsScript(Clone) not found!") 
else 
    behaviourModOptions = ScriptedBehaviour.GetScript(mutatorOptions) -- Get the ScriptedBehaviour of the found Go
	local yourOwnButton = behaviourModOptions:AddMutatorOption("<YourMutatorModName>") -- Add your button the the Mutator Settings Tab
	yourOwnButton.onClick.AddListener(self,"onModOptionPress") -- Add a button listener when the button is pressed
	print("Done")
end
end

function InfiniteThings:onModOptionPress()  
	behaviourModOptions:OpenCanvas(self.targets.canvasit) -- Opens your canvas
end



function InfiniteThings:ToggleIH(change)
	InfiniteHealth = change.isOn
end
function InfiniteThings:ToggleIA(change)
	if not Player.actor.isDead then
	local ammoBeforeToggle = Player.actor.activeWeapon.ammo
	if change.isOn then
		Player.actor.activeWeapon.ammo = 99999
	else
		Player.actor.activeWeapon.ammo = ammoBeforeToggle
	end
end
end
function InfiniteThings:ToggleVH(change)
	isInfiniteVehicleHealth = change.isOn
end
function InfiniteThings:ToggleNF(change)
	AntiFall = change.isOn
end
function InfiniteThings:ToggleNR(change)
	NoRecoil = change.isOn
end
function InfiniteThings:Update()
	if self.targets.canvasit.gameObject.activeSelf then
		self:ToggleIH(self.targets.toggleInfiniteHealth.GetComponent(Toggle))
		self:ToggleIA( self.targets.toggleInfiniteAmmo.GetComponent(Toggle))
		self:ToggleVH(self.targets.toggleVehicleHealth.GetComponent(Toggle))
		self:ToggleNF(self.targets.toggleAntiFall.GetComponent(Toggle))
		self:ToggleNR(self.targets.toggleNoRecoil.GetComponent(Toggle))
	end
-- Ammo Stuff
	if Input.GetKeyDown(KeyCode.U) then
		Overlay.ShowMessage("<color=#0ff526>Infinite Ammo</color>")
		-- SetAmmo(Weapon self, int ammo)

		Player.actor.activeWeapon.ammo = 9999
		
	end
	if isInfiniteVehicleHealth then
		if Player.actor.isSeated then
		Player.actor.activeVehicle.Repair(9999)
		end
	end
	if NoRecoil then
		PlayerCamera.ResetRecoil()
	end
	if AntiFall == true then
		
		Player.actor.balance = 9999
	end
	if isFlying then
	end
	if Input.GetKeyDown(KeyCode.L) then

		isFlying = not isFlying
		if isFlying == true then
			Overlay.ShowMessage("<color=#0ff526>You're now Flying</color>")
		else
		
			Overlay.ShowMessage("<color=red>You're not flying anymore</color>")
		end
	end
	if Input.GetKeyDown(KeyCode.O) then
		
		isInfiniteVehicleHealth = not isInfiniteVehicleHealth
		if isInfiniteVehicleHealth == true then
			Overlay.ShowMessage("<color=#0ff526>Enabled Infinite Vehicle Health</color>")
		else
		
			Overlay.ShowMessage("<color=red>Disabled Infinite Vehicle Health</color>")
		end
	end
	if InfiniteHealth == true then
		Player.actor.health = 90000
	end
	if Input.GetKeyDown(KeyCode.P) then
		
		AntiFall = not AntiFall
		if AntiFall == true then
			Overlay.ShowMessage("<color=#0ff526>Enabled AntiFall</color>")
		else
			Overlay.ShowMessage("<color=red>Disabled AntiFall</color>")
		end
	end
	if InfiniteHealth == true then
		Player.actor.health = 90000
	end
-- Health Stuff
		if Input.GetKeyDown(KeyCode.I) and Player.actor.isDead == false then
				
				isInfiniteHealth = not isInfiniteHealth
				if isInfiniteHealth == false then
					Player.actor.health = 100
					InfiniteHealth = false
					Overlay.ShowMessage("<color=red>Disabled Infinite Health</color>")
					Player.actor.Damage(0)
				else
					InfiniteHealth = true
					Overlay.ShowMessage("<color=#0ff526>Enabled Infinite Health</color>")
				end
		end
	



end
