-- Register the behaviour
behaviour("LoadoutChange")

function LoadoutChange:Start()
self.canvas = self.targets.canvas
self.button = self.targets.button
self.hasLargeGear = false
self.allowLoadoutChange = false
self.Mode = self.script.mutator.GetConfigurationDropdown("versionSelected")
self.resupplyCrateRange = self.script.mutator.GetConfigurationRange("resupplyCrateRange")
self.allResupplyCrates1 = GameObject.FindObjectsOfType(ResupplyCrate)
self.allResupplyCrates = {}
for i,y in ipairs(self.allResupplyCrates1) do -- Unnecessary 
table.insert(self.allResupplyCrates, {y,false})
end

self.button.GetComponent(Button).onClick.AddListener(self,"onOverlayClicked")
self.DeployButton = GameObject.Find("Deploy Button")
self.button.GetComponent(RectTransform).SetParent(self.DeployButton.transform,false)
self.button.GetComponent(RectTransform).anchorMin = self.DeployButton.GetComponent(RectTransform).anchorMin
self.button.GetComponent(RectTransform).anchorMax = self.DeployButton.GetComponent(RectTransform).anchorMax
self.button.GetComponent(RectTransform).anchoredPosition = self.DeployButton.GetComponent(RectTransform).anchoredPosition 
self.button.GetComponent(RectTransform).sizeDelta = self.DeployButton.GetComponent(RectTransform).sizeDelta
self.button.GetComponent(RectTransform).pivot = self.DeployButton.GetComponent(RectTransform).pivot
self.button.GetComponent(RectTransform).offsetMax = self.DeployButton.GetComponent(RectTransform).offsetMax
self.button.GetComponent(RectTransform).offsetMin = self.DeployButton.GetComponent(RectTransform).offsetMin
self.button.GetComponent(RectTransform).localPosition = self.button.GetComponent(RectTransform).localPosition + Vector3(0,65,0)
self.PrimaryWeaponSelected = GameObject.Find("Primary Button").gameObject.transform.GetChild(0).gameObject.GetComponent(Text)
self.secondaryWeaponSelected = GameObject.Find("Secondary Button").gameObject.transform.GetChild(0).gameObject.GetComponent(Text)
self.Gear1WeaponSelected = GameObject.Find("Gear 1 Button").gameObject.transform.GetChild(0).gameObject.GetComponent(Text)
self.loadoutUI = GameObject.Find("Background Panel").gameObject.transform.Find("Minimap Parent")
self.DeployText = self.DeployButton.GetComponentInChildren(Text)
-- local pr = GameObject.Find("Primary Button").gameObject.transform.parent.gameObject.transform
-- for i=0,pr.childCount - 1,1 do
-- print(pr.GetChild(i).gameObject.name)
-- end
end
function LoadoutChange:onOverlayClicked()
	self.Gear2WeaponSelected = GameObject.Find("Gear 2 Button")
	if self.Gear2WeaponSelected == nil then
		self.hasLargeGear = true
		self.LargeGearWeaponSelected = GameObject.Find("Large Gear 2 Button").gameObject.transform.GetChild(0).gameObject.GetComponent(Text)
	else
		self.hasLargeGear = false
		self.Gear2WeaponSelected = GameObject.Find("Gear 2 Button").gameObject.transform.GetChild(0).gameObject.GetComponent(Text)
		self.Gear3WeaponSelected = GameObject.Find("Gear 3 Button").gameObject.transform.GetChild(0).gameObject.GetComponent(Text)
	end

	local selectedPrimary =self.PrimaryWeaponSelected.text
	-- print(selectedPrimary)
	local selectedSecondary =self.secondaryWeaponSelected.text
	-- print(selectedSecondary)
	local selectedGear1 = self.Gear1WeaponSelected.text
	-- print(selectedGear1)
	local selectedLargeGear1
	local selectedGear2 
	local selectedGear3 
	if self.hasLargeGear then
		selectedLargeGear1 = self.LargeGearWeaponSelected.text
		-- print(selectedLargeGear1)
	else
		selectedGear2 = self.Gear2WeaponSelected.text
		-- print(selectedGear2)
		selectedGear3 = self.Gear3WeaponSelected.text
		-- print(selectedGear3)
	end
	for i,y in ipairs(WeaponManager.allWeapons) do

		if y.name == selectedPrimary then
			Player.actor.EquipNewWeaponEntry(y,0,true)
		end
		if y.name == selectedSecondary then
			Player.actor.EquipNewWeaponEntry(y,1,false)
		end
		if y.name == selectedGear1 then
			Player.actor.EquipNewWeaponEntry(y,2,false)
		end
		if self.hasLargeGear then 
		if y.name == selectedLargeGear1 then
			Player.actor.EquipNewWeaponEntry(y,3,false)
			Player.actor.RemoveWeapon(4)
		end
		else
			if y.name == selectedGear2 then
			Player.actor.EquipNewWeaponEntry(y,3,false)
			end
			if y.name == selectedGear3 then
			Player.actor.EquipNewWeaponEntry(y,4,false)
			end
		end
	end
	if self.Mode == 1 then
	self.allowLoadoutChange = false
	end
	self.DeployText.text = "Respawn"
	self.button.transform.gameObject.SetActive(false)
	

end
-- Minimap Parent with parent Background Panel
-- MinimapUi.instance.minimap.rectTransform.SetParent(MinimapUi.instance.loadoutParent, false);
function LoadoutChange:Update()
	
	if self.allowLoadoutChange then
		self.button.transform.gameObject.SetActive(true)
		self.DeployText.text = "Accept new loadout"
	else
		self.button.transform.gameObject.SetActive(false)
	end
	if self.Mode == 0 then
	if not Player.actor.isDead and not Player.actor.isFallenOver and not Player.actor.isInWater and not Player.actor.isOnLadder and not Player.actor.isSeated then
		local atleastOnIsTrue = false
		for i,y in ipairs(self.allResupplyCrates) do
			
	if (Vector3.Distance(Player.actor.position,y[1].transform.position) < self.resupplyCrateRange) then
		atleastOnIsTrue = true
	end
	end
	self.allowLoadoutChange = atleastOnIsTrue
	end
else if self.Mode == 1 then
if Input.GetKey(KeyCode.LeftControl) or Input.GetKey(KeyCode.RightControl) then
if Input.GetKeyBindButtonDown(KeyBinds.OpenLoadout) then
	self.allowLoadoutChange = true
end
end
end
end
end
