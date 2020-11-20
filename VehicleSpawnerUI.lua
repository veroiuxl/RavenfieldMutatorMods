-- Register the behaviour
behaviour("VehicleSpawnerUI")
function VehicleSpawnerUI:Start()
	self.isActive = false
	self.dropDownMenu = nil
	self.selectedVehicle = nil
	self.listOfTurrets = {}
	self.cstmKey = KeyCode.K
	self.listOfVehicles = {}
	self.canvasVehicleSpawner = self.targets.canvasTar
	self.dropDownMenu = self.targets.dropdownMenu.GetComponent(Dropdown)
	self.scriptvar = self.script
	self.targets.buttonTar.GetComponent(Button).onClick.AddListener(self, "ButtonPress")
	self.targets.selectedTeamButton.GetComponent(Button).onClick.AddListener(self, "SelTeamButton")
	self.isActive = false
	self.currentTeam = Player.actor.team
	if self.currentTeam == Team.Blue then
		self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Eagle"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(0, 0, 1)
	else
		self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Raven"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(1, 0, 0)
	end
	self.canvasVehicleSpawner.setActive(false)
	self.script.StartCoroutine("GetVehicles")
	self.script.StartCoroutine("getKeyFromString")
	self.vehiclePrefabList = {}
	self.turretPrefabList = {}
end

function VehicleSpawnerUI:getKeyFromString()
	coroutine.yield(WaitForSeconds(1.3))

	local go = GameObject.Find("Custom Keybinds")

	if (go ~= nil) then
		local customKB = ScriptedBehaviour.GetScript(go)

		local key = self.script.mutator.GetConfigurationString("ctmKey")
		if (key ~= nil or key ~= "") then
			local kcode = customKB:getKeyCodeFromCustomKey(key)

			if (kcode ~= nil and kcode ~= KeyCode.None) then
				self.cstmKey = kcode
			end
		end
	end
end
function VehicleSpawnerUI:SelTeamButton()
	if self.currentTeam == Team.Blue then
		self.currentTeam = Team.Red
		self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Raven"
		self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(1, 0, 0)
	else
		if self.currentTeam == Team.Red then
			self.currentTeam = Team.Blue
			self.targets.selectedTeamButton.GetComponentInChildren(Text).text = "Eagle"
			self.targets.selectedTeamButton.GetComponentInChildren(Text).color = Color(0, 0, 1)
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
	local jeep = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.Jeep)
	local quad = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.Quad)
	local jeepMG = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.JeepMachineGun)
	local tank = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.Tank)
	local ah = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.AttackHelicopter)
	local ap = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.AttackPlane)
	local rhib = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.Rhib)
	local ab = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.AttackBoat)
	local bp = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.BomberPlane)
	local th = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.TransportHelicopter)
	local apc = VehicleSpawner.GetPrefab(self.currentTeam, VehicleSpawnType.Apc)
	self.dropDownMenu.ClearOptions()
	for i = 0, 10, 1 do
		local prefab = VehicleSpawner.GetPrefab(self.currentTeam, i)
		local name = prefab.GetComponent(Vehicle).name
		self.dropDownMenu.AddOptions({name})
		table.insert(self.listOfVehicles, {prefab, name})
		
	end
	local mg = TurretSpawner.GetPrefab(self.currentTeam, TurretSpawnType.MachineGun)
	local at = TurretSpawner.GetPrefab(self.currentTeam, TurretSpawnType.AntiTank)
	local aa = TurretSpawner.GetPrefab(self.currentTeam, TurretSpawnType.AntiAir)
	for turret = 0, 2, 1 do
		local prefab = TurretSpawner.GetPrefab(self.currentTeam, turret)
		local name = prefab.gameObject.GetComponent(Vehicle).name
		self.dropDownMenu.AddOptions({name})
		table.insert(self.listOfTurrets, {prefab, name})
		table.insert(self.listOfVehicles, {prefab, name})
	end
	self.dropDownMenu.RefreshShownValue()
end
function VehicleSpawnerUI:ButtonPress()
	local ray =
		Ray(
		PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1,
		PlayerCamera.activeCamera.main.transform.forward
	)
	local raycast = Physics.Raycast(ray, 50, RaycastTarget.ProjectileHit)
	self.selectedVehicle = nil
	if raycast ~= nil then
		for i, y in ipairs(self.listOfVehicles) do
			if y[2] == self.dropDownMenu.captionText.text then
				self.selectedVehicle = y[1].gameObject
			end
		end
		if (self.selectedVehicle == nil) then
			print("self.selectedVehicle was nil. No " .. tostring(self.dropDownMenu.captionText.text) .. " found")
			return
		end
		local vehicle = GameObject.Instantiate(self.selectedVehicle)
		local isTurret = false
		if vehicle ~= nil then
			local pos = raycast.point - PlayerCamera.activeCamera.main.transform.forward
			local vehicletransform = vehicle.transform
			for z, t in ipairs(self.listOfTurrets) do
				if self.selectedVehicle.gameObject.name == t[1].name then
					isTurret = true
				end
			end
			if not isTurret then
				pos = pos + Vector3(0, 2, 0)
			else
				pos = pos + Vector3(0, 0, 0)
			end
			local direction = pos - Player.actor.position
			direction = Vector3(direction.x, 0, direction.z)
			vehicle.transform.rotation = Quaternion.LookRotation(direction)
			vehicle.transform.position = pos
		else
			print("<color=red>Vehicle not found</color>")
		end
	else
		print("Raycast was nil")
	end
end
function VehicleSpawnerUI:Update()
		if Input.GetKeyDown(self.cstmKey) then
		
		if self.isActive then
			Screen.UnlockCursor()
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
