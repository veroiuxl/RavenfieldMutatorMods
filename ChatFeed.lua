behaviour("ChatFeed")

-- The max number of lines allowed
local maxLines = 10

local playerInvolvedMessageChanceBoost = 0.6



local friendlySquadStatusChance = 0.1;
local enemySquadStatusChance = 0.01;

local killerMessageChance = 0.3
local killedMessageChance = 0.2

local teamKillerMessageChance = 0.5
local teamKilledMessageChance = 0.2
local statusPostTimeVariance = 5
local statusPostTime = 1
local postTimeVariance = 1
local killerPostTime = 1
local killedPostTime = postTimeVariance + 0.3
local isPiratedOrOffline = false
local killerMessages = {
	"You fucking trash %s",
	"You garbage %s",
	"Go play roblox twat",
	"Bitch",
	"You got rekt again!",
	"Get dunked on",
	"Get rekt",
	"I wasn't even looking",
	"Hahaha %s",
	"Haha noob l2p",
	"2 ez 4 me",
	"I'm over here fuckface",
	"Иди нахуй!",
	"пошел ты",
	"You're such a bot"
}

local killedMessage = {
	"You only good against bots",
	"So toxic man",
	"Wow you are good %s",
	"Nice hacks %s",
	"ns",
	"HOW?",
	"Actually cheating...",
	"%s son of dog",
	"1 hp %s",
	"%s so lucky...  ",
	"Why RUSH B ???",
	"Stop camping noob",
	"SIND7 is 2 OP",
	"SR7 plz fix",
	"Enjoy your ban %s",
	"сука блять",
	"lol stop",
	"Pathetic",
	"Try to do that in an online game",
	"It's hard to come up with insults",
	"Suck my ass",
	"Scheiße",
	"Eat ma ass you fatfuck",
	"Nice shot faggot",
	"Actually pretty good! Nice shot!",
	"You dogshit m8",
	"Fuck you cunt",
	"You bitch ass looking mf",
	"%s you dogfucker",
	"%s you dyslexic Hotpocket",
	"%s mega Faggot",
	"%s you polygon looking ass motherfucker",
	"Fuck VIPmods",
	"Reported, have fun getting banned",
	"Иди нахуй!",
	"Get gamer'd",
	"Go back to Fortnite kid",
	"my dad works for steam, u will be deleted!!",
	"How tf did you hit me %s",
	"Fuck you %s fucking tryhard",
	"I fucked your mom %s"
}

local teamKillerMessages = {
	"Whooops",
	"That wasn't my fault",
	"Totally sorry %s",
	"Oops!",
	"It will happen again if you play like this",
	"Aww %s I'm sorry!",
	"sry",
	"sry %s, pls no kick",
	"Why walk in front of me?",
	"You fucking ape",
	"You absolute Gobshite",
	"You're a huge pain in the ass"
}

local teamKilledMessages = {
	"PLEASE KICK %s",
	"Stop teamkilling plz",
	"plz %s",
	"M8 you trash %s",
	"FUCK YOU %s",
	"You fucking moron..",
	"You bloody wanker",
	"Stop YOU FUCKING PRICK"
}



function ChatFeed:Start()
	-- Run when behaviour is created
	GameEvents.onActorDied.AddListener(self, "OnActorDied")
	GameEvents.onMatchEnd.AddListener(self, "OnMatchEnd")
	GameEvents.onSquadAssignedNewOrder.AddListener(self, "OnSquadAssignedNewOrder");
	self.text = self.targets.text.GetComponent(Text)
	-- Create empty lines
	self.lines = {}
	for i=1,maxLines do
		self.lines[i] = ""
	end
	if Player.actor.name == "EaglePancake" then
		table.insert(killerMessages,"Wrong pass my man")
		
		print("EaglePancake line added")
	end
	if Player.actor.name == "Unknown Player" then
		isPiratedOrOffline = true
		print("<color=red>ERROR: This mod can NOT be used in offline mode</color>")
	end
	if Player.actor.name == "Sofa" then
		table.insert(killerMessages,"Will we ever see the boat from Cerzig?")
		print("Sofa line added")
	end

	self:UpdateText()
end

function ChatFeed:OnSquadAssignedNewOrder(squad, order)

	local chance = friendlySquadStatusChance;
	if squad.leader.team ~= Player.team then
		chance = enemySquadStatusChance;
	end

	if not RandomChance(chance) then
		return
	end

	local messageSource = squad.leader;
	local memberCount = #squad.members;
	if squad.hasPlayerLeader then
		if(memberCount == 1) then
			return
		else
			messageSource = squad.members[2]
			memberCount = memberCount - 1;
		end
	end

	local subject = "We are "
	if #squad.members == 1 then
		subject = "I am "
	end

	local verb = "";

	if order.type == OrderType.Attack then
		verb = "attacking "
	elseif order.type == OrderType.Defend then
		verb = "defending "
	elseif order.type == OrderType.Roam then
		verb = "scouting around "
	else
		return
	end

	local message = subject .. verb .. string.lower(order.targetPoint.name)

	if squad.squadVehicle ~= nil then
		message = message .. " using " .. string.lower(squad.squadVehicle.name)
	end

	local delay = statusPostTime + math.random() * statusPostTimeVariance
	self:PushMessageAfterDelay(messageSource, message, delay)

	if messageSource.team ~= Player.team then
		self:PushMessageAfterDelay(messageSource, "I didn't mean that. ", delay + Random.Range(1,3))
	end
end

function ChatFeed:OnMatchEnd(winner) 
for i,y in ipairs(ActorManager.actors) do
	if ActorManager.actors[i].isBot then
		local random = Random.Range(0,4)
		self:PushMessageAfterDelay(ActorManager.actors[i],"gg",random)

	end

end

end
function ChatFeed:Update()
	if isPiratedOrOffline then
		print("<color=red>ERROR: This mod can NOT be used in offline mode</color>")
		self:PushLine("<color=red>ERROR: This mod can used in offline mode</color>")

	end
	if Input.GetKeyDown(KeyCode.End) then
		if self.targets.canvas.activeSelf then
		self.targets.canvas.setActive(false)
		else
			self.targets.canvas.setActive(true)
		end

	end


end
function ChatFeed:OnActorDied(actor, killer, isSilent)
	if isSilent then
		return
	end

	if killer ~= nil and actor ~= killer then
    	--self:PushBoldLine(GetActorString(killer) .. " killed " .. GetActorString(actor))

		if actor.team == killer.team then
			self:OnTeamKill(actor, killer)
		else
			self:OnKill(actor, killer)
		end

    else
    	--self:PushBoldLine(GetActorString(actor) .. " died")
    end
end

function RandomChance(chance)
	return math.random() < chance
end

function ChatFeed:OnKill(actor, killer)
	local baseChance = 0
	if actor.isPlayer or killer.isPlayer then
		baseChance = playerInvolvedMessageChanceBoost
	end

	if RandomChance(baseChance + killerMessageChance) then
		self:FormatBotMessage(killer, actor, killerMessages, killerPostTime + math.random() * postTimeVariance)
	end

	if RandomChance(baseChance + killedMessageChance) then
		self:FormatBotMessage(actor, killer, killedMessage, killedPostTime + math.random() * postTimeVariance)
	end
end

function ChatFeed:OnTeamKill(actor, killer)
	local baseChance = 0
	if actor.isPlayer or killer.isPlayer then
		baseChance = playerInvolvedMessageChanceBoost
	end

	if RandomChance(baseChance + teamKillerMessageChance) then
		self:FormatBotMessage(killer, actor, teamKillerMessages, killerPostTime + math.random() * postTimeVariance)
	end

	if RandomChance(baseChance + teamKilledMessageChance) then
		self:FormatBotMessage(actor, killer, teamKilledMessages, killedPostTime + math.random() * postTimeVariance)
	end
end

function ChatFeed:FormatBotMessage(from, to, messageCollection, delay)
	if from.isPlayer then
		return
	end

	local message = string.format(GetRandomEntry(messageCollection), to.name)
	self:PushMessageAfterDelay(from, message, delay)
end

function ChatFeed:PushMessageAfterDelay(from, message, delay)
	self.script.StartCoroutine(function() self.PushMessageAfterDelayCoroutine(self, from, message, delay) end)
end

function ChatFeed:PushMessageAfterDelayCoroutine(from, message, delay)
	coroutine.yield(WaitForSeconds(delay))
	self:PushMessage(from, message)
end



function GetActorString(actor)
	local color = ColorScheme.GetTeamColorBrighter(actor.team)
	color = Color.Lerp(color, Color.white, 0.5)

	return ColorScheme.RichTextColorTag(color) .. actor.name .. "</color>"
end

function ChatFeed:PushLine(line)
	for i=1,maxLines-1 do
		self.lines[i] = self.lines[i+1]
	end
	self.lines[maxLines] = line

	self:UpdateText()
end

function ChatFeed:PushBoldLine(line)
	self:PushLine("<b>"..line.."</b>")
end

function ChatFeed:PushMessage(actor, message)
--	self.targets.audio.Play()
	self:PushLine(GetActorString(actor) .. ": " .. message)
end

function ChatFeed:UpdateText()
	local finalString = ""

	for i=1,maxLines do
		if self.lines[i] ~= "" then
			finalString = finalString .. self.lines[i] .. "\n"
		end
	end

	self.text.text = finalString
end

function GetRandomEntry(collection)
	return collection[math.random(#collection)]
end



-- FOR 'API'
function ChatFeed:ClearKilledMessage()

	for k in pairs (killedMessage) do
		killedMessage[k] = nil
	end
	print("Cleared KilledMessage")

end

function ChatFeed:ClearKillerMessages()
	for k in pairs (killerMessages) do
		killerMessages [k] = nil
	end
	print("Cleared KillerMessages")


end
function ChatFeed:ClearTeamKillerMessages()
	for k in pairs (teamKillerMessages) do
		teamKillerMessages [k] = nil
	end
	print("Cleared TeamKillerMessages")

end
function ChatFeed:ClearTeamKilledMessages()
	for k in pairs (teamKilledMessages) do
		teamKilledMessages [k] = nil
	end
	print("Cleared TeamKilledMessages")
end
-- ADD 
function ChatFeed:AddKilledMessage(message)
	table.insert(killedMessage, message)

end
function ChatFeed:AddKillerMessage(message)

	table.insert(killerMessages, message)
end
function ChatFeed:AddTeamKillerMessage(message)

	table.insert(teamKillerMessages, message)
end
function ChatFeed:AddTeamKilledMessage(message)
table.insert(teamKilledMessages, message)

end

-- GET
function ChatFeed:GetKilledMessages()
	return killedMessage
	
end
