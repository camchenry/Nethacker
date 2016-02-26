local commands = {}

commands.help = {
	["help"] = "gives help info for all commands",
	["ssh"] = "connects to targeted server",
	["ls"] = "lists files in the current server",
	["print"] = "outputs the contents of a file",
	["access"] = "grants access to a server using a password",
	["back"] = "returns to the previous visited server",
	["download"] = "saves a file to the root server for later access",
	["delete"] = "deletes a file in the current server",
}
commands.usage = {
	["help"] = "help <command>",
	["ssh"] = "ssh <server id>",
	["ls"] = "ls",
	["print"] = "print <filename>",
	["access"] = "access <server id> <password>",
	["back"] = "back",
	["download"] = "download <filename>",
	["delete"] = "delete <filename>",	
}

local self = game
commands.list = {
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

	["ssh"] = function(args)
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
					self:print("connected to server '"..self.currentNode.id.."' (" .. self.currentNode.name ..")")
				
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

				local width, wrappedText = love.graphics.getFont():getWrap(file.data, 700)
				for i, line in pairs(wrappedText) do
					self:print(line)
				end
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

return commands