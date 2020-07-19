-- Register the behaviour
behaviour("VehicleSpawnerUI")
function VehicleSpawnerUI:Start()
self.isActive = false
self.dropDownMenu = nil
self.selectedVehicle = nil
self.listOfTurrets = {}
self.cstmKey = KeyCode.B
self.listOfVehicles = {}

self.canvasVehicleSpawner = self.targets.canvasTar
self.dropDownMenu = self.targets.dropdownMenu.GetComponent(Dropdown)
self.scriptvar = self.script
self.targets.buttonTar.GetComponent(Button).onClick.AddListener(self,"ButtonPress")
self.targets.selectedTeamButton.GetComponent(Button).onClick.AddListener(self,"SelTeamButton")
	--self.teamDropDownMenu.GetComponent(Dropdown).onValueChanged.AddListener(self,"TeamDropDownEvent")
	--self.targets.healthSlider.GetComponent(Slider).onValueChanged.AddListener(self,"oHSVC")
	--self.targets.dropdownMenu.GetComponent(Dropdown).onValueChanged.AddListener(self,"oVC")
self.isActive = false
self.currentTeam = Player.actor.team
if self.currentTeam == Team.Blue then
	self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Eagle"
	self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(0,0,1)
	else
	self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Raven"
	self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(1,0,0)
end
self.canvasVehicleSpawner.setActive(false)
self.script.StartCoroutine("GetVehicles")
self.script.StartCoroutine("getKeyFromString")
end

function VehicleSpawnerUI:getKeyFromString()

	coroutine.yield(WaitForSeconds(1.3))

	local go = GameObject.Find("Custom Keybinds")

	if(go ~= nil) then
		local customKB = ScriptedBehaviour.GetScript(go)

		local key = self.script.mutator.GetConfigurationString("ctmKey")
		if(key ~= nil or key ~= "") then
			local kcode = customKB:getKeyCodeFromCustomKey(key)

			if(kcode ~= nil and kcode ~= KeyCode.None) then
				self.cstmKey = kcode
			end
		end
	end

end
function VehicleSpawnerUI:SelTeamButton()
	if self.currentTeam == Team.Blue then
		self.currentTeam = Team.Red
		self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Raven"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(1,0,0)
	else if self.currentTeam == Team.Red then
		self.currentTeam = Team.Blue
		self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Eagle"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(0,0,1)
	end
	end
	self.script.StartCoroutine("GetVehicles")
end
function VehicleSpawnerUI:GetVehicles()
	local tempArray = {}
	for k in pairs(self.listOfVehicles) do
		self.listOfVehicles[k] = nil
	end
	for k in pairs(self.listOfTurrets) do
		self.listOfTurrets[k] = nil
	end
	local jeep = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.Jeep)
	local quad = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.Quad)
	local jeepMG = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.JeepMachineGun)
	local tank = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.Tank)
	local ah = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.AttackHelicopter)
	local ap = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.AttackPlane)
	local rhib = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.Rhib)
	local ab = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.AttackBoat)
	local bp = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.BomberPlane)
	local th = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.TransportHelicopter)
	local apc = VehicleSpawner.GetPrefab(self.currentTeam,VehicleSpawnType.Apc)

	local mg = TurretSpawner.GetPrefab(self.currentTeam,TurretSpawnType.MachineGun)
	local at = TurretSpawner.GetPrefab(self.currentTeam,TurretSpawnType.AntiTank)
	local aa = TurretSpawner.GetPrefab(self.currentTeam,TurretSpawnType.AntiAir)
	self.dropDownMenu.ClearOptions()
	-- I didn't use a loop because I wanted to make sure that there is no problem with it
	if jeep ~= nil then
		local newTempArray = { jeep.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, jeep)
	else
		print("<color=red>Jeep was nil</color>")
		
	end
	if quad ~= nil then
		local newTempArray = { quad.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, quad)
	else
		print("<color=red>quad was nil</color>")
		
	end
	
	if tank ~= nil then
		local newTempArray = { tank.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, tank)
	else
		print("<color=red>tank was nil</color>")
		
	end
	if ah ~= nil then
		local newTempArray = { ah.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, ah)
	else
		print("<color=red>ah was nil</color>")
		
	end
	if ap ~= nil then
		local newTempArray = { ap.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, ap)
	else
		print("<color=red>ap was nil</color>")
		
	end
	if rhib ~= nil then
		local newTempArray = { rhib.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, rhib)
	else
		print("<color=red>rhib was nil</color>")
		
	end
	if ab ~= nil then
		local newTempArray = { ab.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, ab)
	else
		print("<color=red>ab was nil</color>")
		
	end
	if bp ~= nil then
		local newTempArray = { bp.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, bp)
	else
		print("<color=red>bp was nil</color>")
		
	end
	if th ~= nil then
		local newTempArray = { th.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, th)
	else
		print("<color=red>th was nil</color>")
		
	end
	if apc ~= nil then
		local newTempArray = { apc.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, apc)
	else
		print("<color=red>apc was nil</color>")
		
	end
	if mg ~= nil then
		local newTempArray = { mg.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, mg)
		table.insert(self.listOfTurrets, mg)
	else
		print("<color=red>mg was nil</color>")
		
	end
	if jeepMG ~= nil then
		local newTempArray = { jeepMG.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, jeepMG)
		table.insert(self.listOfTurrets, jeepMG)
	else
		print("<color=red>jeepMG was nil</color>")
		
	end
	if at ~= nil then
		local newTempArray = { at.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, at)
		table.insert(self.listOfTurrets, at)
	else
		print("<color=red>at was nil</color>")
		
	end
	if aa ~= nil then
		local newTempArray = { aa.gameObject.name }
		self.dropDownMenu.AddOptions(newTempArray)
		table.insert(self.listOfVehicles, aa)
		table.insert(self.listOfTurrets, aa)
	else
		print("<color=red>aa was nil</color>")
		
	end
	self.dropDownMenu.RefreshShownValue()
--	local newTempArray = {}
	-- for i= 1, #tempArray, 1 do
	-- 	table.insert(newTempArray, tempArray[i].gameObject.name)
	-- 	print("Added " .. tempArray[i].gameObject.name .. " to newTempArray")-- DEBUG
	-- table.insert(self.listOfVehicles,  tempArray[i])
	-- print("Added " .. tostring(tempArray[i]) .. " to self.listOfVehicles") -- DEBUG
	-- self.dropDownMenu.AddOptions(newTempArray)
	-- table.remove(newTempArray, 1)
	-- end


end
function VehicleSpawnerUI:ButtonPress()
	local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
	local raycast = Physics.Raycast(ray,50, RaycastTarget.ProjectileHit)
	self.selectedVehicle = nil
	if raycast ~= nil then
		for i,y in ipairs(self.listOfVehicles) do 
			if y.gameObject.name == self.dropDownMenu.captionText.text then
				self.selectedVehicle = y.gameObject
			end
		end
		if(self.selectedVehicle == nil) then
			print("self.selectedVehicle was nil. No " .. tostring(self.dropDownMenu.captionText.text) .. " found")
			return
		end
		local vehicle = GameObject.Instantiate(self.selectedVehicle)
		local isTurret = false
		if vehicle ~= nil then
		
		local pos = raycast.point - PlayerCamera.activeCamera.main.transform.forward
		local vehicletransform = vehicle.transform
		for z,t in ipairs(self.listOfTurrets) do
			if self.selectedVehicle.gameObject.name == t.gameObject.name then
				isTurret = true;
				--print(self.selectedVehicle.gameObject.name .. " is Turret")
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
		print("Spawned Vehicle at " .. tostring(pos))
		else
			print("<color=red>Vehicle not found</color>")
		end
	else
		print("Raycast was nil")
	end

end
function VehicleSpawnerUI:Update()

--	if Input.GetKey(KeyCode.Space) and Player.actor.isSeated then
--		Player.actor.activeVehicle.gameObject.GetComponent(Rigidbody).AddRelativeTorque( Vector3(0, 0, 500), ForceMode.Impulse);
--	end
	
	if Input.GetKeyDown(self.cstmKey) then
		--print(#ActorManager.vehicles)
		if self.isActive then
		--	self.targets.anim.SetBool("uian",false)
		Screen.UnlockCursor()
			--self.targets.anim.SetBool("uian",false)
			self.canvasVehicleSpawner.setActive(false)
			self.isActive = false
			Screen.LockCursor()
	
		else
			self.canvasVehicleSpawner.setActive(true)
			self.isActive = true
			Screen.UnlockCursor()
		end
		
		
	end

end
