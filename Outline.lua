-- This script should be only used for educational purposes due to outdated/bad code.(See DeathEffect.txt)
behaviour("Outline")
local gotDefault = false
local renderer
local oldMat
local redOutlineMat
local blueOutlineMat
function Outline:Start()
    -- Run when behaviour is created
    printColor("Testing","green")
    self.blueOutlineMat = self.targets.blueTeamOutline
    self.redOutlineMat = self.targets.redTeamOutline
    gotDefault = false
end
function printColor(input,Color)
    print("<color=" .. tostring(Color) .. ">" .. tostring(input) .. "</color>")
    end


function Outline:EnableOutline(actor)
    print("Enabled for " .. actor.name)
    local skinnedMeshRenderer = actor.gameObject.GetComponentInChildren(SkinnedMeshRenderer) -- OUTDATED
    if actor.team == Team.Blue then
    skinnedMeshRenderer.material = self.blueOutlineMat
    else
        skinnedMeshRenderer.material = self.redOutlineMat
    end
end
function Outline:Update()
    
    if not gotDefault then
        
        renderer = Player.actor.gameObject.GetComponentInChildren(SkinnedMeshRenderer) -- OUTDATED
        if renderer ~= nil then
        print(renderer.name)
        oldMat = renderer.material
        
        gotDefault = true
        local count = 0
        for i,y in ipairs(ActorManager.actors) do
            if ActorManager.actors[i].isBot then
                count = count + 1
            self:EnableOutline(ActorManager.actors[i])
            end
        end
        printColor("Set Outline for " .. tostring(count) .. " actors","green")
        else
            printColor("Renderer Mat is nil","red")
        end
    end

end
