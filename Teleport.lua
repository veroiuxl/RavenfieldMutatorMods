-- Register the behaviour
behaviour("Teleport")
local instance;
local realPlayer
local particleSystem
function Teleport:Start()
	-- Run when behaviour is created
	instance = self;
	if Player.actor.transform.parent ~= nil then
		self.realPlayer = Player.actor.transform.parent
	end

	self.particleSystem = self.gameObject.GetComponent(ParticleSystem)
	
	if self.gameObject.GetComponent(ParticleSystem) ~= nil then
		self.transform.Rotate(-90.0, 0.0, 0.0, Space.Self);
		print("ParticleSystem not null")
	end
	
	print("[Tp]<color=green>Script Activated!</color>")
	print("[Tp]--Teleport-- V9 by Chryses")
	print("Press T to teleport")
	Overlay.ShowMessage("<color=#18f01c>Script Activated!</color>")
end

function Teleport:Update()
	-- Run every frame
	if instance ~= self then
		return
	end
	if Player.actor.transform.parent ~= nil then
		self.realPlayer = Player.actor.transform.parent
	end
	
	if Input.GetKeyDown(KeyCode.T) then
			--Overlay.ShowMessage("<color=#34abeb>Switched</color>")
			local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
		    local raycast = Physics.Raycast(ray,1190, RaycastTarget.ProjectileHit)
			if raycast ~= nil then	-- C# raycast != null
				print("Raycast hit : " .. raycast.point.ToString())
				
				self.particleSystem.transform.position = self.realPlayer.position
				self.transform.Rotate(0, self.realPlayer.localRotation.y, 0.0, Space.Self);
				self.particleSystem.Simulate( 0.0, true, true )
				self.particleSystem.Play();
				
				self.realPlayer.position = raycast.point - PlayerCamera.activeCamera.main.transform.forward
				--print("Collider " .. tostring(raycast.collider))
				
			end
			
		

			

	end
end
