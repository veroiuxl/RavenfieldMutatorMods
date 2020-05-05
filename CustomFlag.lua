-- Register the behaviour
-- If you use this in a mod just give me credit somewhere
-- This is currently really messy, because there is no event for checking if a player is capturing a flag
behaviour("CustomFlag")
local customFlagMat

local customFlagMatBlue
local customFlagMatNeutral
local customFlagMatRed

local setFlag = false
function CustomFlag:Start()
	
	-- customFlagMatBlue = self.targets.customFlagBlueTeam
	-- customFlagMatNeutral = self.targets.customFlagNeutral
	-- customFlagMatRed = self.targets.customFlagRedTeam
	customFlagMatBlue = GameObject.Find("CustomFlagBlue")
	customFlagMatRed = GameObject.Find("CustomFlagRed")
	customFlagMatNeutral = GameObject.Find("CustomFlagNeutral")
	local testSpawnPoint = ActorManager.RandomSpawnPoint()
	if testSpawnPoint.gameObject.Find("Simulated Flag") == nil then
		print("<color=red>Enable Cloth Physics to use Custom Flags!</color>")
		return
	end
	if customFlagMatBlue == nil then
		print("<color=yellow>CustomFlagMatBlue not found. Make sure your GameObject is named \"CustomFlagBlue\"</color>")
		customFlagMatBlue = self.targets.customFlagBlueTeam
	else
		customFlagMatBlue = customFlagMatBlue.GetComponent(SkinnedMeshRenderer).material
	end
	if customFlagMatRed == nil then
		print("<color=yellow>CustomFlagMatRed not found. Make sure your GameObject is named \"CustomFlagRed\"</color>")
		customFlagMatRed = self.targets.customFlagRedTeam
	else
		customFlagMatRed = customFlagMatRed.GetComponent(SkinnedMeshRenderer).material
	end
	
	if customFlagMatNeutral == nil then
		print("<color=yellow>CustomFlagMatNeutral not found. Make sure your GameObject is named \"CustomFlagNeutral\"</color>")
		customFlagMatNeutral = self.targets.customFlagNeutral
	else
		customFlagMatNeutral = customFlagMatNeutral.GetComponent(SkinnedMeshRenderer).material
	end
	self.script.StartCoroutine("SetFlagCurrent")
	self.script.StartCoroutine("SetDefaultFlag")
	GameEvents.onCapturePointCaptured.AddListener(self, "OnFlagCapture")
	GameEvents.onCapturePointNeutralized.AddListener(self,"OnFlagNeutralized")
	print("<color=#32c904>Replaced flag texture!</color>")
	
end
function CustomFlag:SetDefaultFlag()

	local sps = ActorManager.spawnPoints
	if sps == nil then
		print("<color=red>Flags not found</color>")
		
	else
		for i= 1, #sps, 1 do
			local cp = sps[i].capturePoint.defaultOwner
			local SkinnedMeshRFlag = sps[i].gameObject.GetComponentInChildren(SkinnedMeshRenderer)
			
			if cp == Team.Blue then
			    local tempArray = {} -- Probably don't need this
				table.insert(tempArray, customFlagMatBlue) -- Probably don't need this
				
				SkinnedMeshRFlag.materials = tempArray
			else if cp == Team.Red then
				local tempArray = {} 
				table.insert(tempArray, customFlagMatRed) 
				SkinnedMeshRFlag.materials = tempArray
			else if cp == Team.Neutral then
				local tempArray = {} 
				table.insert(tempArray, customFlagMatNeutral) 
				SkinnedMeshRFlag.materials = tempArray
			
			end
			end
			end
		end
	end
	print("Set flag materials")
end
function CustomFlag:OnFlagCapture(capturePoint, newOwner)
	self.script.StartCoroutine(self:SetFlagCaptured(capturePoint, newOwner))
end
function CustomFlag:OnFlagNeutralized(capturePoint, previousOwner)
	self.script.StartCoroutine(self:SetFlagNeutralized(capturePoint, previousOwner))
end


function CustomFlag:SetFlagNeutralized(capturePoint, previousOwner)
	return function()

			
			local cp = capturePoint.owner
			if cp == Team.Blue then
			    local tempArray = {} -- Probably don't need this
				table.insert(tempArray, customFlagMatBlue) -- Probably don't need this
				local SkinnedMeshRFlag = capturePoint.gameObject.GetComponentInChildren(SkinnedMeshRenderer)
				SkinnedMeshRFlag.materials = tempArray
			else if cp == Team.Red then
				local tempArray = {} 
				table.insert(tempArray, customFlagMatRed) 
				local SkinnedMeshRFlag = capturePoint.gameObject.GetComponentInChildren(SkinnedMeshRenderer)
				SkinnedMeshRFlag.materials = tempArray
			else if cp == Team.Neutral then
				local tempArray = {} 
				table.insert(tempArray, customFlagMatNeutral) 
				local SkinnedMeshRFlag = capturePoint.gameObject.GetComponentInChildren(SkinnedMeshRenderer)
				SkinnedMeshRFlag.materials = tempArray
			
			end
		end
	end
end

end
function CustomFlag:SetFlagCaptured(capturePoint,newOwner)
	return function()

			
		local cp = capturePoint.owner
		local SkinnedMeshRFlag = capturePoint.gameObject.GetComponentInChildren(SkinnedMeshRenderer)
		if cp == Team.Blue then
			local tempArray = {} -- Probably don't need this
			table.insert(tempArray, customFlagMatBlue) -- Probably don't need this
			SkinnedMeshRFlag.materials = tempArray
		else if cp == Team.Red then
			local tempArray = {} 
			table.insert(tempArray, customFlagMatRed) 
			SkinnedMeshRFlag.materials = tempArray
		else if cp == Team.Neutral then
			local tempArray = {} 
			table.insert(tempArray, customFlagMatNeutral) 
			SkinnedMeshRFlag.materials = tempArray
		
		end
	end
end
	print("Captured point " .. capturePoint.name)
	end

end

function CustomFlag:SetFlagCurrent()
	-- It's 2 because I don't want to impact performance, but also want the flag to be overridden by the new mat so the user doesn't see the colored flag often
	coroutine.yield(WaitForSeconds(2)) 
	
	local sps = ActorManager.spawnPoints
	if sps == nil then
		print("<color=red>Flags not found</color>")
		
	else
		for i= 1, #sps, 1 do
			local cp = sps[i].capturePoint.owner
			local SkinnedMeshRFlag = sps[i].gameObject.GetComponentInChildren(SkinnedMeshRenderer)
			if cp == Team.Blue then
			    local tempArray = {}
				table.insert(tempArray, customFlagMatBlue) 
				SkinnedMeshRFlag.materials = tempArray
			else if cp == Team.Red then
				local tempArray = {} 
				table.insert(tempArray, customFlagMatRed) 
				SkinnedMeshRFlag.materials = tempArray
			else if cp == Team.Neutral then
				local tempArray = {} 
				table.insert(tempArray, customFlagMatNeutral) 
				SkinnedMeshRFlag.materials = tempArray
			
			end
			end
			end
		end
	end
	self.script.StartCoroutine("SetFlagCurrent")
end
function CustomFlag:Update()
	
end
