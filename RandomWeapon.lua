-- Register the behaviour
behaviour("RandomWeapon")
local allWeapons
function RandomWeapon:Start()
    GameEvents.onActorSelectedLoadout.AddListener(self,"ActorSelectLoadout")
    GameEvents.onActorSpawn.AddListener(self,"ActorSpawn")
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
