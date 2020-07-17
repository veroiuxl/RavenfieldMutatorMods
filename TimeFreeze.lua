
-- Register the behaviour
behaviour("TimeFreeze")
local savedVelocity = {}
function TimeFreeze:Start()

GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")


self.savedAmmoWeapons = {}
self.savedLineRenderer = {}
self.isFrozen = false
self.isDrawing = false
self.currentLineRenderer = nil
self.currentLineRendererEnd = nil
self.currentisActor = false
self.selectedMove = nil
self.projectilesInLevel = {}
self.projectileParticleSystemActive = {}
self.maxProjectileText = self.targets.maxProjectileReached.GetComponent(Text)
self.spawnedHitboxInstance = {}
self.hitBox = self.targets.hitbox -- Cause that apparently is sometimes nil??
self.projectileLimit = 0
self.projectileLimitReached = false
self.isMovingBot = false
self.PlayerFpParent = GameObject.Find("Shoulder Parent")
if(self.PlayerFpParent == nil) then
	print("Shoulder Parent is nil!")
end
self.maxProjectiles = self.script.mutator.GetConfigurationRange("maxProjectiles")
self.maxProjectilesAT = self.maxProjectiles / 2 
self.isMovingProjectile = false
self.cooldownStart = 0

self.infiniteAmmoWhenFrozen = true
self.applyForceAtPosition = self.script.mutator.GetConfigurationBool("forceAtPosition")
self.currentActor = nil
self.currentRigidbody = nil
self.currentLineRendererStart = nil
self.currentPosByRaycastPoint = false
self.speed = self.script.mutator.GetConfigurationRange("speed")
self.canvas = self.targets.canvas
self.canvas.gameObject.SetActive(false)
self.image = self.targets.image
self.isHidden = false
self.forceMuliplier = self.script.mutator.GetConfigurationRange("forceMultiplier")
self.autoKillSelectedBots = self.script.mutator.GetConfigurationBool("automaticallyKillBots")

 end
function TimeFreeze:onActorSpawn(actor)
if(not actor.isBot) then
for i,y in ipairs(actor.weaponSlots) do
	table.insert(self.savedAmmoWeapons, {y,y.ammo})
end
end
end
function TimeFreeze:CreateLineRendererForObject(rigidbody)
local lineRenderer = GameObject.Instantiate(self.targets.lineRenderer)
table.insert(self.savedLineRenderer, {lineRenderer.GetComponent(LineRenderer),rigidbody})
print("Added lineRenderer to list")
self.isDrawing = true
self.currentRigidbody = rigidbody
self.currentLineRenderer = lineRenderer.GetComponent(LineRenderer)
return lineRenderer.GetComponent(LineRenderer)
end
function TimeFreeze:SpawnInvHitBox(projectile)
	if(projectile ~= nil) then -- Problem
	local hitBox = GameObject.Instantiate(self.hitBox)
	hitBox.gameObject.name = hitBox.gameObject.name .. " MoveProj"
	hitBox.gameObject.transform.position = projectile.transform.position
	-- hitBox.gameObject.layer = -14682625
	--print("New Weapon collider name : " .. weaponColliderGameObject.gameObject.name)
	projectile.transform.parent = hitBox.transform
	hitBox.transform.localScale = Vector3(0.7,0.7,0.7)
	hitBox.transform.rotation = projectile.transform.rotation 
	table.insert(self.spawnedHitboxInstance, hitBox)
	end

end
function TimeFreeze:ClearSpawnedHitboxInstanceList()
	for k,a in pairs (self.spawnedHitboxInstance) do
		if(a ~= nil) then
		if(a.transform.GetChild(0) ~= nil) then
		a.transform.GetChild(0).transform.parent = nil
		GameObject.Destroy(a)
		end
		GameObject.Destroy(a)
		end
	end
	for k in pairs (self.spawnedHitboxInstance) do
		self.spawnedHitboxInstance [k] = nil
	end



end
function TimeFreeze:SetLineRendererStart(lineRenderer,startP)
	lineRenderer.SetPosition(0,startP)
end
function TimeFreeze:GetAllProjectiles()
	for i,y in ipairs(GameObject.FindObjectsOfType(Projectile)) do -- Yikes
		if y.gameObject.activeSelf == true and y.velocity ~= Vector3.zero and y.gameObject.GetComponent(Light) ~= nil then
			table.insert(self.projectilesInLevel, y)
		else if y.gameObject.activeSelf == true and y.velocity ~= Vector3.zero and y.isTravellingTowardsPlayer then
			
			table.insert(self.projectilesInLevel, y)
			
			end
		end
	end
end
function TimeFreeze:ClearProjectileList()
	for k in pairs (self.projectilesInLevel) do
		self.projectilesInLevel [k] = nil
	end
	for a in pairs(self.spawnedHitboxInstance) do
		self.spawnedHitboxInstance [a] = nil
	end
end
function TimeFreeze:SetLineRendererEnd(lineRenderer,endP,raycastR)
	self.currentLineRendererStart = lineRenderer.GetPosition(0)
	if(raycastR) then
	self.currentLineRendererEnd = endP + Vector3(0,1,0)
	self.currentPosByRaycastPoint = true
	else
	self.currentLineRendererEnd = endP
	self.currentPosByRaycastPoint = false
	end
	lineRenderer.SetPosition(1,endP)
end
function TimeFreeze:CalculateTrajectory( TargetDistance, velocity)
	local n = (-Physics.gravity.y * TargetDistance)
	local b = velocity * velocity
    local CalculatedAngle = 0.5 * ((Mathf.Asin (n / b)) * Mathf.Rad2Deg);
        if(CalculatedAngle ~= CalculatedAngle) then
            return 0
		end
        return CalculatedAngle
end
function TimeFreeze:SetLineRendererFinal(lineRenderer,endP)
	
	lineRenderer.positionCount = 2
	if(self.currentPosByRaycastPoint) then
	lineRenderer.SetPosition(1,endP - Vector3(0,1,0))
	else
	lineRenderer.SetPosition(1,endP)
	end
	lineRenderer.material.color = Color.blue
	lineRenderer.material.color = Color.blue
	lineRenderer.endWidth = 0.2
	print("LineRenderer finished")
	self.currentLineRenderer = nil
	self.isDrawing = false
	-- self.currentRigidbody.AddForce(Vector3(0,50,0),ForceMode.Impulse)
	local dir
	if(self.currentisActor) then
	--	print("Actor detected")
			dir = (self.currentLineRendererEnd) - self.currentLineRendererStart

	
		local force = Vector3.Scale((dir.normalized * dir.magnitude * 54 * self.forceMuliplier),Vector3(1,1,1))
		local calcTraj = self:CalculateTrajectory(dir.magnitude,force.magnitude)
		local newF
		if calcTraj ~= 0 then
			local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * dir.magnitude
			print(trajectoryHeight)
			newF = Vector3(force.x,force.y + trajectoryHeight,force.z)
		end
		-- if(self.currentActor.isSeated) then
		-- 	self.currentActor.ExitVehicle()
		-- end
		self.currentActor.KnockOver(newF)
		if(self.autoKillSelectedBots) then
			self.currentActor.Damage(self.currentActor.health)
		end
		return
	end
	local dir = self.currentLineRendererEnd - self.currentLineRendererStart
	--print(tostring(dir.magnitude))
	local useMass
	if(self.currentRigidbody.mass == 0) then
		useMass = 1
	else
		useMass = self.currentRigidbody.mass 
	end
	local vehicle
	local mtpl = 1
	if(self.currentRigidbody.transform.root.gameObject.GetComponent(Vehicle) ~= nil) then
	--	print("Got vehicle")
		vehicle = self.currentRigidbody.transform.root.gameObject.GetComponent(Vehicle)
		if(vehicle.isAircraft) then
			mtpl = 1
			dir = ((self.currentLineRendererEnd - Vector3(0,1,0))) - self.currentLineRendererStart
		else
			mtpl = 1.5
		end
		
		
	end
	local force = Vector3.Scale((dir.normalized * dir.magnitude * (2 * self.forceMuliplier) * (useMass / 2) ),Vector3(1,mtpl,1))
	local calcTraj = self:CalculateTrajectory(dir.magnitude,force.magnitude)
	local newF
	if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * dir.magnitude
		newF = Vector3(force.x,force.y + trajectoryHeight,force.z)
	end
	if(self.applyForceAtPosition) then
		self.currentRigidbody.AddForceAtPosition(newF,self.currentLineRendererStart,ForceMode.Impulse)
	else
		self.currentRigidbody.AddForce(newF,ForceMode.Impulse)

	end

end
function TimeFreeze:RemoveCurrentLineRenderer()
GameObject.Destroy(self.currentLineRenderer)
table.remove(self.savedLineRenderer,self:tablefind(self.savedLineRenderer,self.currentLineRenderer))
end
function TimeFreeze:AddForceByLineRenderer(lineRenderer,rigidbody)
local dir = lineRenderer.GetPosition(1) - lineRenderer.GetPosition(0)
print(tostring(dir.magnitude))
local force = Vector3.Scale((dir.normalized * dir.magnitude * 5 * rigidbody.mass),Vector3(1,1.3,1))
rigidbody.AddForceAtPosition(force,lineRenderer.GetPosition(0),ForceMode.Impulse)
print("Applying " .. tostring(force) .. " to " .. rigidbody.transform.name)
end
function TimeFreeze:tablefind(tab,el) -- Because Lua sucks
    for index, value in pairs(tab) do
        if value[1] == el then
            return index
        end
    end
end

function TimeFreeze:Update()
	if self.PlayerFpParent == nil then
		self.PlayerFpParent = GameObject.Find("Shoulder Parent")
		return
	end
	if(Input.GetKeyDown(KeyCode.End) and self.isFrozen) then
		self.isHidden = not self.isHidden
		if(self.isHidden) then
			self.canvas.gameObject.SetActive(false)
		else
			self.canvas.gameObject.SetActive(true)
		end
	end
	if Input.GetKeyDown(KeyCode.H) and not Player.actor.isSeated then
		self.isFrozen = not self.isFrozen
		if(self.isFrozen) then
		
		for i,y in ipairs(Player.actor.weaponSlots) do
			y.LockWeapon()
		end
		-- self:GetAllProjectiles() -- Fuck this
		-- for z,p in ipairs(self.projectilesInLevel) do -- Fuck that
		-- 	self:SpawnInvHitBox(p)
		-- end
		self.canvas.gameObject.SetActive(true)
		self.isHidden = false
		self.maxProjectileText.color = Color(1,0,0,0)
		PlayerCamera.ResetRecoil()
		self.PlayerFpParent.transform.localEulerAngles = Vector3(0,0,0)
		self.targets.forceLineInfoTextAnimator.SetBool("fadeOut",true)
		Time.timeScale = 0.000001
		else
		Time.timeScale = 1
		
		PlayerCamera.ResetRecoil()
		if(self.isDrawing) then
			self:RemoveCurrentLineRenderer()
			--print("Player was still drawing line")
			self.isDrawing = false
			self.currentLineRenderer = nil
		end
		-- self:ClearSpawnedHitboxInstanceList() -- This doesn't fucking matter if it doesn't work
		-- self:ClearProjectileList()
		for i,y in ipairs(Player.actor.weaponSlots) do
			y.UnlockWeapon()
		end
		self.isMovingBot = false 
		self.selectedMove = nil
		self.maxProjectileText.color = Color(1,0,0,0)
		self.isMovingProjectile = false
		-- Apply Force
		-- Clear self.savedLineRenderer
		-- for i,y in ipairs(self.savedLineRenderer) do
		-- 	self:AddForceByLineRenderer(y[1],y[2]) 
		-- end
		for i,y in ipairs(self.savedLineRenderer) do 
			GameObject.Destroy(y[1])
			
		end
		for k in pairs (self.savedLineRenderer) do
			self.savedLineRenderer [k] = nil
		end
	--	print("Cleared list and destoryed objects")
		self.targets.forceLineInfoTextAnimator.SetBool("fadeOut",false)
		
		self.projectileLimitReached = false
		self.projectileLimit = 0
		self.targets.forceLineInfoText.GetComponent(Text).color = Color(1,1,1,1)
		self.isHidden = true
		self.canvas.gameObject.SetActive(false)
		end
	end
	
	if(self.isFrozen and PlayerCamera.activeCamera.main ~= nil) then
		if(Player.actor.isSeated) then
				Player.actor.ExitVehicle()
			
		end
		
		PlayerCamera.ResetRecoil()
		-- if(not Player.actorIsGrounded) then
		-- 	local ray = Ray(PlayerCamera.activeCamera.main.transform.position, Vector3.down)
		-- 	local raycast = Physics.Raycast(ray,1000,RaycastTarget.ProjectileHit)
		-- 	if(raycast ~= nil) then
		-- 		Player.MoveActor((raycast.point - Player.actor.transform.parent.position) * -Time.unscaledDeltaTime * 8)
		-- 	end
		-- end
		if(Input.GetKey(KeyCode.W)) then
			Player.MoveActor(PlayerCamera.activeCamera.main.transform.forward / (15 / self.speed))
		end
		if(Input.GetKey(KeyCode.A)) then
			Player.MoveActor(-PlayerCamera.activeCamera.main.transform.right / (17 / self.speed)) 
		end
		if(Input.GetKey(KeyCode.S)) then
			Player.MoveActor(-PlayerCamera.activeCamera.main.transform.forward / (16 / self.speed))
		end
		if(Input.GetKey(KeyCode.D)) then
			Player.MoveActor(PlayerCamera.activeCamera.main.transform.right / (17 / self.speed))
		end
		
		
		if(Input.GetKey(KeyCode.LeftControl)) then
			Player.MoveActor(-PlayerCamera.activeCamera.main.transform.up / (17 / self.speed))
		end
		if(Input.GetKey(KeyCode.Space)) then
			Player.MoveActor(PlayerCamera.activeCamera.main.transform.up / (17 / self.speed))
		end
		if(Input.GetKeyBindButton(KeyBinds.Sprint) and Input.GetKey(KeyCode.LeftControl) ) then
			Player.MoveActor(-PlayerCamera.activeCamera.main.transform.up / (5 / self.speed))
		end
		if(Input.GetKeyBindButton(KeyBinds.Sprint) and Input.GetKey(KeyCode.Space) ) then
			Player.MoveActor(PlayerCamera.activeCamera.main.transform.up / (5 / self.speed))
		end
		if(Input.GetKeyBindButton(KeyBinds.Sprint) and Input.GetKey(KeyCode.W) ) then
			Player.MoveActor(PlayerCamera.activeCamera.main.transform.forward / (4 / self.speed))
		end
		if(Input.GetKeyBindButton(KeyBinds.Sprint) and Input.GetKey(KeyCode.S) ) then
			Player.MoveActor(-PlayerCamera.activeCamera.main.transform.forward / (4 / self.speed))
		end
		if(Input.GetKeyBindButton(KeyBinds.Sprint) and Input.GetKey(KeyCode.A) ) then
			Player.MoveActor(-PlayerCamera.activeCamera.main.transform.right / (5 / self.speed)) 
		end
		if(Input.GetKeyBindButton(KeyBinds.Sprint) and Input.GetKey(KeyCode.D) ) then
			Player.MoveActor(PlayerCamera.activeCamera.main.transform.right / (5 / self.speed))
		end
		if Input.GetKeyDown(KeyCode.T) then
			--Overlay.ShowMessage("<color=#34abeb>Switched</color>")
			local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
		    local raycast = Physics.Raycast(ray,1100, RaycastTarget.ProjectileHit)
			if raycast ~= nil then
				Player.actor.transform.parent.position = raycast.point - PlayerCamera.activeCamera.main.transform.forward
			end
			
		

			

		end
		if(Player.actor.activeWeapon ~= nil) then
			if(Input.GetKeyBindButtonDown(KeyBinds.Reload)) then
				if(Player.actor.activeWeapon.spareAmmo ~= 0) then
					for i,y in ipairs(self.savedAmmoWeapons) do
						if(y[1] == Player.actor.activeWeapon) then
						local ammoNeeded = y[2] - Player.actor.activeWeapon.ammo
						Player.actor.activeWeapon.ammo = y[2]
						if(not self.infiniteAmmoWhenFrozen) then
							Player.actor.activeWeapon.spareAmmo  = Player.actor.activeWeapon.spareAmmo - ammoNeeded
						end
						end
					end
				end
			end
		if(Input.GetKeyBindButtonDown(KeyBinds.Fire) and not GameManager.isPaused) then

			if(Player.actor.activeWeapon.ammo ~= 0 and not Player.actor.activeWeapon.isReloading and not Player.actor.activeWeapon.isOverheating and not Player.actor.activeWeapon.isEmpty and not self.projectileLimitReached ) then
				if(self.projectileLimit > self.maxProjectiles) then
					self.projectileLimitReached = true
					self.maxProjectileText.color = Color(1,0,0,1)
					return
				else if self.projectileLimit > self.maxProjectilesAT and Player.actor.activeWeapon.weaponEntry.type == LoadoutType.AntiArmor then
					self.projectileLimitReached = true
					self.maxProjectileText.color = Color(1,0,0,1)
					return
				end
				end
				self.projectileLimit = self.projectileLimit + 1
				Player.actor.activeWeapon.Shoot(true)
			end
		end
		
		end
		if(Input.GetKeyBindButton(KeyBinds.Aim) and not GameManager.isPaused) then

			if(Player.actor.activeWeapon.spareAmmo ~= 0) then
				if(Player.actor.activeWeapon.ammo == 0) then
				for i,y in ipairs(self.savedAmmoWeapons) do
					if(y[1] == Player.actor.activeWeapon) then
					local ammoNeeded = y[2] - Player.actor.activeWeapon.ammo
					Player.actor.activeWeapon.ammo = y[2]
					if(not self.infiniteAmmoWhenFrozen) then
					Player.actor.activeWeapon.spareAmmo  = Player.actor.activeWeapon.spareAmmo - ammoNeeded
					end
					end
				end
				end
			end
			if(Player.actor.activeWeapon.ammo ~= 0 and not Player.actor.activeWeapon.isReloading and not Player.actor.activeWeapon.isOverheating and not Player.actor.activeWeapon.isEmpty and not self.projectileLimitReached ) then
				if(self.projectileLimit > self.maxProjectiles) then
					self.projectileLimitReached = true
					self.maxProjectileText.color = Color(1,0,0,1)
					return
				else if self.projectileLimit > self.maxProjectilesAT and Player.actor.activeWeapon.weaponEntry.type == LoadoutType.AntiArmor then
					self.projectileLimitReached = true
					self.maxProjectileText.color = Color(1,0,0,1)
					return
				end
				end
				self.projectileLimit = self.projectileLimit + 1
				Player.actor.activeWeapon.Shoot(true)
			end
		end
		
		if(self.isDrawing and self.currentLineRenderer ~= nil) then
				local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
				local raycast = Physics.Raycast(ray,30,RaycastTarget.ProjectileHit)
				if(raycast ~= nil) then
			--self:SetLineRendererEnd(self.currentLineRenderer,PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 4.5)
				self:SetLineRendererEnd(self.currentLineRenderer,raycast.point,true)
				else
					self:SetLineRendererEnd(self.currentLineRenderer,PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 4.3,false )
				end
		end
		if(self.isMovingBot) then
				if(self.isMovingProjectile) then
					--Handle pos set
					local playerPos = PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 5.5
					local directionBetweenPlayerAndPoint = playerPos - PlayerCamera.activeCamera.main.transform.position

					local rot = Quaternion.LookRotation(directionBetweenPlayerAndPoint)
					self.selectedMove.transform.rotation = rot 
					self.selectedMove.transform.localPosition = playerPos 
				else
					local playerPos = PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 7.5
					local directionBetweenPlayerAndPoint = PlayerCamera.activeCamera.main.transform.position - playerPos
					self.selectedMove.transform.rotation = Quaternion.LookRotation(directionBetweenPlayerAndPoint)
					self.selectedMove.transform.position = playerPos 
				end
		end
		-- if(Input.GetKeyDown(KeyCode.X)) then
		-- 	-- if(self.isMovingBot) then
		-- 	-- 	-- Place proj
		-- 	-- 	if(self.isMovingProjectile) then
		-- 	-- 		local previoursMagn = self.selectedMove.GetComponentInChildren(Projectile).velocity.magnitude 
					
		-- 	-- 		local playerPos = PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 7.5
		-- 	-- 		local directionBetweenPlayerAndPoint =  playerPos - PlayerCamera.activeCamera.main.transform.position
					
		-- 	-- 		for i,y in ipairs(self.projectileParticleSystemActive) do
		-- 	-- 			y.Play(true)
		-- 	-- 		end
		-- 	-- 		for k in pairs (self.projectileParticleSystemActive) do
		-- 	-- 			self.projectileParticleSystemActive [k] = nil
		-- 	-- 		end
		-- 	-- 		self.selectedMove.GetComponentInChildren(Projectile).velocity = directionBetweenPlayerAndPoint.normalized * previoursMagn-- "argument 'rhs' is nil" very fucking precises you useless shit 
		-- 	-- 	end
		-- 	-- 	self.isMovingBot = false 
		-- 	-- 	self.isMovingProjectile = false
		-- 	-- 	self.selectedMove = nil
		-- 	-- 	print("Set to false")
		-- 	-- 	return
		-- 	-- end
		
		-- 	local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
		-- 	local raycast = Physics.Raycast(ray,90,RaycastTarget.ProjectileHit)
		-- 	if(raycast ~= nil) then
		-- 		if(self.isMovingBot) then
		-- 		-- if string.find(raycast.transform.gameObject.name,"MoveProj") then
		-- 		-- 	print("Set projectile")
		-- 			self.selectedMove = raycast.transform.gameObject
		-- 		-- 	local ps = self.selectedMove.gameObject.GetComponentsInChildren(ParticleSystem)
		-- 		-- 	for i,y in ipairs(ps) do
		-- 		-- 		if(y.isEmitting or y.isPlaying) then
		-- 		-- 			table.insert(self.projectileParticleSystemActive, y)
		-- 		-- 			y.Clear(true)
		-- 		-- 			y.Stop(true)
		-- 		-- 		end
		-- 		-- 	end
		-- 			self.isMovingBot = true
		-- 			self.isMovingProjectile = true
		-- 			return
		-- 		end
		-- 		if(raycast.transform.root.gameObject.GetComponent(Actor) ~= nil) then
		-- 			local actor = raycast.transform.root.gameObject.GetComponent(Actor)
		-- 			self.selectedMove = actor.transform.gameObject
		-- 			self.isMovingBot = true
		-- 			print("Set actor")

		-- 		else if(raycast.transform.gameObject.GetComponent(Rigidbody) ~= nil) then
		-- 			self.selectedMove = raycast.transform.gameObject
		-- 			self.isMovingBot = true
		-- 			print("Set rigidbody")
			
		-- 		end
		-- 		end

		-- 	end
		-- end
		if(self.isMovingBot) then
			if(self.isMovingProjectile) then
				--Handle pos set
				local playerPos = PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 5.5
				local directionBetweenPlayerAndPoint = playerPos - PlayerCamera.activeCamera.main.transform.position

				local rot = Quaternion.LookRotation(directionBetweenPlayerAndPoint)
				self.selectedMove.transform.rotation = rot 
				self.selectedMove.transform.localPosition = playerPos 
			else
				local playerPos = PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 7.5
				local directionBetweenPlayerAndPoint = PlayerCamera.activeCamera.main.transform.position - playerPos
				self.selectedMove.transform.rotation = Quaternion.LookRotation(directionBetweenPlayerAndPoint)
				self.selectedMove.transform.position = playerPos 
			end
	end
	if(Input.GetKeyDown(KeyCode.X)) then
		if(self.isMovingBot) then
			-- Place proj
			-- if(self.isMovingProjectile) then
			-- 	local previoursMagn = self.selectedMove.GetComponentInChildren(Projectile).velocity.magnitude
			-- 	local playerPos = PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 7.5
			-- 	local directionBetweenPlayerAndPoint =  playerPos - PlayerCamera.activeCamera.main.transform.position
			-- 	self.selectedMove.GetComponentInChildren(Projectile).velocity = directionBetweenPlayerAndPoint.normalized * previoursMagn
			-- end
			self.isMovingBot = false 
			self.selectedMove = nil
			self.isMovingProjectile = false
		--	print("Set to false")
			return
		end
	
		local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
		local raycast = Physics.Raycast(ray,90,RaycastTarget.ProjectileHit)
		if(raycast ~= nil) then
			-- if string.find(raycast.transform.gameObject.name,"MoveProj") then
			-- 	print("Set projectile")
			-- 	self.selectedMove = raycast.transform.gameObject
			-- 	self.isMovingBot = true
			-- 	self.isMovingProjectile = true
			-- 	return
			-- end
			if(raycast.transform.root.gameObject.GetComponent(Actor) ~= nil) then
				local actor = raycast.transform.root.gameObject.GetComponent(Actor)
				self.selectedMove = actor.transform.gameObject
				self.isMovingBot = true
			--	print("Set actor")

			else if(raycast.transform.gameObject.GetComponent(Rigidbody) ~= nil) then
				self.selectedMove = raycast.transform.gameObject
				self.isMovingBot = true
			--	print("Set rigidbody")
		
			end
			end

		end
	end
		if(Input.GetKeyDown(KeyCode.Y)) then
				if(self.isDrawing) then
					self:SetLineRendererFinal(self.currentLineRenderer,self.currentLineRendererEnd)
					return
				end
				local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
				local raycast = Physics.Raycast(ray,90,RaycastTarget.ProjectileHit)
				if(raycast ~= nil) then
					if(raycast.transform.root.gameObject.GetComponent(Vehicle) ~= nil and raycast.transform.gameObject.GetComponentInParent(Actor) ~= nil ) then
						if(raycast.transform.root.gameObject.GetComponent(Vehicle).transform.gameObject.GetComponentInChildren(Actor) ~= nil ) then
						-- print("Actor is on vehicle")
						local actors = raycast.transform.root.gameObject.GetComponent(Vehicle).transform.gameObject.GetComponentsInChildren(Actor)
						for i,y in ipairs(actors) do
							-- print("if(" .. tostring(y.name) .. " == " .. tostring(raycast.transform.gameObject.GetComponentInParent(Actor).name) .. ") then")
							if(y.name == raycast.transform.gameObject.GetComponentInParent(Actor).name) then
								-- print("Got actor " .. y.name .. " that was on the vehicle")
								self.currentisActor = true
								self.currentActor = y
							end
						end
						if(self.currentisActor == true) then
						
						local lineRendererRaycast = self:CreateLineRendererForObject(self.currentActor.gameObject.GetComponent(Rigidbody))
						self:SetLineRendererStart(lineRendererRaycast,raycast.point)
						self.isDrawing = true
					else
				--		print("No actors on vehicle")
						end
						return
					else
						self.currentisActor = false
					end
					end
					if( raycast.transform.root.gameObject.GetComponent(Actor) ~= nil) then -- root is the reason why bots won't be affected by force when on a vehicle
						local actor = raycast.transform.root.gameObject.GetComponent(Actor)
					--	print("Actor selected")
						
						self.currentisActor = true
						self.currentActor = actor
						if(self.currentActor.isSeated) then
							self.currentActor.ExitVehicle()
						end
						local lineRendererRaycast = self:CreateLineRendererForObject(actor.gameObject.GetComponent(Rigidbody))
						self:SetLineRendererStart(lineRendererRaycast,raycast.point)
						self.isDrawing = true
						return
					else
						self.currentisActor = false
					end
					if(raycast.transform.gameObject.GetComponent(Rigidbody) ~= nil) and not self.currentisActor then
					local lineRendererRaycast = self:CreateLineRendererForObject(raycast.transform.gameObject.GetComponent(Rigidbody) )
					self:SetLineRendererStart(lineRendererRaycast,raycast.point)
					self.isDrawing = true

					else
					--	print(raycast.transform.gameObject.name .. " doesn't have a rigidbody")
					end
				end
		end
	end
	
end
