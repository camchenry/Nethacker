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
	self.id = id or hashids.new(self.name):encode(1235)
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

function Node:mousepressed(x, y, mbutton)

end

function Node:keypressed(key, code)

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
	local email = Node:new(parent.name .. " Email Server", parent.id .. "-mail")
	local ftp = Node:new(parent.name .. " FTP Server", parent.id .. "-ftp")
	local database = Node:new(parent.name .. " Database Server", parent.id .. "-db")

	email:connect(parent)
	ftp:connect(parent)
	database:connect(parent)
end

function game:enter()
    self.objects = {}
    function game:add(obj) table.insert(self.objects, obj) return obj end

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

    self.credits = 0
    self.extranet = self:add(Node:new("Extranet"))
    self.extranet:connect(self.startNode)
    self.extranet.motd = "Welcome to the Extranet, for all your extra-legal needs."

    self.extranetJobs = self:add(Node:new("Extranet Jobs", self.extranet.id .. "-job"))
    self.extranetJobs:connect(self.extranet)
    self.extranetJobs.update = function(dt)
    	self.extranetJobs.motd = "You currently have "..self.credits.." Extranet credits." 
    end

    self.extranetMail = self:add(Node:new("Extranet Mail", self.extranet.id .. "-mail"))
    self.extranetMail:connect(self.extranet)

    self.extranetMarket = self:add(Node:new("Extranet Market", self.extranet.id .. "-market"))
    self.extranetMarket:connect(self.extranet)
    self.extranetMarket.update = function(dt)
    	self.extranetMarket.motd = "You currently have "..self.credits.." Extranet credits." 
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
	}
	self.usage = {
		["help"] = "help <command>",
		["switch"] = "switch <server id>",
		["ls"] = "ls",
		["print"] = "print <filename>",
		["access"] = "access <server id> <password>",
		["back"] = "back",
		["download"] = "download <filename>"
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
			for i, file in pairs(self.currentNode.files) do
				self:print(file.name)
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

function game:update(dt)
	for i, obj in pairs(self.objects) do
    	obj:update(dt)
    end

    if math.floor(self.time) % (20) == 0 and not self.jobAdded then
    	self.jobAdded = true
    	self.extranetJobs:addFile(File:new('job001.txt', 
[[
Hello, if can see this file, it is because we trust you with this 
sensitive job. One of our technicians has leaked confidential 
information, and due to legal obligations, we cannot fire him. 
However, if his employee records were to be suddenly and 
irreparably corrupted, we would be left with no choice but to 
terminate his employment.

The server address is: 000

We will know when the job has been completed, and a payment of 
20 credits will be added to your Extranet account.
]]))
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
    love.graphics.setFont(font[15])

    for i, conn in ipairs(self.currentNode.connections) do
    	local text = conn.id .. " | " .. conn.name
    	local maxWidth, wrappedText = love.graphics.getFont():getWrap(text, widthLimit)
    	love.graphics.printf(text, love.graphics.getWidth()-440, 80 + love.graphics.getFont():getHeight(line)*(i-1), widthLimit)
    end
end