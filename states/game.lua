game = {}

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
	local blur = shine.gaussianblur{}
	local glow = shine.glowsimple{
		min_luma = 0.4,
		sigma = 0.4,
	}
	local bloom = shine.bloom{
		quality = 0.5,
		samples = 8,
	}
	local scanlines = shine.scanlines{
		pixel_size = 4,
		line_height = 0.3,
		opacity = 0.25,
		center_fade = 0.4,
	}
	local crt = shine.crt{
		x = 0.02,
		y = 0.005,
	}
	local chroma = shine.separate_chroma{
		radius = 1,
	}
	local color = shine.colorgradesimple{
		grade = {0.85, 0.85, 1}
	}
	local grain = shine.filmgrain{
		opacity = 0.15,
		grainsize = 1,
	}
	POST_EFFECT = color:chain(glow):chain(grain):chain(crt):chain(scanlines):chain(chroma)

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
		"Hello, if can see this file, it is because we trust you enough\n" ..
		"to carry out a sensitive job. One of our technicians has leaked\n" ..
		"confidential information, and due to legal obligations, we\n" ..
		"cannot fire him. However, if his employee records were to \n" ..
		"suddenly be corrupted or erased, we would be under no such \n" ..
		"obligation. \n" ..
		"\nThe employee name is: ".. employeeName .. "\n" ..
		"The server address is: ".. target.id .. "\n" ..
		"We will know when the job has been completed. If the job\n"..
		"is successful, we may grant you additional hardware. Good luck."
	)
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

   	self.drawServers = false
   	self.canType = false
    self.console = {
    	buffer = {},
    	queue = {},
    	queueTime = 0,
		input = "",
		lastInput = "",
	}
	self.console.clear = function()
		self.console.buffer = {}
	end
	self.bootTime = 11.5

	signal.emit("boot")

	self:print("", 0.25)
	self:print("power on", 0.217)
	self:print("testing memory ")
	self:append(".", 0.55)
	self:append(".", 0.55)
	self:append(".", 0.55)
	self:print("memory: 65536M OK", 0.75)
	self:print("initializing boot loader ", 0.45)
	self:append(".", 0.34)
	self:append(".", 0.45)
	self:append(".", 0.23)
	self:print("VBL v034_gamma loaded", 0.15)
	self:print("starting services ")
	self:append(".", 0.64)
	self:append(".", 0.64)
	self:append(".", 0.64)
	self:print("locating devices", 0.35)
	self:print("drive 1: ok    ATA TC4886460009", 0.8)
	self:print("drive 2: ok    ATA TC9746460001", 0.5)
	self:print("drive 3: ok    MSD XA9004345800", 0.5)
	self:print("loading filesystem ")
	self:append(".", 0.166)
	self:append(".", 0.345)
	self:append(".", 0.78)
	self:print("loading user files ")
	self:append(".", 0.25)
	self:append(".", 0.25)
	self:append(".", 0.35)
	self:print("welcome to VIGIL OS 0.3.4")
	self:print("type 'help' for a list of commands")

	local commands = require 'entities.object.commands'
	self.help = commands.help
	self.usage = commands.usage
	self.commands = commands.list
end

function game:print(string, delay, mode)
	table.insert(self.console.queue, {string, delay or 0.1, mode or "write"})
end

function game:append(string, delay)
	self:print(string, delay, "append")
end

function game:printRandomText(lines)
	for i=1, lines do
		table.insert(self.console.queue, {
			string.random(60),
			0.15	
		})
	end
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

    self.console.queueTime = self.console.queueTime - dt

    if self.console.queueTime <= 0 then
	    for i, data in pairs(self.console.queue) do
	    	local text, time
	    	text = data[1]
	    	time = data[2] or 0.1
	    	mode = data[3] or "write"
	    	self.console.queueTime = time

	    	if mode == "write" then
		    	table.insert(self.console.buffer, 1, text)
		    elseif mode == "append" then
		    	self.console.buffer[1] = self.console.buffer[1] .. text
			end

			table.remove(self.console.queue, i)
	    	break
	    end
	end

    self.time = self.time + dt

    if self.time - self.startTime > self.bootTime then
    	self.canType = true
    	self.drawServers = true
    	soundManager:fadeSound("serverAmbience", 0.4, 4)

    end
end

function game:textinput(text)
	if love.keyboard.hasKeyRepeat() then
    	signal.emit('typing')
    end

    if self.canType then
		self.console.input = self.console.input .. text
	end
end

function game:wheelmoved(x, y)

end

function game:keypressed(key, code)
	for i, obj in pairs(self.objects) do
    	obj:keypressed(key, code)
    end

    if self.canType then
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

    POST_EFFECT(function()
    love.graphics.setColor(6, 6, 6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    if self.drawServers then
	    love.graphics.setColor(22, 22, 22)
	    love.graphics.rectangle("fill", love.graphics.getWidth()-450, 0, 450, love.graphics.getHeight())
	    love.graphics.setColor(255, 255, 255)
	end

    love.graphics.setColor(33, 33, 33)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 40)
    love.graphics.setColor(255, 255, 255)

    love.graphics.setFont(font[16])
    local date = os.date("%c", self.time)
    love.graphics.print(date, love.graphics.getWidth()-love.graphics.getFont():getWidth(date) - 20, 10)
    love.graphics.print("F"..love.timer.getFPS(), 20, 10)
    love.graphics.print("D"..love.timer.getAverageDelta(), 80, 10)

    if self.canType then
	    love.graphics.setFont(fontBold[16])
	    love.graphics.print(self.currentNode.name .. " (" .. self.currentNode.id .. ")", 15, love.graphics.getHeight()-60)
	    love.graphics.setFont(font[16])
	    love.graphics.print("> "..self.console.input, 15, love.graphics.getHeight()-40)
	end

    local widthLimit = 700
    local heightLimit = (love.graphics.getHeight() - 120)/love.graphics.getFont():getHeight("ABCDEFGHJIJKLMNOPQRSTUVWXYZ")

    i = 1
    for j, line in pairs(self.console.buffer) do
    	local maxWidth, wrappedText = love.graphics.getFont():getWrap(line, widthLimit)
    	i = i + #wrappedText
    	love.graphics.printf(line, 15, love.graphics.getHeight() - 70 - love.graphics.getFont():getHeight(line)*i, widthLimit)
    	if i >= heightLimit then break end
    end

    if self.drawServers then
	    local widthLimit = 440
	    love.graphics.setFont(fontBold[16])
	    love.graphics.print("connected servers", love.graphics.getWidth()-widthLimit, 50)
	    love.graphics.setFont(font[14])

    
	    i = 1
	    for i, conn in ipairs(self.currentNode.connections) do
	    	local text = conn.id .. " | " .. conn.name
	    	local maxWidth, wrappedText = love.graphics.getFont():getWrap(text, widthLimit)
	    	i = i + #wrappedText
	    	love.graphics.printf(text, love.graphics.getWidth()-440, 80 + love.graphics.getFont():getHeight(line)*(i-1), widthLimit)
	    end
	end

    love.graphics.setLineWidth(5)
    love.graphics.setColor(77, 77, 77)
    love.graphics.rectangle("line", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end)
end