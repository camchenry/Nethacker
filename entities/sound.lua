Sound = class('Sound')

function Sound:initialize(directory)
	self.directory = directory or "assets/sound/"

	local config = nil
	if love.filesystem.exists(options.file) then
		config = options:getConfig()
	else
		config = options:getDefaultConfig()
	end

	function getFileName(url)
		return url:match("^.+/(.+)$")
	end

	function removeFileExtension(url)
		return url:gsub(".[^.]+$", "")
	end

	self.soundVolume = config.audio.soundVolume/100

	self.sounds = {}
	local files = love.filesystem.getDirectoryItems(self.directory)
	for i, file in pairs(files) do
		local path = self.directory .. file
		if love.filesystem.isFile(path) then
			local name = removeFileExtension(getFileName(path))
			self.sounds[name] = love.audio.newSource(path, 'static')
		end
	end

	self.volumes = {}
	for name, sound in pairs(self.sounds) do
		self.volumes[name] = self.soundVolume
		self.sounds[name]:setVolume(self.soundVolume)
	end

	self.volumes.serverAmbience = 0.5

    signal.register('uiClick', function() self:onUiClick() end)
    signal.register('uiHover', function() self:onUiHover() end)
    signal.register('soundVolumeChanged', function(v) self:onSoundVolumeChanged(v) end)
    signal.register('typing', function() self:onTyping() end)
    signal.register('boot', function() self:onBoot() end)
end

function Sound:update(dt)
	for name, sound in pairs(self.sounds) do
		sound:setVolume(self.volumes[name])
	end
end

function Sound:onSoundVolumeChanged(volume)
	volume = volume/100

	-- fixes a volume bug where if it was set to 0, it would make it 1
	if volume < .01 then
		volume = 0
	end

	for i, sound in pairs(self.sounds) do
		sound:setVolume(volume)
	end
end

function Sound:onUiClick(enemy)
	self.sounds.uiClick:play()
end

function Sound:onUiHover(enemy)
	self.sounds.uiHover:play()
end

function Sound:onTyping()
	local file = "typing"..math.random(6)
	self.sounds[file]:play()
end

function Sound:onBoot()
	--self.sounds.driveSpinUp:play()
	self.sounds.serverAmbience:play()
end

function Sound:fadeSound(sound, level, time)
	tween(time, self.volumes, {[sound] = level})
end

function Sound:draw()

end