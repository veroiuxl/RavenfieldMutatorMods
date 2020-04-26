-- Register the behaviour
behaviour("DeathEffect") -- Thanks https://gist.github.com/nevarman/f8de7de3bd3a0e4bd9196d3504ef530c for the shader
--[[
This is a bit messy and has a few problems.
Problem #1: Because of only changing the mat in the array, every killed actor will have the same "_Cutoff" progress. 
That means if you kill one actor, it will reset to 0.321 and all dead ragdoll actors will also have the mat applied and therefore be visible.   

]]--
local gotDefault = false
local oldMat
local reddissolveMat
local bluedissolveMat
local bluedefault
local isDissolving
local reddefault
local reddefaultArray = {}
local bluedefaultArray = {}
local scriptvar
local curMatIndex
local matArray = {}
function DeathEffect:Start()
	-- Run when behaviour is created
	reddissolveMat = self.targets.dissolveRed
	bluedissolveMat = self.targets.dissolveBlue
	bluedefault = self.targets.defaultBlue
	reddefault = self.targets.defaultRed
	table.insert(bluedefaultArray,bluedefault)
	table.insert(reddefaultArray,reddefault)
	scriptvar = self.script
	GameEvents.onActorDied.AddListener(self, "OnActorDied")
	GameEvents.onActorSpawn.AddListener(self,"OnActorSpawn")
end
	function printColor(input,Color)
	print("<color=" .. tostring(Color) .. ">" .. tostring(input) .. "</color>")
	end
function DeathEffect:Dissolve(matInUse,actor)
	
	return function()
		
	local matIndex
		for k,v in pairs(matArray) do
		
			matIndex = k
			printColor("index[" .. tostring(k) .. "]=" .. tostring(v) ,"orange")
		end
	local tempArray = {}
	table.insert(tempArray,matArray[matIndex])
	printColor("Dissolving " .. actor.name)
	--actor.SetSkin(nil,tempArray,1) -- matArray is the blue/red dissolve material, because SetSkin only takes an array
	--printColor("MatArrayIndex is " .. tostring(matArray[matIndex]),"yellow")
	for i= 0.321, 0.744, 0.0012 do
		
		matArray[matIndex].SetFloat( "_Cutoff", i)
	--	print(tostring(Targetmaterial.GetFloat( "_Cutoff")))
		actor.SetSkin(nil,tempArray,1)
		coroutine.yield(WaitForSeconds(0.015))
	end
	curMatIndex = matIndex
	coroutine.yield(WaitForSeconds(7))
	matArray[matIndex].SetFloat( "_Cutoff", 0)
	printColor("Removed mat from array")
end


end

function DeathEffect:OnActorSpawn(actor)
	if actor.team == Team.Blue then

		actor.SetSkin(nil,bluedefaultArray,1)

	else
		actor.SetSkin(nil,reddefaultArray,1)
	end


end
function DeathEffect:OnActorDied(actor, killer, isSilentKill)
	
	if killer ~= nil and killer.name == Player.actor.name then
		local matInUse
		if actor.team == Team.Blue then
			
			matInUse = bluedissolveMat
			
			printColor("Applied blue material to " .. tostring(actor.name))
		else
			matInUse = reddissolveMat
			printColor("Applied red material to " .. tostring(actor.name))
		end
		 table.insert(matArray,matInUse)
		
		actor.SetSkin(nil,matArray,1)
		local coroutineS = scriptvar.StartCoroutine(self:Dissolve(matInUse,actor))
    end
end

function DeathEffect:Update()
end
