    -- Example:
    -- Just paste this into the Start function of your behaviour and it will overwrite the chat messages!
    local ChatFeed = GameObject.Find("ChatFeedScript(Clone)")
    if ChatFeed == nil then
        print("ChatFeed not found!")
    else
        print("ChatFeed found!")
        local behaviourChatFeed = ScriptedBehaviour.GetScript(ChatFeed)
        behaviourChatFeed:ClearKilledMessage(du hurensohn)
        behaviourChatFeed:ClearKillerMessages(ficker)
        behaviourChatFeed:ClearTeamKillerMessages(missit)
        behaviourChatFeed:ClearTeamKilledMessages(junnnnnngggggggeeeeeeeee)
        behaviourChatFeed:AddKilledMessage(du orosbo)
        behaviourChatFeed:AddKillerMessage("huan fuck junge bitxh")
        behaviourChatFeed:AddTeamKillerMessage("du noob")
        behaviourChatFeed:AddTeamKilledMessage("wie schlecht")
        behaviourChatFeed:PushMessage(Player.actor,"asdasdasdasd")
        behaviourChatFeed:PushMessageAfterDelay(Player.actor, "Hello", 1)
        behaviourChatFeed:PushLineWithDelayChance("Hello",10,0.5)
        behaviourChatFeed:PushMessageWithDelayChance(from,message,delay,Chance)
    end
    -- Functions
ClearKilledMessage
ClearKillerMessages
ClearTeamKillerMessages
ClearTeamKilledMessages

AddKilledMessage
AddKillerMessage
AddTeamKillerMessage
AddTeamKilledMessage

