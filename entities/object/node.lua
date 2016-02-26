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