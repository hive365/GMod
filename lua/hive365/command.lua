Command = {}
Command.__index = Command

function Command.new(comm, help, ac)
    local self = setmetatable({}, Command)
    self.command = comm
    self.help = help
    self.action = ac
    
    return self
end

function Command.execute(self, ply, text)
    if !self.action(ply, text) then
        SendChat(ply, self.help)
    end
end

function Command.isComm(self, name)
    ret = false
    for key,val in pairs(self.command) do
        if val==name then
            ret = true
        end
    end
    return ret
end