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