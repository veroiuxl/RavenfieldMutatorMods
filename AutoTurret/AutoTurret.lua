-- Outdated and flawed
behaviour("AutoTurret")

function AutoTurret:Start()
self.scriptVar = self.script
self.rotateableTurretTreePath = "Anti Air Gun/Mount Parent/Mount Bearing" -- Change these
self.rotateableTurretGunTreePath = "Anti Air Gun/Mount Parent/Mount Bearing/Mount/Gun" -- Change these
self.GunMuzzleTreePath = "Anti Air Gun/Mount Parent/Mount Bearing/Mount/Gun/Muzzle" -- Change these
self.GunMuzzle2TreePath = "Anti Air Gun/Mount Parent/Mount Bearing/Mount/Gun/Muzzle2" -- Change these
self.projectileSpeed = 120 -- Enter the projectile speed
self.rotationOffsetTurretBase = {0,0,0} -- For yours its {-90,0,0}
self.rotationOffsetTurretGun = {0,0,0}

self.gunLead = true 
self.attackActorsInRange = 100
self.turretBaseRotationSpeed = 15.2 
self.turretGunRotationSpeed =  6.2 self.targetUntilEradicated = false -- Not used yet
self.targetForSeconds = 6
self.delayBetweenShots = 0.2
self.friendlyFire = false
self.WaitBetweenNewTargetAcquire = 1
-- TargetMode = 0 is Infantry
-- TargetMode = 1 is Vehicle Only
self.targetMode = 1 -- Only Mode 1 works correctly currently

-- DO NOT CHANGE THESE VARIABLES
self.projectileGravity = nil
self.targetVehicleRigidbody = nil
self.currentTarget = nil
self.hasTarget = false -- Do not change this
self.isShooting = false
self.interceptPointX = nil
self.interceptPointY = nil
self.currentVehicleVel = nil
self.readyToShoot = 0


	self.rotateableTurret = self.gameObject.transform.Find(self.rotateableTurretTreePath)
	self.rotateableTurretGun = self.gameObject.transform.Find(self.rotateableTurretGunTreePath)
	self.GunMuzzle = self.gameObject.transform.Find(self.GunMuzzleTreePath)
	self.GunMuzzle2 = self.gameObject.transform.Find(self.GunMuzzle2TreePath)
	self.projectileGravity = self.targets.projectilePrefab.GetComponent(Projectile).gravityMultiplier
	if self.targetMode == 1 then
		local crb = self.gameObject.GetComponent(Rigidbody)
		if crb == nil then
			self.currentVehicleVel = Vector3.zero
		else
			self.currentVehicleVel = self.gameObject.GetComponent(Rigidbody).velocity
		end
	end
end

function AutoTurret:Shoot()
	self.isShooting = true
	local totaltime = self.targetForSeconds/ self.delayBetweenShots
	
	for i=1,totaltime,1 do
		if self.currentTarget.isDead then
			self.hasTarget = false
			return
		end
		
		coroutine.yield(WaitForSeconds(self.delayBetweenShots))
		if self.readyToShoot == 0 then
		local proj = GameObject.Instantiate(self.targets.projectilePrefab)
		proj.transform.position = self.GunMuzzle.transform.position
		proj.transform.rotation = self.GunMuzzle.transform.rotation
		self.readyToShoot = 1
		else
		local proj = GameObject.Instantiate(self.targets.projectilePrefab)
		proj.transform.position = self.GunMuzzle2.transform.position
		proj.transform.rotation = self.GunMuzzle2.transform.rotation
		self.readyToShoot = 0
		end
		
	end
	--print("Shot target for " .. self.targetForSeconds .. " seconds")
	coroutine.yield(WaitForSeconds(self.WaitBetweenNewTargetAcquire))
	self.isShooting = false
	self.hasTarget = false
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
	if self.rotateableTurret == nil then
		print("self.rotateableTurret is nil")
		return
	end
	if self.rotateableTurretGun == nil then
		print("self.rotateableTurretGun is nil")
		return
	end
	local actorsInRange
	if self.targetMode == 1 then
		local tempArray1 = {}
		actorsInRange = ActorManager.vehicles
		for i,y in ipairs(actorsInRange) do
			if y.name ~= self.gameObject.GetComponent(Vehicle).name then
				if self.friendlyFire == true then
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
	else if self.targetMode == 0 then
	
		actorsInRange = ActorManager.AliveActorsInRange(self.gameObject.transform.position,self.attackActorsInRange)
		
	end
	end
		local tempArray = {}
		for i,y in ipairs(actorsInRange) do
			if self.friendlyFire then
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
		self.scriptVar.StartCoroutine(self:EradicateActor(target))
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
	self.hasTarget = true
	self.currentTarget = target
	if self.targetMode == 0 then 
--	print("<color=orange>New Target: </color>" .. target.name)
	else if self.targetMode == 1 then
	
	--	print("<color=orange>New Vehicle Target: </color>" .. target.gameObject.GetComponent(Vehicle).name)
		self.targetVehicleRigidbody = target.gameObject.GetComponentInChildren(Rigidbody)
		if self.targetVehicleRigidbody == nil then
			self.hasTarget = false
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
function AutoTurret:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function AutoTurret:GetClosestActor(ActorsInRange) 
	local bestTarget = null;
	local closestDistanceSqr = Mathf.Infinity;
	local currentPosition = self.scriptVar.gameObject.transform.position
	for i,potentialTarget in ipairs(ActorsInRange) do
		local directionToTarget = potentialTarget.transform.position - currentPosition
		local dSqrToTarget = directionToTarget.sqrMagnitude
		local ray = Ray(self.GunMuzzle.transform.position, self.GunMuzzle.transform.forward)
		local raycast = Physics.RaycastAll(ray,directionToTarget.magnitude - (directionToTarget.magnitude / 2) - 2, RaycastTarget.Default)
		local dSqrToTarget = directionToTarget.sqrMagnitude
		local size = self:tablelength(raycast)
		
		if size == 0 then
			if dSqrToTarget < closestDistanceSqr then
				closestDistanceSqr = dSqrToTarget;
				bestTarget = potentialTarget;
			end
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
	if self.hasTarget then
	-- CHECK IF ACTOR IS VISABLE
	if self.isShooting then
	local lookPos1
	local lookPos2
	local tar = self.currentTarget.transform.position - self.GunMuzzle.transform.position 
	if self.targetMode == 0 then 
	 lookPos1 = (self.currentTarget.position ) - self.rotateableTurret.transform.position 
	 lookPos2 = (self.currentTarget.position ) - self.rotateableTurretGun.transform.position

	if self.currentTarget.isFallenOver then
		 lookPos1 = self.currentTarget.GetHumanoidTransformRagdoll(HumanBodyBones.Hips).position - self.rotateableTurretGun.transform.position 
		 lookPos2 = self.currentTarget.GetHumanoidTransformRagdoll(HumanBodyBones.Hips).position - self.rotateableTurretGun.transform.position 
	end
	else
		lookPos1 = self.currentTarget.transform.position - self.rotateableTurret.transform.position 
		lookPos2 = self.currentTarget.transform.position - self.rotateableTurretGun.transform.position
	end
	ray = Ray(self.GunMuzzle.transform.position, self.GunMuzzle.transform.forward)
	raycast = Physics.RaycastAll(ray,tar.magnitude - (tar.magnitude / 2) - 2, RaycastTarget.Default) -- Time.frameCount%5 == 0 addition for performance reason
	local size = self:tablelength(raycast)
	if size ~= 0 then
		self.hasTarget = false
		return
	end

if self.gunLead then
--	lookPos1 = Vector3(0,0,lookPos1.y)

if self.targetMode == 0 then
	self.interceptPointY = self:FirstOrderIntercept(self.rotateableTurret.transform.position ,
	Vector3.zero, -- Has to be current Vehicle Velocity
	self.projectileSpeed,
	lookPos1,
	self.currentTarget.velocity)
	local calcTraj = self:CalculateTrajectory(Vector3.Distance(self.rotateableTurret.transform.position,self.currentTarget.position),self.projectileSpeed)
	if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * Vector3.Distance(self.rotateableTurret.transform.position,self.currentTarget.position);
		self.interceptPointY = Vector3(self.interceptPointY.x,self.interceptPointY.y + trajectoryHeight,self.interceptPointY.z)
	end

else if self.targetMode == 1 then
	
	self.interceptPointY = self:FirstOrderIntercept(self.rotateableTurret.transform.position ,
	self.currentVehicleVel, -- Has to be current Vehicle Velocity
	self.projectileSpeed,
	lookPos1,
	self.targetVehicleRigidbody.velocity)
	local calcTraj = self:CalculateTrajectory(Vector3.Distance(self.rotateableTurret.transform.position,self.currentTarget.gameObject.transform.position),self.projectileSpeed)
	if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * Vector3.Distance(self.rotateableTurret.transform.position,self.currentTarget.gameObject.transform.position);
		self.interceptPointY = Vector3(self.interceptPointY.x,self.interceptPointY.y + trajectoryHeight,self.interceptPointY.z)
	end
end
end
local rotation1 = Quaternion.LookRotation(self.interceptPointY)
rotation1 = Quaternion.Euler(Vector3(0, rotation1.eulerAngles.y, 0) + Vector3(self.rotationOffsetTurretBase[1],self.rotationOffsetTurretBase[2],self.rotationOffsetTurretBase[3])) -- https:--answers.unity.com/questions/127765/how-to-restrict-quaternionslerp-to-the-y-axis.html
	self.rotateableTurret.transform.rotation = Quaternion.Slerp(self.rotateableTurret.transform.rotation, rotation1, Time.deltaTime * self.turretBaseRotationSpeed)
	
if self.targetMode == 0 then
	self.interceptPointX = self:FirstOrderIntercept(self.rotateableTurretGun.transform.position ,
		Vector3.zero,
		self.projectileSpeed,
		lookPos2,
		self.currentTarget.velocity)
		local calcTraj = self:CalculateTrajectory(Vector3.Distance(self.rotateableTurretGun.transform.position,self.currentTarget.position),self.projectileSpeed)
		if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * Vector3.Distance(self.rotateableTurretGun.transform.position,self.currentTarget.position);
		self.interceptPointX = Vector3(self.interceptPointX.x,self.interceptPointX.y + trajectoryHeight,self.interceptPointX.z)
		end
else if self.targetMode == 1 then
		self.interceptPointX = self:FirstOrderIntercept(self.rotateableTurretGun.transform.position ,
		self.currentVehicleVel,
		self.projectileSpeed,
		lookPos2,
		self.targetVehicleRigidbody.velocity)
		local calcTraj = self:CalculateTrajectory(Vector3.Distance(self.rotateableTurretGun.transform.position,self.currentTarget.gameObject.transform.position),self.projectileSpeed)
		if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * Vector3.Distance(self.rotateableTurretGun.transform.position,self.currentTarget.gameObject.transform.position);
		self.interceptPointX = Vector3(self.interceptPointX.x,self.interceptPointX.y + trajectoryHeight,self.interceptPointX.z)
		end
	   end
	   end
	local rotation2 = Quaternion.LookRotation(self.interceptPointX)
	local rotation3 = Quaternion.Euler(Vector3(rotation2.eulerAngles.x, 0, 0)  + Vector3(self.rotationOffsetTurretGun[1],self.rotationOffsetTurretGun[2],self.rotationOffsetTurretGun[3]) ) 
	self.rotateableTurretGun.transform.localRotation = Quaternion.Slerp(self.rotateableTurretGun.transform.localRotation, rotation3, Time.deltaTime * self.turretGunRotationSpeed)
else 
local rotation1 = Quaternion.LookRotation(lookPos1)
rotation1 = Quaternion.Euler(Vector3(0, rotation1.eulerAngles.y, 0) + Vector3(self.rotationOffsetTurretBase[1],self.rotationOffsetTurretBase[2],self.rotationOffsetTurretBase[3])) -- https:--answers.unity.com/questions/127765/how-to-restrict-quaternionslerp-to-the-y-axis.html
	self.rotateableTurret.transform.rotation = Quaternion.Slerp(self.rotateableTurret.transform.rotation, rotation1, Time.deltaTime * self.turretBaseRotationSpeed)
	local rotation2 = Quaternion.LookRotation(lookPos2)
	local rotation3 = Quaternion.Euler(Vector3(rotation2.eulerAngles.x, 0, 0) + Vector3(self.rotationOffsetTurretGun[1],self.rotationOffsetTurretGun[2],self.rotationOffsetTurretGun[3]) ) 
	self.rotateableTurretGun.transform.localRotation = Quaternion.Slerp(self.rotateableTurretGun.transform.localRotation, rotation3, Time.deltaTime * self.turretGunRotationSpeed)

end
end
else
	self.hasTarget = false
		self.script.StartCoroutine("AcquireTarget")
end
	
end
