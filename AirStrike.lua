-- Register the behaviour -- UNCONTINUED PROJECT -- IF YOU USE THIS ATLEAST CREDIT ME
behaviour("AirStrike")
local instance
local TargetPosition
local particleSystem
local StartTime = 0
local distanceLerp
local scriptvar
-- For Hold Button
local timer
local holdDur = 1
local hasPressed
-- Configs
local StartDelay = 5
local rocketCount = 15
local DelayBetweenRockets = 0.3
local AirStrikePrefab
local CarpetBombPrefab
local AirStrikeSquareX = 7
local AirStrikeSquareY = 7
local Mode = 1
-- For Bombs
local BombCount = 18
local DelayBetweenBombs = 0.25
local AirStrikeSquareX2 = 2
local AirStrikeSquareY2 = 2
local PlanePrefab
local PlaneAnimation
local jetInstance
local RangeFinderText
function AirStrike:Start()
	instance = self
    
	print("Hold X for " .. holdDur .. " seconds to change the Mode")
	-- Run when behaviour is created
end
function AirStrike:Awake()

	self.particleSystem = GameObject.Instantiate(self.targets.particleTarget).GetComponent(ParticleSystem)
	self.AirStrikePrefab = self.targets.rocket
	self.CarpetBombPrefab = self.targets.bomb
	self.PlanePrefab = self.targets.planePrefab
	self.scriptvar = self.script
	self.RangeFinderText = self.targets.canvas.GetComponentInChildren(Text)
	-- self.PlaneAnimation = self.targets.planePrefab.GetComponent(Animator)

end

function AirStrike:Fly()
	jetInstance = GameObject.Instantiate(self.PlanePrefab)
	jetInstance.transform.position = Vector3(TargetPosition.x,TargetPosition.y + 60,TargetPosition.z - 70)
	local jetRigidbody = jetInstance.GetComponent(Rigidbody)
	--local forceToApply = Vector3(0,0,50)
	--jetRigidbody.AddForce(forceToApply,ForceMode.Impulse)
	jetRigidbody.velocity = Vector3.forward * 30


end
function AirStrike:Launch()
		if Mode == 1 then
		print("Waiting " .. StartDelay .. " seconds")
		coroutine.yield(WaitForSeconds(StartDelay))
		for i = rocketCount,1,-1 do
		local pos2 = Vector3(TargetPosition.x + Random.Range(-AirStrikeSquareX,AirStrikeSquareX),TargetPosition.y + 50, TargetPosition.z + Random.Range(-AirStrikeSquareY,AirStrikeSquareY))
		print(pos2)
		local rocketPrefab = GameObject.Instantiate(self.AirStrikePrefab)
		rocketPrefab.transform.position = pos2
		rocketPrefab.transform.rotation = Quaternion.Euler(90,0,0);
	--	rocketPrefab.velocity = Player.actor.transform.TransformDirection(Vector3.Down * 10)
		coroutine.yield(WaitForSeconds(DelayBetweenRockets))
		end
		self.particleSystem.Stop()
		print("Stopped AirStrike")
	else
		print("Mode Carpet Bombing")
		print("Waiting " .. StartDelay .. " seconds")
		coroutine.yield(WaitForSeconds(StartDelay))
		self.scriptvar.StartCoroutine("Fly")
		
		
	--	PlaneAnimation.Play("Jet")
	--	jet.transform.position = Vector3.MoveTowards(jetStartPosition,jetTargetPosition,Time.deltaTime * 5)
		for i = BombCount,1,-1 do
			local pos2 = Vector3(jetInstance.transform.position.x + Random.Range(-AirStrikeSquareX2,AirStrikeSquareX2),jetInstance.transform.position.y, jetInstance.transform.position.z + Random.Range(-AirStrikeSquareY2,AirStrikeSquareY2))
			print(pos2)
			local bombPrefab = GameObject.Instantiate(self.CarpetBombPrefab)
			bombPrefab.transform.position = pos2
			--	rocketPrefab.transform.rotation = Quaternion.Euler(90,0,0);
			--	rocketPrefab.velocity = Player.actor.transform.TransformDirection(Vector3.Down * 10)
			coroutine.yield(WaitForSeconds(DelayBetweenBombs))
		end
		self.particleSystem.Stop()
		Destroy(jetInstance)
		print("Stopped AirStrike")
	end

end
function AirStrike:Update()
	if instance ~= self then
		return
	end
	if Input.GetKeyDown(KeyCode.X) then
		timer = Time.time
		hasPressed = false
	end
	if (Input.GetKey(KeyCode.X)) and Player.actor ~= nil and not Player.actor.isDead and not Player.actor.isFallenOver and not Player.actor.isSwimming and not Player.actor.isSeated then
		if (Time.time - timer) > holdDur and not hasPressed then
			if Mode == 0 and not hasPressed then
				Mode = 1
				print("Changed Mode to <color=#ff031c>AirStrike</color>")
				hasPressed = true
			end
			if Mode == 1 and not hasPressed then
				Mode = 0
				print("Changed Mode to <color=#03b3ff>CarpetBombing</color>")
				hasPressed = true
			end

		end
	end
	if Input.GetKey(KeyCode.Mouse1) then
		local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
		local raycast = Physics.Raycast(ray,5000, RaycastTarget.ProjectileHit)
		if raycast ~= nil then
		RangeFinderText.text = tostring(System.Math.Round(hit.distance,0))

		else
			RangeFinderText.text = "-"

		end

	end

	
	if Input.GetKeyDown(KeyCode.Mouse0) and Input.GetKey(KeyCode.Mouse1) and not Player.actor.isDead and not Player.actor.isFallenOver and not Player.actor.isSwimming and not Player.actor.isSeated then
		local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
		local raycast = Physics.Raycast(ray,1190, RaycastTarget.ProjectileHit)
			if raycast ~= nil then
				self.particleSystem.transform.position = raycast.point - PlayerCamera.activeCamera.main.transform.forward
			--	self.particleSystem.rotation = Quaternion.Euler(-90,0,0)
				self.particleSystem.Play()
				StartTime = Time.time
				TargetPosition = raycast.point
				self.script.StartCoroutine("Launch")
				print("Started AirStrike")
			end

	end

	
end
