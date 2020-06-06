-- Register the behaviour
behaviour("RandomWeapon")
local allWeapons
function RandomWeapon:Start()
    if self.script.mutator.GetConfigurationDropdown("selectedVersion") == 0 then
        GameEvents.onActorSpawn.AddListener(self,"ActorSpawn")
    end
    if self.script.mutator.GetConfigurationDropdown("selectedVersion") == 1 then
        GameEvents.onActorSpawn.AddListener(self,"ActorSpawnAISelected")
    end
    if self.script.mutator.GetConfigurationDropdown("selectedVersion") == 2 then
        self.script.StartCoroutine("RandomizePerMinutes")
        print("Will wait " .. tostring(self.script.mutator.GetConfigurationFloat("waitMinutes") * 60) .. " seconds")
    end

   -- GameEvents.onActorSelectedLoadout.AddListener(self,"ActorSelectLoadout")
     allGear = {}
     allBigGear = {}
     allPrimary = {}
     allSecondary = {}
    self.allWeapons = WeaponManager.allWeapons
    for index,weaponentry in ipairs(self.allWeapons) do 
        if weaponentry.slot == WeaponSlot.Primary then
            table.insert(allPrimary, weaponentry)
        end
        if weaponentry.slot == WeaponSlot.LargeGear then
            table.insert(allBigGear, weaponentry)
        end
        if weaponentry.slot == WeaponSlot.Gear then
            table.insert(allGear, weaponentry)
        end
        if weaponentry.slot == WeaponSlot.Secondary then
            table.insert(allSecondary, weaponentry)
        end
    

    end

end
function RandomWeapon:RandomizePerMinutes()
    if not Player.actor.isDead then
    Player.actor.RemoveWeapon(0)
    Player.actor.RemoveWeapon(1)
    Player.actor.RemoveWeapon(2)
    Player.actor.RemoveWeapon(3)
    Player.actor.RemoveWeapon(4)
    Player.actor.EquipNewWeaponEntry(allGear[Random.Range(1,#allGear)], 2, false)
    Player.actor.EquipNewWeaponEntry(allBigGear[Random.Range(1,#allBigGear)], 3, false)
    Player.actor.EquipNewWeaponEntry(allPrimary[Random.Range(1,#allPrimary)], 0, false)
    Player.actor.EquipNewWeaponEntry(allSecondary[Random.Range(1,#allSecondary)], 1, false)
    print("\n")
    for i,y in ipairs(Player.actor.weaponSlots) do
        print("Selected Weapon: " .. y.weaponEntry.name .. " in " .. tostring(y.weaponEntry.slot) )
    end
    coroutine.yield(WaitForSeconds(self.script.mutator.GetConfigurationFloat("waitMinutes") * 60))
    self.script.StartCoroutine("RandomizePerMinutes")
    else
        coroutine.yield(WaitForSeconds(3))
        self.script.StartCoroutine("RandomizePerMinutes")
    end

end
function RandomWeapon:Randomize(actor)

    return function()
        local aliveActors = ActorManager.GetAliveActorsOnTeam(Player.team)
        local randomActor = aliveActors[Random.Range(0,#aliveActors)]
        if #aliveActors == 0 or randomActor == nil then
            coroutine.yield(WaitForSeconds(1))
            self.script.StartCoroutine(self:Randomize(actor))
            return
        end
        local WeaponsActor = randomActor
        while randomActor == Player.actor do
            coroutine.yield(WaitForSeconds(1))
            self.script.StartCoroutine(self:Randomize(actor))
            return
        end
        if WeaponsActor == nil then
            coroutine.yield(WaitForSeconds(1))
            self.script.StartCoroutine(self:Randomize(actor))
            return
        end
        local allWeapons = WeaponsActor.weaponSlots
        for i,y in ipairs(allWeapons) do
            local weapon = y.weaponEntry
            actor.RemoveWeapon(y.slot)
            actor.EquipNewWeaponEntry(weapon, y.slot, false)
    
        end 
        print("\n")
        for i,y in ipairs(actor.weaponSlots) do
            print("Selected AI Weapon: " .. y.weaponEntry.name.. " in "  .. tostring(y.weaponEntry.slot) )
        end
    end
    end
function RandomWeapon:ActorSpawnAISelected(actor)
    if not actor.isBot then
        self.script.StartCoroutine(self:Randomize(actor))
    end
end
function RandomWeapon:ActorSpawn(actor)
    if not actor.isBot then
        actor.RemoveWeapon(0)
        actor.RemoveWeapon(1)
        actor.RemoveWeapon(2)
        actor.RemoveWeapon(3)
        actor.RemoveWeapon(4)
        actor.EquipNewWeaponEntry(allPrimary[Random.Range(1,#allPrimary)], 0, false)
        actor.EquipNewWeaponEntry(allSecondary[Random.Range(1,#allSecondary)], 1, false)
        actor.EquipNewWeaponEntry(allGear[Random.Range(1,#allGear)], 2, false)
        actor.EquipNewWeaponEntry(allBigGear[Random.Range(1,#allBigGear)], 3, false)
        print("\n")
        for i,y in ipairs(actor.weaponSlots) do
        print("Selected Weapon: " .. y.weaponEntry.name.. " in "  .. tostring(y.weaponEntry.slot) )
        end
    end
end
function RandomWeapon:ActorSelectLoadout(actor,loadout,strategy)
--     if not actor.isBot then

-- loadout.primary = allPrimary[Random.Range(1,#allPrimary)]
-- loadout.secondary = allSecondary[Random.Range(1,#allSecondary)]
-- loadout.gear3 = allGear[Random.Range(1,#allGear)]
-- loadout.gear2 = allGear[Random.Range(1,#allGear)]
-- loadout.gear1 =allGear[Random.Range(1,#allGear)]
-- print("Set random loadout")
--     end
end


function RandomWeapon:Update()
		
end
