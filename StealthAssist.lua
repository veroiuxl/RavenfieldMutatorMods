-- Register the behaviour
behaviour("StealthAssist")

function StealthAssist:Start()

		self.affectedBots = {}
		self.meshRendererBlue = self:GetRandomBotInTeam(Team.Blue).aiController.gameObject.transform.Find("Soldier/Soldier").gameObject.GetComponent(SkinnedMeshRenderer)
		self.meshRendererRed = self:GetRandomBotInTeam(Team.Red).aiController.gameObject.transform.Find("Soldier/Soldier").gameObject.GetComponent(SkinnedMeshRenderer)
		self.allSkinMatBlue = self.meshRendererBlue.material
		self.allSkinMatRed = self.meshRendererRed.material
		self.materialOutlineRed = self.targets.outlineRed
		if(Player.enemyTeam == Team.Blue) then
		self.materialOutlineRed.mainTexture = self.allSkinMatBlue.mainTexture
		else
		self.materialOutlineRed.mainTexture = self.allSkinMatRed.mainTexture
		end
		-- local self.customColor = ColorScheme.GetTeamColor(Player.enemyTeam)
		self.customColor = ColorScheme.GetTeamColor(Player.enemyTeam)

		if(self.script.mutator.GetConfigurationBool("isUsingCustomColor")) then
			local hexColorString = self.script.mutator.GetConfigurationString("customColorHex")
			if(self:stringstartswith(hexColorString)) then
				local hexRGBRed = self:hex2rgb(hexColorString)
				self.customColor = Color(hexRGBRed[1] ,hexRGBRed[2],hexRGBRed[3],0)
			end
		end
		self.customColor.a = 0
		self.startFov = PlayerCamera.activeCamera.main.fieldOfView
		self.maxFov = PlayerCamera.activeCamera.main.fieldOfView + 10
		self.materialOutlineRed.SetColor("_OutlineColor",self.customColor)
		-- self.enemyOnly = self.script.mutator.GetConfigurationBool("enemyOnly")
		self.stealthModeEnabled = false
		self.speedMultiplier = self.script.mutator.GetConfigurationRange("speedMultiplier")
		self.stealthMaxDuration = self.script.mutator.GetConfigurationRange("stealthMaxduration")
		self.defaultSpeed = Player.actor.speedMultiplier
		self.text = self.targets.text.GetComponent(Text)
		self.animator = self.targets.animator
		self.animator.SetBool("FadeIn",false)
		self.timerIsRunning = false
		self.timeRemaining = self.stealthMaxDuration
		self.targetSpeed = Player.actor.speedMultiplier * self.speedMultiplier * 0.9
		self.audio = self.gameObject.GetComponent(AudioSource)
		-- self.filter = MeanFilter(32)
		self.audioBars = {}
		-- Footsteps Sound Sources
		self.defaultFootStepsSoundVolume = {}
		self.footstepAudioSources = {}
		-- for i,y in ipairs(self.footStepsSoundSources.GetComponentsInChildren(AudioSource)) do
		-- 	table.insert(self.defaultFootStepsSoundVolume, y.volume)
		-- 	table.insert(self.footstepAudioSources, y)
		-- end
		self.isCrouching = 0
		self.currentWeaponAudio = nil
		
		self.currentTargetObj = nil
		self.handTransform1 = nil
		self.handTransform2 = nil
		self.isDragging = false
		self.visionOccluder = GameObject.Instantiate(self.targets.visionOccluderPrefab)
		self.visionOccluder.gameObject.SetActive(false)
		self.visionOccluderBack = GameObject.Instantiate(self.targets.visionOccluderPrefab)
		self.visionOccluderBack.gameObject.SetActive(false)
		self.visionOccluderRight = GameObject.Instantiate(self.targets.visionOccluderPrefab)
		self.visionOccluderRight.gameObject.SetActive(false)
		self.visionOccluderLeft = GameObject.Instantiate(self.targets.visionOccluderPrefab)
		self.visionOccluderLeft.gameObject.SetActive(false)
		self.visionOccluderUp = GameObject.Instantiate(self.targets.visionOccluderPrefab)
		self.visionOccluderUp.gameObject.SetActive(false)
		self.setCurrentWaterComponent = 0

		self.waterRaycastVec = Vector3(0,0,0)
		self.targetSwimSpeed = 2
		self.playerSwimming = 0
		self.isDiving = false
		self.vignette = self.targets.vignetteImage.GetComponent(Image)
		self:SetVignetteAlpha(0,0)

		self.sliderAnimator = self.targets.DurationSlider.GetComponent(Animator)
		self.DurationSlider = self.targets.DurationSlider.GetComponent(Slider)
		self.DurationSlider.minValue = 0
		self.DurationSlider.maxValue = self.stealthMaxDuration
		self.durationText = self.targets.DurationText.GetComponent(Text)
		self.sliderIsEmpty = false
		self.sliderImage = self.DurationSlider.gameObject.transform.GetChild(1).gameObject.GetComponentInChildren(Image)
		self.SlideremptyColor = Color(197 / 255,197 / 255,197 / 255,0.9) 
		self.SliderNormalColor = Color.white
		self.startregenDurationTimer = 4
		self.startregenTimerRunning = false
		self.isRegeneratingDuration = false
		self.shouldRegenAndNotCrouching = false
		self.lastTimerStop = Time.time
		self.lastCrouchedTimeRemaining = 4
		self.lastCrouchTimerRunning = false
		self.isRegeneratingBecauseOfCrouchTimer = false

		self.normalRegenSpeed = 5
		self.diveDepth = 2

		self.isProning = 0
		self.spotMethod = self.script.mutator.GetConfigurationDropdown("spotMethod")
		self.spotLimit = 5

		self.spottedTime = self.script.mutator.GetConfigurationRange("spottedTime")
		self.SpotCooldownSlider = self.targets.SpotCooldownSlider.GetComponent(Slider)
		self.spotAnimator = self.targets.SpotCooldownSlider.GetComponent(Animator)
		self.SpotCooldownSlider.minValue = 0
		self.SpotCooldownSlider.maxValue = self.spottedTime + 3
		self.SpotText = self.targets.SpotCooldownText.GetComponent(Text)
		self.spotTimerStart = false
		self.spotTimerValue = self.spottedTime + 3
		GameEvents.onActorDied.AddListener(self,"onActorDied")
		self:SetSpotSliderValue(self.spotTimerValue,tostring(self.spotTimerValue))
		self.audioSource = self.targets.spotStealthSFX
		self.spottingKeybindInde = self.script.mutator.GetConfigurationDropdown("spottingKeybind")
		self.spotKeybind = KeyCode.F
		if(self.spottingKeybindInde == 1) then
			self.spotKeybind = KeyCode.T
		elseif self.spottingKeybindInde == 2 then
			self.spotKeybind = KeyCode.X
		end
end
local ERandom = {
	RangeInt = function(min, max)
	return Mathf.RoundToInt(Random.Range(min, max))
end
}
end
function StealthAssist:onActorDied(actor,source,isSilent)
if(actor == Player.actor) then
	self.sliderAnimator.SetBool("extended",false)
	self.spotTimerStart = false
	self.spotTimerValue = self.spottedTime + 3
	self:SetSpotSliderValue(self.spotTimerValue,self.spottedTime + 3)
end


end
function StealthAssist:SetVignetteAlpha(alpha,duration)
	self.vignette.CrossFadeAlpha(alpha, duration, false)
end
function StealthAssist:SetSpotSliderValue(value,valueText)
	self.SpotCooldownSlider.value = value
	self.SpotText.text = tostring(valueText)
end
function StealthAssist:SetSliderValue(value,valueText)
	self.DurationSlider.value = value
	self.durationText.text = tostring(valueText)
end
function StealthAssist:hex2rgb(hex)
	hex = hex:gsub("#","")
	local r = tonumber("0x"..hex:sub(1,2),16)
	local g = tonumber("0x"..hex:sub(3,4),16)
	local b = tonumber("0x"..hex:sub(5,6),16)
	if(r ~= 0) then
		r = r / 255
	end
	if(g ~= 0) then
		g = g / 255
	end
	if(b ~= 0) then
		b = b / 255
	end
	self:DebugPrint(string.format("R %s G %s B %s",r,g,b))
	return {r,g,b}
end
function StealthAssist:stringstartswith(str)
	return str:sub(1, 1) == "#"
end
function StealthAssist:starts_with(str, start)
	return str:sub(1, #start) == start
end
function StealthAssist:AnimateOpacityIn(material)
	-- for i = PlayerCamera.activeCamera.main.fieldOfView, self.maxFov,0.25 do
	-- 	PlayerCamera.activeCamera.main.fieldOfView = i
	-- 	self.fovLabel.text = tostring(i)
	-- end
return function()
	self:DebugPrint("AnimateOpacityIn")
	local color2 = self.customColor
	for i = 0, 1,0.003 do 
		color2.a = i
		material.SetColor("_OutlineColor",color2)
		coroutine.yield(WaitForSeconds(0.0009))
	end
end

end

function StealthAssist:AnimateOpacityOut(material,bot)
return function()
	local color1 = self.customColor
	for i = 1, 0,-0.009 do 
		color1.a = i
		material.SetColor("_OutlineColor",color1)
		coroutine.yield(WaitForSeconds(0.0003))
	end
	self:RemoveOutline(bot)
end
end
function StealthAssist:GetRandomBotInTeam(team)
local botsonteam = {}
for i,y in ipairs(ActorManager.GetActorsOnTeam(team)) do
	if(y.isBot) then
	table.insert(botsonteam, y)
	end
end
local botCount = ActorManager.GetNumberOfBotsInTeam(team)
if(botCount == 0) then
	self:DebugPrint("You are not playing with any bots in team " .. tostring(team))
	return ActorManager.actors[2]
end
return botsonteam[ERandom.RangeInt(1,ActorManager.GetNumberOfBotsInTeam(team))]
end

function StealthAssist:contains(table, element)
	for _, value in pairs(table) do
	  if value == element then
		return true
	  end
	end
	return false
end
function StealthAssist:AddOutline(bot)
return function()
	self:DebugPrint("Added " .. bot.name)
	bot.SetSkin(nil, {self.materialOutlineRed},1)
	local material = bot.aiController.gameObject.transform.GetChild(0).gameObject.transform.GetChild(1).gameObject.GetComponent(SkinnedMeshRenderer).material
	table.insert(self.affectedBots, bot)
	self.script.StartCoroutine(self:AnimateOpacityIn(material))
	coroutine.yield(WaitForSeconds(self.spottedTime))
	self.script.StartCoroutine(self:AnimateOpacityOut(material,bot))
	end
end
function StealthAssist:tablefind(tab,el) 
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

function StealthAssist:RemoveOutline(bot)
	bot.ApplyTeamSkin()
	table.remove(self.affectedBots,self:tablefind(self.affectedBots,bot))
	self:DebugPrint("Botname " .. bot.name)
end


function StealthAssist:GetClosestEnemy()
	local enemys = {}
	for i,y in ipairs(ActorManager.AliveActorsInRange(Player.actor.position, 700)) do
		if(y.isBot) then -- and y.team == Player.enemyTeam
			table.insert(enemys, y)
		end
		local closestBot
	end
	local minDist = Mathf.Infinity
	local currentPos = Player.actor.position

	for index,enemy in ipairs(enemys) do
	local distance = Vector3.Distance(enemy.position,currentPos)
		if(distance < minDist) then
			closestBot = enemy
			minDist = distance
		end
	end

	for k in ipairs(enemys) do
		enemys[k] = nil
	end

	return closestBot
end
function StealthAssist:GetCenterPosition(actor)
	local retV
	if(actor.isFallenOver) then
		retV = actor.GetHumanoidTransformRagdoll(HumanBodyBones.Spine)
		else
		retV = actor.GetHumanoidTransformAnimated(HumanBodyBones.Spine)
	end
	return retV.position
end
function StealthAssist:FindParentWithName(childObject,name)
   local t = childObject.transform;
   while t.parent ~= nil do
	if (t.parent.transform.name == name) then
		return t.parent.gameObject;
	end
	-- print(t.gameObject.name .. " does not equal " .. name)
	t = t.parent.transform
	end
   return nil
end
function StealthAssist:DebugPrint(message)
	if(Debug.isTestMode) then
		print("<color=#c47910>" .. message .. "</color>")
	end
end
function StealthAssist:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function StealthAssist:ToggleStealth(value)
	self.visionOccluder.gameObject.SetActive(value)
	self.visionOccluderBack.gameObject.SetActive(value)
	self.visionOccluderRight.gameObject.SetActive(value)
	self.visionOccluderLeft.gameObject.SetActive(value)
	self.visionOccluderUp.gameObject.SetActive(value)
	if(value == true) then
		self:SetVignetteAlpha(1,0.5)
		self.timerIsRunning = true
	else
		self.timerIsRunning = false
		self:SetVignetteAlpha(0,1)
	end
end
function StealthAssist:GetClosestActor(ActorsInRange,point) 
	local bestTarget = null;
	local closestDistanceSqr = Mathf.Infinity;
	local currentPosition = point
	for i,potentialTarget in ipairs(ActorsInRange) do
		local directionToTarget = potentialTarget.transform.position - currentPosition
		local dSqrToTarget = directionToTarget.sqrMagnitude
		if dSqrToTarget < closestDistanceSqr then
				closestDistanceSqr = dSqrToTarget;
				bestTarget = potentialTarget;
		end
	end
	return bestTarget
end
function StealthAssist:Square(value)
	return value * value
end
function StealthAssist:Update()
	

	if(Debug.isTestMode) then
		if Input.GetKeyDown(KeyCode.T) then
			local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward, PlayerCamera.activeCamera.main.transform.forward)
		    local raycast = Physics.Raycast(ray,2000, RaycastTarget.ProjectileHit)
			if raycast ~= nil then	
				Player.actor.transform.parent.position = raycast.point - PlayerCamera.activeCamera.main.transform.forward
			end
	end
	end
	if(Input.GetKeyDown(self.spotKeybind) ) then
		if(self.spotMethod == 1) then
			if(not self.spotTimerStart) then
				self.script.StartCoroutine("SpotFOV")
			end
		else
			self:SpotDirect()
		end
	end
	
	if(self.timerIsRunning) then
		if(self.visionOccluder ~= nil and PlayerCamera.activeCamera.main ~= nil) then
			Player.actor.speedMultiplier = Mathf.Lerp(Player.actor.speedMultiplier,self.targetSpeed,Time.deltaTime * 0.6) 
			self.visionOccluder.transform.position = PlayerCamera.activeCamera.main.transform.position + self.visionOccluder.transform.forward * 1.8
			self.visionOccluder.transform.rotation = PlayerCamera.activeCamera.main.transform.rotation		

			self.visionOccluderBack.transform.rotation = PlayerCamera.activeCamera.main.transform.rotation
			self.visionOccluderBack.transform.position = PlayerCamera.activeCamera.main.transform.position + self.visionOccluder.transform.forward * -1.8
			self.visionOccluderRight.transform.position = PlayerCamera.activeCamera.main.transform.position + self.visionOccluder.transform.right * 1.8
			self.visionOccluderRight.transform.rotation = PlayerCamera.activeCamera.main.transform.rotation
			self.visionOccluderLeft.transform.position = PlayerCamera.activeCamera.main.transform.position + self.visionOccluder.transform.right * -1.8
			self.visionOccluderLeft.transform.rotation = PlayerCamera.activeCamera.main.transform.rotation
			self.visionOccluderUp.transform.position = PlayerCamera.activeCamera.main.transform.position + self.visionOccluder.transform.up * 1.8
			self.visionOccluderUp.transform.rotation = PlayerCamera.activeCamera.main.transform.rotation
		end
	end
	if(Player.actor ~= nil and not Player.actor.isDead ) then
		if(self.spotTimerStart) then
			if (self.spotTimerValue > 0) then
				self.spotTimerValue = self.spotTimerValue - Time.deltaTime
				local secondsleft = Mathf.FloorToInt((self.spotTimerValue) % 60)
				self:SetSpotSliderValue(self.spotTimerValue,secondsleft)
			else
				self.spotTimerStart = false 
				self.spotAnimator.SetBool("extended",false)
				self.script.StartCoroutine("RefillSpot")
			end
		end
		if (self.timerIsRunning) then
			if (self.timeRemaining > 0) then
				self.timeRemaining = self.timeRemaining - Time.deltaTime
				local secondsleft = Mathf.FloorToInt((self.timeRemaining) % 60)
				self:SetSliderValue(self.timeRemaining,secondsleft)
				self.sliderIsEmpty = false
	
			else
				self.timeRemaining = 0
				self.sliderIsEmpty = true
				self.text.color = Color.red
				self:SetSliderValue(0,"")
				self.timerIsRunning = false
				self:ToggleStealth(false)
				-- self.sliderAnimator.SetBool("extended",false)
				self.sliderImage.CrossFadeColor(self.SlideremptyColor,2,false,true)
				self:DebugPrint("Timer ran out startRegenTimerRunning = true")
				self.startregenDurationTimer = 4
				self.startregenTimerRunning = true
			end
		end

		if(self.startregenTimerRunning and not Player.actor.isCrouching) then
			if (self.startregenDurationTimer > 0) then
				self.startregenDurationTimer = self.startregenDurationTimer - Time.deltaTime
				self.isRegeneratingDuration = false
			else
				self:DebugPrint("self.isRegeneratingDuration = true")
				self.isRegeneratingDuration = true 
				self.sliderAnimator.SetBool("extended",true)
				self.startregenTimerRunning = false
				self.lastTimerStop = Time.time
			end
		end
		if(self.lastCrouchTimerRunning and not self.startregenTimerRunning) then
			if (self.lastCrouchedTimeRemaining >= 0 ) then
				self.lastCrouchedTimeRemaining = self.lastCrouchedTimeRemaining - Time.deltaTime
				-- self:DebugPrint("CrouchedTimeRemaining " .. tostring(self.lastCrouchedTimeRemaining))
				self.isRegeneratingBecauseOfCrouchTimer = false
			else
				self:DebugPrint("self.isRegeneratingBecauseOfCrouchTimer = true")
				self.isRegeneratingBecauseOfCrouchTimer = true 
				self.sliderAnimator.SetBool("extended",true)
				self.lastCrouchTimerRunning = false
				self.lastTimerStop = Time.time
			end
		end
		-- If you crouch while the duration slider is depleted it will still enable the isRegeneratingDuration 
		if(self.isRegeneratingBecauseOfCrouchTimer and not self.isRegeneratingDuration and not Player.actor.isCrouching) then
			self.exp = self:Square((Time.time - self.lastTimerStop) / 6)
			self.startregenDurationTimer = Mathf.Lerp(self.startregenDurationTimer,self.stealthMaxDuration,self.exp)
			self.timeRemaining = Mathf.Lerp(self.timeRemaining,self.stealthMaxDuration,self.exp)
			local secondsleft = Mathf.FloorToInt((self.timeRemaining) % 60)
			self:DebugPrint(tostring(secondsleft))
			self:SetSliderValue(self.timeRemaining,secondsleft)
			self.sliderIsEmpty = false
			-- self:DebugPrint("Should retract " .. tostring(self.timeRemaining >= self.stealthMaxDuration - (self.stealthMaxDuration * 0.15)))
			if(self.timeRemaining >= self.stealthMaxDuration - (self.stealthMaxDuration * 0.15)) then
				self.sliderAnimator.SetBool("extended",false)
			end
		end
		if( self.isRegeneratingDuration and not self.isRegeneratingBecauseOfCrouchTimer and not Player.actor.isCrouching) then
			self.exp = self:Square((Time.time - self.lastTimerStop) / 6)
			self.timeRemaining = Mathf.Lerp(self.timeRemaining,self.stealthMaxDuration,self.exp)
			local secondsleft = Mathf.FloorToInt((self.timeRemaining) % 60)
			self:SetSliderValue(self.timeRemaining,secondsleft)
			self.sliderIsEmpty = false
			if(self.timeRemaining >= self.stealthMaxDuration - (self.stealthMaxDuration * 0.15)) then
				self.sliderAnimator.SetBool("extended",false)
			end
		end


		if(Player.actor.isCrouching and not Player.actor.isDead) then
			if(self.isCrouching == 0) then
				if(not self.sliderIsEmpty) then
					self.timerIsRunning = true
					self:ToggleStealth(true)
					self.sliderAnimator.SetBool("extended",true)
					self:DebugPrint("Crouching")
					self.sliderImage.CrossFadeColor(self.SliderNormalColor,2,false,true)
					self.isRegeneratingBecauseOfCrouchTimer = false
					self.isRegeneratingDuration = false
					self.shouldRegenAndNotCrouching = false
					self.lastCrouchedTimeRemaining = self.normalRegenSpeed
					self.lastCrouchTimerRunning = false
				end
				self.isCrouching = 1
			end
		else
			if(self.isCrouching == 1) then
				self:ToggleStealth(false)
				Player.actor.speedMultiplier = self.defaultSpeed
				self.sliderAnimator.SetBool("extended",false)
				self.timerIsRunning = false
				self:DebugPrint("Not crouching")
				self.isCrouching = 0
				if(self.sliderIsEmpty) then
					self.shouldRegenAndNotCrouching = true
					self.startregenTimerRunning = true
					self.sliderImage.CrossFadeColor(self.SlideremptyColor,2,false,true)
				else
					self.lastCrouchTimerRunning = true
				end
		end

			if(Player.actor.isSwimming and not Player.actor.isDead) then
				if(self.playerSwimming == 0) then
					self:DebugPrint("Swimming")
					
					self.playerSwimming = 1
				end
				if(Input.GetKeyBindButton(KeyBinds.Sprint)) then
					-- if(Water.IsInWater(self:GetCenterPosition(Player.actor))) then
						local raycast = Water.Raycast(Ray(Player.actor.transform.parent.transform.position + Vector3(0,2,0) ,-Player.actor.transform.parent.transform.up), 5)
						-- Debug.DrawRay(Player.actor.transform.parent.transform.position + Vector3(0,1,0), -Player.actor.transform.parent.transform.up, Color.red,2)
						if(raycast ~= nil) then
							if(self.setCurrentWaterComponent == 0) then
								self:DebugPrint("Got currentWaterComponent")
								self.waterRaycastVec = raycast.point
								self.setCurrentWaterComponent = 1
							elseif(self.setCurrentWaterComponent == 1) then
								if(self.waterRaycastVec.y ~= raycast.point.y) then
									self:DebugPrint("Changed water")
									self.setCurrentWaterComponent = 0
								end
							end
						else
							self.isDiving = false
						end
						if(self.setCurrentWaterComponent == 1) then
							self.isDiving = true
							self.targetSwimSpeed = 10
							self:ToggleStealth(true)
							Player.actor.transform.parent.position = Vector3.Lerp(Player.actor.transform.parent.position,Vector3(Player.actor.transform.parent.position.x,self.waterRaycastVec.y - self.diveDepth,Player.actor.transform.parent.position.z),Time.deltaTime * 6)
						end
				else
					self.isDiving = false
					self:ToggleStealth(false)
					self.targetSwimSpeed = self.defaultSpeed
				
				end
				Player.actor.speedMultiplier = Mathf.Lerp(Player.actor.speedMultiplier,self.targetSwimSpeed,Time.deltaTime * 1.2) 
			else
				if(self.playerSwimming == 1) then
					self:ToggleStealth(false)
					self.isDiving = false
					Player.actor.speedMultiplier = self.defaultSpeed
					self:DebugPrint("Not swimming")
					self.playerSwimming = 0
				end
			end
		end

		if(Player.actor.isProne and not Player.actor.isDead) then
			if(self.isProning == 0) then
				self:ToggleStealth(true)
				self:DebugPrint("Prone")
				self.sliderImage.CrossFadeColor(self.SliderNormalColor,2,false,true)
				self.isProning = 1
			end
		else
			if(self.isProning == 1) then
				self:ToggleStealth(false)
				Player.actor.speedMultiplier = self.defaultSpeed
				self:DebugPrint("Not proning")
				self.isProning = 0
			elseif self.isProning == 1 and self.isCrouching == 1 then -- Doesn't really work
				self:DebugPrint("Not proning (but crouching)")
				self.isProning = 0
			end
		end

		

	end
	self:DragBody()
end
function StealthAssist:RefillSpot()
	coroutine.yield(WaitForSeconds(0.3))
	self.spotTimerValue = self.spottedTime + 3
end
function StealthAssist:SpotDirect()
		for i=1,2,1 do
			local ray = Ray(PlayerCamera.activeCamera.main.transform.position,PlayerCamera.activeCamera.main.transform.forward)
			local raycast = Physics.Raycast(ray,6500,RaycastTarget.ProjectileHit)
			
			if(raycast ~= nil) then
				local actor = self:GetClosestActor(ActorManager.AliveActorsInRange(raycast.point,4),raycast.point)
				if(actor ~= nil) then
					if(not self:contains(self.affectedBots,actor) and actor.team == Player.enemyTeam) then
						if(self:starts_with(actor.name,"Lt.")) then
							for i,y in ipairs(ActorManager.ActorsInRange(actor.position,50)) do
								if(y.isBot and y.team == Player.enemyTeam) then
										self.audioSource.pitch = Random.Range(0.9,1.2)
										self.audioSource.PlayClipAtPoint(self.audioSource.clip,Player.actor.position,1)
										self.script.StartCoroutine(self:AddOutline(y))
									return
								end
							end
							else
								self.audioSource.pitch = Random.Range(0.9,1.2)
								self.audioSource.PlayClipAtPoint(self.audioSource.clip,Player.actor.position,1)
								self.script.StartCoroutine(self:AddOutline(actor))
								return
							end
						end
					end
				end
		end
end
function StealthAssist:SpotFOV()
	local actorsInRange = ActorManager.AliveActorsInRange(Player.actor.position,700)
	table.sort(actorsInRange,function(a,b) return a.position.sqrMagnitude < b.position.sqrMagnitude end)
	if(actorsInRange ~= 0) then
		self.spotTimerStart = true
		self.spotAnimator.SetBool("extended",true)
	else
		self:DebugPrint("Actors in range : 0")
	end
	for z,a in ipairs(actorsInRange) do
		
		if(a.isBot and a.team == Player.enemyTeam and not self:contains(self.affectedBots,a) and self:tablelength(self.affectedBots) <= self.spotLimit) then
			if(self:BotInFov(a)) then
				coroutine.yield(WaitForSeconds(Random.Range(0.1,0.4)))
				self.audioSource.pitch = Random.Range(0.9,1.2)
				self.audioSource.PlayClipAtPoint(self.audioSource.clip,Player.actor.position,1)
				self.script.StartCoroutine(self:AddOutline(a))
			end
		end
	end
end
function StealthAssist:BotInFov(target)
	local normalized = (target.position - Player.actor.transform.position).normalized
	if(not ActorManager.ActorCanSeePlayer(target)) then
		return 0
	end
	return Vector3.Dot(normalized, Player.actor.facingDirection) > 0.85
end
function StealthAssist:DragBody()
	if(self.isDragging) then
		if(self.currentTargetObj ~= nil) then
			-- local lookPos = PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 4 + PlayerCamera.activeCamera.main.transform.up * 1.1
			-- local direction = self.currentTargetObj.transform.position - Player.actor.position
			-- -- direction = Vector3(direction.x,0,direction.z) 
			-- self.currentTargetObj.transform.rotation = Quaternion.Slerp(self.currentTargetObj.transform.rotation,Quaternion.LookRotation(direction),Time.deltaTime * 8)
			-- self.currentTargetObj.transform.position = Vector3.Lerp(self.currentTargetObj.transform.position,lookPos,Time.deltaTime * 9)
			-- self.handTransform1.transform.position = Player.actor.centerPosition
			if(Player.actor.activeWeapon ~= nil) then
				self.handTransform1.transform.position = Vector3.Lerp(self.handTransform1.transform.position,Player.actor.activeWeapon.currentMuzzleTransform.position,Time.deltaTime * 40)
				self.handTransform2.transform.position = Vector3.Lerp(self.handTransform2.transform.position,Player.actor.activeWeapon.currentMuzzleTransform.position,Time.deltaTime * 40)
			end
		end
	end
	if(Input.GetKeyDown(KeyCode.K)) then
		if(not self.isDragging) then
		local ray = Ray(PlayerCamera.activeCamera.main.transform.position,PlayerCamera.activeCamera.main.transform.forward * 1.2)
		local raycast = Physics.Raycast(ray,5,RaycastTarget.ProjectileHit)
		if(raycast ~= nil) then
			if(string.find(raycast.transform.gameObject.name,"Bone")) then
				self.currentTargetObj = raycast.transform.gameObject
				if(self.currentTargetObj.transform.root.gameObject.GetComponent(Actor) == nil) then
					return	
				end
				self.isDragging = true
				-- self.currentTargetObj.GetComponent(Rigidbody).useGravity = false
				-- self.currentTargetObj.GetComponent(Rigidbody).isKinematic = true
				self.handTransform1 = self.currentTargetObj.transform.root.gameObject.GetComponent(Actor).GetHumanoidTransformRagdoll(HumanBodyBones.LeftUpperArm)
				self.handTransform2 = self.currentTargetObj.transform.root.gameObject.GetComponent(Actor).GetHumanoidTransformRagdoll(HumanBodyBones.RightUpperArm)
				print("Dragging")
				
			end
		end
	else
		self.isDragging = false
		print("Not dragging anymore")
		if(self.currentTargetObj ~= nil) then
			self.currentTargetObj.GetComponent(Rigidbody).useGravity = true
			self.currentTargetObj.GetComponent(Rigidbody).isKinematic = false
		end
		self.currentTargetObj = nil
	end
end

end
-- if(Player.actor ~= nil and self.currentWeaponAudio ~= nil) then
	-- local samples = self.currentWeaponAudio.GetSpectrumData(0)
	-- local sampleBass = samples[2]
	-- local Multiplier = 10000
	-- local speed = 1.7
	-- local filteredSampleBass = self.filter.Tick(math.abs(sampleBass)) * Multiplier
	-- self.audioBars[1].value = Mathf.Lerp(self.audioBars[1].value,filteredSampleBass ,Time.deltaTime * speed)
    -- local sampleBass2 = samples[11] -- 64
	-- local filteredSampleBass2 = self.filter.Tick(math.abs(sampleBass2)) * Multiplier
	-- self.audioBars[2].value = Mathf.Lerp(self.audioBars[2].value,filteredSampleBass2,Time.deltaTime * speed)
	-- local sampleMid = samples[24]
	-- local filteredSampleMid = self.filter.Tick(math.abs(sampleMid)) * Multiplier
	-- self.audioBars[3].value = Mathf.Lerp(self.audioBars[3].value,filteredSampleMid,Time.deltaTime * speed)
	-- local sampleMid2 = samples[35]
	-- local filteredSampleMid2 = self.filter.Tick(math.abs(sampleMid2)) * Multiplier
	-- self.audioBars[4].value = Mathf.Lerp(self.audioBars[4].value,filteredSampleMid2,Time.deltaTime * speed)
	-- local sampleMid3 = samples[42]
	-- local filteredSampleMid3 = self.filter.Tick(math.abs(sampleMid3)) * Multiplier
	-- self.audioBars[5].value = Mathf.Lerp(self.audioBars[5].value,filteredSampleMid3,Time.deltaTime * speed)
	-- local sampleHigh = samples[54]
	-- local filteredSampleHigh = self.filter.Tick(math.abs(sampleHigh)) * Multiplier
	-- self.audioBars[6].value = Mathf.Lerp(self.audioBars[6].value,filteredSampleHigh,Time.deltaTime * speed)
	-- end
