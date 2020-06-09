    -- Example:
    -- Just paste this into the Start function of your behaviour and it will overwrite the chat messages!
    local ChatFeed = GameObject.Find("ChatFeedScript(Clone)")
    if ChatFeed == nil then
        print("ChatFeed not found!")
    else
        print("ChatFeed found!")
        local behaviourChatFeed = ScriptedBehaviour.GetScript(ChatFeed)
        behaviourChatFeed:ClearKilledMessage()
        behaviourChatFeed:ClearKillerMessages()
        behaviourChatFeed:ClearTeamKillerMessages()
        behaviourChatFeed:ClearTeamKilledMessages()
        behaviourChatFeed:AddKilledMessage("Hello from Killed")
        behaviourChatFeed:AddKillerMessage("Hello from Killer")
        behaviourChatFeed:AddTeamKillerMessage("Hello from Teamkiller")
        behaviourChatFeed:AddTeamKilledMessage("Hello from Teamkilled")
        behaviourChatFeed:PushMessage(Player.actor,"asdasdasdasd")
        behaviourChatFeed:PushMessageAfterDelay(from, message, delay)

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
