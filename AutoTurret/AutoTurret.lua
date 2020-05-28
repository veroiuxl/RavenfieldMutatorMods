-- This is my AutoTurret Script. It automatically targets Vehicles/Infantry without being controlled by a bot.  
behaviour("AutoTurret") -- unmanned turrets
local rotateableTurretTreePath = "Anti Air Gun/Mount Parent/Mount Bearing" -- Change these
local rotateableTurretGunTreePath = "Anti Air Gun/Mount Parent/Mount Bearing/Mount/Gun" -- Change these
local GunMuzzleTreePath = "Anti Air Gun/Mount Parent/Mount Bearing/Mount/Gun/Muzzle" -- Change these
local projectileSpeed = 300 -- Enter the projectile speed

local gunLead = true 
local attackActorsInRange = 100
local turretBaseRotationSpeed = 15.2 
local turretGunRotationSpeed =  6.2
local targetUntilEradicated = false -- Not used yet
local targetForSeconds = 5 
local delayBetweenShots = 0.2
local friendlyFire = false
local WaitBetweenNewTargetAcquire = 1
-- TargetMode = 0 is Infantry
-- TargetMode = 1 is Vehicle Only
local targetMode = 1 -- Only Mode 1 works correctly currently

-- DO NOT CHANGE THESE VARIABLES
local projectileGravity
local targetVehicleRigidbody
local rotateableTurret
local rotateableTurretGun
local GunMuzzle
local currentTarget
local hasTarget = false -- Do not change this
local scriptVar
local isShooting = false
local interceptPointX
local interceptPointY
local currentVehicleVel
function AutoTurret:Start()
	scriptVar = self.script
	
	rotateableTurret = self.gameObject.transform.Find(rotateableTurretTreePath)
	rotateableTurretGun = self.gameObject.transform.Find(rotateableTurretGunTreePath)
	GunMuzzle = self.gameObject.transform.Find(GunMuzzleTreePath)
	projectileGravity = self.targets.projectilePrefab.GetComponent(Projectile).gravityMultiplier
	if targetMode == 1 then
		local crb = self.gameObject.GetComponent(Rigidbody)
		if crb == nil then
			currentVehicleVel = Vector3.zero
		else
			currentVehicleVel = self.gameObject.GetComponent(Rigidbody).velocity
		end
	end
end

function AutoTurret:Shoot()
	isShooting = true
	local totaltime = targetForSeconds/delayBetweenShots
	
	for i=1,totaltime,1 do
		if currentTarget.isDead then
			hasTarget = false
			return
		end
		coroutine.yield(WaitForSeconds(delayBetweenShots))
		local proj = GameObject.Instantiate(self.targets.projectilePrefab)
		proj.transform.position = GunMuzzle.transform.position
		proj.transform.rotation = GunMuzzle.transform.rotation
		
	end
	--print("Shot target for " .. targetForSeconds .. " seconds")
	coroutine.yield(WaitForSeconds(WaitBetweenNewTargetAcquire))
	isShooting = false
	hasTarget = false
end
function AutoTurret:TeamToNumber(team)
if team == Team.Blue then
return 0
else if team == Team.Red then
return 1
else if team == Team.Neutral then
return -1
end
end
end
end
function AutoTurret:AcquireTarget()
	if rotateableTurret == nil then
		print("rotateableTurret is nil")
		return
	end
	if rotateableTurretGun == nil then
		print("rotateableTurretGun is nil")
		return
	end
	local actorsInRange
	if targetMode == 1 then
		local tempArray1 = {}
		actorsInRange = ActorManager.vehicles
		for i,y in ipairs(actorsInRange) do
			if y.name ~= self.gameObject.GetComponent(Vehicle).name then
				if friendlyFire == true then
				table.insert(tempArray1, y)
			--	print("Added Vehicle all")
				else
				if y.team ~= self:TeamToNumber(Player.actor.team) then
					if y.team ~= self:TeamToNumber(Team.Neutral) then
						table.insert(tempArray1, y)
			--			print("Added Vehicle ")
					
					end
				end
				end
			end
		end
		actorsInRange = tempArray1
	else if targetMode == 0 then
	
		actorsInRange = ActorManager.AliveActorsInRange(self.gameObject.transform.position,attackActorsInRange)
		
	end
	end
		local tempArray = {}
		for i,y in ipairs(actorsInRange) do
			if friendlyFire then
				table.insert(tempArray, y)
			end
			if y.team ~= Player.actor.team then
				table.insert(tempArray, y)
			end
		end
		actorsInRange = tempArray
		if #actorsInRange ~= 0 then
	--		print("Set enemys in range")
		end
	target = self:GetClosestActor(actorsInRange)
	if target ~= nil then
	--	print("Acquiring target...")
		scriptVar.StartCoroutine(self:EradicateActor(target))
	end
end
function AutoTurret:CalculateTrajectory( TargetDistance, ProjectileVelocitys)
	local n = (-Physics.gravity.y * TargetDistance)
	local b = ProjectileVelocitys * ProjectileVelocitys
        local CalculatedAngle = 0.5 * ((Mathf.Asin (n / b)) * Mathf.Rad2Deg);
        if(CalculatedAngle ~= CalculatedAngle) then
            return 0
            
		end
        return CalculatedAngle
end
function AutoTurret:EradicateActor(target)
return function()
	if target ~= nil then
	hasTarget = true
	currentTarget = target
	if targetMode == 0 then 
--	print("<color=orange>New Target: </color>" .. target.name)
	else if targetMode == 1 then
	
	--	print("<color=orange>New Vehicle Target: </color>" .. target.gameObject.GetComponent(Vehicle).name)
		targetVehicleRigidbody = target.gameObject.GetComponentInChildren(Rigidbody)
		if targetVehicleRigidbody == nil then
			hasTarget = false
	--		print("Target vehicle doesn't have a rigidbody")
			return
		end
		
	end
	end
	self.script.StartCoroutine("Shoot")
	
	else
		print("Target is already dead?")
	end
   
end
end
function AutoTurret:GetClosestActor(ActorsInRange) 
	local bestTarget = null;
	local closestDistanceSqr = Mathf.Infinity;
	local currentPosition = scriptVar.gameObject.transform.position
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


function AutoTurret:FirstOrderIntercept(shooterPosition,shooterVelocity,shotSpeed,targetPosition,targetVelocity) -- Credit to https:--wiki.unity3d.com/index.php/Calculating_Lead_For_ProjectilesshooterVelocity
	local targetRelativePosition = targetPosition - shooterPosition;
	local targetRelativeVelocity = targetVelocity - shooterVelocity;
	
	local t = self:FirstOrderInterceptTime( shotSpeed,
				   targetRelativePosition,
				   targetRelativeVelocity);
	
	return targetPosition + t*(targetRelativeVelocity)
	end
function AutoTurret:FirstOrderInterceptTime(shotSpeed,
		targetRelativePosition,
		targetRelativeVelocity)
	
	local velocitySquared = targetRelativeVelocity.sqrMagnitude;
	if(velocitySquared < 0.001) then
	return 0.0
	end
	
	local a = velocitySquared - shotSpeed*shotSpeed;
	
	--handle similar velocities
	if (Mathf.Abs(a) < 0.001) then
	local t = -targetRelativePosition.sqrMagnitude /(2 *Vector3.Dot(targetRelativeVelocity,targetRelativePosition))
	return Mathf.Max(t, 0.0)
	end
	
	local b = 2*Vector3.Dot(targetRelativeVelocity, targetRelativePosition)
	local c = targetRelativePosition.sqrMagnitude
	local determinant = b*b - 4*a*c
	
	if (determinant > 0.0) then--determinant > 0; two intercept paths (most common)
		local t1 = (-b + Mathf.Sqrt(determinant))/(2*a)
		local t2 = (-b - Mathf.Sqrt(determinant))/(2*a)
			if (t1 > 0.0) then
				if (t2 > 0.0) then
					return Mathf.Min(t1, t2); --both are positive
				else
					return t1; --only t1 is positive
				end
			else
				return Mathf.Max(t2, 0.0); --don't shoot back in time
			end
	else if determinant < 0.0 then
		return 0.0
	else --determinant = 0; one intercept path, pretty much never happens
		return Mathf.Max(-b/(2*a), 0.0) --don't shoot back in time
	end
end
end
function AutoTurret:Update()
	if hasTarget then
	-- CHECK IF ACTOR IS VISABLE
	if isShooting then
	local lookPos1
	local lookPos2
	if targetMode == 0 then 
	 lookPos1 = (currentTarget.position ) - rotateableTurret.transform.position 
	 lookPos2 = (currentTarget.position ) - rotateableTurretGun.transform.position
	if currentTarget.isFallenOver then
		 lookPos1 = currentTarget.GetHumanoidTransformRagdoll(HumanBodyBones.Hips).position - rotateableTurretGun.transform.position 
		 lookPos2 = currentTarget.GetHumanoidTransformRagdoll(HumanBodyBones.Hips).position - rotateableTurretGun.transform.position 
	end
	else
		lookPos1 = currentTarget.transform.position - rotateableTurret.transform.position 
		lookPos2 = currentTarget.transform.position - rotateableTurretGun.transform.position
	end

if gunLead then
--	lookPos1 = Vector3(0,0,lookPos1.y)

if targetMode == 0 then
	interceptPointY = self:FirstOrderIntercept(rotateableTurret.transform.position ,
	Vector3.zero, -- Has to be current Vehicle Velocity
	projectileSpeed,
	lookPos1,
	currentTarget.velocity)
	local calcTraj = self:CalculateTrajectory(Vector3.Distance(rotateableTurret.transform.position,currentTarget.position),projectileSpeed)
	if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * Vector3.Distance(rotateableTurret.transform.position,currentTarget.position);
		interceptPointY = Vector3(interceptPointY.x,interceptPointY.y + trajectoryHeight,interceptPointY.z)
	end

else if targetMode == 1 then
	interceptPointY = self:FirstOrderIntercept(rotateableTurret.transform.position ,
	currentVehicleVel, -- Has to be current Vehicle Velocity
	projectileSpeed,
	lookPos1,
	targetVehicleRigidbody.velocity)
	local calcTraj = self:CalculateTrajectory(Vector3.Distance(rotateableTurret.transform.position,currentTarget.gameObject.transform.position),projectileSpeed)
	if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * Vector3.Distance(rotateableTurret.transform.position,currentTarget.gameObject.transform.position);
		interceptPointY = Vector3(interceptPointY.x,interceptPointY.y + trajectoryHeight,interceptPointY.z)
	end
end
end
local rotation1 = Quaternion.LookRotation(interceptPointY)
rotation1 = Quaternion.Euler(Vector3(0, rotation1.eulerAngles.y, 0)) -- https:--answers.unity.com/questions/127765/how-to-restrict-quaternionslerp-to-the-y-axis.html
	rotateableTurret.transform.rotation = Quaternion.Slerp(rotateableTurret.transform.rotation, rotation1, Time.deltaTime * turretBaseRotationSpeed)
	
if targetMode == 0 then
	interceptPointX = self:FirstOrderIntercept(rotateableTurretGun.transform.position ,
		Vector3.zero,
		projectileSpeed,
		lookPos2,
		currentTarget.velocity)
		local calcTraj = self:CalculateTrajectory(Vector3.Distance(rotateableTurretGun.transform.position,currentTarget.position),projectileSpeed)
		if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * Vector3.Distance(rotateableTurretGun.transform.position,currentTarget.position);
		interceptPointX = Vector3(interceptPointX.x,interceptPointX.y + trajectoryHeight,interceptPointX.z)
		end
else if targetMode == 1 then
		interceptPointX = self:FirstOrderIntercept(rotateableTurretGun.transform.position ,
		currentVehicleVel,
		projectileSpeed,
		lookPos2,
		targetVehicleRigidbody.velocity)
		local calcTraj = self:CalculateTrajectory(Vector3.Distance(rotateableTurretGun.transform.position,currentTarget.gameObject.transform.position),projectileSpeed)
		if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * Vector3.Distance(rotateableTurretGun.transform.position,currentTarget.gameObject.transform.position);
		interceptPointX = Vector3(interceptPointX.x,interceptPointX.y + trajectoryHeight,interceptPointX.z)
		end
	   end
	   end
	local rotation2 = Quaternion.LookRotation(interceptPointX)
	local rotation3 = Quaternion.Euler(Vector3(rotation2.eulerAngles.x, 0, 0)) 
	rotateableTurretGun.transform.localRotation = Quaternion.Slerp(rotateableTurretGun.transform.localRotation, rotation3, Time.deltaTime * turretGunRotationSpeed)
else -- gunLead false
local rotation1 = Quaternion.LookRotation(lookPos1)
rotation1 = Quaternion.Euler(Vector3(0, rotation1.eulerAngles.y, 0)) -- https:--answers.unity.com/questions/127765/how-to-restrict-quaternionslerp-to-the-y-axis.html
	rotateableTurret.transform.rotation = Quaternion.Slerp(rotateableTurret.transform.rotation, rotation1, Time.deltaTime * turretBaseRotationSpeed)
	local rotation2 = Quaternion.LookRotation(lookPos2)
	local rotation3 = Quaternion.Euler(Vector3(rotation2.eulerAngles.x, 0, 0)) 
	rotateableTurretGun.transform.localRotation = Quaternion.Slerp(rotateableTurretGun.transform.localRotation, rotation3, Time.deltaTime * turretGunRotationSpeed)

end
end
else
	hasTarget = false
		self.script.StartCoroutine("AcquireTarget")
end
	
end
