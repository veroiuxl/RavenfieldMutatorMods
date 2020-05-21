local behaviourModOptions

function YourBehaviour:Start()
-- SETUP YOUR UI
self.script.StartCoroutine("AddOption")
self.canvasit.gameObject.SetActive(false) 
end

function YourBehaviour:AddOption()
coroutine.yield(WaitForSeconds(0.1)) 
local mutatorOptions = GameObject.Find("ModOptionsScript(Clone)") 
if mutatorOptions == nil then 
	print("ModOptionsScript(Clone) not found!") 
else 
    behaviourModOptions = ScriptedBehaviour.GetScript(mutatorOptions)
	local yourOwnButton = behaviourModOptions:AddMutatorOption("<YourMutatorModName>") 
	
	yourOwnButton.onClick.AddListener(self,"onModOptionPress")
	print("Done")
end
end

function YourBehaviour:onModOptionPress()  
	behaviourModOptions:OpenCanvas(self.targets.canvasit)
end
end

