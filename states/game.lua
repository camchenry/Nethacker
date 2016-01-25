game = {}

File = class('File')

function File:initialize(name, data, pass)
	self.name = name
	self.data = data or string.random(700)

	function replaceChar(pos, str, r)
	    return ("%s%s%s"):format(str:sub(1,pos-1), r, str:sub(pos+1))
	end

	if pass then
		local stringToInsert = "PaSswORD='"..pass.."'"
		local n = math.random(200, 600)	

		for i=n, n+stringToInsert:len() do
			self.data = replaceChar(i, self.data, stringToInsert:sub(i-n, i-n))
		end
	end
end

Node = class('Node')

function Node:initialize(name, id)
	self.name = name or "Node"
	self.id = id or hashids.new(self.name, 4, "1234567890abcdef"):encode(1235)
	self.motd = nil
	self.radius = 25
	self.connections = {}
	self.files = {}
	self.secured = false
	self.password = nil
	self.selected = false
end

function Node:connect(other, stop)
	local found = false
	for i, node in pairs(self.connections) do
		if node == other then
			found = true
			break
		end
	end
	if not found then
		table.insert(self.connections, other)
	end
	if not stop then
		other:connect(self, true)
	end

	return self
end

function Node:addFile(file)
	table.insert(self.files, file)
end

function Node:addPassword(password)
	self.password = password
	self.secured = true
end

function Node:update(dt)

end

function Node:keypressed(key, code)

end

function Node:mousepressed(x, y, mbutton)

end

Job = class("Job")

function Job:initialize(name, description)
	self.name = name
	self.description = description
	self.completed = false
	self.alreadyCompleted = false
	self.trigger = function(self) end
end

function Job:update(dt)
	self.completed = self.trigger()

	if self.completed and not self.alreadyCompleted then
		self.alreadyCompleted = true
		self.onCompleted()
	end
end

function game:generateBusinessServers(start, n)
	local subnodes = {}

	for i=1, n do 
		local node = Node:new(self:getBusinessName())
		node:connect(start)
		self:add(node)
		table.insert(subnodes, node)
	end

	return subnodes
end

function game:generateServices(parent)
	local email = Node:new(parent.name .. " Email Server", parent.id .. ":f2")
	local ftp = Node:new(parent.name .. " FTP Server", parent.id .. ":22")
	local database = Node:new(parent.name .. " Database Server", parent.id .. ":0f")

	email:connect(parent)
	ftp:connect(parent)
	database:connect(parent)
end

function game:enter()
    self.objects = {}
    function game:add(obj) table.insert(self.objects, obj) return obj end

    self.personNames = {}
    local i = 1
    for line in love.filesystem.lines("data/names.txt") do
    	self.personNames[i] = line
    	i = i + 1
    end

    self.businessNames = {}
    self.nameUsed = {}
    local i = 1
    for line in love.filesystem.lines("data/businesses.txt") do
    	self.businessNames[i] = line
    	i = i + 1
    end
    
    self.startTime = 1506000490
    self.time = self.startTime

    self.startName = "Root Server"
    self.startNode = self:add(Node:new(self.startName))
    self.currentNode = self.startNode
    self.prevNode = self.currentNode

    local s = self:generateBusinessServers(self.startNode, 3)
    for i, v in pairs(s) do
    	self:generateServices(v)
    end

    local employeeName = self:getPersonName()
    local target = self.startNode.connections[math.random(#self.startNode.connections)]
    self.currentJob = Job:new("job001.txt", 
[[
Hello, if can see this file, it is because we trust you with a 
sensitive job. One of our technicians has leaked confidential 
information, and due to legal obligations, we cannot fire him. 
We need you to delete his employee records.

The employee name is: ]]..employeeName..[[

The server address is: ]]..target.id..[[

We will know when the job has been completed.
]])
   	self.startNode:addFile(File:new(self.currentJob.name, self.currentJob.description))

   	local employeeRecords = Node:new(target.name .. " Employee Records", target.id .. ":e8")
   	target:connect(employeeRecords)

   	local targetFile = File:new(string.lower(employeeName:sub(1, 1) .. employeeName:split(' ')[2] .. ".dat"))

   	self.currentJob.trigger = function()
   		local found = false
   		for i, f in pairs(employeeRecords.files) do
   			if f == targetFile then
   				found = true
   			end
   		end

   		return not found
   	end
   	self.currentJob.onCompleted = function()
		self.currentJob = Job:new("job002.txt",
[[
We are pleased with your work so far. We have more work for
you to do.
]])
	   	self.startNode:addFile(File:new(self.currentJob.name, self.currentJob.description))
   	end

   	for i=1, math.random(10, 20) do
   		local name = self:getPersonName()
   		name = name:split(' ')

   		local firstLetter = name[1]:sub(1, 1)
   		local username = string.lower(firstLetter .. name[2])

   		employeeRecords:addFile(File:new(username .. ".dat", string.random(100)))
   	end

   	employeeRecords:addFile(targetFile)

	for i=1, math.random(10, 20) do
   		local name = self:getPersonName()
   		name = name:split(' ')

   		local firstLetter = name[1]:sub(1, 1)
   		local username = string.lower(firstLetter .. name[2])

   		employeeRecords:addFile(File:new(username .. ".dat", string.random(100)))
   	end

    self.console = {
    	buffer = {},
		input = "",
		lastInput = "",
	}
	self:print("welcome to VIGIL OS 0.3.4")
	self:print("type 'help' for a list of commands")

	self.help = {
		["help"] = "gives help info for all commands",
		["switch"] = "changes the current node to targeted server",
		["ls"] = "lists files in the current server",
		["print"] = "outputs the contents of a file",
		["access"] = "grants access to a server using a password",
		["back"] = "returns to the previous visited server",
		["download"] = "saves a file to the root server for later access",
		["delete"] = "deletes a file in the current server",
	}
	self.usage = {
		["help"] = "help <command>",
		["switch"] = "switch <server id>",
		["ls"] = "ls",
		["print"] = "print <filename>",
		["access"] = "access <server id> <password>",
		["back"] = "back",
		["download"] = "download <filename>",
		["delete"] = "delete <filename>",	
	}
	self.commands = {
		["help"] = function(args)
			if args[1] == nil then
				self:print("usage: "..self.usage["help"])
				self:print("commands:")
				for command, f in pairs(self.commands) do
					self:print(command .. " - "..self.help[command])
				end
			else
				if self.usage[args[1]] then
					self:print("usage: "..self.usage[args[1]])
				else
					self:print("no usage docs found for '"..args[1].."'")
				end
			end
		end,

		["switch"] = function(args)
			if args[1] ~= nil then
				local found = false
				local node

				for i, _node in pairs(self.currentNode.connections) do
					if _node.id == args[1] then
						found = true
						node = _node
					end
				end

				if found then
					if node.secured then
						self:print("access denied. password required")
					else
						self.prevNode = self.currentNode
						self.currentNode = node
						self:print("switched to server '"..self.currentNode.id.."' (" .. self.currentNode.name ..")")
					
						if self.currentNode.motd then
							self:print("\nServer message of the day:")
							self:print(self.currentNode.motd)
						end
					end
				else
					self:print("no server '"..args[1].."' found")
				end
			else
				self:print("error: no server unique id given")
			end
		end,

		["ls"] = function(args)
			local filesToPrint = #self.currentNode.files
			local line = ""
			local filesInLine = 0

			for i, file in pairs(self.currentNode.files) do
				line = line .. file.name .. "\t"
				filesToPrint = filesToPrint - 1
				filesInLine = filesInLine + 1

				if filesInLine >= 3 or filesToPrint == 0 then
					self:print(line)
					filesInLine = 0
					line = ""
				end
			end

			if #self.currentNode.files == 0 then
				self:print("no files in current server.")
			end
		end,

		["print"] = function(args)
			if args[1] ~= nil and args[1] ~= "" then
				local found = false
				local file = nil

				for i, f in pairs(self.currentNode.files) do
					if f.name == args[1] then
						found = true
					end
					file = f
				end

				if found then
					self:print("file contents:")
					self:print(file.data)
				else
					self:print("no file named '"..args[1].."'")
				end
			else
				self:print("error: no filename given")
			end
		end,

		["access"] = function(args)
			if args[1] ~= nil and args[1] ~= "" then
				local found = false
				local node

				for i, _node in pairs(self.currentNode.connections) do
					if _node.id == args[1] then
						found = true
						node = _node
					end
				end

				if found then
					if not node.secured then
						self:print("error: server is not password secured")
						return
					end

					if args[2] ~= nil and args[2] ~= "" then
						if args[2] == node.password then
							node.secured = false
							self:print("server '"..args[1].."' unlocked")
						else
							self:print("error: invalid password")
						end
					else
						self:print("error: no password given")
					end
				else
					self:print("no server '"..args[1].."' found")
				end
			else
				self:print("error: no server unique id given")
			end
		end,

		["back"] = function(args)
			self.currentNode = self.prevNode
			self:print("returned to previous node '"..self.currentNode.id.."' ("..self.currentNode.name..")")
		end,

		["download"] = function(args)
			if args[1] ~= nil and args[1] ~= "" then
				local found = false
				local file = nil

				for i, f in pairs(self.currentNode.files) do
					if f.name == args[1] then
						found = true
					end
					file = f
				end

				if found then
					table.insert(self.startNode.files, file)
					self:print("file '"..file.name.."' downloaded to root server")
				else
					self:print("no file named '"..args[1].."'")
				end
			else
				self:print("error: no file given")
			end
		end,

		["delete"] = function(args)
			if args[1] ~= nil and args[1] ~= "" then
				local found = false
				local file = nil

				for i, f in pairs(self.currentNode.files) do
					if f.name == args[1] then
						found = true
						table.remove(self.currentNode.files, i)
						file = f
					end
				end

				if found then
					self:print("file '"..file.name.."' deleted")
				else
					self:print("no file named '"..args[1].."'")
				end
			else
				self:print("error: no file given")
			end
		end,
	}
end

function game:print(string)
	table.insert(self.console.buffer, 1, string)
end

function string:split(sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField, nStart = 1, 1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
	end

	for i=#aRecord, 1, -1 do
		if aRecord[i] == "" then
			table.remove(aRecord, i)
		end
	end

	return aRecord
end

function game:runCommand(line)
	local args = line:split(' ')
	local cmd = args[1]
	table.remove(args, 1)

	if cmd ~= "" and cmd ~= nil then
		if self.commands[cmd] then
			self.commands[cmd](args)
		else
			self:print("no command '"..cmd.."' found")
		end
	end

	self:print()
end

function game:getBusinessName()
	local n = math.random(#self.businessNames)
	while self.nameUsed[n] do
		n = math.random(#self.businessNames)
	end
	self.nameUsed[n] = true
	return self.businessNames[n]
end

function game:getPersonName()
	local n = math.random(#self.personNames)
	while self.nameUsed[n] do
		n = math.random(#self.personNames)
	end
	self.nameUsed[n] = true
	return self.personNames[n]
end

function game:update(dt)
	for i, obj in pairs(self.objects) do
    	obj:update(dt)
    end

    if self.currentJob then
    	self.currentJob:update(dt)
    end

    self.time = self.time + dt
end

function game:textinput(text)
	if love.keyboard.hasKeyRepeat() then
    	signal.emit('typing')
    end

	self.console.input = self.console.input .. text
end

function game:wheelmoved(x, y)

end

function game:keypressed(key, code)
	for i, obj in pairs(self.objects) do
    	obj:keypressed(key, code)
    end

    if not love.keyboard.hasKeyRepeat() then
    	signal.emit('typing')
    end

    if key == "backspace" then
    	love.keyboard.setKeyRepeat(true)
    	self.console.input = self.console.input:sub(1, -2)
    end

    if key == "return" then
    	self:print("> "..self.console.input)
    	self:runCommand(self.console.input)
    	self.console.lastInput = self.console.input
    	self.console.input = ""
    end

    if key == "up" then
    	self.console.input = self.console.lastInput
    end
end

function game:keyreleased(key, code)
	if key == "backspace" then
		love.keyboard.setKeyRepeat(false)
	end
end

function game:mousepressed(x, y, mbutton)
	for i, obj in pairs(self.objects) do
    	obj:mousepressed(x, y, mbutton)
    end
end

function game:draw()
    for i, obj in pairs(self.objects) do
    	--obj:draw()
    end

    love.graphics.setColor(22, 22, 22)
    love.graphics.rectangle("fill", love.graphics.getWidth()-450, 0, 450, love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)

    love.graphics.setColor(33, 33, 33)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 40)
    love.graphics.setColor(255, 255, 255)

    love.graphics.setFont(font[16])
    local date = os.date("%c", self.time)
    love.graphics.print(date, love.graphics.getWidth()-love.graphics.getFont():getWidth(date) - 20, 10)
    love.graphics.print("F"..love.timer.getFPS(), 20, 10)
    love.graphics.print("AD"..love.timer.getAverageDelta(), 80, 10)

    love.graphics.setFont(fontBold[16])
    love.graphics.print(self.currentNode.name .. " (" .. self.currentNode.id .. ")", 15, love.graphics.getHeight()-60)
    love.graphics.setFont(font[16])
    love.graphics.print("> "..self.console.input, 15, love.graphics.getHeight()-40)

    local widthLimit = 700
    local heightLimit = (love.graphics.getHeight() - 120)/love.graphics.getFont():getHeight("ABCDEFGHJIJKLMNOPQRSTUVWXYZ")

    i = 1
    for j, line in pairs(self.console.buffer) do
    	local maxWidth, wrappedText = love.graphics.getFont():getWrap(line, widthLimit)
    	i = i + #wrappedText
    	love.graphics.printf(line, 15, love.graphics.getHeight() - 70 - love.graphics.getFont():getHeight(line)*i, widthLimit)
    	if i >= heightLimit then break end
    end

    love.graphics.setFont(fontBold[16])
    love.graphics.print("connected servers", 840, 50)
    love.graphics.setFont(font[14])

    local widthLimit = 440
    i = 1
    for i, conn in ipairs(self.currentNode.connections) do
    	local text = conn.id .. " | " .. conn.name
    	local maxWidth, wrappedText = love.graphics.getFont():getWrap(text, widthLimit)
    	i = i + #wrappedText
    	love.graphics.printf(text, love.graphics.getWidth()-440, 80 + love.graphics.getFont():getHeight(line)*(i-1), widthLimit)
    end
end