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
