-- Register the behaviour
behaviour("CustomCrosshair")
local isEnabled
local labelsize
local size = 0.6
local crosshairImage
local sliderforsize

local rSlider
local rLabel
local GSlider
local GLabel
local BSlider
local BLabel

local crosshairImageColor

local GabSlider
local GabLabel
local lengthslider
local lengthlabel
function CustomCrosshair:Start()	
	self.crosshairTransform = self.targets.crosshairParent.GetComponent(RectTransform)
	isEnabled = false
	labelsize = self.targets.labelsize.GetComponent(Text)
	self.targets.canvas.setActive(false)
	crosshairImage = self.targets.crosshairImage.GetComponentsInChildren(RectTransform)
	sliderforsize = self.targets.sliderforsize.GetComponent(Slider)
	crosshairImageColor = self.targets.crosshairImage.GetComponentsInChildren(Image)

	rSlider = self.targets.rSlider.GetComponent(Slider)
	rLabel = self.targets.rLabel.GetComponent(Text)
	GSlider = self.targets.gSlider.GetComponent(Slider)
	GLabel = self.targets.gLabel.GetComponent(Text)
	BSlider = self.targets.bSlider.GetComponent(Slider)
	BLabel = self.targets.bLabel.GetComponent(Text)
	BSlider = self.targets.bSlider.GetComponent(Slider)
	BLabel = self.targets.bLabel.GetComponent(Text)
	GabSlider = self.targets.gabslider.GetComponent(Slider)
	GabLabel = self.targets.gablabel.GetComponent(Text)
	lengthslider = self.targets.length.GetComponent(Slider)
	lengthlabel = self.targets.lengthlabel.GetComponent(Text)
end

function CustomCrosshair:Update()

	if Input.GetKeyDown(KeyCode.F1) then
		if not Player.actor.isSeated then
		if isEnabled then
			--	self.targets.anim.SetBool("uian",false)
			Screen.UnlockCursor()
				--self.targets.anim.SetBool("uian",false)
				self.targets.canvas.setActive(false)
				isEnabled = false
				Screen.LockCursor()
		
			else
				self.targets.canvas.setActive(true)
				isEnabled = true
				Screen.UnlockCursor()
			end
		end
	end
	if isEnabled then
	local r = rSlider.value
	local g = GSlider.value
	local b = BSlider.value
	local gap = GabSlider.value
	local length = lengthslider.value
	size = sliderforsize.value
	labelsize.text = "Size: " .. tostring(size)

	rLabel.text = "R: " .. tostring(r)

	GLabel.text = "G: " .. tostring(g)
		
	BLabel.text = "B: " .. tostring(b)
	GabLabel.text = "Gap: " .. tostring(gap)
	lengthlabel.text = "Length: " .. tostring(length)

	self.crosshairTransform.localScale = Vector3(size, size,1)
	for x,z in ipairs(crosshairImage) do
	
		if z.gameObject.name == "Left" then
			z.transform.localPosition = Vector3( -gap,0,0)
			z.transform.localScale = Vector3(  length,z.transform.localScale.y,z.transform.localScale.z)
		end
		
		if z.gameObject.name == "Right" then
			z.transform.localPosition = Vector3(gap,0,0)
			z.transform.localScale = Vector3( length,z.transform.localScale.y,z.transform.localScale.z)
		end
		
		if z.gameObject.name == "Up" then
			z.transform.localPosition = Vector3(0,gap,0)
			z.transform.localScale = Vector3(  length,z.transform.localScale.y,z.transform.localScale.z)
		end
		
		if z.gameObject.name == "Down" then
			z.transform.localPosition = Vector3(0, -gap,0)
			z.transform.localScale = Vector3( length,z.transform.localScale.y,z.transform.localScale.z)
		end

	end
	for x,z in ipairs(crosshairImageColor) do
	
		z.color = Color(r,g,b,255)
	
	end
	
	
	

	end
	local activeWeapon = Player.actor.activeWeapon;


	if activeWeapon == nil then
		-- Disable the crosshair if no weapon is equipped or the player is not in first person mode
		self.targets.crosshairParent.SetActive(false)
		return
	end

	-- Some weapons have sub weapons such as underslung grenade launchers. Get the active sub weapon.
	activeWeapon = activeWeapon.activeSubWeapon

	local muzzleTransform = activeWeapon.currentMuzzleTransform

	-- Only draw the crosshair when the weapon is ready to fire
	local enabled = muzzleTransform ~= nil and not activeWeapon.isReloading and activeWeapon.isUnholstered and not activeWeapon.isAiming and not Player.actor.isSprinting and not Player.actor.isFallenOver and not Player.actor.isOnLadder and not Player.actor.isInWater
	self.targets.crosshairParent.SetActive(enabled)

	if not enabled then
		return;
	end

	local ray = Ray(muzzleTransform.position, muzzleTransform.forward)
	local target = RaycastTarget.ProjectileHit
	local distance = 1000
	local hit = Physics.Raycast(ray, distance, target)

	if hit ~= nil then
		distance = hit.distance
	end

	-- Position the crosshair so it on the point 1000 meters ahead of the muzzle.
	local aimPoint = ray.origin + ray.direction * distance

	local screenPoint = PlayerCamera.activeCamera.WorldToScreenPoint(aimPoint)
	-- Set screen point depth to 0, if it is too high it will be culled.
	screenPoint.z = 0

	-- Calculate the crosshair size based on the current weapon spread angle and the player camera FOV.
	local fovRatio = (activeWeapon.currentSpreadMaxAngleRadians * Mathf.Rad2Deg) / PlayerCamera.activeCamera.fieldOfView
	local size = Mathf.Max(size, (fovRatio * Screen.height) - 0.5)

	-- Assign the point and size to the transform.
	self.crosshairTransform.position = screenPoint
	
end
