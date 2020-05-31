-- Register the behaviour
behaviour("VehicleSpawnerUI")

local isActive = false
local canvasVehicleSpawner
local scriptVar
local animatorComponent
local canTriggerAgain = true
local hud
local dropDownMenu
local teamDropDownMenu
local healthSlider
local healthText
local selectedVehicle
local currentTeam
local listOfTurrets = {}
local listOfVehicles = {}
-- Will be replaced
function VehicleSpawnerUI:Start()
	-- Run when behaviour is created
	self.canvasVehicleSpawner = self.targets.canvasTar
	self.dropDownMenu = self.targets.dropdownMenu.GetComponent(Dropdown)
	self.scriptvar = self.script
	self.healthText = self.targets.healthText
	self.healthSlider = self.targets.healthSlider
	self.teamDropDownMenu = self.targets.teamdropdown

	self.targets.buttonTar.GetComponent(Button).onClick.AddListener(self,"ButtonPress")
	self.targets.selectedTeamButton.GetComponent(Button).onClick.AddListener(self,"SelTeamButton")
	--self.teamDropDownMenu.GetComponent(Dropdown).onValueChanged.AddListener(self,"TeamDropDownEvent")
	--self.targets.healthSlider.GetComponent(Slider).onValueChanged.AddListener(self,"oHSVC")
	--self.targets.dropdownMenu.GetComponent(Dropdown).onValueChanged.AddListener(self,"oVC")
	isActive = false
	currentTeam = Player.actor.team
	if currentTeam == Team.Blue then
		self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Eagle"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(0,0,1)
		else
			self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Raven"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(1,0,0)
	end
	self.canvasVehicleSpawner.setActive(false)
	self.script.StartCoroutine("GetVehicles")

end
function VehicleSpawnerUI:SelTeamButton()
	if currentTeam == Team.Blue then
		currentTeam = Team.Red
		self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Raven"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(1,0,0)
	else if currentTeam == Team.Red then
		currentTeam = Team.Blue
		self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Eagle"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(0,0,1)
	end
	end
	self.script.StartCoroutine("GetVehicles")
end
function VehicleSpawnerUI:GetVehicles()
	local tempArray = {}
	for k in pairs(listOfVehicles) do
		listOfVehicles[k] = nil
	end
	for k in pairs(listOfTurrets) do
		listOfTurrets[k] = nil
	end
	local jeep = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.Jeep)
	local quad = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.Quad)
	local tank = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.Tank)
	local ah = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.AttackHelicopter)
	local ap = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.AttackPlane)
	local rhib = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.Rhib)
	local ab = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.AttackBoat)
	local bp = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.BomberPlane)
	local th = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.TransportHelicopter)
	local apc = VehicleSpawner.GetPrefab(currentTeam,VehicleSpawnType.Apc)

	local mg = TurretSpawner.GetPrefab(currentTeam,TurretSpawnType.MachineGun)
	local at = TurretSpawner.GetPrefab(currentTeam,TurretSpawnType.AntiTank)
	local aa = TurretSpawner.GetPrefab(currentTeam,TurretSpawnType.AntiAir)
	self.dropDownMenu.ClearOptions()
	-- I didn't use a loop because I wanted to make sure that there is no problem with it
	if jeep ~= nil then
		local newTempArray = { jeep.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, jeep)
	else
		print("<color=red>Jeep was nil</color>")
		
	end
	if quad ~= nil then
		local newTempArray = { quad.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, quad)
	else
		print("<color=red>quad was nil</color>")
		
	end
	
	if tank ~= nil then
		local newTempArray = { tank.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, tank)
	else
		print("<color=red>tank was nil</color>")
		
	end
	if ah ~= nil then
		local newTempArray = { ah.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, ah)
	else
		print("<color=red>ah was nil</color>")
		
	end
	if ap ~= nil then
		local newTempArray = { ap.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, ap)
	else
		print("<color=red>ap was nil</color>")
		
	end
	if rhib ~= nil then
		local newTempArray = { rhib.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, rhib)
	else
		print("<color=red>rhib was nil</color>")
		
	end
	if ab ~= nil then
		local newTempArray = { ab.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, ab)
	else
		print("<color=red>ab was nil</color>")
		
	end
	if bp ~= nil then
		local newTempArray = { bp.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, bp)
	else
		print("<color=red>bp was nil</color>")
		
	end
	if th ~= nil then
		local newTempArray = { th.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, th)
	else
		print("<color=red>th was nil</color>")
		
	end
	if apc ~= nil then
		local newTempArray = { apc.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, apc)
	else
		print("<color=red>apc was nil</color>")
		
	end
	if mg ~= nil then
		local newTempArray = { mg.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, mg)
		table.insert(listOfTurrets, mg)
	else
		print("<color=red>mg was nil</color>")
		
	end
	if at ~= nil then
		local newTempArray = { at.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, at)
		table.insert(listOfTurrets, at)
	else
		print("<color=red>at was nil</color>")
		
	end
	if aa ~= nil then
		local newTempArray = { aa.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(listOfVehicles, aa)
		table.insert(listOfTurrets, aa)
	else
		print("<color=red>aa was nil</color>")
		
	end
	self.dropDownMenu.RefreshShownValue()
--	local newTempArray = {}
	-- for i= 1, #tempArray, 1 do
	-- 	table.insert(newTempArray, tempArray[i].gameObject.name)
	-- 	print("Added " .. tempArray[i].gameObject.name .. " to newTempArray")-- DEBUG
	-- table.insert(listOfVehicles,  tempArray[i])
	-- print("Added " .. tostring(tempArray[i]) .. " to listOfVehicles") -- DEBUG
	-- self.dropDownMenu.AddOptions(newTempArray)
	-- table.remove(newTempArray, 1)
	-- end


end
function VehicleSpawnerUI:oVC()

--healthSlider.maxValue = selectedVehicle.

end
function VehicleSpawnerUI:TeamDropDownEvent(value)
	if value == 0 then 
		self.dropDownMenu.ClearOptions()
		self.script.StartCoroutine("GetVehicles")
	
	end
end
function VehicleSpawnerUI:oHSVC()
	healthText.text = "Vehicle Health: " .. tostring(healthSlider.value)

end
function VehicleSpawnerUI:ButtonPress()
	local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
	local raycast = Physics.Raycast(ray,50, RaycastTarget.ProjectileHit)
	if raycast ~= nil then
		for i,y in ipairs(listOfVehicles) do 
			if y.gameObject.name == self.dropDownMenu.captionText.text then
				selectedVehicle = y.gameObject
			end
		end
		local vehicle = GameObject.Instantiate(selectedVehicle)
		local isTurret = false
		if vehicle ~= nil then
		
		local pos = raycast.point - PlayerCamera.activeCamera.main.transform.forward
		local vehicletransform = vehicle.transform
		for z,t in ipairs(listOfTurrets) do
			if selectedVehicle.gameObject.name == t.gameObject.name then
				isTurret = true;
				--print(selectedVehicle.gameObject.name .. " is Turret")
			end
		end
		if not isTurret then
		pos = pos + Vector3(0,2,0)
		else
			pos = pos + Vector3(0,0,0)
		end
		local direction = pos - Player.actor.position
		direction = Vector3(direction.x,0,direction.z) 
		vehicle.transform.rotation = Quaternion.LookRotation(direction)
		vehicle.transform.position = pos
		else

			print("<color=red>Vehicle not found</color>")
		end

	end

end
function VehicleSpawnerUI:Update()

--	if Input.GetKey(KeyCode.Space) and Player.actor.isSeated then
--		Player.actor.activeVehicle.gameObject.GetComponent(Rigidbody).AddRelativeTorque( Vector3(0, 0, 500), ForceMode.Impulse);
--	end
	
	if Input.GetKeyDown(KeyCode.B) then
		--print(#ActorManager.vehicles)
		if isActive then
		--	self.targets.anim.SetBool("uian",false)
		Screen.UnlockCursor()
			--self.targets.anim.SetBool("uian",false)
			self.canvasVehicleSpawner.setActive(false)
			isActive = false
			Screen.LockCursor()
	
		else
			self.canvasVehicleSpawner.setActive(true)
			isActive = true
			Screen.UnlockCursor()
		end
		
		
	end

end
