-- Licensed under the Boost Software License, Version 1.0
behaviour("WeaponPickupALL")
function WeaponPickupALL:Start()
	print("Despawn time: " .. tostring(self.script.mutator.GetConfigurationInt("despawnTime")))
	print("Dropdown selected: " .. tostring(self.script.mutator.GetConfigurationDropdown("versionSelected")))
	print("DropChance:(math.random) " .. tostring((self.script.mutator.GetConfigurationRange("dropChance") / 100)))
	
	weaponsIni = {}
	local offline = false
	allWeapons = WeaponManager.allWeapons
	GameEvents.onActorDied.AddListener(self,"ActorDied")
	-- Outdated
	if Player.actor.name == "Unknown Player" then
		print("<color=red>Play in online mode if you want to experience all features!</color>",5)
		offline = true
	end
	local squadUiText = GameObject.Find("Squad Text").GetComponent(Text)
	if squadUiText ~= nil and offline then
		squadUiText.text = "<color=red>Play in online mode if you want to experience all features!</color>"
	end

end
function WeaponPickupALL:ActorDied(actor,killer,isSilent)
	if actor == nil or killer == nil then
		return
	end
	-- This is a mess, but it works
	-- I had to do a few nil checks because it seems like it sometimes doesn't detect it in the first if statement
	if self.script.mutator.GetConfigurationBool("everyBotDrops") then
		if not isSilent and math.random() < ((self.script.mutator.GetConfigurationRange("dropChance") / 100)) then
			if Player.actor.activeWeapon ~= nil and Player.actor.activeWeapon.weaponEntry.name ~= nil and actor.activeWeapon ~= nil then
			if  actor.activeWeapon.weaponEntry == nil or actor.activeWeapon.weaponEntry.name == nil and Player.actor.activeWeapon.weaponEntry.name  then
			return
			end
		
			if actor.activeWeapon.weaponEntry.name ~= Player.actor.activeWeapon.weaponEntry.name then
		local actorWeapon = actor.activeWeapon.weaponEntry
		
		local actorActualWeapon = actor.activeWeapon
		local selected
		
		for i,y in ipairs(allWeapons) do 
			if y.name == actorWeapon.name then
				selected = y
			end
			
		end
		print(selected.name)
		if self.script.mutator.GetConfigurationDropdown("versionSelected") == 1 then
		print("DistanceSpawnWeapon")
		self.script.StartCoroutine(self:SpawnWeaponDistance(selected, actor))
		else if self.script.mutator.GetConfigurationDropdown("versionSelected") == 0 then
		self.script.StartCoroutine(self:SpawnWeaponRaycast(selected, actor))
		end
		end
		end
		end
		end
		return
	end
	if killer.name == Player.actor.name and not isSilent and math.random() < (self.script.mutator.GetConfigurationRange("dropChance") / 100) then
	if Player.actor.activeWeapon ~= nil and Player.actor.activeWeapon.weaponEntry.name ~= nil and actor.activeWeapon ~= nil then
	if  actor.activeWeapon.weaponEntry == nil or actor.activeWeapon.weaponEntry.name == nil and Player.actor.activeWeapon.weaponEntry.name  then
	return
	end

	if actor.activeWeapon.weaponEntry.name ~= Player.actor.activeWeapon.weaponEntry.name then
local actorWeapon = actor.activeWeapon.weaponEntry

local actorActualWeapon = actor.activeWeapon
local selected

for i,y in ipairs(allWeapons) do 
	if y.name == actorWeapon.name then
		selected = y
	end
	
end
print(selected.name)
if self.script.mutator.GetConfigurationDropdown("versionSelected") == 1 then
self.script.StartCoroutine(self:SpawnWeaponDistance(selected, actor))
else if self.script.mutator.GetConfigurationDropdown("versionSelected") == 0 then
self.script.StartCoroutine(self:SpawnWeaponRaycast(selected, actor))
end
end
end
end
end
end
function WeaponPickupALL:IsGreaterOrEqual(localV,other)

	if(localV.x >= other.x and localV.y >= other.y and localV.z >= other.z) then
		return true;
	else
		return false;
	end
end
function WeaponPickupALL:SpawnWeaponRaycast(selectedWeapon,actor)
return function()
	coroutine.yield(WaitForSeconds(0.07))
	local spawnPos
	local ray = Ray(actor.position, Vector3.down)
	local raycast = Physics.Raycast(ray,400, RaycastTarget.Default)
	if raycast ~= nil then
		spawnPos = raycast.point + Vector3(Random.Range(0,0.2),0.08,Random.Range(0,0.2))
	else
		coroutine.yield(WaitForSeconds(0.05))
		spawnPos = actor.GetHumanoidTransformRagdoll( HumanBodyBones.Chest).position + Vector3(Random.Range(0,0.7),0,Random.Range(0,0.7))
	end
	local weaponToSpawn = selectedWeapon.InstantiateImposter(spawnPos, Quaternion(90,90,0,0))
	local weaponColliderGameObject = GameObject.Instantiate(self.targets.weaponCollider)
	weaponColliderGameObject.gameObject.name = weaponColliderGameObject.gameObject.name .. " SpawnedWeapon" -- Tags didn't work. Thanks Unity
	--print("New Weapon collider name : " .. weaponColliderGameObject.gameObject.name)
	weaponColliderGameObject.transform.parent = weaponToSpawn.transform
	if weaponToSpawn.gameObject.GetComponent(Renderer) == nil then -- Because some modded weapons are lazily designed
		print("Weapon " .. weaponToSpawn.gameObject.name .. " has no Renderer")
		weaponColliderGameObject.transform.localScale = Vector3(0.6,0.6,0.6)

	else
	
		if self:IsGreaterOrEqual(weaponToSpawn.gameObject.GetComponent(Renderer).bounds.size,Vector3(1.9,1.9,1.9)) then
			weaponColliderGameObject.transform.localScale = Vector3(1.9,1.9,1.9)
			print("Weapon " .. weaponToSpawn.gameObject.name .. " had an incorrect Renderer")
		else
			weaponColliderGameObject.transform.localScale = (weaponToSpawn.gameObject.GetComponent(Renderer).bounds.size + Vector3(0.11,0.11,0.11))
		end
	end
	
	weaponColliderGameObject.transform.localRotation = weaponToSpawn.transform.localRotation
	weaponColliderGameObject.transform.position = weaponToSpawn.transform.position
	local weaponEntryAndPosNew = {selectedWeapon,weaponToSpawn}
	table.insert(weaponsIni, weaponEntryAndPosNew)
--	print("Added " .. selectedWeapon.name .. " as y[1] and " .. weaponToSpawn.gameObject.name .. " for y[2]")
--		self.script.StartCoroutine(self:Rotate(weaponToSpawn, 11,0.021,19))
self.script.StartCoroutine(self:DestroyWithDelay(weaponToSpawn,self.script.mutator.GetConfigurationInt("despawnTime")))
end
end
function WeaponPickupALL:SpawnWeaponDistance(selectedWeapon,actor)
	return function()
		coroutine.yield(WaitForSeconds(0.21))
		local spawnPos = actor.GetHumanoidTransformRagdoll( HumanBodyBones.Chest).position + Vector3(0,0.2,0)
		local weaponToSpawn = selectedWeapon.InstantiateImposter(spawnPos, Quaternion(180,0,0,0))
		local weaponEntryAndPosNew = {selectedWeapon,weaponToSpawn}
		table.insert(weaponsIni, weaponEntryAndPosNew)
	--	print("Added " .. selectedWeapon.name .. " as y[1] and " .. weaponToSpawn.gameObject.name .. " for y[2]")
		self.script.StartCoroutine(self:Rotate(weaponToSpawn, 20,0.021,self.script.mutator.GetConfigurationInt("despawnTime") - 1))
		self.script.StartCoroutine(self:DestroyWithDelay(weaponToSpawn,self.script.mutator.GetConfigurationInt("despawnTime")))
end


end
function WeaponPickupALL:Rotate(gameObject,duration,animationSpeed,speed)
	return function()
		local t = 0
		if gameObject == nil or gameObject.transform == nil then 
		return
		end
		local yTransform = gameObject.transform.position.y
		while (t < duration) and gameObject ~= nil do
			if yTransform == nil then
			return
			end
			 t = t + Time.deltaTime
			 yTransform = gameObject.transform.position.y + 0.009 * Mathf.Sin(2*Time.time) -- This gives a nil error when destroyed even when a nil check is present, but it doesn't affect gameplay. 
			 gameObject.transform.position = Vector3(gameObject.transform.position.x,yTransform,gameObject.transform.position.z)
			 gameObject.transform.Rotate(gameObject.transform.up,(speed * 14) * Time.deltaTime)
			coroutine.yield(WaitForSeconds(animationSpeed))
			--end
		end
	end


end
function WeaponPickupALL:DestroyWithDelay(gameObject,delay)

	return function()
		coroutine.yield(WaitForSeconds(delay))
		if gameObject == nil then -- This hurts inside
			return
		end
		local destroyGO = gameObject.gameObject
		if destroyGO == nil then
			return
		end
		GameObject.Destroy(destroyGO)
		table.remove(weaponsIni, self:tablefindInTable2(weaponsIni,destroyGO))
	end

end
function WeaponPickupALL:DestroyWithDelaySimple(gameObject,delay)

	return function()
		coroutine.yield(WaitForSeconds(delay))
		if gameObject == nil then -- This hurts inside
			return
		end
		local destroyGO = gameObject.gameObject
		if destroyGO == nil then
			return
		end
		GameObject.Destroy(destroyGO)
	end

end
function WeaponPickupALL:tablefindInTable2(tab,el) -- Because Lua sucks
    for index, value in pairs(tab) do
        if value[2] == el then
            return index
        end
    end
end
function WeaponPickupALL:tablefindInTable1(tab,el) -- Because Lua sucks
    for index, value in pairs(tab) do
        if value[1] == el then
            return index
        end
    end
end
function WeaponPickupALL:tablefind(tab,el) -- Because Lua sucks
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end
function WeaponPickupALL:Update()
	if self.script.mutator.GetConfigurationDropdown("versionSelected") == 1 then
	for i,y in ipairs(weaponsIni) do
	
		if y[2].gameObject ~= nil then
		if Vector3.Distance(Player.actor.position,y[2].gameObject.transform.position) < 2 then
				local weaponApply = y[1]
				local spawnedWeaponGo = y[2]
		    	if weaponApply.slot == WeaponSlot.Primary then
				Player.actor.RemoveWeapon(0)
				Player.actor.EquipNewWeaponEntry(weaponApply, 0, true)
				print("Selected weapon in primary")
				end

				if weaponApply.slot == WeaponSlot.Secondary and not offline then
				Player.actor.RemoveWeapon(1)
				Player.actor.EquipNewWeaponEntry(weaponApply, 1, true)
				print("Selected weapon in secondary")
				end
				if weaponApply.slot == WeaponSlot.Gear and not offline then
				Player.actor.RemoveWeapon(2)
				Player.actor.EquipNewWeaponEntry(weaponApply, 2, true)
				print("Selected weapon in gear")
				end
				if weaponApply.slot == WeaponSlot.LargeGear and not offline then
				Player.actor.RemoveWeapon(3)
				Player.actor.EquipNewWeaponEntry(weaponApply, 3, true)
				print("Selected weapon in largeGear")
				end
				
				GameObject.Destroy(spawnedWeaponGo)
				table.remove(weaponsIni, self:tablefindInTable2(weaponsIni,spawnedWeaponGo))
			
				print("Ignore that error please, it's nothing serious and will be fixed")
		end
	end
	end
end
	if self.script.mutator.GetConfigurationDropdown("versionSelected") == 0 then
	if Input.GetKeyBindButtonDown(KeyBinds.Use) then
		--Overlay.ShowMessage("<color=#34abeb>Switched</color>")
		local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
		local raycast = Physics.Raycast(ray,7, RaycastTarget.Default)
		if raycast ~= nil then	-- C# raycast != null
			if string.find(raycast.transform.gameObject.name,"SpawnedWeapon") then
				local parentGO = raycast.transform.parent.gameObject
				local weaponApply
				
				for i,y in ipairs(weaponsIni) do
					if y[2].gameObject ~= nil then

							if parentGO.name == y[2].gameObject.name then
								weaponApply = y[1]
							end
					end
				end
				if weaponApply == nil then
					print("No weapon found on " .. parentGO.name)
					return
				end
				if weaponApply.slot == WeaponSlot.Primary then
						Player.actor.RemoveWeapon(0)
						Player.actor.EquipNewWeaponEntry(weaponApply, 0, true)
						print("Selected weapon in primary")
						end
			
						if weaponApply.slot == WeaponSlot.Secondary and not offline then
						Player.actor.RemoveWeapon(1)
						Player.actor.EquipNewWeaponEntry(weaponApply, 1, true)
						print("Selected weapon in secondary")
						end
						if weaponApply.slot == WeaponSlot.Gear and not offline then
						Player.actor.RemoveWeapon(2)
						Player.actor.EquipNewWeaponEntry(weaponApply, 2, true)
						print("Selected weapon in gear")
						end
						if weaponApply.slot == WeaponSlot.LargeGear and not offline then
						Player.actor.RemoveWeapon(3)
						Player.actor.EquipNewWeaponEntry(weaponApply, 3, true)
						print("Selected weapon in largeGear")
						end
						
						GameObject.Destroy(parentGO)
						table.remove(weaponsIni, self:tablefindInTable2(weaponsIni,parentGO))
			end
			
		end
		
	

		

end
end
end
